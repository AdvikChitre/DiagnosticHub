import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: root
    spacing: 20
    width: parent.width

    // --- Translation Setup ---
    property var translations: {
        "en_US": { "title": "Notifications", "flash": "Flashing Light", "sound": "Sound Alert", "haptic": "Vibration Alert" },
        "es_ES": { "title": "Notificaciones", "flash": "Luz Intermitente", "sound": "Alerta Sonora", "haptic": "Alerta Vibratoria" },
        "fr_FR": { "title": "Notifications", "flash": "Lumière Clignotante", "sound": "Alerte Sonore", "haptic": "Alerte Vibrante" },
        "de_DE": { "title": "Benachrichtigungen", "flash": "Blinklicht", "sound": "Ton-Alarm", "haptic": "Vibrationsalarm" }
    }
    function getText(key) {
        var lang = appStorage.selectedLanguage;
        if (translations.hasOwnProperty(lang) && translations[lang].hasOwnProperty(key)) {
            return translations[lang][key];
        }
        if (translations["en_US"] && translations["en_US"].hasOwnProperty(key)) {
           return translations["en_US"][key];
        }
        return key;
    }


    Text {
        // Use translation function and theme text color
        text: root.getText("title")
        color: appStorage.selectedTextColor
        font.pixelSize: 32
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    GridLayout {
        columns: 2
        rowSpacing: 25
        columnSpacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.fillWidth: true

        // Flash
        Text {
            text: root.getText("flash")
            color: appStorage.selectedTextColor // Use theme text color
            font.pixelSize: 24
            Layout.alignment: Qt.AlignLeft
        }
        RoundedSwitch {
            checked: appStorage.notifyFlash
            onCheckedChanged: appStorage.notifyFlash = checked
            Layout.alignment: Qt.AlignRight

            // Assuming your RoundedSwitch has properties for theming.
            // You would bind them to your theme colors like this:
            // activeColor: appStorage.selectedBorderColor
            // inactiveColor: Qt.rgba(appStorage.selectedTextColor.r, appStorage.selectedTextColor.g, appStorage.selectedTextColor.b, 0.3)
            // handleColor: appStorage.themeBackgroundColor
        }

        // Sound
        Text {
            text: root.getText("sound")
            color: appStorage.selectedTextColor // Use theme text color
            font.pixelSize: 24
            Layout.alignment: Qt.AlignLeft
        }
        RoundedSwitch {
            checked: appStorage.notifyAudio
            onCheckedChanged: appStorage.notifyAudio = checked
            Layout.alignment: Qt.AlignRight

            // Example of how to theme the switch
            // activeColor: appStorage.selectedBorderColor
        }

        // Vibration
        Text {
            text: root.getText("haptic")
            color: appStorage.selectedTextColor // Use theme text color
            font.pixelSize: 24
            Layout.alignment: Qt.AlignLeft
        }
        RoundedSwitch {
            checked: appStorage.notifyHaptic
            onCheckedChanged: appStorage.notifyHaptic = checked
            Layout.alignment: Qt.AlignRight

            // Example of how to theme the switch
            // activeColor: appStorage.selectedBorderColor
        }
    }
}
