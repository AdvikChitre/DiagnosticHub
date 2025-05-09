#ifndef SENDERWORKER_H
#define SENDERWORKER_H

#include <QObject>
#include <QTimer>
#include <QMutex>
#include <QJsonObject>
#include <QThread>
#include <QJsonDocument>
#include "buffer.h"
#include "../../request/networkmanager.h"

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
    /// Kick off the periodic send-checker once the thread starts
    void start() {
        QTimer *timer = new QTimer(this);
        timer->setInterval(10);
        connect(timer, &QTimer::timeout, this, &SenderWorker::trySendNext);
        timer->start();
    }

    /// If you ever want to stop early
    void stop() {
        emit finished();
    }

signals:
    void triggerSend(const QString &url, const QByteArray &body);
    void packetSent(int packetId);
    void sendError(int packetId, const QString &error);
    void finished();

private slots:
    void handleResponse(const QString &) {
        completeRequest();
    }

    void handleError(const QString &error) {
        QMutexLocker locker(&m_mutex);
        qWarning() << "Send error for packet" << m_currentPacket.id << ":" << error;
        // Requeue the failed packet at the front of the buffer
        m_buffer->addData(m_currentPacket);
        emit sendError(m_currentPacket.id, error);
        m_activeRequest = false;
        m_currentPacket = DataPacket();
    }

    void trySendNext() {
        if (m_activeRequest || !m_buffer->hasPendingData())
            return;

        QMutexLocker locker(&m_mutex);
        m_currentPacket = m_buffer->getNextForSending();
        m_activeRequest = true;

        QJsonObject obj;
        obj["timestamp"]   = m_currentPacket.timestamp.toMSecsSinceEpoch();
        obj["data"] = QString(m_currentPacket.data);
        QByteArray payload = QJsonDocument(obj).toJson();

        emit triggerSend(m_apiUrl, payload);
    }

private:
    void connectSignals() {
        // replies → this worker
        connect(m_networkManager, &NetworkManager::responseDataChanged,
                this, &SenderWorker::handleResponse);
        connect(m_networkManager, &NetworkManager::errorOccurred,
                this, &SenderWorker::handleError);

        // this worker → network manager
        connect(this, &SenderWorker::triggerSend,
                m_networkManager, &NetworkManager::post,
                Qt::QueuedConnection);
    }

    void completeRequest() {
        QMutexLocker locker(&m_mutex);
        m_buffer->markSent({ m_currentPacket.id });
        emit packetSent(m_currentPacket.id);
        m_activeRequest = false;
        m_currentPacket = DataPacket();
    }

    Buffer *m_buffer;
    NetworkManager *m_networkManager;
    QString m_apiUrl;
    std::atomic<bool> m_activeRequest;
    DataPacket m_currentPacket;
    QMutex m_mutex;
};

#endif // SENDERWORKER_H
