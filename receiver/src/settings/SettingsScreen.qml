import QtQuick
import QtQuick.Controls
import "../common"

Item {

    ScrollView {
        width: 200
        height: 200

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        ListView {
            Rectangle{
                    id: rect1
                    width: parent.width
                    height: 200
                    color: "#ffff00"
                    //anchors.horizontalCenter: parent.horizontalCenter
                }

            Rectangle{
                    id: rect2
                    width: parent.width
                    height: 200
                    color: "#ffff00"
                    //anchors.horizontalCenter: parent.horizontalCenter
                }
        }
    }

    BackButton {
        anchors {
            top: parent.top
            left: parent.left
            margins: 20
        }
    }
}
