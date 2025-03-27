#include "devicelist.h"


DeviceList::DeviceList(QObject *parent)
    : QAbstractListModel(parent)
{}

int DeviceList::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_devices.count();
}

QVariant DeviceList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_devices.count())
        return QVariant();

    Device *device = m_devices.at(index.row());

    switch(role) {
    case NameRole:
        return device->name();
    case DescriptionRole:
        return device->description();
    case QuestionsRole:
        return QVariant::fromValue(device->questions());
    }

    return QVariant();
}

QHash<int, QByteArray> DeviceList::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[DescriptionRole] = "description";
    roles[QuestionsRole] = "questions";
    return roles;
}

void DeviceList::addDevice(Device *device)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_devices.append(device);
    endInsertRows();
}

Device* DeviceList::get(int index) const
{
    if (index < 0 || index >= m_devices.count())
        return nullptr;
    return m_devices.at(index);
}
