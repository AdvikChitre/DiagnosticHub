#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class NetworkManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString responseData READ responseData NOTIFY responseDataChanged)
    Q_PROPERTY(QString error READ error)
public:
    explicit NetworkManager(QObject *parent = nullptr);
    QString responseData() const { return m_responseData; }
    QString error() const { return m_error; }

public slots:
    void get(const QString &url);
    void post(const QString &url, const QByteArray &data);

signals:
    // void responseReceived(const QString &response);
    void responseDataChanged(const QString &data);
    void errorOccurred(const QString &error);

private:
    QNetworkAccessManager *m_manager;
    QString m_responseData;
    QString m_error;
};
