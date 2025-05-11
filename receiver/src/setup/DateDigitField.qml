// DateDigitField.qml
import QtQuick
import QtQuick.Controls

TextField {
    signal enterPressed()

    id: root
    width: 30
    height: 50
    maximumLength: 1
    horizontalAlignment: TextInput.AlignHCenter
    verticalAlignment: TextInput.AlignVCenter
    color: "black"
    font.pixelSize: 18
    inputMethodHints: Qt.ImhDigitsOnly
    validator: IntValidator { bottom: 0; top: 9 }

    property Item nextField: null
    property Item prevField: null
    property color activeBorderColor: "#0078d4"
    property color inactiveBorderColor: "#cccccc"
    property color activeBackgroundColor: "#ffffff"
    property color inactiveBackgroundColor: "#f8f8f8"
    property int backgroundRadius: 4

    onTextChanged: {
        if (text.length === 1 && nextField) {
            nextField.forceActiveFocus()
        }
    }

    Keys.onPressed: event => {
        console.log(event.key)
        if (event.key === Qt.Key_Backspace && text.length === 0 && prevField) {
            prevField.forceActiveFocus()
            prevField.text = ""
        }
        else if (event.key === Qt.Key_Left && prevField) {
            prevField.forceActiveFocus()
        }
        else if (event.key === Qt.Key_Right && nextField) {
            nextField.forceActiveFocus()
        }
        else if (event.key === Qt.Key_Return) {
            console.log("Enter Pressed")
            enterPressed()
        }
    }

    background: Rectangle {
        color: root.activeFocus ? root.activeBackgroundColor : root.inactiveBackgroundColor
        border.color: root.activeFocus ? root.activeBorderColor : root.inactiveBorderColor
        border.width: 2
        radius: root.backgroundRadius
    }
}
