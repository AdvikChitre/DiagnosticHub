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
import "./background/ble"
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

    // Persistent settings
    Settings {
        id: appStorage
        category: "AppConfig"
        property string baseUrl: "http://192.168.215.199:3000/"

        property var availableDevices: []
        property bool onboardingCompleted: false

        property var selectedDevices: []
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
            console.log(appStorage.availableDevices)
            console.log(appStorage.availableDevices.wearables[0].manufacturer)
        }
        onErrorOccurred: console.error("Error:", network.error)
    }

    // On start
    Component.onCompleted: {
        // Display debug state info
        console.log("Available Devices:", appStorage.availableDevices)
        console.log("Selected Devices:", appStorage.selectedDevices.length)
        console.log("Request URL:", Constants.baseUrl+"api/wearables/config")
        network.get(Constants.baseUrl + "api/wearables/config")
    }


    Component {
        id: onboardingScreen
        OnboardingScreen {
            onCompleted: {
                console.log(appStorage.onboardingCompleted)
                screenStack.push(wifiScreen)
            }
        }
    }

    Component {
        id: wifiScreen
        WifiScreen {
            anchors.fill: parent
            // anchors.bottomMargin: parent.height - inputPanel.y
            onNext: {
                screenStack.push(setupScreen)
            }
        }
    }

    Component {
        id: setupScreen
        SetupScreen {
            onSelected: (device) => {
                appStorage.selectedDevices.push(device)
                console.log(appStorage.selectedDevices)
                screenStack.replace(homeScreen)
            }
        }
    }

    Component {
        id: homeScreen
        HomeScreen {
            onSettings: {
                screenStack.push(settingsScreen)
            }
        }
    }

    Component {
        id: settingsScreen
        SettingsScreen {
            onSettingsUpdated: {
                appSettings.sync()
                screenStack.pop()
            }
            onSettingsCancelled: {
                screenStack.pop()
            }
        }
    }

    Component {
        id: bleTestScreen
        BLETest { }
    }

    // Screen Manager
    StackView {
        id: screenStack
        initialItem: appStorage.selectedDevices.length == 0 ? bleTestScreen : homeScreen
        anchors.fill: parent
        onCurrentItemChanged: console.log("Current screen:", currentItem)
    }

    // // Import and use keyboard component
    // Keyboard {
    //     id: keyboard
    //     rootWindow: mainWindow
    // }
}
