import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import './item' as Items
import './item/colours' as Items
import './item/notifications' as Items
import "../"

Item {
    id: root
    anchors.fill: parent

    property int currentStep: 1

    property var translations: {
        "en_US": { "language": "Language", "theme": "Theme", "alerts": "Alerts", "wifi": "Wi-Fi", "newDevice": "New Device", "welcomeVideo": "Welcome Video", "reset": "Reset", "changeWifi": "Tap to change Wi-Fi", "addNewDevice": "Tap to add new device", "rewatchVideo": "Tap to rewatch welcome video", "resetSettings": "Tap to reset all settings", "confirmResetTitle": "Confirm Reset", "confirmResetText": "Are you sure you want to reset all settings to their defaults?", "cancel": "Cancel", "back": "Back", "next": "Next", "finish": "Finish" },
        "es_ES": { "language": "Idioma", "theme": "Tema", "alerts": "Alertas", "wifi": "Wi-Fi", "newDevice": "Nuevo Dispositivo", "welcomeVideo": "Ver Vídeo", "reset": "Reiniciar", "changeWifi": "Toca para cambiar Wi-Fi", "addNewDevice": "Toca para añadir nuevo dispositivo", "rewatchVideo": "Toca para ver el vídeo de bienvenida", "resetSettings": "Toca para reiniciar los ajustes", "confirmResetTitle": "Confirmar Reinicio", "confirmResetText": "¿Estás seguro de que quieres reiniciar todos los ajustes a sus valores predeterminados?", "cancel": "Cancelar", "back": "Atrás", "next": "Siguiente", "finish": "Finalizar" },
        "fr_FR": { "language": "Langue", "theme": "Thème", "alerts": "Alertes", "wifi": "Wi-Fi", "newDevice": "Nouvel Appareil", "welcomeVideo": "Voir la Vidéo", "reset": "Réinitialiser", "changeWifi": "Touchez pour changer le Wi-Fi", "addNewDevice": "Touchez pour ajouter un appareil", "rewatchVideo": "Touchez pour revoir la vidéo", "resetSettings": "Touchez pour réinitialiser les paramètres", "confirmResetTitle": "Confirmer la Réinitialisation", "confirmResetText": "Êtes-vous sûr de vouloir réinitialiser tous les paramètres par défaut?", "cancel": "Annuler", "back": "Retour", "next": "Suivant", "finish": "Terminer" },
        "de_DE": { "language": "Sprache", "theme": "Thema", "alerts": "Alarme", "wifi": "WLAN", "newDevice": "Neues Gerät", "welcomeVideo": "Video Ansehen", "reset": "Zurücksetzen", "changeWifi": "Tippen, um WLAN zu ändern", "addNewDevice": "Tippen, um neues Gerät hinzuzufügen", "rewatchVideo": "Tippen, um das Video erneut anzusehen", "resetSettings": "Tippen, um alle Einstellungen zurückzusetzen", "confirmResetTitle": "Zurücksetzen Bestätigen", "confirmResetText": "Sind Sie sicher, dass Sie alle Einstellungen auf die Standardwerte zurücksetzen möchten?", "cancel": "Abbrechen", "back": "Zurück", "next": "Weiter", "finish": "Fertig" }
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
        return key;
    }

    property var steps: [
        { key: "language" }, { key: "theme" }, { key: "alerts" }, { key: "wifi" },
        { key: "newDevice" }, { key: "welcomeVideo" }, { key: "reset" }
    ]

    signal settingsUpdated()
    signal settingsCancelled()

    SettingsProgressBar {
        id: progressBar
        totalSteps: root.steps.length
        // stepLabels: root.steps.map(step => root.getText(step.key))
        currentStep: root.currentStep
        anchors { top: parent.top; topMargin: 20; horizontalCenter: parent.horizontalCenter }
    }

    StackLayout {
        id: settingsContent
        currentIndex: currentStep - 1
        anchors { top: progressBar.bottom; left: parent.left; right: parent.right; bottom: navButtons.top; margins: 30; topMargin: 50 }

        Items.Language { id: languageSelection }
        Items.Colours {}
        Items.Notifications {}

        Item {
            Column {
                id: wifiContent
                spacing: 10
                anchors.centerIn: parent
                Text { text: root.getText("changeWifi"); color: appStorage.selectedTextColor; font.pixelSize: 32; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Item {
                    id: wifiIconContainer
                    width: 160; height: 160
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image { id: wifiIcon; source: "../icon/wifi-connection.svg"; anchors.fill: parent; visible: false; }
                    ColorOverlay { anchors.fill: wifiIcon; source: wifiIcon; color: appStorage.selectedTextColor }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (typeof stackLoader !== 'undefined' && stackLoader.item) stackLoader.item.push(wifiScreen); }
            }
        }

        Item {
            Column {
                id: newDeviceContent
                spacing: 10
                anchors.centerIn: parent
                Text { text: root.getText("addNewDevice"); color: appStorage.selectedTextColor; font.pixelSize: 32; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Item {
                    id: newDeviceIconContainer
                    width: 160; height: 160
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image { id: newDeviceIcon; source: "../icon/wearable-connection.svg"; anchors.fill: parent; visible: false; }
                    ColorOverlay { anchors.fill: newDeviceIcon; source: newDeviceIcon; color: appStorage.selectedTextColor }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (typeof stackLoader !== 'undefined' && stackLoader.item) stackLoader.item.push(activationScreen); }
            }
        }

        Item {
            Column {
                id: rewatchContent
                spacing: 10
                anchors.centerIn: parent
                Text { text: root.getText("rewatchVideo"); color: appStorage.selectedTextColor; font.pixelSize: 32; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Item {
                    id: rewatchIconContainer
                    width: 160; height: 160
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image { id: rewatchIcon; source: "../icon/settings/step-6.svg"; anchors.fill: parent; visible: false }
                    ColorOverlay { anchors.fill: rewatchIcon; source: rewatchIcon; color: appStorage.selectedTextColor }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (typeof stackLoader !== 'undefined' && stackLoader.item) stackLoader.item.push(videoScreen); }
            }
        }

        Item {
            Dialog {
                id: resetConfirmation
                modal: true; anchors.centerIn: parent
                title: root.getText("confirmResetTitle")
                standardButtons: Dialog.No | Dialog.Yes
                onAccepted: root.resetSettings()
                background: Rectangle { color: appStorage.themeBackgroundColor; border.color: appStorage.selectedBorderColor; border.width: 1; radius: 10 }
                contentItem: Text { text: root.getText("confirmResetText"); color: appStorage.selectedTextColor; font.pixelSize: 24; wrapMode: Text.WordWrap }
            }
            Column {
                id: resetContent
                spacing: 10
                anchors.centerIn: parent
                Text { text: root.getText("resetSettings"); color: appStorage.selectedTextColor; font.pixelSize: 32; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                Item {
                    id: resetIconContainer
                    width: 160; height: 160
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image { id: resetIcon; source: "../icon/settings/step-7.svg"; anchors.fill: parent; visible: false }
                    ColorOverlay { anchors.fill: resetIcon; source: resetIcon; color: appStorage.selectedTextColor }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: resetConfirmation.open()
            }
        }
    }

    Row {
        id: navButtons
        spacing: 20; anchors { bottom: parent.bottom; bottomMargin: 30; horizontalCenter: parent.horizontalCenter }

        Button {
            id: leftButton
            width: 175; height: 88
            Accessible.name: root.getText(currentStep === 1 ? "cancel" : "back")
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
            contentItem: Item {
                Image {
                    id: leftIconSource
                    source: currentStep === 1 ? "../icon/cancel.svg" : "../icon/arrow-left.svg"
                    width: parent.width * 0.4
                    height: parent.height * 0.4
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: leftIconSource
                    source: leftIconSource
                    color: appStorage.selectedTextColor
                }
            }
        }
        Button {
            id: rightButton
            width: 175; height: 88
            Accessible.name: root.getText(currentStep === root.steps.length ? "finish" : "next")
            onClicked: {
                if (currentStep === root.steps.length) root.settingsUpdated()
                else currentStep = Math.min(root.steps.length, currentStep + 1)
            }
            background: Rectangle {
                radius: 20
                color: parent.down ? Qt.darker(appStorage.selectedBorderColor) : appStorage.selectedBorderColor
            }
            contentItem: Item {
                Image {
                    id: rightIconSource
                    source: currentStep === root.steps.length ? "../icon/tick.svg" : "../icon/arrow-right.svg"
                    width: parent.width * 0.4
                    height: parent.height * 0.4
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: rightIconSource
                    source: rightIconSource
                    color: "white"
                }
            }
        }
    }

    Behavior on currentStep {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    function resetSettings() {
        if (typeof appStorage !== 'undefined' && typeof Constants !== 'undefined') {
            appStorage.selectedLanguage = "en_US";
            appStorage.selectedTheme = "light";
            appStorage.selectedTextColor = Constants.defaultPrimaryColor;
            appStorage.selectedBgColor = Constants.defaultSecondaryColor;
            appStorage.selectedBorderColor = Constants.defaultBackgroundColor;
            appStorage.themeBackgroundColor = Constants.defaultSecondaryColor;
            appStorage.notifyAudio = true;
            appStorage.notifyHaptic = true;
            appStorage.notifyFlash = true;
        }
    }
}
