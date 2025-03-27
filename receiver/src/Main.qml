import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import "./common"
import "./onboarding"
import "./setup"
import "./home"
import "./settings"

ApplicationWindow {
    id: mainWindow
    width: 1024
    height: 600
    visible: true
    title: qsTr("Hello World")
    color: "#2adbde"

    // Persistent settings
    Settings {
        id: appSettings
        property bool onboardingCompleted: false
        property int selectedDevice: -1
    }

    Component {
        id: onboardingScreen
        OnboardingScreen {
            onCompleted: {
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
            // Add settings screen properties here
        }
    }

    StackView {
        id: screenStack
        initialItem: appSettings.selectedDevice == -1 ? onboardingScreen : homeScreen
        anchors.fill: parent
        onCurrentItemChanged: console.log("Current screen:", currentItem)
    }

    // Import and use keyboard component
    Keyboard {
        id: keyboard
        rootWindow: mainWindow
    }
}
