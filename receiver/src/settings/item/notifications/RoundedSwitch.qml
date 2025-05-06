import QtQuick
import QtQuick.Controls

Switch {
    id: control
    property color checkedColor: "#4CAF50"
    property color uncheckedColor: "#ffffff"
    property color borderColor: control.checked ? checkedColor : "#cccccc"

    indicator: Rectangle {
        implicitWidth: 48
        implicitHeight: 26
        x: control.width - width - control.rightPadding
        y: control.height / 2 - height / 2
        radius: 13
        color: control.checked ? checkedColor : uncheckedColor
        border.color: borderColor

        Rectangle {
            x: control.checked ? parent.width - width - 2 : 2
            y: 2
            width: 22
            height: 22
            radius: 11
            color: control.checked ? "#ffffff" : "#f0f0f0"
            border.color: control.checked ? checkedColor : "#999999"

            Behavior on x {
                NumberAnimation { duration: 100 }
            }
        }
    }
}
