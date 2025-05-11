#include "buffer.h"

Buffer::Buffer(QObject *parent) : QObject(parent) {
    m_database.initialize();
}

void Buffer::addData(const DataPacket &packet) {
    QMutexLocker locker(&m_mutex);
    m_memoryBuffer.enqueue(packet);
    checkThreshold();
}

DataPacket Buffer::getNextForSending() {
    QMutexLocker locker(&m_mutex);

    if(m_memoryBuffer.isEmpty()) {
        QList<DataPacket> dbPackets = m_database.bulkFetch(50);
        for(const DataPacket &packet : dbPackets) {
            m_memoryBuffer.enqueue(packet);
        }
    }

    return m_memoryBuffer.dequeue();
}

bool Buffer::hasPendingData() const {
    QMutexLocker locker(&m_mutex);
    return !m_memoryBuffer.isEmpty() || m_database.bulkFetch(1).count() > 0;
}

void Buffer::checkThreshold() {
    if(m_memoryBuffer.size() >= m_threshold) {
        QList<DataPacket> toStore;

        // Move ALL packets from memory buffer to database
        while(!m_memoryBuffer.isEmpty()) {
            toStore.append(m_memoryBuffer.dequeue());
        }

        // Alternative one-line version:
        // toStore.swap(m_memoryBuffer); // Requires m_memoryBuffer as QList instead of QQueue

        if(!toStore.isEmpty()) {
            m_database.bulkInsert(toStore);
            qDebug() << "Moved" << toStore.size() << "packets to database";
        }
    }
}

int Buffer::memorySize() const {
    QMutexLocker locker(&m_mutex);
    return m_memoryBuffer.size();
}

int Buffer::databaseSize() const {
    return m_database.rowCount();
}

void Buffer::cleanDatabase() {
    m_database.cleanup();
}
