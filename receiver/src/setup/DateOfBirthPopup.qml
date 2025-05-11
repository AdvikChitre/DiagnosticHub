import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: dateOfBirthPopup
    anchors.fill: parent
    color: "#09102b"
    visible: false
    opacity: 0.9

    signal accepted(string birthDate)
    signal canceled()

    property string errorMessage: ""
    property color borderColor: "#9d9faa"
    property color buttonGreenColor: "#41cd52"
    property color buttonGrayColor: "#9d9faa"
    property color buttonActiveColor: "#216729"
    property string appFont: "TitilliumWeb"

    function showPopup() {
        errorMessage = ""
        dd1.text = dd2.text = mm1.text = mm2.text = ""
        yyyy1.text = yyyy2.text = yyyy3.text = yyyy4.text = ""
        visible = true
        dd1.forceActiveFocus()
    }

    Rectangle {
        id: popupFrame
        anchors.centerIn: parent
        width: popupColumn.width + 40
        height: popupColumn.height + 40
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
                text: "Date of Birth"
                color: "white"
                font.bold: true
                font.pixelSize: 20
                Layout.alignment: Qt.AlignHCenter
                font.family: appFont
            }
            Text {
                text: "(DD/MM/YYYY)"
                Layout.alignment: Qt.AlignHCenter
                font.italic: true
                color: "white"
                font.pixelSize: 18
                font.family: appFont
            }

            Row {
                spacing: 5

                // Day
                Row {
                    spacing: 2
                    DateDigitField {
                        id: dd1
                        onEnterPressed: {
                            setButton.click()
                        }
                        nextField: dd2
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                    DateDigitField {
                        id: dd2
                        onEnterPressed: {
                            setButton.click()
                        }
                        nextField: mm1
                        prevField: dd1
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                }

                Text { text: "/"; color: "white"; font.pixelSize: 32 }

                // Month
                Row {
                    spacing: 2
                    DateDigitField {
                        id: mm1
                        onEnterPressed: {
                            setButton.click()
                        }
                        nextField: mm2
                        prevField: dd2
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                    DateDigitField {
                        id: mm2
                        onEnterPressed: {
                            setButton.click()
                        }
                        nextField: yyyy1
                        prevField: mm1
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                }

                Text { text: "/"; color: "white"; font.pixelSize: 32 }

                // Year
                Row {
                    spacing: 2
                    DateDigitField {
                        id: yyyy1
                        onEnterPressed: {
                            setButton.click()
                        }
                        nextField: yyyy2
                        prevField: mm2
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                    DateDigitField {
                        id: yyyy2
                        onEnterPressed: {
                            setButton.click()
                        }
                        nextField: yyyy3
                        prevField: yyyy1
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                    DateDigitField {
                        id: yyyy3
                        onEnterPressed: {
                            setButton.click()
                        }
                        nextField: yyyy4
                        prevField: yyyy2
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                    DateDigitField {
                        id: yyyy4
                        onEnterPressed: {
                            setButton.click()
                        }
                        prevField: yyyy3
                        activeBorderColor: buttonGreenColor
                        inactiveBorderColor: buttonGrayColor
                    }
                }
            }

            Text {
                text: errorMessage
                color: "red"
                visible: errorMessage !== ""
                font.pixelSize: 24
                font.family: appFont
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
                        const day = dd1.text + dd2.text
                        const month = mm1.text + mm2.text
                        const year = yyyy1.text + yyyy2.text + yyyy3.text + yyyy4.text
                        const dateStr = `${day}/${month}/${year}`

                        const dateRegex = /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$/
                        if (dateRegex.test(dateStr)) {
                            errorMessage = ""
                            dateOfBirthPopup.accepted(dateStr)
                            // visible = false
                        } else {
                            errorMessage = "Invalid date format"
                        }
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
                        dateOfBirthPopup.canceled()
                    }
                }
            }
        }
    }

    Component {
        id: dateDigitField
        TextField {
            width: 30
            height: 50
            maximumLength: 1
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            color: "white"
            font.pixelSize: 18
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 0; top: 9 }

            property Item nextField: null
            property Item prevField: null

            onTextChanged: {
                if (text.length === 1 && nextField) {
                    nextField.focus = true
                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Backspace && text.length === 0 && prevField) {
                    prevField.focus = true
                    prevField.text = ""
                }
            }

            background: Rectangle {
                color: "transparent"
                border.color: parent.activeFocus ? buttonGreenColor : buttonGrayColor
                border.width: 2
                radius: 4
            }
        }
    }
}
