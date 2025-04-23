// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only
import QtQuick
import "./Network"

Rectangle {
    id: main
    anchors.fill: parent
    color: "#9d9faa"
    opacity: 0.97

    function getMargin(width) {
        return (width / 3 * 2) * 0.05;
    }

    property int margin: getMargin(main.width)
    signal closed()

    NetworkSettings {
        anchors.margins: margin
    }
}
