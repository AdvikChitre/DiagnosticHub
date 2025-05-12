import QtQuick
import QtQuick.Controls
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings

Column {
    spacing: 20

    Text {
        text: "Select Language"
        font.pixelSize: 32
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Component.onCompleted: {
        console.log(VirtualKeyboardSettings.activeLocales)
        console.log(VirtualKeyboardSettings.availableLocales)
    }

    Repeater {
        model: [
            { name: "en_US", label: "English (US)" },
            { name: "es_ES", label: "Español (ES)" },
            { name: "fr_FR", label: "Français (FR)" },
            { name: "de_DE", label: "Deutsch (DE)" }
        ]

        RadioButton {
            text: modelData.label
            font.pixelSize: 24
            checked: appStorage.selectedLanguage === modelData.name
            anchors.horizontalCenter: parent.horizontalCenter

            onCheckedChanged: {
                if (checked) {
                    // Update app settings
                    appStorage.selectedLanguage = modelData.name

                    // Update keyboard layout
                    VirtualKeyboardSettings.locale = modelData.name
                }
            }
        }
    }
}
