import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Button {
    id: backButton

    // Customizable properties
    property real touchSize: 80

    // Visual properties
    implicitWidth: touchSize
    implicitHeight: touchSize
    opacity: enabled ? 1 : 0.5

    // Touch feedback states
    states: [
        State {
            name: "PRESSED"
            when: backButton.down
            PropertyChanges {
                target: background
                color: Qt.darker("#f0f0f0", 1.1)
            }
        }
    ]

    // Background with touch feedback
    background: Rectangle {
        id: background
        color: "transparent"
        radius: touchSize
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // Icon
    contentItem: Image {
        id: backIcon
        source: "../icon/back.svg"
        sourceSize: Qt.size(touchSize * 0.6, touchSize * 0.6)
        anchors.centerIn: parent
        layer.enabled: true
        layer.smooth: true
    }

    ColorOverlay {
        anchors.fill: backIcon
        source: backIcon
        color: "#000000"
    }

    // Touch handling
    onPressed: {
        scaleAnim.from = 1.0
        scaleAnim.to = 0.9
        scaleAnim.start()
    }

    onReleased: {
        scaleAnim.from = 0.9
        scaleAnim.to = 1.0
        scaleAnim.start()
    }

    // Scale animation for touch feedback
    ScaleAnimator {
        id: scaleAnim
        target: backButton
        duration: 100
    }

    onClicked: {
        screenStack.pop()
    }

    // Accessibility
    Accessible.name: "Back button"
    Accessible.role: Accessible.Button
}
