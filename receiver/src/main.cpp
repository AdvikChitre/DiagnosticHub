#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>
#include <QTimer> // Added for example in main.cpp
#include <QStringList>
#include <QDebug>
#include <QSettings> // For ConnectionWorker to read target devices

// Your existing includes
#include "./request/networkmanager.h"
#include "src/background/ble/characteristicinfo.h"
#include "src/background/ble/device.h"       // This is the one from the immersive
#include "src/background/ble/deviceinfo.h"
#include "src/background/ble/serviceinfo.h"
#include "src/background/buffer/buffer.h"     // Assuming Buffer class definition
#include "src/background/buffer/senderworker.h"
#include "src/background/ble/connectionworker.h"
#include "src/background/notification/notificationmanager.h"


// --- Definition of MainThreadBridge ---
// In a real project, this would be in MainThreadBridge.h and MainThreadBridge.cpp
class MainThreadBridge : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList qmlConnectedDevices READ qmlConnectedDevices WRITE setQmlConnectedDevices NOTIFY qmlConnectedDevicesChanged)

public:
    explicit MainThreadBridge(QObject *parent = nullptr) : QObject(parent) {}

    QStringList qmlConnectedDevices() const {
        return m_qmlConnectedDevices;
    }

public slots:
    void setQmlConnectedDevices(const QStringList &devices) {
        if (m_qmlConnectedDevices != devices) {
            m_qmlConnectedDevices = devices;
            qDebug() << "MainThreadBridge: qmlConnectedDevices updated to:" << m_qmlConnectedDevices;
            emit qmlConnectedDevicesChanged(m_qmlConnectedDevices);

            // --- CRITICAL: Update QSettings here from the main thread ---
            // This is where appStorage (QML Settings) will pick up the change
            // if it's also reading this value, or if QML bindings are enough.
            // If appStorage in QML is a QML Settings object, it reads/writes its own file.
            // This C++ property is what QML should bind to.
            // If you also need to persist this specific list via C++ QSettings for other C++ parts,
            // you can do it here.
            // QSettings settings;
            // settings.beginGroup("AppConfig");
            // settings.setValue("connectedDevices", m_qmlConnectedDevices);
            // settings.endGroup();
            // However, the primary goal is for QML to react to the NOTIFY signal.
        }
    }

signals:
    void qmlConnectedDevicesChanged(const QStringList &devices);

private:
    QStringList m_qmlConnectedDevices;
};
// --- End of MainThreadBridge Definition ---


bool simulator = false; // This global variable is generally not ideal, consider passing as arg or config

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QCoreApplication::setOrganizationName("Imperial College London");
    QCoreApplication::setOrganizationDomain("imperial.ac.uk");
    QCoreApplication::setApplicationName("ReceiverApp"); // Good to set for QSettings

    QGuiApplication app(argc, argv);

    // Create shared buffer
    Buffer *sharedBuffer = new Buffer(&app); // Parent to app for auto-cleanup

    // Create Device singleton instance
    // Device *deviceInstance = new Device(sharedBuffer, &app); // Parent to app
    // The Device instance is registered as a singleton, QML will manage its lifetime if created by QML.
    // If created in C++ and registered as an instance, ensure its lifetime.
    // Your current Device.cpp is QML-centric for UI messages.
    // Let's assume Device is primarily for QML interaction and ConnectionWorker manages Device instances.

    // QML type registrations
    qmlRegisterType<CharacteristicInfo>("receiver.ble", 1, 0, "CharacteristicInfo");
    // qmlRegisterSingletonInstance<Device>("receiver.ble", 1, 0, "Device", deviceInstance); // If Device is a global singleton managed from C++
    // For your current structure where ConnectionWorker creates Device instances:
    qmlRegisterType<Device>("receiver.ble", 1, 0, "Device"); // So QML can understand Device type if needed, but instances are C++ managed
    qmlRegisterType<DeviceInfo>("receiver.ble", 1, 0, "DeviceInfo");
    qmlRegisterType<ServiceInfo>("receiver.ble", 1, 0, "ServiceInfo");
    qmlRegisterType<NetworkManager>("Network", 1, 0, "NetworkManager");


    // --- Create and set up MainThreadBridge ---
    MainThreadBridge mainThreadBridge;


    // Set up connection worker
    QThread *connectionThread = new QThread(&app);
    ConnectionWorker *connectionWorker = new ConnectionWorker(sharedBuffer); // Does not take a parent, will be moved
    connectionWorker->moveToThread(connectionThread);

    QObject::connect(connectionThread, &QThread::started, connectionWorker, &ConnectionWorker::startMonitoring);
    // Clean up connection worker and thread
    QObject::connect(connectionWorker, &ConnectionWorker::destroyed, connectionThread, &QThread::quit);
    QObject::connect(connectionThread, &QThread::finished, connectionThread, &QThread::deleteLater);


    // --- Connect ConnectionWorker's signal to MainThreadBridge's slot ---
    QObject::connect(connectionWorker, &ConnectionWorker::connectedDevicesActualListChanged,
                     &mainThreadBridge, &MainThreadBridge::setQmlConnectedDevices, Qt::QueuedConnection);


    // Set up sender thread & worker
    QThread *senderThread = new QThread(&app);
    SenderWorker *senderWorker = new SenderWorker(
        sharedBuffer,
        QStringLiteral("http://192.168.1.230:3000/api/test") // Consider making this configurable
        );
    senderWorker->moveToThread(senderThread);

    QObject::connect(senderThread, &QThread::started, senderWorker, &SenderWorker::start);
    QObject::connect(senderWorker, &SenderWorker::finished, senderThread, &QThread::quit);
    QObject::connect(senderThread, &QThread::finished, senderWorker, &QObject::deleteLater);
    QObject::connect(senderThread, &QThread::finished, senderThread, &QObject::deleteLater);

    QObject::connect(senderWorker, &SenderWorker::packetSent,
                     [](int id){ qDebug() << "Main: Packet" << id << "sent"; });
    QObject::connect(senderWorker, &SenderWorker::sendError,
                     [](const QList<int> &ids, const QString &err) {
                         qWarning() << "Main: Failed packets" << ids << "error:" << err;
                     });

    // Clean on quit
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&]() { // Capture by reference if needed
        qDebug() << "Main: Application about to quit. Stopping workers...";
        if (senderWorker) senderWorker->stop(); // Check if not null
        if (senderThread) senderThread->quit();
        if (senderThread) senderThread->wait(5000); // Wait with timeout

        if (connectionWorker) connectionWorker->stopMonitoring();
        if (connectionThread) connectionThread->quit();
        if (connectionThread) connectionThread->wait(5000); // Wait with timeout
        qDebug() << "Main: Workers stopped.";
    });

    // QML engine
    QQmlApplicationEngine engine;

    NotificationManager notificationManager;
    engine.rootContext()->setContextProperty("notificationManager", &notificationManager);

    // --- Expose MainThreadBridge to QML ---
    engine.rootContext()->setContextProperty("mainThreadBridge", &mainThreadBridge);
    // Expose Device singleton IF you manage one instance from C++ globally.
    // If ConnectionWorker creates Device instances, this global Device might be for other purposes or not needed.
    // For now, assuming 'Device' in QML refers to instances created by ConnectionWorker or for discovery.
    // If you need a global C++ 'Device' instance for QML:
    // Device* globalDeviceInterface = new Device(sharedBuffer, &app);
    // engine.rootContext()->setContextProperty("cppDeviceInterface", globalDeviceInterface);


    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [](){ QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    // Load QML from module
    engine.loadFromModule("receiver", "Main");
    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Main: Failed to load QML from module.";
        return -1;
    }

    senderThread->start();
    senderThread->setPriority(QThread::LowPriority);
    connectionThread->start();
    connectionThread->setPriority(QThread::NormalPriority);

    return app.exec();
}

#include "main.moc"
