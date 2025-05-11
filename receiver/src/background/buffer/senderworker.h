#ifndef SENDERWORKER_H
#define SENDERWORKER_H

#include <QObject>
#include <QTimer>
#include <QMutex>
#include <QJsonArray>
#include <QJsonObject>
#include <QThread>
#include <QJsonDocument>
#include "buffer.h"
#include "../../request/networkmanager.h"

static const int BATCH_SIZE = 10; // number of packets per batch

class SenderWorker : public QObject {
    Q_OBJECT
public:
    explicit SenderWorker(Buffer *buffer, const QString &apiUrl, QObject *parent = nullptr)
        : QObject(parent),
        m_buffer(buffer),
        m_apiUrl(apiUrl),
        m_activeRequest(false)
    {
        m_networkManager = new NetworkManager(this);
        connectSignals();
        qDebug() << "SenderWorker created in thread:" << QThread::currentThreadId();
        qDebug() << "Buffer Length:" << m_buffer->memorySize();
        qDebug() << "Database Length:" << m_buffer->databaseSize();
    }

public slots:
    void start() {
        QTimer *timer = new QTimer(this);
        timer->setInterval(200); // poll every X ms
        connect(timer, &QTimer::timeout, this, &SenderWorker::trySendBatch);
        timer->start();
    }

    void stop() {
        emit finished();
    }

signals:
    void triggerSend(const QString &url, const QByteArray &body);
    void packetSent(int packetId);
    void sendError(const QList<int> &packetIds, const QString &error);
    void finished();

private slots:
    void handleResponse(const QString &) {
        completeSuccess();
    }

    void handleError(const QString &error) {
        QMutexLocker locker(&m_mutex);
        qWarning() << "Batch send error for packets" << m_currentBatchIds << ":" << error;
        // Requeue all failed packets at the front
        for (const DataPacket &pkt : m_currentBatch) {
            m_buffer->addData(pkt);
        }
        emit sendError(m_currentBatchIds, error);
        m_activeRequest = false;
        m_currentBatch.clear();
        m_currentBatchIds.clear();
    }

    void trySendBatch() {
        // Only send when at least BATCH_SIZE packets available
        if (m_activeRequest)
            return;
        int available = m_buffer->memorySize() + m_buffer->databaseSize();
        if (available < BATCH_SIZE)
            return;

        QMutexLocker locker(&m_mutex);
        m_activeRequest = true;

        // collect up to BATCH_SIZE packets
        m_currentBatch.clear();
        m_currentBatchIds.clear();
        for (int i = 0; i < BATCH_SIZE; ++i) {
            DataPacket pkt = m_buffer->getNextForSending();
            m_currentBatch.append(pkt);
            m_currentBatchIds.append(pkt.id);
        }

        // build JSON array
        QJsonArray array;
        for (const DataPacket &pkt : m_currentBatch) {
            QJsonObject obj;
            obj["timestamp"] = pkt.timestamp.toMSecsSinceEpoch();
            obj["serviceUuid"]   = QString(pkt.serviceUuid);
            obj["charUuid"]   = QString(pkt.charUuid);
            obj["mac"]       = QString(pkt.MAC);
            obj["data"]      = QString(pkt.data);
            // obj["id"]        = pkt.id;
            array.append(obj);
        }
        QJsonObject root;
        root["packets"] = array;
        QByteArray payload = QJsonDocument(root).toJson();

        emit triggerSend(m_apiUrl, payload);
    }

private:
    void connectSignals() {
        connect(m_networkManager, &NetworkManager::responseDataChanged,
                this, &SenderWorker::handleResponse);
        connect(m_networkManager, &NetworkManager::errorOccurred,
                this, &SenderWorker::handleError);
        connect(this, &SenderWorker::triggerSend,
                m_networkManager, &NetworkManager::post,
                Qt::QueuedConnection);
    }

    void completeSuccess() {
        QMutexLocker locker(&m_mutex);
        // mark all in batch as sent
        m_buffer->markSent(m_currentBatchIds);
        m_buffer->cleanDatabase();
        for (int id : m_currentBatchIds) {
            emit packetSent(id);
        }
        m_activeRequest = false;
        m_currentBatch.clear();
        m_currentBatchIds.clear();
    }

    Buffer *m_buffer;
    NetworkManager *m_networkManager;
    QString m_apiUrl;
    std::atomic<bool> m_activeRequest;
    QList<DataPacket> m_currentBatch;
    QList<int> m_currentBatchIds;
    QMutex m_mutex;
};

#endif // SENDERWORKER_H
