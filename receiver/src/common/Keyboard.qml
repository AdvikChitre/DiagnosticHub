import QtQuick
import QtQuick.VirtualKeyboard

InputPanel {
    id: keyboard
    required property Item rootWindow // Active window

    z: 99
    x: 0
    y: rootWindow.height
    width: rootWindow.width

    states: State {
        name: "visible"
        when: keyboard.active
        PropertyChanges {
            target: keyboard
            y: rootWindow.height - keyboard.height
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
}
