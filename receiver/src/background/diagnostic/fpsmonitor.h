#ifndef FPSMONITOR_H
#define FPSMONITOR_H

#include <QObject>
#include <QElapsedTimer>
#include <QFile>
#include <QTextStream>
#include <QQuickWindow>
#include <QTimer>

class FpsMonitor : public QObject
{
    Q_OBJECT
public:
    explicit FpsMonitor(QObject *parent = nullptr);
    ~FpsMonitor();

public slots:
    void startMonitoring(QQuickWindow *window, const QString &logFilePath = "/fps.csv");
    void stopMonitoring();

private slots:
    void onFrameSwapped();
    void calculateAndLogFps();

private:
    QQuickWindow* m_monitoringWindow = nullptr;
    QTimer* m_loggingTimer = nullptr;
    qint64 m_frameCount = 0;

    QFile* m_logFile = nullptr;
    QTextStream* m_logStream = nullptr;
};

#endif // FPSMONITOR_H
