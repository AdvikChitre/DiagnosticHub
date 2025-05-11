#include "connectionworker.h"
#include <QSettings>

#include <QThread>

ConnectionWorker::ConnectionWorker(Buffer *buffer, QObject *parent)
    : QObject(parent), m_buffer(buffer)
{

    m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    m_discoveryAgent->setLowEnergyDiscoveryTimeout(5000);

    m_updateTimer = new QTimer(this);
    m_updateTimer->setInterval(5000);

    m_reconnectTimer = new QTimer(this);
    m_reconnectTimer->setInterval(10000);

    connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            this, &ConnectionWorker::handleDeviceDiscovered);
    connect(m_discoveryAgent, &QBluetoothDeviceDiscoveryAgent::errorOccurred,
            [](QBluetoothDeviceDiscoveryAgent::Error error) {
                qWarning() << "Discovery error:" << error;
            });
    connect(m_updateTimer, &QTimer::timeout, this, &ConnectionWorker::updateDeviceList);
    connect(m_reconnectTimer, &QTimer::timeout, this, &ConnectionWorker::reconnectDevices);

    qDebug() << "ConnectionWorker created in thread:" << QThread::currentThreadId();
}

ConnectionWorker::~ConnectionWorker()
{
    stopMonitoring();
    qDeleteAll(m_connectedDevices);
    m_connectedDevices.clear();
}

void ConnectionWorker::startMonitoring()
{
    updateDeviceList();
    m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
    m_updateTimer->start();
    m_reconnectTimer->start();
}

void ConnectionWorker::stopMonitoring()
{
    m_discoveryAgent->stop();
    m_updateTimer->stop();
    m_reconnectTimer->stop();
    qDeleteAll(m_connectedDevices);
    m_connectedDevices.clear();
}

void ConnectionWorker::handleDeviceDiscovered(const QBluetoothDeviceInfo &info)
{
    if (!info.coreConfigurations().testFlag(QBluetoothDeviceInfo::LowEnergyCoreConfiguration))
        return;

    QString address;
#ifdef Q_OS_DARWIN
    address = info.deviceUuid().toString();
#else
    address = info.address().toString();
#endif

    if(m_targetDevices.contains(address) && !m_connectedDevices.contains(address)) {
        qDebug() << "Address Found:" << address;
        Device *device = new Device(m_buffer);
        // Run another scan so the new device instance can see it
        device->startDeviceDiscovery();
        device->autoConnectServices(true);
        connect(device, &Device::serviceDiscovered,
                this, &ConnectionWorker::handleServiceDiscovered);
        connect(device, &Device::disconnected,
                this, &ConnectionWorker::handleDeviceDisconnected,
                Qt::QueuedConnection);


        device->scanServices(address);
        m_connectedDevices.insert(address, device);
    }
}

void ConnectionWorker::handleDeviceDisconnected()
{
    Device *device = qobject_cast<Device*>(sender());
    if (!device) return;

    m_connectedDevices.remove(device->getCurrentAddress());
}

void ConnectionWorker::updateDeviceList()
{
    QSettings settings;
    settings.beginGroup("AppConfig");
    m_targetDevices = settings.value("selectedDevices").toStringList();
    settings.endGroup();

    // Cleanup disconnected devices
    QMutableMapIterator<QString, Device*> it(m_connectedDevices);
    while(it.hasNext()) {
        it.next();
        if(!m_targetDevices.contains(it.key())) {
            delete it.value();
            it.remove();
        }
    }
}

void ConnectionWorker::handleServiceDiscovered(const QString &serviceUuid)
{
    Device *device = qobject_cast<Device*>(sender());
    if(device) {
        device->connectToService(serviceUuid);
    }
}

void ConnectionWorker::reconnectDevices()
{
    qDebug() << "Scanning devices";
    // Re-scan periodically to maintain connections
    if(!m_discoveryAgent->isActive()) {
        m_discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
    }
}
