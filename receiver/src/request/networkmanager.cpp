#include "networkmanager.h"
// #include <QNetworkRequest>
// #include <QUrl>

NetworkManager::NetworkManager(QObject *parent) : QObject(parent) {
    m_manager = new QNetworkAccessManager(this);
}

void NetworkManager::get(const QString &url) {
    QNetworkReply *reply = m_manager->get(QNetworkRequest(QUrl(url)));
    connect(reply, &QNetworkReply::finished, [=]() {
        if (reply->error() == QNetworkReply::NoError) {
            // emit responseReceived();
            QByteArray bytes = reply->readAll();
            m_responseData = QString::fromUtf8(bytes);
            emit responseDataChanged(m_responseData);
        } else {
            m_error = reply->errorString();
            emit errorOccurred(reply->errorString());
        }
        reply->deleteLater();
    });
}

void NetworkManager::post(const QString &url, const QByteArray &data) {
    QUrl url_ = QUrl(url);
    QNetworkRequest request = QNetworkRequest(url_);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QNetworkReply *reply = m_manager->post(request, data);
    connect(reply, &QNetworkReply::finished, [=]() {
        if (reply->error() == QNetworkReply::NoError) {
            emit responseReceived(reply->readAll());
        } else {
            emit errorOccurred(reply->errorString());
        }
        reply->deleteLater();
    });
}
