// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtDeviceUtilities.NetworkSettings

Rectangle {
    id: passphrasePopup
    anchors.fill: parent
    color: "#09102b"
    visible: false
    opacity: 0.9

    property string extraInfo: ""
    property bool showSsid: false
    property color borderColor: "#9d9faa"
    property color buttonGreenColor: "#41cd52"
    property color buttonGrayColor: "#9d9faa"
    property color buttonActiveColor: "#216729"
    property string appFont: "TitilliumWeb"

    function showPopup() {
        extraInfo = ""
        passField.text = ""
        ssidField.text = ""
        visible = true
        if(showSsid) ssidField.forceActiveFocus()
        else passField.forceActiveFocus()
    }

    Rectangle {
        id: popupFrame
        anchors.centerIn: parent
        width: popupColumn.width + 40
        height: popupColumn.height
        color: "#09102b"
        border.color: borderColor
        border.width: 2
        radius: 5

        transform: Translate {
            y: keyboard.active ? -150 : 0
            Behavior on y {
                NumberAnimation { duration: 200 }
            }
        }

        Column {
            id: popupColumn
            anchors.centerIn: parent
            spacing: 20
            padding: 20

            Text {
                text: showSsid ? "Connect to Network" : "Enter Passphrase"
                color: "white"
                font.bold: true
                font.pixelSize: 20
                Layout.alignment: Qt.AlignHCenter
                font.family: appFont
            }

            Text {
                visible: showSsid
                text: "Enter SSID"
                font.pixelSize: 18
                color: "white"
                font.family: appFont
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: ssidField
                visible: showSsid
                width: 200
                height: 50
                color: "white"
                font.pixelSize: 18
                font.family: appFont
                background: Rectangle {
                    color: "transparent"
                    border.color: ssidField.activeFocus ? buttonGreenColor : buttonGrayColor
                    border.width: 2
                    radius: 4
                }
            }

            Text {
                text: "Enter Passphrase"
                font.pixelSize: 18
                color: "white"
                font.family: appFont
                Layout.alignment: Qt.AlignHCenter
                visible: !showSsid
            }

            TextField {
                id: passField
                width: 200
                height: 50
                color: "white"
                echoMode: TextInput.Password
                font.pixelSize: 18
                font.family: appFont
                background: Rectangle {
                    color: "transparent"
                    border.color: passField.activeFocus ? buttonGreenColor : buttonGrayColor
                    border.width: 2
                    radius: 4
                }
            }

            Text {
                text: extraInfo
                color: "red"
                visible: extraInfo !== ""
                font.pixelSize: 18
                font.family: appFont
                Layout.alignment: Qt.AlignHCenter
            }

            Row {
                spacing: 20

                Button {
                    id: setButton
                    text: "SET"
                    width: 100
                    height: 40

                    background: Rectangle {
                        color: parent.down ? buttonActiveColor : buttonGreenColor
                        radius: 5
                    }

                    onClicked: {
                        if (showSsid) {
                            NetworkSettingsManager.connectBySsid(ssidField.text, passField.text)
                            showSsid = false
                        } else {
                            NetworkSettingsManager.userAgent.setPassphrase(passField.text)
                        }
                        passphrasePopup.visible = false
                    }
                }

                Button {
                    text: "CANCEL"
                    width: 100
                    height: 40

                    background: Rectangle {
                        color: parent.down ? "#666666" : buttonGrayColor
                        radius: 5
                    }

                    onClicked: {
                        if (!showSsid) NetworkSettingsManager.userAgent.cancelInput()
                        showSsid = false
                        passphrasePopup.visible = false
                    }
                }
            }
        }
    }
}
