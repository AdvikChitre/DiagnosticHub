import QtQuick
import QtQuick.Controls

Item {
    signal settings()

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
