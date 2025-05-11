#ifndef DATAPACKET_H
#define DATAPACKET_H

#include <QDateTime>
#include <QByteArray>

struct DataPacket {
    int id = -1;
    QDateTime timestamp;
    QByteArray MAC;
    QByteArray serviceUuid;
    QByteArray charUuid;
    QByteArray data;
    bool sent = false;
};

#endif // DATAPACKET_H
