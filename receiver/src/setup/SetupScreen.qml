import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../common"

Item {
    signal selected(int deviceIndex)

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
                    onAccepted: selected(selectedIndex)

                    property int selectedIndex: -1
                }

                Repeater {
                    model: deviceList // defined in c++

                    Loader {
                        active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                        sourceComponent: DeviceCard {
                            name: model.name
                            label: model.description

                            // Confirm when dialog selected
                            onClicked: {
                                confirmationDialog.title = "Confirm " + model.name
                                confirmationDialog.selectedIndex = index
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
