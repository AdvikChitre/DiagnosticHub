#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>
#include <QTimer>
#include <QStringList>
#include <QDebug>
#include <QSettings>
#include <QQuickWindow>
#include <QDateTime>

#include "./request/networkmanager.h"
#include "src/background/ble/characteristicinfo.h"
#include "src/background/ble/device.h"
#include "src/background/ble/deviceinfo.h"
#include "src/background/ble/serviceinfo.h"
#include "src/background/buffer/buffer.h"
#include "src/background/buffer/senderworker.h"
#include "src/background/ble/connectionworker.h"
#include "src/background/notification/notificationmanager.h"
#include "src/background/diagnostic/fpsmonitor.h"
#include "src/background/thread/mainthreadbridge.h"


bool simulator = false;

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QCoreApplication::setOrganizationName("Imperial College London");
    QCoreApplication::setOrganizationDomain("imperial.ac.uk");
    QCoreApplication::setApplicationName("ReceiverApp");

    QGuiApplication app(argc, argv);

    Buffer *sharedBuffer = new Buffer(&app);

    MainThreadBridge mainThreadBridge;
    NotificationManager notificationManager;
    FpsMonitor fpsMonitor;

    qmlRegisterType<CharacteristicInfo>("receiver.ble", 1, 0, "CharacteristicInfo");
    qmlRegisterType<Device>("receiver.ble", 1, 0, "Device");
    qmlRegisterType<DeviceInfo>("receiver.ble", 1, 0, "DeviceInfo");
    qmlRegisterType<ServiceInfo>("receiver.ble", 1, 0, "ServiceInfo");
    qmlRegisterType<NetworkManager>("Network", 1, 0, "NetworkManager");

    QThread *connectionThread = new QThread(&app);
    ConnectionWorker *connectionWorker = new ConnectionWorker(sharedBuffer);
    connectionWorker->moveToThread(connectionThread);

    QObject::connect(connectionThread, &QThread::started, connectionWorker, &ConnectionWorker::startMonitoring);
    QObject::connect(connectionWorker, &ConnectionWorker::destroyed, connectionThread, &QThread::quit);
    QObject::connect(connectionThread, &QThread::finished, connectionThread, &QThread::deleteLater);

    QObject::connect(connectionWorker, &ConnectionWorker::connectedDevicesActualListChanged,
                     &mainThreadBridge, &MainThreadBridge::setQmlConnectedDevices, Qt::QueuedConnection);

    QThread *senderThread = new QThread(&app);
    SenderWorker *senderWorker = new SenderWorker(
        sharedBuffer,
        QStringLiteral("http://192.168.1.230:3001/api/wearable/data")
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

    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&]() {
        qDebug() << "Main: Application about to quit. Stopping workers...";
        if (senderWorker) senderWorker->stop();
        if (senderThread) senderThread->quit();
        if (senderThread) senderThread->wait(5000);

        if (connectionWorker) connectionWorker->stopMonitoring();
        if (connectionThread) connectionThread->quit();
        if (connectionThread) connectionThread->wait(5000);
        qDebug() << "Main: Workers stopped.";
    });

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("mainThreadBridge", &mainThreadBridge);
    engine.rootContext()->setContextProperty("notificationManager", &notificationManager);

    const QUrl url("qrc:/qt/qml/receiver/Main.qml");

    // QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
    //                  &app, [&](QObject *obj, const QUrl &objUrl) {
    //                      if (!obj && url == objUrl)
    //                          QCoreApplication::exit(-1);

    //                      QQuickWindow *window = qobject_cast<QQuickWindow*>(obj);
    //                      if (window) {
    //                          QString logFileName = QString("/fps_log_%1.csv").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss"));
    //                          qDebug() << "Starting FPS monitoring. Log file:" << logFileName;
    //                          fpsMonitor.startMonitoring(window, logFileName);
    //                      } else {
    //                          qWarning() << "Failed to get QQuickWindow to start FPS monitor.";
    //                      }
    //                  }, Qt::QueuedConnection);

    engine.loadFromModule("receiver", "Main");

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Main: Failed to load QML from module.";
        return -1;
    }

    senderThread->start();
    senderThread->setPriority(QThread::LowPriority);
    connectionThread->start();
    connectionThread->setPriority(QThread::NormalPriority);

    int ret = app.exec();

    fpsMonitor.stopMonitoring();

    return ret;
}
