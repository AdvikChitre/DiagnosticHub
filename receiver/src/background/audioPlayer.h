#ifndef AUDIOPLAYER_H
#define AUDIOPLAYER_H

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>

class AudioPlayer : public QObject
{
    Q_OBJECT

public:
    explicit AudioPlayer(QObject *parent = nullptr);
    ~AudioPlayer();

    void init();
    void play(const QString &source);
    void setVolume(int volume);
    void incVolume();
    void decVolume();

private:
    QMediaPlayer *player;
    QAudioOutput *audioOutput;
    int volume;
};

#endif // AUDIOPLAYER_H
