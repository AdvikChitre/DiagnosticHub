import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects // Using Qt5Compat as per your original import

Button {
    id: settingsButton

    // Customizable properties
    property real touchSize: 80

    // Assuming appStorage is globally accessible.
    // If not, define color properties here and pass them in when using SettingsButton:
    // property color iconColor: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
    // property color buttonBackgroundColor: "transparent" // Default, could be appStorage.themeBackgroundColor
    // property color buttonPressedColor: typeof appStorage !== 'undefined' ? Qt.darker(appStorage.themeBackgroundColor, 1.2) : Qt.darker("#f0f0f0", 1.1)

    // Visual properties
    implicitWidth: touchSize
    implicitHeight: touchSize
    opacity: enabled ? 1 : 0.5

    // Touch feedback states
    states: [
        State {
            name: "PRESSED"
            when: settingsButton.down
            PropertyChanges {
                target: background
                // Use a slightly darker version of the theme's background or a specific pressed color
                color: typeof appStorage !== 'undefined' ? Qt.darker(appStorage.themeBackgroundColor, 1.2) : Qt.darker("#f0f0f0", 1.1)
                // If you want a more distinct pressed color, you could use a subtle accent:
                // color: typeof appStorage !== 'undefined' ? Qt.rgba(appStorage.selectedBorderColor.r, appStorage.selectedBorderColor.g, appStorage.selectedBorderColor.b, 0.2) : Qt.darker("#f0f0f0", 1.1)
            }
        }
    ]

    // Background with touch feedback
    background: Rectangle {
        id: background
        // Button background can be transparent or match the theme background
        color: "transparent" // Or: typeof appStorage !== 'undefined' ? appStorage.themeBackgroundColor : "transparent"
        radius: touchSize / 2 // Make it a circle if touchSize is for diameter
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // Icon
    contentItem: Item { // Use an Item as contentItem to properly contain Image and ColorOverlay
        id: iconContainer
        anchors.fill: parent

        Image {
            id: settingsIcon
            source: "../icon/settings.svg" // Ensure this path is correct
            // Maintain aspect ratio within a slightly smaller area than the button for padding
            width: parent.width * 0.6
            height: parent.height * 0.6
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            // layer.enabled and layer.smooth are more relevant for complex rendering/shaders,
            // might not be strictly necessary for simple icon tinting but generally harmless.
            layer.enabled: true
            layer.smooth: true
            visible: false // Hide original SVG, ColorOverlay will render it
        }

        ColorOverlay {
            anchors.fill: settingsIcon // Overlay the (now invisible) Image
            source: settingsIcon      // Use the Image as the source texture
            // Use the theme's text color for the icon
            color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "#000000"
        }
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
        target: settingsButton
        duration: 100
    }

    // Accessibility
    Accessible.name: "Settings button"
    Accessible.role: Accessible.Button
}
