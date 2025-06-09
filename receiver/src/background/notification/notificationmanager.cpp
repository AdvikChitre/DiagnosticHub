#include "notificationmanager.h"
#include "mmapgpio.h"
#include <QThread>
#include <iostream>

NotificationManager::NotificationManager(QObject *parent) : QObject(parent)
{
}

void NotificationManager::doNotification()
{
    QSettings settings;
    settings.beginGroup("AppConfig");
    bool useBuzzer = settings.value("notifyHaptic", true).toBool();
    bool useLed = settings.value("notifyFlash", true).toBool();
    settings.endGroup();

    qDebug() << "Notification triggered. Buzzer enabled:" << useBuzzer << "LED enabled:" << useLed;

    if (!useBuzzer && !useLed) {
        return;
    }

    (void)QtConcurrent::run(&NotificationManager::runNotificationPattern, this, useBuzzer, useLed);
}

void NotificationManager::runNotificationPattern(bool useBuzzer, bool useLed)
{
    try {
        MmapGpio gpio;

        if (useBuzzer) {
            gpio.setAsOutput(BUZZER_PIN);
        }
        if (useLed) {
            gpio.setAsOutput(LED_PIN);
        }

        for (int i = 0; i < 10; ++i) {
            if (useBuzzer) gpio.write(BUZZER_PIN, true);
            if (useLed)    gpio.write(LED_PIN, true);
            QThread::msleep(100);

            if (useBuzzer) gpio.write(BUZZER_PIN, false);
            if (useLed)    gpio.write(LED_PIN, false);
            QThread::msleep(150);
        }

    } catch (const std::exception& e) {
        qWarning() << "GPIO Notification Error:" << e.what();
    }
}
