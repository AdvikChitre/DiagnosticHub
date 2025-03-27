import QtQuick
import QtQuick.Effects

Item {
    id: deviceCard
    signal clicked()

    property string name: "DEFAULT"
    property string label: "DEFAULT"

    MouseArea {
        anchors.fill: parent
        onClicked: deviceCard.clicked()
    }

    Text {
        text: qsTr(name)
        anchors.top: parent.top
        topPadding: 30
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pixelSize: 20
    }


    Rectangle {
        height: 200
        width: 200
        anchors.centerIn: parent
        radius: 30
        clip: true

        // Rounded corners for the image
        MultiEffect {
            source: image
            anchors.fill: image
            maskEnabled: true
            maskSource: mask
        }

        Image {
            id: image
            source: "../devices/img/" + name + ".png"
            anchors.fill: parent
            visible: false
        }

        Item {
            id: mask
            anchors.fill: image; layer.enabled: true; visible: false
            Rectangle { anchors.fill: parent; radius: 8 }
        }
    }


    Text {
        text: qsTr(label)
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.italic: true
        bottomPadding: 20
    }
}
