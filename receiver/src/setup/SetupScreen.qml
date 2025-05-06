import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../common"
import "../"

Item {
    signal selected(var device)

    Component.onCompleted: {
        console.log(appStorage.availableDevices.wearables[0].name)
        console.log(appStorage.availableDevices.wearables[0].description)
        console.log(JSON.stringify(appStorage.availableDevices.wearables))
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        anchors.topMargin: parent.height * 0.05

        // Title
        Text {
            text: "Select Your Device"
            font.pixelSize: 32
            Layout.alignment: Qt.AlignHCenter
            font.bold: true
        }

        // Contained SwipeView
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 400  // Custom height
            Layout.leftMargin: 200
            Layout.rightMargin: 200
            border.color: "#cccccc"
            color: "#EAEAEA"
            radius: 8
            clip: true

            SwipeView {
                id: swipeView
                anchors {
                    fill: parent
                    margins: 10
                }
                currentIndex: 0

                // Confirmation dialog
                MessageDialog {
                    id: confirmationDialog
                    // title: "Confirm Selection"
                    buttons: MessageDialog.Ok | MessageDialog.Cancel
                    onAccepted: {
                        console.log("Selected Devices", appStorage.selectedDevices)
                        selected(selectedDevice)
                        console.log("Selected Devices", appStorage.selectedDevices)
                    }

                    property var selectedDevice: null
                }

                Repeater {
                    model: appStorage.availableDevices.wearables // deviceList // defined in c++

                    Loader {
                        active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                        sourceComponent: DeviceCard {
                            name: modelData.name || "ERROR: NO NAME"
                            label: modelData.description || ""

                            // Confirm when dialog selected
                            onClicked: {
                                confirmationDialog.title = "Confirm: " + modelData.name
                                confirmationDialog.selectedDevice = modelData
                                confirmationDialog.open()
                            }
                        }
                    }
                }
            }

            PageIndicator {
                count: swipeView.count
                currentIndex: swipeView.currentIndex
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    BackButton {
        anchors {
            top: parent.top
            left: parent.left
            margins: 20
        }
    }
}
