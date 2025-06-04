import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property alias text: hintText.text

    // Animation properties (can be adjusted)
    property int tapDistance: 20
    property int tapDuration: 700
    property int tapPause: 600

    // Assuming appStorage is a globally accessible ID or a QML singleton
    // If not, you'll need to pass appStorage or its color properties as properties to this component.
    // For example:
    // property color iconColor: typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "grey"
    // property color textColor: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "white"


    width: Math.max(fingerIcon.width, hintText.width) // Changed finger to fingerIcon
    height: fingerIcon.height + hintText.height + 20  // Changed finger to fingerIcon

    // Container for the finger icon and its ColorOverlay
    Item {
        id: fingerIcon // Renamed from 'finger' to avoid conflict if 'finger' is a keyword, and to be more descriptive
        height: 70
        width: 70
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0 // Initial y position for animation

        Image {
            id: fingerSourceImage // The actual SVG source, will be hidden
            source: "../icon/finger.svg"
            anchors.fill: parent
            visible: false // Hide the original image, ColorOverlay will render it
        }

        ColorOverlay {
            anchors.fill: fingerSourceImage
            source: fingerSourceImage
            // Use a theme color, e.g., the accent color or text color
            // Depending on the background this component will be on, you might choose
            // appStorage.selectedTextColor or appStorage.selectedBorderColor (accent)
            color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "grey"
        }

        SequentialAnimation on y {
            running: true
            loops: Animation.Infinite

            // Tap down animation
            NumberAnimation {
                to: tapDistance
                duration: tapDuration
                easing.type: Easing.OutQuad
            }

            // Return animation
            NumberAnimation {
                to: 0
                duration: tapDuration
                easing.type: Easing.InQuad
            }

            // Pause between taps
            PauseAnimation { duration: tapPause }
        }
    }

    Text {
        id: hintText
        anchors {
            top: fingerIcon.bottom // Anchor to the fingerIcon Item
            topMargin: 15
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        // Bind text color to the theme's selected text color
        color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "#ffffff"
        font.pixelSize: 14
        // Ensure hintText width doesn't exceed its container or a reasonable maximum
        width: Math.min(implicitWidth, root.width) // Use root.width as a practical limit
    }
}
