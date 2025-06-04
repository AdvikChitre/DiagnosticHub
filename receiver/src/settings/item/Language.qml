import QtQuick
import QtQuick.Controls
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings

Column {
    spacing: 20

    property var translations: {
        "en_US": { "selectLanguage": "Select Language" },
        "es_ES": { "selectLanguage": "Seleccione el Idioma" },
        "fr_FR": { "selectLanguage": "Sélectionner la langue" },
        "de_DE": { "selectLanguage": "Sprache auswählen" }
    }

    Text {
        text: translations[appStorage.selectedLanguage] ? translations[appStorage.selectedLanguage].selectLanguage : translations["en_US"].selectLanguage
        color: appStorage.selectedTextColor
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
            { name: "en_US", label: "English" },
            { name: "es_ES", label: "Español" },
            { name: "fr_FR", label: "Français" },
            { name: "de_DE", label: "Deutsch" }
        ]

        RadioButton {
            id: radioBtn
            checked: appStorage.selectedLanguage === modelData.name
            anchors.horizontalCenter: parent.horizontalCenter

            onCheckedChanged: {
                if (checked) {
                    appStorage.selectedLanguage = modelData.name
                    VirtualKeyboardSettings.locale = modelData.name
                }
            }

            contentItem: Row {
                spacing: 10
                // Layout.alignment: Qt.AlignVCenter

                Text {
                    text: modelData.label
                    font.pixelSize: 24
                    // color: checked ? "black" : "gray"
                    color: checked ? appStorage.selectedTextColor : Qt.lighter(appStorage.selectedTextColor, 1.5)
                }

                Image {
                    source: "../../icon/flag/" + modelData.name + ".svg"
                    width: 26
                    height: 26
                    fillMode: Image.PreserveAspectFit
                }
            }

            // Maintain proper radio button layout
            indicator: Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                radius: 13
                x: parent.leftPadding - 30
                y: parent.height / 2 - height / 2
                border.color: checked ? "dodgerblue" : "gray"

                Rectangle {
                    width: 14
                    height: 14
                    x: 6
                    y: 6
                    radius: 7
                    color: checked ? "dodgerblue" : "transparent"
                }
            }
        }
    }
}
