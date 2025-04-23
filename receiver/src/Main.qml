import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import Qt.labs.settings
import "./common"
import "./onboarding"
import "./setup"
import "./home"
import "./settings"
import "./settings/item/settingsuiapp/DeviceUtilities/SettingsUI"

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
        id: appSettings
        category: "AppConfig"  // Organize settings under this group
        property bool onboardingCompleted: false
        property int selectedDevice: -1
        property string language: "en"
        property string theme: "light"
    }

    Component {
        id: onboardingScreen
        OnboardingScreen {
            onCompleted: {
                console.log(Globals.aNumber)
                screenStack.push(setupScreen)
            }
        }
    }

    Component {
        id: setupScreen
        SetupScreen {
            onSelected: (i) => {
                appSettings.selectedDevice = i
                console.log(appSettings.selectedDevice)
                screenStack.replace(homeScreen)
            }
        }
    }

    Component {
        id: wifi
        SettingsUI {
            id: settingsUI
            anchors.fill: parent
            anchors.bottomMargin: parent.height - inputPanel.y
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


    StackView {
        id: screenStack
        initialItem: appSettings.selectedDevice == -1 ? wifi : homeScreen
        anchors.fill: parent
        onCurrentItemChanged: console.log("Current screen:", currentItem)
    }

    // Import and use keyboard component
    Keyboard {
        id: keyboard
        rootWindow: mainWindow
    }
}
