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
                target: backgroundRectangle // Changed target to backgroundRectangle
                // Use a slightly darker version of the theme's main background for pressed state
                color: typeof appStorage !== 'undefined' ? Qt.darker(appStorage.themeBackgroundColor, 1.2) : Qt.darker("#f0f0f0", 1.1)
            }
        }
    ]

    background: Rectangle {
        id: backgroundRectangle // Gave an id to target in states
        // Set to transparent so it blends with whatever is behind it, or use themeBackgroundColor
        color: "transparent"
        // Or, if you want it to have the page's background color:
        // color: typeof appStorage !== 'undefined' ? appStorage.themeBackgroundColor : "transparent"
        radius: touchSize / 2 // Make it circular
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Item {
        id: iconContainer
        anchors.fill: parent // Fill the button's content area

        Image {
            id: backIconSource // Renamed for clarity, this is the source for the overlay
            source: "../icon/back.svg" // Ensure this path is correct

            // Size the icon relative to the button's touchSize, providing some padding
            width: parent.width * 0.5  // e.g., 50% of the button's content area width
            height: parent.height * 0.5 // e.g., 50% of the button's content area height
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            visible: false // Hide the original SVG, ColorOverlay will render it
        }

        ColorOverlay {
            anchors.fill: backIconSource // Make the overlay the same size and position as the (now invisible) Image
            source: backIconSource      // Use the Image as the source texture
            // Bind to the theme's text color, or an accent color if preferred for icons
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
        target: backButton // Apply scale to the whole button
        duration: 100
    }

    onClicked: {
        // Assuming stackLoader is globally accessible from Main.qml
        if (typeof stackLoader !== 'undefined' && stackLoader.item && typeof stackLoader.item.pop === 'function') {
            stackLoader.item.pop()
        } else {
            console.warn("BackButton: stackLoader.item is not available or does not have a pop method.")
        }
    }

    // Accessibility
    Accessible.name: "Back button"
    Accessible.role: Accessible.Button
}
