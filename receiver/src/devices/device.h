#ifndef DEVICE_H
#define DEVICE_H

#include <QObject>
#include <QString>
#include <QSet>

class Device : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name)
    Q_PROPERTY(QString description READ description)
    Q_PROPERTY(QSet<QString> questions READ questions)

public:
    Device(const QString &name, const QString &description, const QSet<QString> &questions = {});

    // Getters
    QString name() const;
    QString description() const;
    QSet<QString> questions() const;

private:
    QString m_name;
    QString m_description;
    QSet<QString> m_questions;
};

#endif
