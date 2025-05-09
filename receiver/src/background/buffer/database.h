#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QSqlDatabase>
#include <QList>
#include "datapacket.h"

class Database : public QObject {
    Q_OBJECT
public:
    explicit Database(QObject *parent = nullptr);
    ~Database();

    bool initialize(const QString &dbName = "buffer.db");
    bool bulkInsert(const QList<DataPacket> &packets);
    QList<DataPacket> bulkFetch(int batchSize) const;
    bool markSent(const QList<int> &packetIds);
    void cleanup();
    int rowCount() const;

private:
    QSqlDatabase m_db;
    QString m_tableName = "data_packets";
};

#endif // DATABASE_H
