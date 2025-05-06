import QtQuick
import QtQuick.VirtualKeyboard

InputPanel {
    id: keyboard
    property Item rootWindow // Active window

    z: 99
    x: 0
    y: parent.height /*rootWindow ? rootWindow.height : 0*/
    width: rootWindow ? rootWindow.width : parent.width

    states: State {
        name: "visible"
        when: keyboard.active
        PropertyChanges {
            target: keyboard
            y: parent.height - keyboard.height /*rootWindow ? (rootWindow.height - keyboard.height) : 0*/
        }
    }
    transitions: Transition {
        from: ""
        to: "visible"
        reversible: true
        ParallelAnimation {
            NumberAnimation {
                properties: "y"
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }
    AutoScroller {}
}
