import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.VirtualKeyboard 2.15
import QtQuick.VirtualKeyboard.Settings
import Network
import "../common"

Item {
    id: root
    signal activation()

    width: parent.width
    height: parent.height

    // Manages HTTP request for activation
    NetworkManager {
        id: network
        onResponseDataChanged: {
            // Add device to selected list
            console.log(JSON.stringify(network.responseData))
            var targetDevice = getDeviceByName(JSON.parse(network.responseData).wearableName)
            // Add with different array reference to store properly
            var updatedDevices = appStorage.selectedDevices.slice()
            updatedDevices.push(targetDevice)
            appStorage.selectedDevices = updatedDevices
            console.log("Selected Devices:", appStorage.selectedDevices.length)
            dateOfBirthPopup.visible = false
            activation()
        }
        onErrorOccurred: {
            console.error("Error:", network.error)
            dateOfBirthPopup.errorMessage = network.error || "An unknown error occurred"
            dateOfBirthPopup.visible = true
        }
    }

    property bool isValid: code.length === 6
    property string code: codeField1.text + codeField2.text + codeField3.text +
                         codeField4.text + codeField5.text + codeField6.text
    property string birthDate: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 30

        Text {
            text: "Activate Device"
            font.pixelSize: 32
            font.bold: true
            Layout.alignment: Qt.AlignCenter
        }

        // Activation Code Section
        ColumnLayout {
            spacing: 10
            Layout.alignment: Qt.AlignCenter

            transform: Translate {
                y: keyboard.active ? -100 : 0
                Behavior on y {
                    NumberAnimation { duration: 200 }
                }
            }

            Text {
                text: "Enter Provided Activation Code"
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 16
            }

            Row {
                spacing: 10
                DateDigitField {
                    id: codeField1
                    onEnterPressed: {
                        if (root.isValid) {
                            dateOfBirthPopup.showPopup()
                        }
                    }
                    width: 60
                    height: 80
                    font.pixelSize: 32
                    nextField: codeField2
                    activeBackgroundColor: "#ffffff"
                    inactiveBackgroundColor: "#f8f8f8"
                    activeBorderColor: "#0078d4"
                    inactiveBorderColor: "#cccccc"
                    backgroundRadius: 8
                }
                DateDigitField {
                    id: codeField2
                    onEnterPressed: {
                        if (root.isValid) {
                            dateOfBirthPopup.showPopup()
                        }
                    }
                    width: 60
                    height: 80
                    font.pixelSize: 32
                    prevField: codeField1
                    nextField: codeField3
                    activeBackgroundColor: "#ffffff"
                    inactiveBackgroundColor: "#f8f8f8"
                    activeBorderColor: "#0078d4"
                    inactiveBorderColor: "#cccccc"
                    backgroundRadius: 8
                }
                DateDigitField {
                    id: codeField3
                    onEnterPressed: {
                        if (root.isValid) {
                            dateOfBirthPopup.showPopup()
                        }
                    }
                    width: 60
                    height: 80
                    font.pixelSize: 32
                    prevField: codeField2
                    nextField: codeField4
                    activeBackgroundColor: "#ffffff"
                    inactiveBackgroundColor: "#f8f8f8"
                    activeBorderColor: "#0078d4"
                    inactiveBorderColor: "#cccccc"
                    backgroundRadius: 8
                }
                DateDigitField {
                    id: codeField4
                    onEnterPressed: {
                        if (root.isValid) {
                            dateOfBirthPopup.showPopup()
                        }
                    }
                    width: 60
                    height: 80
                    font.pixelSize: 32
                    prevField: codeField3
                    nextField: codeField5
                    activeBackgroundColor: "#ffffff"
                    inactiveBackgroundColor: "#f8f8f8"
                    activeBorderColor: "#0078d4"
                    inactiveBorderColor: "#cccccc"
                    backgroundRadius: 8
                }
                DateDigitField {
                    id: codeField5
                    onEnterPressed: {
                        if (root.isValid) {
                            dateOfBirthPopup.showPopup()
                        }
                    }
                    width: 60
                    height: 80
                    font.pixelSize: 32
                    prevField: codeField4
                    nextField: codeField6
                    activeBackgroundColor: "#ffffff"
                    inactiveBackgroundColor: "#f8f8f8"
                    activeBorderColor: "#0078d4"
                    inactiveBorderColor: "#cccccc"
                    backgroundRadius: 8
                }
                DateDigitField {
                    id: codeField6
                    onEnterPressed: {
                        if (root.isValid) {
                            dateOfBirthPopup.showPopup()
                        }
                    }
                    width: 60
                    height: 80
                    font.pixelSize: 32
                    prevField: codeField5
                    activeBackgroundColor: "#ffffff"
                    inactiveBackgroundColor: "#f8f8f8"
                    activeBorderColor: "#0078d4"
                    inactiveBorderColor: "#cccccc"
                    backgroundRadius: 8
                }
            }
        }

        // Submit Button
        Button {
            text: "ACTIVATE"
            font.pixelSize: 18
            font.bold: true
            enabled: root.isValid
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: 250
            Layout.preferredHeight: 60

            background: Rectangle {
                radius: 10
                color: parent.enabled ? "#0078d4" : "#cccccc"
            }

            onClicked: dateOfBirthPopup.showPopup()
        }
    }

    DateOfBirthPopup {
        id: dateOfBirthPopup
        anchors.fill: parent
        onAccepted: function(birthDate) {
            root.birthDate = birthDate
            const jsonData = JSON.stringify({ activationCode: root.code, DoB: birthDate})
            network.post(Constants.baseUrl + "api/studies/confirm", jsonData)
        }
        onCanceled: {
            root.birthDate = ""
            visible = false
        }
    }

    function reset() {
        codeField1.text = ""
        codeField2.text = ""
        codeField3.text = ""
        codeField4.text = ""
        codeField5.text = ""
        codeField6.text = ""
        birthDate = ""
        codeField1.forceActiveFocus()
    }

    function getDeviceByName(deviceName) {
        try {
            // Parse the JSON string into a JavaScript array
            console.log(appStorage.availableDevices)
            var devices = appStorage.availableDevices.wearables;
            console.log("Looking for:", deviceName)
            // Loop through each device to find a name match
            for (var i = 0; i < devices.length; i++) {
                console.log(i, devices[i].name)
                if (devices[i].name === deviceName) {
                    return devices[i]; // Return the matched device object
                }
            }
        } catch (e) {
            console.error("Error parsing or searching devices:", e);
        }
        return null; // Return null if no match or error
    }
}
