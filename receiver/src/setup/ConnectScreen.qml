import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import receiver

Rectangle {
    id: devicesPage
    color: "transparent"

    property var approvedDevices: appStorage.approvedDevices
    signal deviceFound()

    width: parent.height
    height: parent.width
    anchors {
        horizontalCenter: parent.horizontalCenter
        topMargin: 20
    }

    property var translations: {
        "en_US": {
            "connectingTitle": "Connecting...",
            "turnOnDeviceHint": "Turn on your device",
            "ensureDeviceOnHint": "Make sure the device is switched on"
        },
        "es_ES": {
            "connectingTitle": "Conectando...",
            "turnOnDeviceHint": "Encienda su dispositivo",
            "ensureDeviceOnHint": "Asegúrese de que el dispositivo esté encendido"
        },
        "fr_FR": {
            "connectingTitle": "Connexion...",
            "turnOnDeviceHint": "Allumez votre appareil",
            "ensureDeviceOnHint": "Assurez-vous que l'appareil est allumé"
        },
        "de_DE": {
            "connectingTitle": "Verbinden...",
            "turnOnDeviceHint": "Schalten Sie Ihr Gerät ein",
            "ensureDeviceOnHint": "Stellen Sie sicher, dass das Gerät eingeschaltet ist"
        }
    }

    Component.onCompleted: {
        if (permission.status === Qt.PermissionStatus.Granted) {
            Device.startDeviceDiscovery()
        }
    }

    ColumnLayout {
        anchors {
            top: parent.top
            topMargin: 60
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 30

        Label {
            text: "Connecting..."
            color: appStorage.selectedTextColor
            font.pixelSize: 46
            font.bold: true
            topPadding: 60
            Layout.alignment: Qt.AlignHCenter
            // leftPadding:
        }

        BusyIndicator {
            running: true
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignCenter
        }

        Label {
            text: "Turn on your device"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            color: "gray"
            bottomPadding: 20
        }
    }

    // Instruction text remains at bottom
    Label {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 40
        }
        text: "Make sure the device is switched on"
        font.pixelSize: 16
        color: "gray"
    }

    // Rest of the original logic remains unchanged
    Connections {
        target: Device
        function onDevicesUpdated() {
            for (var i = 0; i < Device.devicesList.length; i++) {
                var device = Device.devicesList[i]
                var index = approvedDevices.indexOf(device.deviceName)
                if (index > -1) {
                    var selected = appStorage.selectedDevices
                    if (!selected.includes(device.deviceAddress)) {
                        selected.slice()
                        selected.push(device.deviceAddress)
                        appStorage.selectedDevices = selected
                    }
                    appStorage.settingUpDevice = device.deviceName
                    approvedDevices.splice(index, 1)
                    appStorage.approvedDevices = approvedDevices.slice()
                    deviceFound()
                    break
                }
            }
        }
    }

    BluetoothPermission {
        id: permission
        communicationModes: BluetoothPermission.Access
        onStatusChanged: {
            if (status === Qt.PermissionStatus.Granted) {
                Device.startDeviceDiscovery()
            }
        }
    }

    Connections {
        target: Device
        function onStateChanged() {
            if (!Device.state && approvedDevices.length > 0) {
                Qt.callLater(Device.startDeviceDiscovery)
            }
        }
    }
}
