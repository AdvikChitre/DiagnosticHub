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
import "./video"
import "./question"
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
import QtQuick.VirtualKeyboard.Settings

// Remote Control
import QtVncServer


Window {
    id: mainWindow
    width: 1024
    height: 600
    visible: true
    title: qsTr("Hello World")
    // color: "#2adbde"
    // color: "#ef476f"
    color: appStorage.selectedBgColor || "#ef476f"
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
        property var deviceSessions: ({})
        property var approvedDevices: [] // Approved by activation code
        property string settingUpDevice: ""
        property var selectedDevices: [] // Selected MAC address
        property var connectedDevices: mainThreadBridge.qmlConnectedDevices
        property string selectedLanguage: Constants.defaultLanguage
        property string selectedTheme: Constants.defaultTheme
        property string selectedTextColor: Constants.defaultTextColor
        property string selectedBgColor: Constants.defaultSecondaryColor
        property string selectedBorderColor: Constants.defaultBackgroundColor
        property bool notifyAudio: Constants.defaultNotifyAudio
        property bool notifyHaptic: Constants.defaultNotifyHaptic
        property bool notifyFlash: Constants.defaultNtifyFlash
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
        console.log("Keyboard locale:", VirtualKeyboardSettings.locale)
        // appStorage.approvedDevices = []
        // appStorage.selectedDevices = []
        storageReady = true
        // Display debug state info
        console.log("Available Devices:", appStorage.availableDevices)
        console.log("Selected Devices:", appStorage.selectedDevices)
        console.log("")
        console.log("Request URL:", Constants.baseUrl+"/api/wearables/config")
        network.get(Constants.baseUrl + "/api/wearables/config")
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
                if (appStorage.selectedDevices.length > 0) {
                    // settingsScreen.currentIndex += 1
                    stackLoader.item.pop()
                }
                else {
                    stackLoader.item.push(activationScreen)
                }
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
                console.log(stackLoader.item.depth())
                if (stackLoader.item.depth() === 4) {
                    Qt.callLater(() => stackLoader.item.push(videoScreen))
                }
                else {
                    stackLoader.item.pop()
                }
            }
        }
    }

    Component {
        id: videoScreen
        VideoScreen {
            onNext: {
                console.log("depth:", stackLoader.item.depth())
                if (stackLoader.item.depth() === 5) {
                    stackLoader.item.push(questionScreen)
                }
                else {
                    stackLoader.item.pop()
                }
            }
        }
    }

    Component {
        id: questionScreen
        QuestionScreen {
            onSubmit: {
                stackLoader.item.replace(homeScreen)
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
                appStorage.sync()
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
        VncItem {
            id: vncItem
            anchors.fill: parent
            vncPort: 5901

            // forwarders:
            function push(item)    { stackView.push(item) }
            function pop()         { stackView.pop() }
            function replace(item) { stackView.replace(item) }
            function depth()       { return stackView.depth }

            StackView {
                id: stackView
                initialItem: appStorage.selectedDevices.length === 0 ? onboardingScreen : (appStorage.settingUpDevice === "" ? homeScreen : questionScreen)
                anchors.fill: parent
            }
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
