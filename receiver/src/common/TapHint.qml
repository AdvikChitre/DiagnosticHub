import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property alias text: hintText.text

    property int showDelay: 30000
    property bool hintVisible: false
    visible: hintVisible

    property int tapDistance: 20
    property int tapDuration: 700
    property int tapPause: 600

    width: Math.max(fingerIcon.width, hintText.width)
    height: fingerIcon.height + hintText.height + 20

    Timer {
        id: inactivityTimer
        interval: root.showDelay
        repeat: false
        running: true
        onTriggered: {
            root.hintVisible = true;
        }
    }

    function reset() {
        root.hintVisible = false;
        inactivityTimer.restart();
    }

    Item {
        id: fingerIcon
        height: 70
        width: 70
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0

        Image {
            id: fingerSourceImage
            source: "../icon/finger.svg"
            anchors.fill: parent
            visible: false
        }

        ColorOverlay {
            anchors.fill: fingerSourceImage
            source: fingerSourceImage
            color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "grey"
        }

        SequentialAnimation on y {
            running: root.visible
            loops: Animation.Infinite

            NumberAnimation {
                to: tapDistance
                duration: tapDuration
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                to: 0
                duration: tapDuration
                easing.type: Easing.InQuad
            }

            PauseAnimation { duration: tapPause }
        }
    }

    Text {
        id: hintText
        anchors {
            top: fingerIcon.bottom
            topMargin: 15
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: appStorage.selectedTextColor
        font.pixelSize: 14
        width: Math.min(implicitWidth, root.width)
    }
}
