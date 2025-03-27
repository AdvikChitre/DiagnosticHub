import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    signal completed()

    property real progress: 0.0
    property color circleColor: "#ffffff"
    property bool animationRunning: false

    // Title with independent positioning
    Text {
        id: title
        text: "Tap to Continue"
        font.pixelSize: 32
        anchors.horizontalCenter: parent.horizontalCenter
        y: progress >= 1 ? 40 : (parent.height - height) / 2
        font.bold: true

        Behavior on y {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: introRect
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: title.bottom
            topMargin: 20
        }
        width: parent.width * 0.8
        height: 320
        radius: 10
        color: "#808080"
        opacity: progress >= 1 ? 1 : 0 // Fade in/out based on progress
        visible: opacity > 0 // Hide when fully transparent

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InQuint }
        }

        // Text content
        Text {
            id: introText
            anchors.centerIn: parent
            text: {
                if (progress >= 1 && progress < 2) return "Step 1: Initializing...\nHello";
                if (progress >= 2 && progress < 3) return "Step 2: Processing...";
                if (progress >= 3 && progress < 4) return "Step 3: Finalizing...";
                return ""; // Hide text at progress 0 and 4
            }
            font.pixelSize: 24
            color: "#FFFFFF"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Circle 'continue' button
    Item {
        id: circleContainer
        width: 100
        height: 100
        anchors {
            horizontalCenter: parent.horizontalCenter
            topMargin: 50
        }

        // Vertical position control
        y: progress >= 1 ? parent.height - height - 50 : title.y + title.height + 50
        Behavior on y {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: backgroundCircle
            anchors.centerIn: parent
            width: 80
            height: 80
            radius: width/2
            color: "#FFFFFF"
            opacity: 0.9
        }

        // Icon inside the circle
        Image {
            id: circleIcon
            anchors.centerIn: parent
            source: "../icon/next.svg"
            sourceSize: Qt.size(backgroundCircle.width * 0.6, backgroundCircle.height * 0.6)
            opacity: 0.8

            // Add color transition if using monochrome icon
            Behavior on source {
                PropertyAnimation { duration: 200 }
            }
        }

        Canvas {
            id: progressCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = circleColor
                ctx.lineWidth = 4
                ctx.lineCap = "round"

                var centerX = width/2
                var centerY = height/2
                var radius = Math.min(width, height)/2 - ctx.lineWidth
                var startAngle = -Math.PI/2
                var endAngle = startAngle + (Math.PI * 2 * (progress/4))

                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.stroke()
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.animationRunning && progress < 4.0
            onClicked: {
                var target = Math.min(progress + 1.0, 4.0)
                progressAnimator.from = progress
                progressAnimator.to = target
                progressAnimator.start()
            }

            onPressed: circleScaleAnimator.to = 0.9
            onReleased: circleScaleAnimator.to = 1.0
            onCanceled: circleScaleAnimator.to = 1.0
        }

        ScaleAnimator {
            id: circleScaleAnimator
            target: backgroundCircle
            duration: 200
        }
    }

    NumberAnimation {
        id: progressAnimator
        target: root
        property: "progress"
        duration: 1000
        easing.type: Easing.InOutQuad
        onStarted: root.animationRunning = true
        onStopped: {
            root.animationRunning = false
            if(progress >= 4.0) {
                root.completed()
                resetTimer.start()
            }
        }
    }

    Timer {
        id: resetTimer
        interval: 1000
        onTriggered: {
            progressAnimator.from = 4.0
            progressAnimator.to = 0.0
            progressAnimator.start()
        }
    }

    onProgressChanged: progressCanvas.requestPaint()
}
