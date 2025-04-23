import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import './item' as Items

Item {
    id: settingsScreen
    anchors.fill: parent

    property int currentStep: 1
    property int totalSteps: 4
    property color circleColor: "#4CAF50"
    property color activeColor: "#2196F3"

    // Define your steps here (label + component)
    property var steps: [
        { label: "Language" },
        { label: "Theme" },
        { label: "Alerts" },
        { label: "Update" }
    ]

    signal settingsUpdated()
    signal settingsCancelled()

    // Progress bar with circles
    SettingsProgressBar {
        id: progressBar
        labels: steps.map(step => step.label)
        currentStep: settingsScreen.currentStep
        circleColor: settingsScreen.circleColor
        anchors {
            top: parent.top
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
    }

    // Content Area
    StackLayout {
        id: settingsContent
        anchors {
            top: progressBar.bottom
            left: parent.left
            right: parent.right
            bottom: navButtons.top
            margins: 30
            topMargin: 50
        }
        currentIndex: currentStep - 1

        // Step components remain the same
        Items.Language { id: languageSelection }
        Items.Colours {}
        Items.Notifications {}
        Column {
            spacing: 20
            Text { text: "Confirm Settings"; font.pixelSize: 24; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Review your settings and click Finish"; font.pixelSize: 16; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    // Modified Navigation Buttons
    Row {
        id: navButtons
        spacing: 20
        anchors {
            bottom: parent.bottom
            bottomMargin: 30
            horizontalCenter: parent.horizontalCenter
        }

        // Left button (Cancel/Back)
        Button {
            id: leftButton
            text: (currentStep === 1 || currentStep === totalSteps) ? "Cancel" : "Back"
            onClicked: {
                if (currentStep === 1 || currentStep === totalSteps) {
                    settingsScreen.settingsCancelled()
                } else {
                    currentStep = Math.max(1, currentStep - 1)
                }
            }
            visible: currentStep === 1 || currentStep > 1  // Always visible except when currentStep < 1

            background: Rectangle {
                radius: 20
                color: parent.down ? "#BDBDBD" : "#E0E0E0"
            }
        }

        // Right button (Next/Finish)
        Button {
            text: currentStep === totalSteps ? "Finish" : "Next"
            onClicked: {
                if (currentStep === totalSteps) {
                    settingsScreen.settingsUpdated()
                } else {
                    currentStep = Math.min(totalSteps, currentStep + 1)
                }
            }

            background: Rectangle {
                radius: 20
                color: parent.down ? activeColor : circleColor
            }

            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // Animation for step changes
    Behavior on currentStep {
        NumberAnimation {
            property: "currentStep"
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
}
