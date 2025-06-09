import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "../common"

Item {
    id: homeScreenRoot
    signal settings()

    MouseArea {
        anchors.fill: parent
        onPressed: {
            // Reset the hint timer whenever there's a click on the background.
            settingsTapHint.reset();
        }
    }

    property var translations: {
        "en_US": { "settingsHint": "Tap to Customise", "allConnected": "Collecting data", "wearableDisconnected": "Wearable Disconnected" },
        "es_ES": { "settingsHint": "Toca para personalizar", "allConnected": "Recopilando datos", "wearableDisconnected": "Dispositivo Desconectado" },
        "fr_FR": { "settingsHint": "Touchez pour personnaliser", "allConnected": "Collecte de données", "wearableDisconnected": "Appareil Déconnecté" },
        "de_DE": { "settingsHint": "Tippen, um anzupassen", "allConnected": "Daten werden erfasst", "wearableDisconnected": "Gerät Getrennt" }
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

    property bool _internalAllDevicesConnected: true
    readonly property bool allDevicesConnected: _internalAllDevicesConnected
    readonly property bool hasSelectedDevices: typeof appStorage !== 'undefined' && appStorage.selectedDevices && appStorage.selectedDevices.length > 0

    function checkDeviceConnectivity() {
        if (typeof appStorage === 'undefined' || !appStorage.selectedDevices || !appStorage.connectedDevices) {
            if (homeScreenRoot.hasSelectedDevices) {
                 _internalAllDevicesConnected = false;
            } else {
                _internalAllDevicesConnected = true;
            }
            return;
        }

        if (appStorage.selectedDevices.length === 0) {
            _internalAllDevicesConnected = true;
            return;
        }

        var allFound = true;
        for (var i = 0; i < appStorage.selectedDevices.length; i++) {
            var selectedDeviceAddress = appStorage.selectedDevices[i];
            var foundInConnected = false;
            for (var j = 0; j < appStorage.connectedDevices.length; j++) {
                if (appStorage.connectedDevices[j] === selectedDeviceAddress) {
                    foundInConnected = true;
                    break;
                }
            }
            if (!foundInConnected) {
                allFound = false;
                break;
            }
        }

        if (_internalAllDevicesConnected && !allFound) {
            console.log("NOTIFICATION: A selected wearable has disconnected!");
            if (typeof notificationManager !== 'undefined') {
                notificationManager.doNotification();
            } else {
                console.warn("notificationManager is not available to call doNotification()");
            }
        }
        _internalAllDevicesConnected = allFound;
    }

    Connections {
        target: typeof appStorage !== 'undefined' ? appStorage : null
        function onSelectedDevicesChanged() {
            console.log("HomeScreen: appStorage.selectedDevices changed to:", JSON.stringify(appStorage.selectedDevices));
            homeScreenRoot.checkDeviceConnectivity();
        }
        function onConnectedDevicesChanged() {
            console.log("HomeScreen: appStorage.connectedDevices changed to:", JSON.stringify(appStorage.connectedDevices));
            homeScreenRoot.checkDeviceConnectivity();
        }
    }

    Component.onCompleted: {
        homeScreenRoot.checkDeviceConnectivity();
    }

    ColumnLayout {
        id: statusDisplay
        anchors.centerIn: parent
        spacing: 20
        visible: homeScreenRoot.hasSelectedDevices

        Item {
            id: statusIconContainer
            width: 300
            height: 300
            Layout.alignment: Qt.AlignHCenter

            Image {
                id: tickIconSource
                source: "../icon/tick.svg"
                anchors.fill: parent
                visible: false
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: tickIconSource
                source: tickIconSource
                color: typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "green"
                visible: homeScreenRoot.allDevicesConnected
            }

            Image {
                id: disconnectedIconSource
                source: "../icon/wearable-connection.svg"
                anchors.fill: parent
                visible: false
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: disconnectedIconSource
                source: disconnectedIconSource
                color: typeof appStorage !== 'undefined' ? (appStorage.warningColor || "red") : "red"
                visible: !homeScreenRoot.allDevicesConnected
            }
        }

        Text {
            text: homeScreenRoot.allDevicesConnected ? homeScreenRoot.getText("allConnected") : homeScreenRoot.getText("wearableDisconnected")
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 28
            font.bold: true
            color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
            visible: homeScreenRoot.hasSelectedDevices
        }
    }

    SettingsButton {
        id: settingsButtonInstance
        anchors {
            top: parent.top
            right: parent.right
            margins: 20
        }
        onClicked: homeScreenRoot.settings()
    }

    TapHint {
        id: settingsTapHint
        anchors.top: settingsButtonInstance.bottom
        anchors.topMargin: 0
        anchors.right: settingsButtonInstance.right
        anchors.rightMargin: (settingsButtonInstance.width - width) / 2
        text: homeScreenRoot.getText("settingsHint")
    }
}
