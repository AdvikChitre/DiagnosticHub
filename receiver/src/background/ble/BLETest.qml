// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Layouts

Item {
    id: main

    width: anchors.fill
    height: anchors.fill
    visible: true

    StackLayout {
        id: pagesLayout
        anchors.fill: parent
        currentIndex: 0

        Devices {
            onShowServices: pagesLayout.currentIndex = 1
        }
        Services {
            onShowDevices: pagesLayout.currentIndex = 0
            onShowCharacteristics: pagesLayout.currentIndex = 2
        }
        Characteristics {
            onShowDevices: pagesLayout.currentIndex = 0
            onShowServices: pagesLayout.currentIndex = 1
        }
    }
}
