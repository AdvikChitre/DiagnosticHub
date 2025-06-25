#ifndef MAINTHREADBRIDGE_H
#define MAINTHREADBRIDGE_H

#include <QObject>
#include <QStringList>
#include <QDebug>

class MainThreadBridge : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList qmlConnectedDevices READ qmlConnectedDevices WRITE setQmlConnectedDevices NOTIFY qmlConnectedDevicesChanged)

public:
    explicit MainThreadBridge(QObject *parent = nullptr);

    QStringList qmlConnectedDevices() const;

public slots:
    void setQmlConnectedDevices(const QStringList &devices);

signals:
    void qmlConnectedDevicesChanged(const QStringList &devices);

private:
    QStringList m_qmlConnectedDevices;
};

#endif // MAINTHREADBRIDGE_H
