#include "fpsmonitor.h"
#include <QDateTime>
#include <QDebug>

FpsMonitor::FpsMonitor(QObject *parent) : QObject(parent)
{
}

FpsMonitor::~FpsMonitor()
{
    stopMonitoring();
}

void FpsMonitor::startMonitoring(QQuickWindow *window, const QString &logFilePath)
{
    if (!window || m_loggingTimer) {
        qWarning() << "FPS Monitor: Already running or window is null.";
        return;
    }

    m_monitoringWindow = window;
    m_frameCount = 0;

    m_logFile = new QFile(logFilePath, this);
    if (!m_logFile->open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        qWarning() << "FPS Monitor: Could not open log file for writing:" << logFilePath;
        delete m_logFile;
        m_logFile = nullptr;
        return;
    }

    m_logStream = new QTextStream(m_logFile);
    *m_logStream << "timestamp,fps" << Qt::endl;

    qInfo() << "FPS Monitor: Started logging to" << logFilePath;

    connect(m_monitoringWindow, &QQuickWindow::frameSwapped, this, &FpsMonitor::onFrameSwapped, Qt::DirectConnection);

    m_loggingTimer = new QTimer(this);
    m_loggingTimer->setInterval(1000);
    connect(m_loggingTimer, &QTimer::timeout, this, &FpsMonitor::calculateAndLogFps);
    m_loggingTimer->start();
}

void FpsMonitor::stopMonitoring()
{
    if (m_monitoringWindow) {
        disconnect(m_monitoringWindow, &QQuickWindow::frameSwapped, this, &FpsMonitor::onFrameSwapped);
        m_monitoringWindow = nullptr;
    }

    if (m_loggingTimer) {
        m_loggingTimer->stop();
        m_loggingTimer->deleteLater();
        m_loggingTimer = nullptr;
    }

    if (m_logFile && m_logFile->isOpen()) {
        qInfo() << "FPS Monitor: Stopped logging.";
        if (m_logStream) {
            m_logStream->flush();
        }
        m_logFile->close();
    }
}

void FpsMonitor::onFrameSwapped()
{
    m_frameCount++;
}

void FpsMonitor::calculateAndLogFps()
{
    if (!m_logStream) return;

    qint64 timestamp = QDateTime::currentMSecsSinceEpoch();
    *m_logStream << timestamp << "," << m_frameCount << Qt::endl;

    m_frameCount = 0;
}
