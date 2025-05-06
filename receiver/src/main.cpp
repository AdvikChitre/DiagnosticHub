#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
// #include "./devices/device.h"
// #include "./devices/devicelist.h"
// #include <applicationsettings.h>
// #include "./settings/item/wifi/wifiscanner.h"
#include "./request/networkmanager.h"
// #include "./settings/item/settingsapp/DeviceUtilities/QtButtonImageProvider/qtbuttonimageprovider.h"
#include "background/ble/characteristicinfo.h"
#include "background/ble/device.h"
#include "background/ble/deviceinfo.h"
#include "background/ble/serviceinfo.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    // Set organisation info
    QCoreApplication::setOrganizationName("Imperial College London");
    QCoreApplication::setOrganizationDomain("imperial.ac.uk");

    QGuiApplication app(argc, argv);

    // Register BLE helper types
    qmlRegisterType<CharacteristicInfo>("BLE", 1, 0, "CharacteristicInfo");
    qmlRegisterSingletonType<Device>("BLE", 1, 0, "Device", [](QQmlEngine *, QJSEngine *) -> QObject * {
        static Device deviceInstance;
        return &deviceInstance;
    });
    qmlRegisterType<DeviceInfo>    ("BLE", 1, 0, "DeviceInfo");
    qmlRegisterType<ServiceInfo>   ("BLE", 1, 0, "ServiceInfo");


    // Register Network Manager
    qmlRegisterType<NetworkManager>("Network", 1, 0, "NetworkManager");

    QQmlApplicationEngine engine;
    // engine.addImageProvider("buttonimages", new QtButtonImageProvider);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("receiver", "Main");



    // Create list of avaiable devices
    // DeviceList deviceList;

    // QSet<QString> questions1 = {"Question1"};
    // Device *device1 = new Device("Acupebble", "Obstructive Sleep Apnoea Diagnosis", questions1);
    // deviceList.addDevice(device1);

    // QSet<QString> questions2 = {"Question1", "Question2"};
    // Device *device2 = new Device("Device2", "Description2", questions2);
    // deviceList.addDevice(device2);

    // engine.rootContext()->setContextProperty("deviceList", &deviceList);

    return app.exec();
}
