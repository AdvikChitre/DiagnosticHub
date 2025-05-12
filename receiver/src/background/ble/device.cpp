// Copyright (C) 2013 BlackBerry Limited. All rights reserved.
// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "src/background/ble/device.h"
// #include "device.h"
#include "datapacket.h"


#include <QBluetoothDeviceInfo>
#include <QBluetoothUuid>

#include <QDebug>
#include <QMetaObject>
#include <QTimer>

#if QT_CONFIG(permissions)
#include <QPermissions>

#include <QGuiApplication>
#endif

using namespace Qt::StringLiterals;

// Device::Device()
// {
//     //! [les-devicediscovery-1]
//     discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
//     discoveryAgent->setLowEnergyDiscoveryTimeout(25000);
//     connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
//             this, &Device::addDevice);
//     connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred,
//             this, &Device::deviceScanError);
//     connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
//             this, &Device::deviceScanFinished);
//     connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
//             this, &Device::deviceScanFinished);
//     //! [les-devicediscovery-1]

//     setUpdate(u"Search"_s);

//     m_buffer = new Buffer(this);
// }

Device::Device(Buffer *buffer, QObject *parent)
    : QObject(parent), m_buffer(buffer)
{
    //! [les-devicediscovery-1]
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    discoveryAgent->setLowEnergyDiscoveryTimeout(25000);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            this, &Device::addDevice);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred,
            this, &Device::deviceScanError);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished,
            this, &Device::deviceScanFinished);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled,
            this, &Device::deviceScanFinished);
    //! [les-devicediscovery-1]
}

Device::~Device()
{
    disconnectFromDevice();
    qDeleteAll(devices);
    qDeleteAll(m_services);
    qDeleteAll(m_characteristics);
    devices.clear();
    m_services.clear();
    m_characteristics.clear();
}

void Device::startDeviceDiscovery()
{
    qDeleteAll(devices);
    devices.clear();
    emit devicesUpdated();

    //! [les-devicediscovery-2]
    discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
    //! [les-devicediscovery-2]

    if (discoveryAgent->isActive()) {
        setUpdate(u"Stop"_s);
        m_deviceScanState = true;
        Q_EMIT stateChanged();
    }
}

void Device::stopDeviceDiscovery()
{
    if (discoveryAgent->isActive())
        discoveryAgent->stop();
}

//! [les-devicediscovery-3]
void Device::addDevice(const QBluetoothDeviceInfo &info)
{
    if (info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) {
        auto devInfo = new DeviceInfo(info);
        auto it = std::find_if(devices.begin(), devices.end(),
                               [devInfo](DeviceInfo *dev) {
                                   return devInfo->getAddress() == dev->getAddress();
                               });
        if (it == devices.end()) {
            devices.append(devInfo);
        } else {
            auto oldDev = *it;
            *it = devInfo;
            delete oldDev;
        }
        emit devicesUpdated();
    }
}
//! [les-devicediscovery-3]

void Device::deviceScanFinished()
{
    m_deviceScanState = false;
    emit stateChanged();
    if (devices.isEmpty())
        setUpdate(u"No Low Energy devices found..."_s);
    else
        setUpdate(u"Done! Scan Again!"_s);
}

QVariant Device::getDevices()
{
    return QVariant::fromValue(devices);
}

QVariant Device::getServices()
{
    return QVariant::fromValue(m_services);
}

QVariant Device::getCharacteristics()
{
    return QVariant::fromValue(m_characteristics);
}

QString Device::getUpdate()
{
    return m_message;
}

void Device::scanServices(const QString &address)
{
    m_currentAddress = address.toUtf8();

    // We need the current device for service discovery.

    for (auto d: std::as_const(devices)) {
        if (auto device = qobject_cast<DeviceInfo *>(d)) {
            if (device->getAddress() == address) {
                currentDevice.setDevice(device->getDevice());
                break;
            }
        }
    }

    if (!currentDevice.getDevice().isValid()) {
        qWarning() << "Not a valid device";
        return;
    }

    qDeleteAll(m_characteristics);
    m_characteristics.clear();
    emit characteristicsUpdated();
    qDeleteAll(m_services);
    m_services.clear();
    emit servicesUpdated();

    setUpdate(u"Back\n(Connecting to device...)"_s);
    qDebug() << "Connecting to device";

    if (controller && m_previousAddress != currentDevice.getAddress()) {
        controller->disconnectFromDevice();
        delete controller;
        controller = nullptr;
    }

    //! [les-controller-1]
    if (!controller) {
        // Connecting signals and slots for connecting to LE services.
        controller = QLowEnergyController::createCentral(currentDevice.getDevice(), this);
        connect(controller, &QLowEnergyController::connected,
                this, &Device::deviceConnected);
        connect(controller, &QLowEnergyController::errorOccurred, this, &Device::errorReceived);
        connect(controller, &QLowEnergyController::disconnected,
                this, &Device::deviceDisconnected);
        connect(controller, &QLowEnergyController::serviceDiscovered,
                this, &Device::addLowEnergyService);
        connect(controller, &QLowEnergyController::discoveryFinished,
                this, &Device::serviceScanDone);
    }

    if (isRandomAddress())
        controller->setRemoteAddressType(QLowEnergyController::RandomAddress);
    else
        controller->setRemoteAddressType(QLowEnergyController::PublicAddress);
    controller->connectToDevice();
    //! [les-controller-1]

    m_previousAddress = currentDevice.getAddress();
}

void Device::addLowEnergyService(const QBluetoothUuid &serviceUuid)
{
    qDebug() << "Adding low energy service:" << serviceUuid;
    //! [les-service-1]
    QLowEnergyService *service = controller->createServiceObject(serviceUuid);
    if (!service) {
        qWarning() << "Cannot create service for uuid";
        return;
    }
    //! [les-service-1]
    auto serv = new ServiceInfo(service);
    m_services.append(serv);

    connectToService(serv->getUuid());

    emit servicesUpdated();
}
//! [les-service-1]

void Device::serviceScanDone()
{
    setUpdate(u"Back\n(Service scan done!)"_s);
    qDebug() << "service scan done";
    // force UI in case we didn't find anything
    if (m_services.isEmpty())
        emit servicesUpdated();
}

void Device::connectToService(const QString &uuid)
{
    // qDebug() << m_services[0]->getUuid();
    qDebug() << uuid;


    QLowEnergyService *service = nullptr;
    for (auto s: std::as_const(m_services)) {
        auto serviceInfo = qobject_cast<ServiceInfo *>(s);
        if (!serviceInfo)
            continue;

        if (serviceInfo->getUuid() == uuid) {
            service = serviceInfo->service();
            break;
        }
    }

    qDebug() << "connecting to service (1)";

    if (!service)
        return;

    qDebug() << "connecting to service (2)";

    qDeleteAll(m_characteristics);
    m_characteristics.clear();
    emit characteristicsUpdated();

    if (service->state() == QLowEnergyService::RemoteService) {
        //! [les-service-3]
        connect(service, &QLowEnergyService::stateChanged,
                this, &Device::serviceDetailsDiscovered);
        service->discoverDetails();
        setUpdate(u"Back\n(Discovering details...)"_s);
        qDebug() << "Discovering details";
        //! [les-service-3]
        return;
    }

    //discovery already done
    const QList<QLowEnergyCharacteristic> chars = service->characteristics();
    for (const QLowEnergyCharacteristic &ch : chars) {
        auto cInfo = new CharacteristicInfo(ch);
        m_characteristics.append(cInfo);
    }

    QTimer::singleShot(0, this, &Device::characteristicsUpdated);
}

void Device::deviceConnected()
{
    setUpdate(u"Back\n(Discovering services...)"_s);
    connected = true;
    //! [les-service-2]
    controller->discoverServices();
    //! [les-service-2]
}

void Device::errorReceived(QLowEnergyController::Error /*error*/)
{
    qWarning() << "Error: " << controller->errorString();
    setUpdate(u"Back\n(%1)"_s.arg(controller->errorString()));
    disconnectFromDevice();
    deviceDisconnected();
}

void Device::setUpdate(const QString &message)
{
    m_message = message;
    emit updateChanged();
}

void Device::disconnectFromDevice()
{
    // UI always expects disconnect() signal when calling this signal
    // TODO what is really needed is to extend state() to a multi value
    // and thus allowing UI to keep track of controller progress in addition to
    // device scan progress

    if (controller->state() != QLowEnergyController::UnconnectedState)
        controller->disconnectFromDevice();
    else
        deviceDisconnected();
}

void Device::deviceDisconnected()
{
    qWarning() << "Disconnect from device";
    emit disconnected();
}

void Device::serviceDetailsDiscovered(QLowEnergyService::ServiceState newState)
{

    qDebug() << "Subscribing to characteristics!";
    if (newState != QLowEnergyService::RemoteServiceDiscovered) {
        // do not hang in "Scanning for characteristics" mode forever
        // in case the service discovery failed
        // We have to queue the signal up to give UI time to even enter
        // the above mode
        if (newState != QLowEnergyService::RemoteServiceDiscovering) {
            QMetaObject::invokeMethod(this, "characteristicsUpdated",
                                      Qt::QueuedConnection);
        }
        return;
    }

    auto service = qobject_cast<QLowEnergyService *>(sender());
    if (!service)
        return;

    // Get service uuid
    const QBluetoothUuid serviceUuid = service->serviceUuid();

    //! [les-chars]
    const QList<QLowEnergyCharacteristic> chars = service->characteristics();
    for (const QLowEnergyCharacteristic &ch : chars) {
        auto cInfo = new CharacteristicInfo(ch);
        cInfo->setValue(ch.value()); // Initialize with current value
        m_characteristics.append(cInfo);
        // Store mapping
        m_charServiceMap.insert(ch.uuid(), serviceUuid);


        if (ch.properties() & (QLowEnergyCharacteristic::Notify | QLowEnergyCharacteristic::Indicate)) {
            QLowEnergyDescriptor cccd = ch.descriptor(QBluetoothUuid::DescriptorType::ClientCharacteristicConfiguration);
            if (cccd.isValid()) {
                service->writeDescriptor(cccd, QByteArray::fromHex("0100"));
            }

            if(m_autoConnect) {
                emit characteristicEnabled(service->serviceUuid(), ch.uuid());
            }

        }
    }

    // Connect to notify about changes
    connect(service, &QLowEnergyService::characteristicChanged,
            this, &Device::handleCharacteristicChanged);
    //! [les-chars]

    emit characteristicsUpdated();
}

void Device::deviceScanError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    if (error == QBluetoothDeviceDiscoveryAgent::PoweredOffError) {
        setUpdate(u"The Bluetooth adaptor is powered off, power it on before doing discovery."_s);
    } else if (error == QBluetoothDeviceDiscoveryAgent::InputOutputError) {
        setUpdate(u"Writing or reading from the device resulted in an error."_s);
    } else {
        static QMetaEnum qme = discoveryAgent->metaObject()->enumerator(
                    discoveryAgent->metaObject()->indexOfEnumerator("Error"));
        setUpdate(u"Error: "_s + QLatin1StringView(qme.valueToKey(error)));
    }

    m_deviceScanState = false;
    emit stateChanged();
}

bool Device::state()
{
    return m_deviceScanState;
}

bool Device::hasControllerError() const
{
    return (controller && controller->error() != QLowEnergyController::NoError);
}

bool Device::isRandomAddress() const
{
    return randomAddress;
}

void Device::setRandomAddress(bool newValue)
{
    randomAddress = newValue;
    emit randomAddressChanged();
}

QByteArray Device::getCurrentAddress() const
{
    return m_currentAddress;
}

void Device::autoConnectServices(bool enable)
{
    m_autoConnect = enable;
}

// Handle notification characteristic value changes
void Device::handleCharacteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &newValue)
{
    // Update the corresponding CharacteristicInfo
    for (CharacteristicInfo *cInfo : std::as_const(m_characteristics)) {
        if (cInfo->getCharacteristic().uuid() == characteristic.uuid()) {
            cInfo->setValue(newValue);
            // Get service UUID from map
            const QBluetoothUuid serviceUuid_ = m_charServiceMap.value(characteristic.uuid());

            // Add to shared buffer
            DataPacket packet;
            packet.timestamp = QDateTime::currentDateTime();
            packet.MAC = m_currentAddress;
            packet.charUuid = characteristic.uuid().toByteArray();
            packet.data = newValue;
            packet.serviceUuid = serviceUuid_.toByteArray();

            m_buffer->addData(packet);

            break;
        }
    }
    emit characteristicsUpdated(); // Refresh UI

    qDebug() << "Added to buffer. Current buffer size:" << m_buffer->memorySize();
}


QBluetoothUuid Device::getServiceUuid(const QBluetoothUuid &characteristicUuid) const
{
    return m_charServiceMap.value(characteristicUuid);
}
