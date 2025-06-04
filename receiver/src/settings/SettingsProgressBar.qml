import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // Public properties
    property int currentStep: 1
    property int totalSteps: 7
    property real activeCircleSize: 60

    width: parent.width * 0.9
    height: 60

    // Background line
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - circleSize
        height: 4
        x: circleSize / 2
        color: Qt.rgba(appStorage.selectedTextColor.r, appStorage.selectedTextColor.g, appStorage.selectedTextColor.b, 0.2)
    }

    // Active line
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: totalSteps > 1 ?
               ((parent.width - circleSize) / (totalSteps - 1)) * (currentStep - 1) : 0
        height: 4
        x: circleSize / 2
        color: appStorage.selectedBorderColor
        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
    }

    // Icons container
    Repeater {
        model: totalSteps

        Item {
            readonly property bool isCompleted: index < root.currentStep
            readonly property bool isCurrent: index + 1 === root.currentStep
            readonly property real stepPosition: totalSteps > 1 ? index / (totalSteps - 1) : 0.5

            x: (parent.width - circleSize) * stepPosition
            y: parent.height / 2 - circleSize / 2
            width: circleSize
            height: circleSize

            Rectangle {
                id: circle
                width: isCurrent ? activeCircleSize : circleSize
                height: isCurrent ? activeCircleSize : circleSize
                radius: width / 2

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                anchors.centerIn: parent

                // Dynamic coloring for the circle itself
                color: isCompletedOrCurrent ? appStorage.selectedBorderColor : appStorage.themeBackgroundColor
                border.color: isCompletedOrCurrent ? appStorage.selectedBorderColor : Qt.rgba(appStorage.selectedTextColor.r, appStorage.selectedTextColor.g, appStorage.selectedTextColor.b, 0.3)
                border.width: 2 // Reduced border width for a cleaner look with ColorOverlay


                Image {
                    id: iconImage // Give the source Image an id
                    source: getIconSource(index + 1)
                    visible: false // Hide the original SVG, ColorOverlay will render it

                    anchors.centerIn: parent
                    readonly property real sizeMultiplier: isCurrent ? 0.65 : 0.6
                    width: parent.width * sizeMultiplier
                    height: parent.height * sizeMultiplier
                }
                ColorOverlay {
                    anchors.fill: iconImage // Fill the space of the iconImage
                    source: iconImage
                    color: isCompletedOrCurrent ? appStorage.themeBackgroundColor : appStorage.selectedTextColor
                }
            }
        }
    }

    function getIconSource(step) {
        return "../icon/settings/step-" + step + ".svg"
    }

    property real circleSize: 32
}
