import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "../common"

Item {
    id: homeScreenRoot
    signal settings()

    // --- Translation Setup ---
    property var translations: {
        "en_US": { "settingsHint": "Tap to Customise", "allConnected": "All Systems Go!", "wearableDisconnected": "Wearable Disconnected" },
        "es_ES": { "settingsHint": "Toca para personalizar", "allConnected": "¡Todo en Orden!", "wearableDisconnected": "Dispositivo Desconectado" },
        "fr_FR": { "settingsHint": "Touchez pour personnaliser", "allConnected": "Tout est Prêt !", "wearableDisconnected": "Appareil Déconnecté" },
        "de_DE": { "settingsHint": "Tippen, um anzupassen", "allConnected": "Alle Systeme Funktionieren!", "wearableDisconnected": "Gerät Getrennt" }
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

    // --- Connectivity State ---
    property bool _internalAllDevicesConnected: true // Internal tracking
    readonly property bool allDevicesConnected: _internalAllDevicesConnected
    readonly property bool hasSelectedDevices: typeof appStorage !== 'undefined' && appStorage.selectedDevices && appStorage.selectedDevices.length > 0

    function checkDeviceConnectivity() {
        if (typeof appStorage === 'undefined' || !appStorage.selectedDevices || !appStorage.connectedDevices) {
            // If appStorage or lists are not ready, assume connected or no devices to check
            if (homeScreenRoot.hasSelectedDevices) { // Only consider disconnected if devices were selected
                 // console.log("HomeScreen: appStorage not ready, assuming disconnected if devices were selected.");
                 // _internalAllDevicesConnected = false; // Or some other default state
            } else {
                _internalAllDevicesConnected = true;
            }
            return;
        }

        if (appStorage.selectedDevices.length === 0) {
            _internalAllDevicesConnected = true; // No devices selected, so all "selected" are connected
            return;
        }

        var allFound = true;
        for (var i = 0; i < appStorage.selectedDevices.length; i++) {
            var selectedDeviceAddress = appStorage.selectedDevices[i]; // Assuming these are unique identifiers like MAC addresses
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
            // Transitioned from all connected to some disconnected
            console.log("NOTIFICATION: A selected wearable has disconnected!");
            // Replace with your actual notification call:
            // if (typeof NotificationManager !== 'undefined') NotificationManager.showWearableDisconnectedAlert("A wearable has disconnected.");
        }
        _internalAllDevicesConnected = allFound;
    }

    Connections {
        target: appStorage
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
        homeScreenRoot.checkDeviceConnectivity(); // Initial check
    }

    // --- Central Status Display ---
    ColumnLayout {
        id: statusDisplay
        anchors.centerIn: parent
        spacing: 20
        visible: homeScreenRoot.hasSelectedDevices // Only show status icons if devices are selected

        Item { // Container for the status icon
            id: statusIconContainer
            width: 400
            height: 400
            Layout.alignment: Qt.AlignHCenter

            Image {
                id: tickIconSource
                source: "../icon/tick.svg"
                anchors.fill: parent
                visible: false // Hidden, ColorOverlay will render
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: tickIconSource
                source: tickIconSource
                color: typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "green" // Use accent color
                visible: homeScreenRoot.allDevicesConnected
            }

            Image {
                id: disconnectedIconSource
                source: "../icon/wearable-connection.svg"
                anchors.fill: parent
                visible: false // Hidden, ColorOverlay will render
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: disconnectedIconSource
                source: disconnectedIconSource
                color: "#EE2400"
                // Example: appStorage.warningColor or a specific shade of selectedTextColor
                visible: !homeScreenRoot.allDevicesConnected
            }
        }

        Text {
            text: homeScreenRoot.allDevicesConnected ? root.getText("allConnected") : root.getText("wearableDisconnected")
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 28
            font.bold: true
            color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
            visible: homeScreenRoot.hasSelectedDevices // Only show text if devices are selected
        }
    }

    // --- Existing Settings Button and Hint ---
    SettingsButton {
        id: settingsButtonInstance // Renamed to avoid conflict if SettingsButton.qml uses 'settingsButton' as id
        anchors {
            top: parent.top
            right: parent.right
            margins: 20
        }
        onClicked: homeScreenRoot.settings() // Ensure signal is emitted from homeScreenRoot
        // Assuming SettingsButton is already themed internally or accepts theme properties
    }

    TapHint {
        id: settingsTapHint // Renamed
        // Adjust x and y to be relative to the settingsButtonInstance or parent anchors
        anchors.top: settingsButtonInstance.bottom
        anchors.topMargin: 5
        anchors.right: settingsButtonInstance.right
        anchors.rightMargin: (settingsButtonInstance.width - width) / 2 // Center below button

        text: root.getText("settingsHint")
        // Assuming TapHint has a property to set its text color, or themes internally
        // textColor: appStorage.selectedTextColor // Example if TapHint has such a property
    }
}
