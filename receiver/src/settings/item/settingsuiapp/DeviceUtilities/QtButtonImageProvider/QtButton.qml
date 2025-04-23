// Copyright (C) 2016 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only
import QtQuick
// import DeviceUtilities.SettingsUI
import "../SettingsUI"

Image {
    id: root
    source: "image://QtButton/" + cutSize + "/" + fillColor + "/" + borderColor
    sourceSize: Qt.size(width, height)
    property string state: "enabled"
    property int cutSize: 10
    property color fillColor: "#41cd52"
    property color borderColor: mouseArea.pressed ? "#216729" : "#41cd52"
    property alias text: buttonText.text
    property alias fontFamily: buttonText.font.family
    signal clicked()

    width: buttonText.contentWidth + cutSize * 4

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
    Text {
        id: buttonText
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: parent.height * 0.65
        //font.family: "TitilliumWeb"
        color: "white"
    }
}
