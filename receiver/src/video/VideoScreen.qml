import QtQuick
import QtQuick.Controls
import QtMultimedia
import "../common"

Rectangle {
    id: root
    anchors.fill: parent
    signal next()

    // Video player container
    Rectangle {
        id: videoContainer
        width: parent.width * 0.9
        height: parent.height * 0.8
        color: "transparent"
        radius: 12
        anchors.centerIn: parent
        clip: true

        MediaPlayer {
            id: videoPlayer
            source: "./example.mp4" // Set your video source here
            autoPlay: true
            videoOutput: videoOutput

            audioOutput: AudioOutput {
                volume: 1
            }
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectFit
        }
    }

    // Control button
    Button {
        id: controlButton
        width: 200
        height: 60
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 40
        }

        // Dynamic text based on playback state
        contentItem: Text {
            text: videoPlayer.position === videoPlayer.duration ? "Next" : "Skip"
            color: "white"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.down ? "#404040" : "#606060"
            radius: 8
        }

        onClicked: {
            if (videoPlayer.playbackState !== MediaPlayer.StoppedState) {
                videoPlayer.stop()
            }
            next()
        }
    }

    // Play/Pause button (optional)
    RoundButton {
        id: playButton
        width: 60
        height: 60
        anchors {
            right: videoContainer.right
            bottom: videoContainer.bottom
            margins: 20
        }
        contentItem: Text {
            text: videoPlayer.playbackState === MediaPlayer.PlayingState ? "❙❙" : "▶"
            color: "white"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.down ? "#404040" : "#606060"
            radius: height/2
        }
        onClicked: videoPlayer.playbackState === MediaPlayer.PlayingState ?
            videoPlayer.pause() : videoPlayer.play()
    }

    // BackButton {
    //     anchors {
    //         top: parent.top
    //         left: parent.left
    //         margins: 20
    //     }
    // }
}
