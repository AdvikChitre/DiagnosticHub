pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import receiver

Rectangle {
    id: devicesPage

    property var approvedDevices: appStorage.approvedDevices
    signal deviceFound()

    width: parent.height
    height: parent.width

    Component.onCompleted: {
        // Start discovery when page loads
        if (permission.status === Qt.PermissionStatus.Granted) {
            Device.startDeviceDiscovery()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Label {
            text: "Connecting..."
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        BusyIndicator {
            running: true
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter
        }
    }

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

    Connections {
        target: Device
        function onDevicesUpdated() {
            console.log("Approved devices:", JSON.stringify(appStorage.approvedDevices))
            console.log("Selected devices:", appStorage.selectedDevices)
            // Check all discovered devices against approved list
            for (var i = 0; i < Device.devicesList.length; i++) {
                var device = Device.devicesList[i]
                var index = approvedDevices.indexOf(device.deviceName)

                if (index > -1) {
                    // Add MAC to selected devices
                    var selected = appStorage.selectedDevices
                    if (!selected.includes(device.deviceAddress)) {
                        selected.slice()
                        selected.push(device.deviceAddress)
                        appStorage.selectedDevices = updatedSelectedDevices
                    }

                    // Remove name from approved devices
                    approvedDevices.splice(index, 1)
                    var updatedApprovedDevices = approvedDevices.slice()
                    appStorage.approvedDevices = updatedApprovedDevices

                    deviceFound()
                    console.log("AFTER DEVICE FOUND")
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
                // If discovery stopped but still have approved devices, retry
                Qt.callLater(Device.startDeviceDiscovery)
            }
        }
    }
}
