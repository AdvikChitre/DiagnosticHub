#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QThread>
#include "./request/networkmanager.h"
#include "src/background/ble/characteristicinfo.h"
#include "src/background/ble/device.h"
#include "src/background/ble/deviceinfo.h"
#include "src/background/ble/serviceinfo.h"
#include "src/background/buffer/senderworker.h"

bool simulator = false;

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QCoreApplication::setOrganizationName("Imperial College London");
    QCoreApplication::setOrganizationDomain("imperial.ac.uk");

    QGuiApplication app(argc, argv);

    // Create Device & buffer early
    Device *deviceInstance = new Device;

    // QML type registrations...
    qmlRegisterType<CharacteristicInfo>("receiver", 1, 0, "CharacteristicInfo");
    qmlRegisterSingletonInstance<Device>("receiver", 1, 0, "Device", deviceInstance);
    qmlRegisterType<DeviceInfo>("receiver", 1, 0, "DeviceInfo");
    qmlRegisterType<ServiceInfo>("receiver", 1, 0, "ServiceInfo");
    qmlRegisterType<NetworkManager>("Network", 1, 0, "NetworkManager");

    // Set up the sender thread & worker
    QThread *senderThread = new QThread(&app);

    Buffer *sharedBuffer = deviceInstance->buffer();
    SenderWorker *senderWorker = new SenderWorker(
        sharedBuffer,
        QStringLiteral("http://192.168.215.199:3000/api/test")
        );

    senderWorker->moveToThread(senderThread);

    // When the thread starts, call start()
    QObject::connect(senderThread, &QThread::started,
                     senderWorker, &SenderWorker::start);

    // Clean up when done
    QObject::connect(senderWorker, &SenderWorker::finished,
                     senderThread, &QThread::quit);
    QObject::connect(senderThread, &QThread::finished,
                     senderWorker, &QObject::deleteLater);
    QObject::connect(senderThread, &QThread::finished,
                     senderThread, &QObject::deleteLater);

    // (Optional) track success / error
    QObject::connect(senderWorker, &SenderWorker::packetSent,
                     [](int id){ qDebug() << "Packet" << id << "sent"; });
    QObject::connect(senderWorker, &SenderWorker::sendError,
                     [](int id, const QString &err){ qWarning() << "Packet" << id << "error:" << err; });

    senderThread->start();
    senderThread->setPriority(QThread::LowPriority);

    // QML engine
    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [](){ QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);
    engine.loadFromModule("receiver", "Main");

    // Make sure to tear down cleanly on quit
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [=]() {
        senderWorker->stop();
        senderThread->quit();
        senderThread->wait();
    });

    return app.exec();
}
