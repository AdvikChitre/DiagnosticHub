#ifndef DEVICELIST_H
#define DEVICELIST_H

#include <QAbstractListModel>
#include <QList>
#include "device.h"

class DeviceList : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        DescriptionRole,
        QuestionsRole
    };

    explicit DeviceList(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addDevice(Device *device);
    Q_INVOKABLE Device* get(int index) const;

private:
    QList<Device*> m_devices;
};

#endif // DEVICELIST_H
