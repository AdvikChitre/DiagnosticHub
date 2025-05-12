import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
// import Qt.labs.settings
import "./common"
import "./onboarding"
import "./setup"
import "./home"
import "./settings"
// import "./settings/item/settingsuiapp"
// import DeviceUtilities
// import DeviceUtilities.SettingsUI
import "./settings/item/wifi"
// import "./background/ble"
// import QtQml
import Network
// import QtOtaUpdate
// import "common/constants.qml"
import receiver

ApplicationWindow {
    id: mainWindow
    width: 1024
    height: 600
    visible: true
    title: qsTr("Hello World")
    // color: "#2adbde"
    color: "#ef476f"
    property bool storageReady: false

    // Persistent settings
    Settings {
        id: appStorage
        category: "AppConfig"
        property string baseUrl: "http://192.168.215.199:3000/"

        // Global device info
        property var availableDevices: []
        property bool onboardingCompleted: false

        // Current Session
        property var approvedDevices: [] // Approved by activation code
        property var selectedDevices: [] // Selected MAC address
        property string selectedLanguage: "en"
        property string selectedTheme: "light"
        property string selectedColor1: Constants.defaultPrimaryColor
        property string selectedColor2: Constants.defaultSecondaryColor
        property string selectedColor3: Constants.defaultBackgroundColor
        property bool notifyAudio: true
        property bool notifyHaptic: true
        property bool notifyFlash: true
    }

    // Manages HTTP requests
    NetworkManager {
        id: network
        // onResponseReceived: console.log("Response:", network.responseData)
        onResponseDataChanged: {
            console.log(appStorage.availableDevices)
            appStorage.availableDevices = JSON.parse(network.responseData)
            console.log(JSON.stringify(JSON.parse(network.responseData).wearables))
            console.log(appStorage.availableDevices)
            console.log(appStorage.availableDevices.wearables[0].manufacturer)
        }
        onErrorOccurred: console.error("Error:", network.error)
    }

    // On start
    Component.onCompleted: {
        // appStorage.selectedDevices = []
        // appStorage.approvedDevices = []
        storageReady = true
        // Display debug state info
        console.log("Available Devices:", appStorage.availableDevices)
        console.log("Selected Devices:", appStorage.selectedDevices)
        console.log("Request URL:", Constants.baseUrl+"api/wearables/config")
        network.get(Constants.baseUrl + "api/wearables/config")
    }


    Component {
        id: onboardingScreen
        OnboardingScreen {
            onCompleted: {
                console.log(appStorage.onboardingCompleted)
                stackLoader.item.push(wifiScreen)
            }
        }
    }

    Component {
        id: wifiScreen
        WifiScreen {
            anchors.fill: parent
            // anchors.bottomMargin: parent.height - inputPanel.y
            onNext: {
                stackLoader.item.push(activationScreen)
            }
        }
    }

    Component {
        id: activationScreen
        ActivationScreen {
            onActivation: {
                stackLoader.item.push(connectScreen)
            }
        }
    }

    Component {
        id: connectScreen
        ConnectScreen {
            onDeviceFound: {
                console.log("DEVICE FOUND")
                // stackLoader.item.replace(homeScreen)
                Qt.callLater(() => stackLoader.item.replace(homeScreen))
            }
        }
    }

    // Component {
    //     id: setupScreen
    //     SetupScreen {
    //         onSelected: (device) => {
    //             appStorage.selectedDevices.push(device)
    //             console.log(appStorage.selectedDevices)
    //             stackLoader.item.replace(homeScreen)
    //         }
    //     }
    // }

    Component {
        id: homeScreen
        HomeScreen {
            onSettings: {
                stackLoader.item.push(settingsScreen)
            }
        }
    }

    Component {
        id: settingsScreen
        SettingsScreen {
            onSettingsUpdated: {
                appSettings.sync()
                stackLoader.item.pop()
            }
            onSettingsCancelled: {
                stackLoader.item.pop()
            }
        }
    }

    // Component {
    //     id: bleTestScreen
    //     BLETest { }
    // }

    // Screen Stack System
    Component {
        id: stackComponent
        StackView {
            initialItem: appStorage.selectedDevices.length === 0 ? onboardingScreen : homeScreen
            anchors.fill: parent
        }
    }

    // Load the screen stack after settings ready
    Loader {
        id: stackLoader
        anchors.fill: parent
        sourceComponent: {
            if (!mainWindow.storageReady) return undefined // Wait for settings
            return stackComponent
        }
    }



    // Import and use keyboard component
    Keyboard {
        id: keyboard
        rootWindow: mainWindow
    }
}
