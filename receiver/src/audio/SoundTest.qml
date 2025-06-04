import QtQuick
import QtQuick.Controls
import QtMultimedia

Item {
    width: 200
    height: 100

    MediaPlayer {
        id: mediaPlayer
        source: "430811__mmoerth__strange-electronic-toilet-speech-wav.wav"
        audioOutput: AudioOutput {
            volume: 1
        }
    }

    Button {
        text: "Test Sound"
        anchors.centerIn: parent
        onClicked: {
            mediaPlayer.stop()
            mediaPlayer.play()
            console.log('Playing audio')
            console.log("CONNECTED:", appStorage.connectedDevices)
        }
    }
}
