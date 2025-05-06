// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only
import QtQuick
import QtQuick.Controls
import QtDeviceUtilities.NetworkSettings

Rectangle {
    id: passphrasePopup
    width: parent.width
    height: parent.height
    color: passphrasePopup.backgroundColor
    opacity: 0.9
    property string extraInfo: ""
    property bool showSsid: false

    property int margin: (width / 3 * 2) * 0.05
    property int spacing: margin * 0.5

    property string appFont: "TitilliumWeb"
    property color backgroundColor: "#09102b"
    property color borderColor: "#9d9faa"
    property color buttonGreenColor: "#41cd52"
    property color buttonGrayColor: "#9d9faa"
    property color buttonActiveColor: "#216729"
    property color scrollBarColor: "#41cd52"
    // property real spacing: 0.5
    property real titleFontSize: 0.04
    property real subTitleFontSize: 0.035
    property real valueFontSize: 0.025
    property real fieldHeight: 0.07
    property real fieldTextHeight: 0.05
    property real buttonHeight: 0.05

    Rectangle {
        id: frame
        color: passphrasePopup.backgroundColor
        border.color: passphrasePopup.borderColor
        border.width: 3
        anchors.centerIn: parent
        width: passphraseColumn.width * 1.1
        height: passphraseColumn.height * 1.1

        Column {
            id: passphraseColumn
            anchors.centerIn: parent
            spacing: spacing

            Text {
                visible: showSsid
                font.pixelSize: passphrasePopup.height * passphrasePopup.subTitleFontSize
                font.family: passphrasePopup.appFont
                color: "white"
                text: qsTr("Enter SSID")
            }

            TextField {
                id: ssidField
                visible: showSsid
                width: passphrasePopup.width * 0.4
                height: passphrasePopup.height * 0.075
                color: "white"
                background: Rectangle{
                    color: "transparent"
                    border.color: ssidField.focus ? passphrasePopup.buttonGreenColor : passphrasePopup.buttonGrayColor
                    border.width: ssidField.focus ? width * 0.01 : 2
                }
            }

            Text {
                font.pixelSize: passphrasePopup.height * passphrasePopup.subTitleFontSize
                font.family: passphrasePopup.appFont
                color: "white"
                text: qsTr("Enter Passphrase")
            }

            Text {
                font.pixelSize: passphrasePopup.height * passphrasePopup.valueFontSize
                font.family: passphrasePopup.appFont
                color: "red"
                text: extraInfo
                visible: (extraInfo !== "")
            }

            TextField {
                id: passField
                width: passphrasePopup.width * 0.4
                height: passphrasePopup.height * 0.075
                color: "white"
                echoMode: TextInput.Password
                background: Rectangle{
                    color: "transparent"
                    border.color: passField.focus ? passphrasePopup.buttonGreenColor : passphrasePopup.buttonGrayColor
                    border.width: passField.focus ? width * 0.01 : 2
                }
            }

            Row {
                spacing: parent.width * 0.025
                Button {
                    id: setButton
                    text: qsTr("SET")
                    onClicked: {
                        if (showSsid) {
                            NetworkSettingsManager.connectBySsid(ssidField.text, passField.text)
                            showSsid = false
                        } else {
                            NetworkSettingsManager.userAgent.setPassphrase(passField.text)
                        }
                        passphrasePopup.visible = false;
                    }
                }
                Button {
                    id: cancelButton
                    text: qsTr("CANCEL")
                    // borderColor: "transparent"
                    // fillColor: passphrasePopup.buttonGrayColor
                    onClicked: {
                        if (!showSsid) {
                            NetworkSettingsManager.userAgent.cancelInput()
                        }
                        showSsid = false
                        passphrasePopup.visible = false;
                    }
                }
            }
        }
    }
}
