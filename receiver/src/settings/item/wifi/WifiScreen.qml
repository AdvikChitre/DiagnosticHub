import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtDeviceUtilities.NetworkSettings
import "./"
import "../../../common"

Item {
    id: wifiScreen

    signal next()

    anchors.topMargin: 20
    property var connectingService: null
    property bool retryConnectAfterIdle: false

    Component.onCompleted: {
        NetworkSettingsManager.services.type = NetworkSettingsType.Wifi
    }

    // Fixed Title
    Text {
        id: title
        text: qsTr("Wi-Fi")
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 32
        font.bold: true
        color: "white"
        height: 60
    }

    // ListView between title and next button
    ListView {
        id: wifiList
        anchors {
            top: title.bottom
            bottom: nextButton.top
            left: parent.left
            right: parent.right
            topMargin: 10
            bottomMargin: 10
        }
        clip: true
        model: NetworkSettingsManager.services
        spacing: 10
        boundsBehavior: Flickable.DragOverBounds

        header: Column {
            width: parent.width
            spacing: 10
            padding: 10

            Row {
                spacing: 10
            }
        }

        delegate: Item {
            width: wifiList.width
            height: 80
            property bool connected: model.connected

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * 0.6
                spacing: 5

                Text {
                    text: model.name || qsTr("Unnamed")
                    font.pixelSize: 20
                    color: connected ? "#4CAF50" : "white"
                    font.bold: connected ? true : false
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                width: 120
                height: 40
                radius: 5
                color: {
                    if (connected) return "#666"
                    if (model.state === NetworkSettingsState.Association) return "#2196F3"
                    return "#4CAF50"
                }

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (connected) return qsTr("DISCONNECT")
                        if (model.state === NetworkSettingsState.Association) return qsTr("CONNECTING...")
                        return qsTr("CONNECT")
                    }
                    color: "white"
                    font.pixelSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !connected && model.state !== NetworkSettingsState.Association
                    onClicked: {
                        wifiScreen.connectingService = NetworkSettingsManager.services.itemFromRow(index)
                        console.log("selected network: ", wifiScreen.connectingService)
                        if (wifiScreen.connectingService) {
                            passphraseEnter.extraInfo = "";
                            wifiScreen.connectingService.connectService();
                            wifiScreen.connectingService.stateChanged.connect(connectingServiceStateChange);
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#333"
                anchors.bottom: parent.bottom
            }
        }
    }

    // Next Button
    Rectangle {
        id: nextButton
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 20
        }
        width: 240
        height: 80
        radius: 5
        color: "#4CAF50"

        Text {
            text: qsTr("Next")
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 16
        }

        MouseArea {
            anchors.fill: parent
            onClicked: wifiScreen.next()
        }
    }

    PassphraseEnter {
        id: passphraseEnter
        anchors.centerIn: parent
        visible: false
    }

    Connections {
        target: NetworkSettingsManager.userAgent
        function onShowUserCredentialsInput() {
            passphraseEnter.visible = true
        }
    }

    Keyboard {
        id: keyboard
        //        rootWindow: mainWindow
    }

    BackButton {
        anchors {
            top: parent.top
            left: parent.left
            margins: 10
        }
    }

    function connectingServiceStateChange() {
        if (connectingService !== null) {
            if (connectingService.state === NetworkSettingsState.Failure) {
                retryConnectAfterIdle = true
            } else if (connectingService.state === NetworkSettingsState.Ready) {
                connectingService = null;
                retryConnectAfterIdle = false;
            } else if (connectingService.state === NetworkSettingsState.Idle) {
                if (retryConnectAfterIdle) {
                    passphraseEnter.extraInfo = qsTr("Invalid passphrase");
                    connectingService.connectService();
                }
                retryConnectAfterIdle = false;
            }
        }
    }
}
