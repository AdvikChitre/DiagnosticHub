#ifndef CONNECTIONWORKER_H
#define CONNECTIONWORKER_H

#include <QObject>
#include <QTimer>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QSettings>
#include "device.h"

class ConnectionWorker : public QObject
{
    Q_OBJECT
public:
    explicit ConnectionWorker(Buffer *buffer, QObject *parent = nullptr);
    virtual ~ConnectionWorker();

public slots:
    void startMonitoring();
    void stopMonitoring();

private slots:
    void handleDeviceDiscovered(const QBluetoothDeviceInfo &info);
    void updateDeviceList();
    void handleServiceDiscovered(const QString &serviceUuid);
    void reconnectDevices();
    void handleDeviceDisconnected();

private:
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent;
    QTimer *m_updateTimer;
    QTimer *m_reconnectTimer;
    QMap<QString, Device*> m_connectedDevices;
    QStringList m_targetDevices;
    Buffer *m_buffer;
};

#endif // CONNECTIONWORKER_H
