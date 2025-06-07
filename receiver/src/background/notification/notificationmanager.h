#ifndef NOTIFICATIONMANAGER_H
#define NOTIFICATIONMANAGER_H

#include <QObject>
#include <QtConcurrent>
#include <QDebug>
#include <QSettings>

class NotificationManager : public QObject
{
    Q_OBJECT
public:
    explicit NotificationManager(QObject *parent = nullptr);

public slots:
    void doNotification();

private:
    void runNotificationPattern(bool useBuzzer, bool useLed);

    const int BUZZER_PIN = 4;
    const int LED_PIN = 18;
    const std::string GPIO_CHIP_NAME = "gpiochip0";
};

#endif // NOTIFICATIONMANAGER_H
