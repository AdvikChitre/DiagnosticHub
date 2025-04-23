// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only
import QtQuick
import QtDeviceUtilities.NetworkSettings
// import DeviceUtilities.SettingsUI
// import DeviceUtilities.QtButtonImageProvider
import "../../QtButtonImageProvider"
import "../"

ListView {
    id: list
    clip: true
    property var connectingService: null
    property bool retryConnectAfterIdle: false

    focus: true
    boundsBehavior: Flickable.DragOverBounds
    model: NetworkSettingsManager.services

    function connectBySsid() {
        passphraseEnter.showSsid = true
        passphraseEnter.visible = true
    }

    function margin(width) {
        return (width / 3 * 2) * 0.05;
    }

    delegate: Item {
        id: networkDelegate
        width: list.width
        height: list.height * 0.15
        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.5
            Text {
                id: networkName
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 0.035
                font.family: "TitilliumWeb"
                color: connected ? "#41cd52" : "white"
                text: (type === NetworkSettingsType.Wired) ? name + " (" + entry["id"] + ")" : name
            }
            Row {
                id: ipRow
                height: networkDelegate.height * 0.275 * opacity
                spacing: networkDelegate.width * 0.0075
                Item {
                    width: margin(list.width)
                    height: 1
                }
                Text {
                    id: ipAddressLabel
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("IP Address:")
                    color: connected ? "#41cd52" : "white"
                    font.pointSize: 0.025
                    font.family: "TitilliumWeb"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
                Text {
                    id: ipAddress
                    width: root.width * 0.15
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: connected ? "#41cd52" : "white"
                    text: connected ? NetworkSettingsManager.services.itemFromRow(index).ipv4.address
                                        : (NetworkSettingsManager.services.itemFromRow(index).state === NetworkSettingsState.Idle) ?
                                        qsTr("Not connected") : qsTr("Connecting")
                    font.pointSize: 0.025
                    font.family: "TitilliumWeb"
                    font.styleName: connected ? "SemiBold" : "Regular"
                }
            }
        }
        QtButton {
            id: connectButton
            fontFamily: "TitilliumWeb"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            fillColor: connected ? "#9d9faa" : "#41cd52"
            borderColor: "transparent"
            text: connected ? qsTr("DISCONNECT") : qsTr("CONNECT")
            enabled: true
            onClicked: {
                if (connected) {
                    NetworkSettingsManager.services.itemFromRow(index).disconnectService();
                } else {
                    list.connectingService = NetworkSettingsManager.services.itemFromRow(index)
                    if (list.connectingService) {
                        passphraseEnter.extraInfo = "";
                        list.connectingService.connectService();
                        list.connectingService.stateChanged.connect(connectingServiceStateChange);
                    }
                }
            }
        }
        Rectangle {
            id: delegateBottom
            width: networkDelegate.width
            color: "#9d9faa"
            height: 2
            anchors.bottom: networkDelegate.bottom
            anchors.horizontalCenter: networkDelegate.horizontalCenter
        }
        Behavior on height { NumberAnimation { duration: 200} }
    }

    Connections {
        target: NetworkSettingsManager.userAgent
        function onShowUserCredentialsInput() {
            passphraseEnter.visible = true;
        }
    }

    // Popup for entering passphrase
    PassphraseEnter {
        id: passphraseEnter
        parent: list.parent
        visible: false
    }

    function connectingServiceStateChange() {
        if (connectingService !== null) {
            if (connectingService.state === NetworkSettingsState.Failure) {
                // If authentication failed, request connection again. That will
                // initiate new passphrase request.
                retryConnectAfterIdle = true
            } else if (connectingService.state === NetworkSettingsState.Ready) {
                // If connection succeeded, we no longer have service connecting
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
