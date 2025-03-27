#include "device.h"

Device::Device(const QString &name, const QString &description, const QSet<QString> &questions)
    : m_name(name), m_description(description), m_questions(questions)
{
}

QString Device::name() const
{
    return m_name;
}

QString Device::description() const
{
    return m_description;
}

QSet<QString> Device::questions() const
{
    return m_questions;
}
