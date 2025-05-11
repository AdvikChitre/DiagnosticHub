#include "database.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

Database::Database(QObject *parent) : QObject(parent) {
    m_db = QSqlDatabase::addDatabase("QSQLITE", "buffer_connection");
}

Database::~Database() {
    if(m_db.isOpen()) m_db.close();
}

bool Database::initialize(const QString &dbName) {
    m_db.setDatabaseName(dbName);
    if(!m_db.open()) return false;

    QSqlQuery query(m_db);
    return query.exec(
        "CREATE TABLE IF NOT EXISTS " + m_tableName + " ("
                                                      "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                                                      "timestamp DATETIME NOT NULL, "
                                                      "data BLOB NOT NULL, "
                                                      "sent BOOLEAN NOT NULL DEFAULT 0)"
        );
}

bool Database::bulkInsert(const QList<DataPacket> &packets) {
    if(packets.isEmpty()) return true;

    QSqlQuery query(m_db);
    m_db.transaction();

    query.prepare("INSERT INTO " + m_tableName + " (timestamp, data) VALUES (?, ?)");

    for(const DataPacket &packet : packets) {
        query.addBindValue(packet.timestamp);
        query.addBindValue(packet.data);
        if(!query.exec()) {
            m_db.rollback();
            return false;
        }
    }

    return m_db.commit();
}

QList<DataPacket> Database::bulkFetch(int batchSize) const {
    QList<DataPacket> result;
    QSqlQuery query(m_db);

    query.prepare("SELECT id, timestamp, data FROM " + m_tableName +
                  " WHERE sent = 0 ORDER BY id ASC LIMIT ?");
    query.addBindValue(batchSize);

    if(query.exec()) {
        while(query.next()) {
            DataPacket packet;
            packet.id = query.value(0).toInt();
            packet.timestamp = query.value(1).toDateTime();
            packet.data = query.value(2).toByteArray();
            result.append(packet);
        }
    }
    return result;
}

bool Database::markSent(const QList<int> &packetIds) {
    if(packetIds.isEmpty()) return true;

    QStringList idStrings;
    for(int id : packetIds) {
        idStrings << QString::number(id);
    }

    QSqlQuery query(m_db);
    return query.exec(
        "UPDATE " + m_tableName +
        " SET sent = 1 WHERE id IN (" +
        idStrings.join(",") + ")"
        );
}

void Database::cleanup() {
    QSqlQuery query(m_db);
    query.exec("DELETE FROM " + m_tableName + " WHERE sent = 1");
}

int Database::rowCount() const {
    QSqlQuery query(m_db);
    if (!query.exec("SELECT COUNT(*) FROM " + m_tableName)) {
        qWarning() << "rowCount error:" << query.lastError().text();
        return 0;
    }
    if (query.next()) {
        return query.value(0).toInt();
    }
    return 0;
}
