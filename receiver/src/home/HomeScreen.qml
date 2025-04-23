import QtQuick
import QtQuick.Controls
import "../audio"

Item {
    signal settings()

    SoundTest {

    }

    SettingsButton {
        anchors {
            top: parent.top
            right: parent.right
            margins: 20
        }

        onClicked: {
            settings()
        }
    }
}
