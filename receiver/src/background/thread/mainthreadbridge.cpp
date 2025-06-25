#include "mainthreadbridge.h"

MainThreadBridge::MainThreadBridge(QObject *parent) : QObject(parent)
{
}

QStringList MainThreadBridge::qmlConnectedDevices() const
{
    return m_qmlConnectedDevices;
}

void MainThreadBridge::setQmlConnectedDevices(const QStringList &devices)
{
    if (m_qmlConnectedDevices != devices) {
        m_qmlConnectedDevices = devices;
        qDebug() << "MainThreadBridge: qmlConnectedDevices updated to:" << m_qmlConnectedDevices;
        emit qmlConnectedDevicesChanged(m_qmlConnectedDevices);
    }
}
