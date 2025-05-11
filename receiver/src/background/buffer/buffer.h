#ifndef BUFFER_H
#define BUFFER_H

#include <QObject>
#include <QQueue>
#include <QMutex>
#include "database.h"

class Buffer : public QObject {
    Q_OBJECT
public:
    explicit Buffer(QObject *parent = nullptr);
    void addData(const DataPacket &packet);
    DataPacket getNextForSending();
    bool hasPendingData() const;
    int memorySize() const;
    int databaseSize() const;
    int totalSize()    const { return memorySize() + databaseSize(); }
    void cleanDatabase();

private:
    void checkThreshold();

    QQueue<DataPacket> m_memoryBuffer;
    Database m_database;
    int m_threshold = 1000;
    mutable QMutex m_mutex;

public slots:
    void markSent(const QList<int>& packetIds) {
        QMutexLocker locker(&m_mutex);
        m_database.markSent(packetIds);
    }

signals:
    void dataAvailable();
};

#endif // BUFFER_H
