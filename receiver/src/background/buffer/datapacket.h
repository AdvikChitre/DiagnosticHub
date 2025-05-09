#ifndef DATAPACKET_H
#define DATAPACKET_H

#include <QDateTime>
#include <QByteArray>

struct DataPacket {
    int id;
    QDateTime timestamp;
    QByteArray data;
    bool sent = false;
};

#endif
