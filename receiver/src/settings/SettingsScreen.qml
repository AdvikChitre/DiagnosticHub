import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import './item' as Items
import './item/colours' as Items // Note: You have duplicate import aliases
import './item/notifications' as Items
import "../"

Item {
    id: root
    anchors.fill: parent

    // --- Properties ---
    property int currentStep: 1

    // --- Translation Setup ---
    property var translations: {
        "en_US": { "language": "Language", "theme": "Theme", "alerts": "Alerts", "wifi": "Wi-Fi", "newDevice": "New Device", "welcomeVideo": "Welcome Video", "reset": "Reset", "changeWifi": "Tap to change Wi-Fi", "addNewDevice": "Tap to add new device", "rewatchVideo": "Tap to rewatch welcome video", "resetSettings": "Tap to reset all settings", "confirmResetTitle": "Confirm Reset", "confirmResetText": "Are you sure you want to reset all settings to their defaults?", "cancel": "Cancel", "back": "Back", "next": "Next", "finish": "Finish" },
        "es_ES": { "language": "Idioma", "theme": "Tema", "alerts": "Alertas", "wifi": "Wi-Fi", "newDevice": "Nuevo Dispositivo", "welcomeVideo": "Ver Vídeo", "reset": "Reiniciar", "changeWifi": "Toca para cambiar Wi-Fi", "addNewDevice": "Toca para añadir nuevo dispositivo", "rewatchVideo": "Toca para ver el vídeo de bienvenida", "resetSettings": "Toca para reiniciar los ajustes", "confirmResetTitle": "Confirmar Reinicio", "confirmResetText": "¿Estás seguro de que quieres reiniciar todos los ajustes a sus valores predeterminados?", "cancel": "Cancelar", "back": "Atrás", "next": "Siguiente", "finish": "Finalizar" },
        "fr_FR": { "language": "Langue", "theme": "Thème", "alerts": "Alertes", "wifi": "Wi-Fi", "newDevice": "Nouvel Appareil", "welcomeVideo": "Voir la Vidéo", "reset": "Réinitialiser", "changeWifi": "Touchez pour changer le Wi-Fi", "addNewDevice": "Touchez pour ajouter un appareil", "rewatchVideo": "Touchez pour revoir la vidéo", "resetSettings": "Touchez pour réinitialiser les paramètres", "confirmResetTitle": "Confirmer la Réinitialisation", "confirmResetText": "Êtes-vous sûr de vouloir réinitialiser tous les paramètres par défaut?", "cancel": "Annuler", "back": "Retour", "next": "Suivant", "finish": "Terminer" },
        "de_DE": { "language": "Sprache", "theme": "Thema", "alerts": "Alarme", "wifi": "WLAN", "newDevice": "Neues Gerät", "welcomeVideo": "Video Ansehen", "reset": "Zurücksetzen", "changeWifi": "Tippen, um WLAN zu ändern", "addNewDevice": "Tippen, um neues Gerät hinzuzufügen", "rewatchVideo": "Tippen, um das Video erneut anzusehen", "resetSettings": "Tippen, um alle Einstellungen zurückzusetzen", "confirmResetTitle": "Zurücksetzen Bestätigen", "confirmResetText": "Sind Sie sicher, dass Sie alle Einstellungen auf die Standardwerte zurücksetzen möchten?", "cancel": "Abbrechen", "back": "Zurück", "next": "Weiter", "finish": "Fertig" }
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

    // --- Steps now use translation keys ---
    property var steps: [
        { key: "language" }, { key: "theme" }, { key: "alerts" }, { key: "wifi" },
        { key: "newDevice" }, { key: "welcomeVideo" }, { key: "reset" }
    ]

    signal settingsUpdated()
    signal settingsCancelled()

    // --- Progress bar now gets translated labels ---
    SettingsProgressBar {
        id: progressBar
        totalSteps: root.steps.length
        // stepLabels: root.steps.map(step => root.getText(step.key))
        currentStep: root.currentStep
        anchors { top: parent.top; topMargin: 20; horizontalCenter: parent.horizontalCenter }
    }

    // --- Content Area ---
    StackLayout {
        id: settingsContent
        currentIndex: currentStep - 1
        anchors { top: progressBar.bottom; left: parent.left; right: parent.right; bottom: navButtons.top; margins: 30; topMargin: 50 }

        Items.Language { id: languageSelection }
        Items.Colours {}
        Items.Notifications {}

        // Wifi
        Item {
            Column {
                id: wifiContent
                spacing: 10
                anchors.centerIn: parent
                Text {
                    text: root.getText("changeWifi")
                    color: appStorage.selectedTextColor
                    font.pixelSize: 32
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item {
                    id: wifiIconContainer
                    width: 160
                    height: 160
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: wifiIcon
                        source: "../icon/wifi-connection.svg"
                        anchors.fill: parent // Fill the wifiIconContainer
                        visible: false // Keep original image hidden for tinting
                    }
                    ColorOverlay {
                        anchors.fill: parent // Fill the wifiIconContainer (which is same as wifiIcon)
                        source: wifiIcon     // Source is still the hidden Image
                        color: appStorage.selectedTextColor
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: stackLoader.item.push(wifiScreen)
            }
        }

        // New Wearable
        Item {
            Column {
                id: newDeviceContent
                spacing: 10
                anchors.centerIn: parent
                Text {
                    text: root.getText("addNewDevice")
                    color: appStorage.selectedTextColor
                    font.pixelSize: 32
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item {
                    id: newDeviceIconContainer
                    width: 160
                    height: 160
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image {
                        id: newDeviceIcon
                        source: "../icon/wearable-connection.svg"
                        anchors.fill: parent
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: parent
                        source: newDeviceIcon
                        color: appStorage.selectedTextColor
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: stackLoader.item.push(activationScreen)
            }
        }

        // Rewatch welcome video
        Item { // Container for the clickable area
            Column {
                id: rewatchContent
                spacing: 10 // Spacing between Text and the icon container
                anchors.centerIn: parent // Center this column of content

                Text {
                    text: root.getText("rewatchVideo")
                    color: appStorage.selectedTextColor
                    font.pixelSize: 32
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // --- Container for the Image and its ColorOverlay ---
                Item {
                    id: rewatchIconContainer
                    width: 160  // Explicit size for the icon area
                    height: 160 // Explicit size for the icon area
                    anchors.horizontalCenter: parent.horizontalCenter // Center this container in the Column

                    Image {
                        id: rewatchIcon
                        source: "../icon/settings/step-6.svg" // Ensure this path is correct
                        anchors.fill: parent // Fill the rewatchIconContainer
                        visible: false // Keep original image hidden for tinting
                    }
                    ColorOverlay {
                        anchors.fill: parent // Fill the rewatchIconContainer
                        source: rewatchIcon  // Source is still the hidden Image
                        color: appStorage.selectedTextColor
                    }
                }
                // --- End of icon container ---
            }
            MouseArea {
                anchors.fill: parent // Fills the outer Item, making the whole section clickable
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (typeof stackLoader !== 'undefined' && stackLoader.item) stackLoader.item.push(videoScreen); }
            }
        }

        // Reset to default settings
        Item { // Container for the clickable area
            Dialog {
                id: resetConfirmation
                modal: true; anchors.centerIn: parent // This will center in the Item, which is fine
                title: root.getText("confirmResetTitle")
                standardButtons: Dialog.No | Dialog.Yes
                onAccepted: root.resetSettings()
                background: Rectangle { color: appStorage.themeBackgroundColor; border.color: appStorage.selectedBorderColor; border.width: 1; radius: 10 }
                contentItem: Text { text: root.getText("confirmResetText"); color: appStorage.selectedTextColor; font.pixelSize: 24; wrapMode: Text.WordWrap }
            }
            Column {
                id: resetContent
                spacing: 10 // Spacing between Text and the icon container
                anchors.centerIn: parent // Center this column of content

                Text {
                    text: root.getText("resetSettings")
                    color: appStorage.selectedTextColor
                    font.pixelSize: 32
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // --- Container for the Image and its ColorOverlay ---
                Item {
                    id: resetIconContainer
                    width: 160  // Explicit size for the icon area
                    height: 160 // Explicit size for the icon area
                    anchors.horizontalCenter: parent.horizontalCenter // Center this container in the Column

                    Image {
                        id: resetIcon
                        source: "../icon/settings/step-7.svg" // Ensure this path is correct
                        anchors.fill: parent // Fill the resetIconContainer
                        visible: false // Keep original image hidden for tinting
                    }
                    ColorOverlay {
                        anchors.fill: parent // Fill the resetIconContainer
                        source: resetIcon    // Source is still the hidden Image
                        color: appStorage.selectedTextColor
                    }
                }
                // --- End of icon container ---
            }
            MouseArea {
                anchors.fill: parent // Fills the outer Item, making the whole section clickable
                cursorShape: Qt.PointingHandCursor
                onClicked: resetConfirmation.open()
            }
        }
    }

    // --- Themed Navigation Buttons ---
    Row {
        id: navButtons
        spacing: 20; anchors { bottom: parent.bottom; bottomMargin: 30; horizontalCenter: parent.horizontalCenter }

        Button { // Left button (Cancel/Back)
            width: 175; height: 88; font.pixelSize: 24
            text: root.getText(currentStep === 1 ? "cancel" : "back")
            onClicked: {
                if (currentStep === 1) root.settingsCancelled()
                else currentStep = Math.max(1, currentStep - 1)
            }
            background: Rectangle {
                radius: 20
                color: parent.down ? Qt.darker(appStorage.themeBackgroundColor, 1.3) : Qt.lighter(appStorage.themeBackgroundColor, 1.2)
                border.color: appStorage.selectedBorderColor
                border.width: 1
            }
            contentItem: Text { text: parent.text; color: appStorage.selectedTextColor; font: parent.font; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
        }
        Button { // Right button (Next/Finish)
            width: 175; height: 88; font.pixelSize: 24
            text: root.getText(currentStep === root.steps.length ? "finish" : "next")
            onClicked: {
                if (currentStep === root.steps.length) root.settingsUpdated()
                else currentStep = Math.min(root.steps.length, currentStep + 1)
            }
            background: Rectangle {
                radius: 20
                color: parent.down ? Qt.darker(appStorage.selectedBorderColor) : appStorage.selectedBorderColor
            }
            contentItem: Text { text: parent.text; color: "#ffffff"; font: parent.font; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
        }
    }

    Behavior on currentStep {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
}
