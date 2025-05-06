import QtQuick
import QtQuick.Controls

Item {
    id: root

    // Public properties
    property var labels: []
    property int currentStep: 1
    property color circleColor: "#4CAF50"
    property color activeColor: "#2196F3"

    width: parent.width * 0.8
    height: 80  // Increased height for labels

    // Background line
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        color: "#E0E0E0"
    }

    // Active line
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: labels.length > 1 ? (root.width / (labels.length - 1)) * (currentStep - 1) : 0
        height: 4
        color: activeColor
        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
    }

    // Circles with labels
    Row {
        anchors.fill: parent
        spacing: labels.length > 1 ? (parent.width - (labels.length * 60)) / (labels.length - 1) : 0

        Repeater {
            model: labels

            Column {
                spacing: 5
                width: 60

                // Step number
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: index + 1 <= currentStep ? activeColor : circleColor
                    border.color: "#BDBDBD"
                    border.width: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                    }
                }

                // Custom label
                Text {
                    text: modelData
                    color: index + 1 <= currentStep ? activeColor : "#757575"
                    font.pixelSize: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
