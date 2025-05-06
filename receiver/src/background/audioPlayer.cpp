#include "audioplayer.h"
#include <QUrl>

AudioPlayer::AudioPlayer(QObject *parent)
    : QObject(parent),
    player(nullptr),
    audioOutput(nullptr)
{
}

AudioPlayer::~AudioPlayer()
{
    delete player;
    delete audioOutput;
}

void AudioPlayer::init()
{
    audioOutput = new QAudioOutput(this);
    player = new QMediaPlayer(this);
    player->setAudioOutput(audioOutput);
}

void AudioPlayer::play(const QString &source)
{
    if (player && audioOutput) {
        player->stop();
        player->setSource(QUrl::fromLocalFile(source));
        player->play();
    }
}

void AudioPlayer::setVolume(int vol)
{
    if (audioOutput) {
        // Convert 0-100 range to 0.0-1.0 range
        audioOutput->setVolume(static_cast<float>(vol) / 100.0f);
    }
}

void AudioPlayer::incVolume()
{
    volume += 0.1;
    AudioPlayer::setVolume(volume);
}

void AudioPlayer::decVolume()
{
    volume -= 0.1;
    AudioPlayer::setVolume(volume);
}
