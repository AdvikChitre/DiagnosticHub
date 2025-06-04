import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects // Or QtGraphicalEffects if using Qt 6

Item {
    id: root
    signal completed()

    property real progress: 0.0
    // Removed: property color circleColor: "#ffffff" // Will use theme color
    property bool animationRunning: false

    // --- Translation Setup ---
    // Assuming appStorage is globally accessible for selectedLanguage
    // If this component is always used where 'root' from SettingsScreen.qml is available,
    // you could potentially use that. For self-containment:
    property var translations: {
        "en_US": {
            "tapToContinue": "Tap to Continue",
            "introStep1": "You have been given a device to record some data",
            "introStep2": "That device can't do everything on its own, \nso I'm here to help it!",
            "introStep3": "Keep me close by when you use your device"
        },
        "es_ES": {
            "tapToContinue": "Toca para Continuar",
            "introStep1": "Se te ha dado un dispositivo para registrar algunos datos",
            "introStep2": "Ese dispositivo no puede hacerlo todo solo, \n¡así que estoy aquí para ayudarlo!",
            "introStep3": "Mantenme cerca cuando uses tu dispositivo"
        },
        "fr_FR": {
            "tapToContinue": "Touchez pour Continuer",
            "introStep1": "Un appareil vous a été remis pour enregistrer des données",
            "introStep2": "Cet appareil ne peut pas tout faire seul, \n_LINK_ alors je suis là pour l'aider !",
            "introStep3": "Gardez-moi à proximité lorsque vous utilisez votre appareil"
        },
        "de_DE": {
            "tapToContinue": "Tippen zum Fortfahren",
            "introStep1": "Sie haben ein Gerät erhalten, um einige Daten aufzuzeichnen",
            "introStep2": "Dieses Gerät kann nicht alles alleine, \nalso bin ich hier, um ihm zu helfen!",
            "introStep3": "Halten Sie mich in Ihrer Nähe, wenn Sie Ihr Gerät verwenden"
        }
    }
    function getText(key) {
        if (typeof appStorage !== 'undefined' && appStorage.selectedLanguage) {
            var lang = appStorage.selectedLanguage;
            if (translations.hasOwnProperty(lang) && translations[lang].hasOwnProperty(key)) {
                return translations[lang][key];
            }
        }
        if (translations["en_US"] && translations["en_US"].hasOwnProperty(key)) {
           return translations["en_US"][key];
        }
        return key; // Fallback to key
    }


    // Title at top
    Text {
        id: title
        text: root.getText("tapToContinue")
        color: appStorage.selectedTextColor // Theme color
        font.pixelSize: 32
        anchors.horizontalCenter: parent.horizontalCenter
        y: progress >= 1 ? 40 : (parent.height - height) / 2
        font.bold: true

        Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
    }

    Rectangle {
        id: introRect
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: title.bottom
            topMargin: 20
        }
        width: parent.width * 0.8
        height: 320
        radius: 10
        color: Qt.lighter(appStorage.themeBackgroundColor, 1.1) // Slightly lighter than main background
        border.color: appStorage.selectedBorderColor // Use accent for border
        border.width: 1
        opacity: progress >= 1 ? 1 : 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InQuint } }

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            // Step 1: Progress 1-2
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: progress >= 1 && progress < 2

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20

                    Text {
                        text: root.getText("introStep1")
                        font.pixelSize: 24
                        topPadding: 10
                        color: appStorage.selectedTextColor // Theme color
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }

                    Item { // Container for wearable icon
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 160
                        Layout.alignment: Qt.AlignHCenter
                        Image { id: wearableIcon1; source: "../icon/wearable.svg"; anchors.fill: parent; visible: false; fillMode: Image.PreserveAspectFit }
                        ColorOverlay { anchors.fill: wearableIcon1; source: wearableIcon1; color: appStorage.selectedTextColor }
                    }
                }
            }

            // Step 2: Progress 2-3
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: progress >= 2 && progress < 3

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 20

                    Text {
                        text: root.getText("introStep2")
                        font.pixelSize: 24
                        topPadding: 10
                        color: appStorage.selectedTextColor // Theme color
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        Item { // Container for wearable icon
                            Layout.preferredWidth: 100 // Adjusted size for two icons
                            Layout.preferredHeight: 100
                            Image { id: wearableIcon2; source: "../icon/wearable.svg"; anchors.fill: parent; visible: false; fillMode: Image.PreserveAspectFit }
                            ColorOverlay { anchors.fill: wearableIcon2; source: wearableIcon2; color: appStorage.selectedTextColor }
                        }

                        Item { // Container for receiver icon
                            Layout.preferredWidth: 100 // Adjusted size for two icons
                            Layout.preferredHeight: 100
                            Image { id: receiverIcon; source: "../icon/receiver.svg"; anchors.fill: parent; visible: false; fillMode: Image.PreserveAspectFit }
                            ColorOverlay { anchors.fill: receiverIcon; source: receiverIcon; color: appStorage.selectedTextColor }
                        }
                    }
                }
            }

            // Step 3: Progress 3-4
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: progress >= 3 && progress < 4

                Text {
                    text: root.getText("introStep3")
                    font.pixelSize: 24
                    color: appStorage.selectedTextColor // Theme color
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                }
            }
        }
    }

    // Circle 'continue' button
    Item {
        id: circleContainer
        width: 100
        height: 100
        anchors {
            horizontalCenter: parent.horizontalCenter
            topMargin: 50 // This margin is applied when y is determined by title.bottom
        }
        y: progress >= 1 ? parent.height - height - 50 : title.y + title.height + 50

        Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }

        Rectangle {
            id: backgroundCircle
            anchors.centerIn: parent
            width: 80
            height: 80
            radius: width/2
            color: appStorage.selectedBorderColor // Use accent color for button background
            opacity: 0.9
            border.color: Qt.darker(appStorage.selectedBorderColor, 1.2) // Slightly darker border for definition
            border.width: 2
        }

        Item { // Container for the 'next' icon to manage its ColorOverlay
            id: circleIconContainer
            width: backgroundCircle.width * 0.5 // Icon size relative to circle
            height: backgroundCircle.height * 0.5
            anchors.centerIn: backgroundCircle

            Image {
                id: circleIconSource
                source: "../icon/next.svg"
                anchors.fill: parent
                visible: false
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay{
                anchors.fill: circleIconSource
                source: circleIconSource
                // Color to contrast with backgroundCircle's color (selectedBorderColor)
                // Often themeBackgroundColor (if light) or a specific contrasting icon color
                color: appStorage.themeBackgroundColor
            }
        }


        Canvas {
            id: progressCanvas
            anchors.fill: parent // Fill the circleContainer
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                // Use a contrasting color for the progress stroke, e.g., text color or a lighter/darker accent
                ctx.strokeStyle = Qt.lighter(appStorage.selectedBorderColor, 1.5)
                ctx.lineWidth = 4
                ctx.lineCap = "round"

                var centerX = width/2
                var centerY = height/2
                var radius = Math.min(width, height)/2 - ctx.lineWidth // Radius for the progress arc
                var startAngle = -Math.PI/2 // Start at 12 o'clock
                var endAngle = startAngle + (Math.PI * 2 * (progress/4)) // progress goes up to 4 for full circle

                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.stroke()
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.animationRunning && progress < 4.0
            onClicked: {
                var target = Math.min(progress + 1.0, 4.0)
                progressAnimator.from = progress
                progressAnimator.to = target
                progressAnimator.start()
            }
            onPressed: circleScaleAnimator.to = 0.9
            onReleased: circleScaleAnimator.to = 1.0
            onCanceled: circleScaleAnimator.to = 1.0
        }

        ScaleAnimator {
            id: circleScaleAnimator
            target: backgroundCircle // Scale the background circle, icon will move with it
            duration: 200
        }
    }

    NumberAnimation {
        id: progressAnimator
        target: root
        property: "progress"
        duration: 1000
        easing.type: Easing.InOutQuad
        onStarted: root.animationRunning = true
        onStopped: {
            root.animationRunning = false
            if(progress >= 4.0) {
                root.completed()
                resetTimer.start()
            }
        }
    }

    Timer {
        id: resetTimer
        interval: 1000
        onTriggered: {
            progressAnimator.from = 4.0
            progressAnimator.to = 0.0
            progressAnimator.start()
        }
    }

    onProgressChanged: progressCanvas.requestPaint()

    // Debugging component (optional)
    Text {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        text: `Progress: ${progress.toFixed(1)}`
        color: appStorage.selectedTextColor // Theme color for debug text
        font.pixelSize: 14
        visible: false // Set to true for debugging
    }
}
