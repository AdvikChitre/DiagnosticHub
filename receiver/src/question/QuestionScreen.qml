import QtQuick 2.15
import QtQuick.Controls 2.15 // For Text, TextField, Button
import QtQuick.Layouts 1.15
// import QtQuick.VirtualKeyboard 2.15 // Not directly used for UI elements here
// import QtQuick.VirtualKeyboard.Settings // Not directly used for UI elements here
// import Network // Not used in this file's UI directly
// import "../common" // For Constants.qml if needed

// Assuming 'Device' from Connections is a C++ context property or QML singleton
// Assuming 'appStorage' from Main.qml is globally accessible by its ID

Item {
    id: root
    signal submit()

    property var currentDevice: null
    property int currentQuestionIndex: 0
    property var answers: ({})
    property var questions: []

    property var translations: {
        "en_US": {
            "noQuestions": "No questions available",
            "placeholderAnswer": "Tap here to answer...",
            "previousButton": "Previous",
            "nextButton": "Next",
            "submitButton": "Submit"
        },
        "es_ES": {
            "noQuestions": "No hay preguntas disponibles",
            "placeholderAnswer": "Toca aquí para responder...",
            "previousButton": "Anterior",
            "nextButton": "Siguiente",
            "submitButton": "Enviar"
        },
        "fr_FR": {
            "noQuestions": "Aucune question disponible",
            "placeholderAnswer": "Touchez ici pour répondre...",
            "previousButton": "Précédent",
            "nextButton": "Suivant",
            "submitButton": "Soumettre"
        },
        "de_DE": {
            "noQuestions": "Keine Fragen verfügbar",
            "placeholderAnswer": "Zum Antworten hier tippen...",
            "previousButton": "Vorherige",
            "nextButton": "Nächste",
            "submitButton": "Senden"
        }
    }

    function getText(key) {
        if (typeof appStorage !== 'undefined' && appStorage.selectedLanguage) {
            var lang = appStorage.selectedLanguage;
            if (translations.hasOwnProperty(lang) && translations[lang].hasOwnProperty(key)) {
                return translations[lang][key];
            }
        }
        if (translations["en_US"] && translations["en_US"].hasOwnProperty(key)) {
           return translations["en_US"][key];
        }
        console.warn("Translation key not found in QuestionScreen:", key);
        return key;
    }


    Component.onCompleted: {
        console.log("QuestionScreen: Getting questions for:", typeof appStorage !== 'undefined' ? appStorage.settingUpDevice : "N/A");
        if (typeof appStorage !== 'undefined' && appStorage.settingUpDevice) {
            currentDevice = getDeviceByName(appStorage.settingUpDevice);
            if (currentDevice) {
                questions = currentDevice.questions || [];
                console.log("QuestionScreen: Found questions:", JSON.stringify(questions));
                if (questions.length > 0) {
                    answerField.text = answers[questions[0].id] || "";
                }
            } else {
                 console.warn("QuestionScreen: Current device not found for questions.");
            }
        } else {
            console.warn("QuestionScreen: appStorage or settingUpDevice not defined.");
        }
    }

    ColumnLayout {
        id: mainContentLayout
        anchors.centerIn: parent
        width: parent.width * 0.85 // Give some horizontal padding
        spacing: 30

        // This transform moves the entire content block when keyboard is active
        transform: Translate {
            id: keyboardOffsetTransform
            y: (typeof keyboard !== 'undefined' && keyboard.active) ? -150 : 0 // Adjust value as needed
            Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        Text {
            id: questionText
            text: questions.length > 0 && currentQuestionIndex < questions.length
                  ? questions[currentQuestionIndex].question
                  : root.getText("noQuestions")
            color: appStorage.selectedTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 32
            font.bold: true
        }

        TextField {
            id: answerField
            placeholderText: root.getText("placeholderAnswer")
            color: appStorage.selectedTextColor
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            font.pixelSize: 24
            horizontalAlignment: TextInput.AlignHCenter // Center text input
            verticalAlignment: TextInput.AlignVCenter

            background: Rectangle {
                radius: 15
                // Use a color slightly different from main background for contrast, or theme's input field color
                color: Qt.lighter(appStorage.themeBackgroundColor, 1.1)
                border.color: appStorage.selectedBorderColor
                border.width: answerField.activeFocus ? 2 : 1 // Thicker border when active
            }

            onTextChanged: {
                if (questions.length > currentQuestionIndex && questions[currentQuestionIndex]) {
                    answers[questions[currentQuestionIndex].id] = text;
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = true; // Consume event
                    console.log("Enter Pressed in answerField");
                    if (currentQuestionIndex < questions.length - 1) {
                        currentQuestionIndex++;
                        answerField.text = answers[questions[currentQuestionIndex].id] || "";
                        answerField.forceActiveFocus(); // Keep focus or move to next logical field
                    } else {
                        // Check if answer is not empty before submitting if it's the last question
                        if (answerField.text.trim() !== "") {
                            root.submit();
                            submitAnswers();
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 40

            Button {
                id: previousButton
                text: root.getText("previousButton")
                enabled: currentQuestionIndex > 0
                implicitWidth: 180
                implicitHeight: 70
                font.pixelSize: 24

                background: Rectangle {
                    radius: 35
                    color: previousButton.enabled ?
                               (typeof appStorage !== 'undefined' ? Qt.lighter(appStorage.themeBackgroundColor, 1.3) : "#f0f0f0") :
                               (typeof appStorage !== 'undefined' ? Qt.lighter(appStorage.themeBackgroundColor, 1.1) : "#cccccc")
                    border.color: typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "#a0a0a0"
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: appStorage.selectedTextColor
                    opacity: parent.enabled ? 1.0 : 0.5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (currentQuestionIndex > 0) {
                        currentQuestionIndex--;
                        answerField.text = answers[questions[currentQuestionIndex].id] || "";
                    }
                }
            }

            Button {
                id: nextButton
                text: root.getText(currentQuestionIndex === questions.length - 1 ? "submitButton" : "nextButton")
                enabled: answerField.text.trim() !== "" || (questions.length === 0 && currentQuestionIndex === 0) // Enable submit if no questions
                implicitWidth: 180
                implicitHeight: 70
                font.pixelSize: 24

                background: Rectangle {
                    radius: 35
                    color: nextButton.enabled ?
                               (typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "#0078d4") : // Accent color when enabled
                               (typeof appStorage !== 'undefined' ? Qt.lighter(appStorage.themeBackgroundColor, 1.3) : "#cccccc")
                    border.color: nextButton.enabled ?
                                    (typeof appStorage !== 'undefined' ? Qt.darker(appStorage.selectedBorderColor,1.2) : Qt.darker("#0078d4",1.2)) :
                                    (typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "#a0a0a0")
                    border.width: 1
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: typeof appStorage !== 'undefined' ?
                               (nextButton.enabled ? (Qt.colorBrightness(appStorage.selectedBorderColor) > 0.5 ? "black" : "white")
                                                   : appStorage.selectedTextColor)
                               : "white"
                    opacity: parent.enabled ? 1.0 : 0.5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (currentQuestionIndex < questions.length - 1) {
                        currentQuestionIndex++;
                        answerField.text = answers[questions[currentQuestionIndex].id] || "";
                        answerField.forceActiveFocus();
                    } else {
                        root.submit();
                        submitAnswers();
                    }
                }
            }
        }
    }

    function getDeviceByName(deviceName) {
        if (typeof appStorage === 'undefined' || !appStorage.availableDevices || !appStorage.availableDevices.wearables) {
            console.warn("QuestionScreen: appStorage or available wearables not defined in getDeviceByName");
            return null;
        }
        try {
            var devices = appStorage.availableDevices.wearables;
            for (var i = 0; i < devices.length; i++) {
                if (devices[i] && devices[i].name === deviceName) { // Added check for devices[i]
                    return devices[i];
                }
            }
        } catch (e) {
            console.error("Error parsing or searching devices:", e);
        }
        return null;
    }

    function submitAnswers() {
        const payload = {
            deviceId: currentDevice.id,
            answers: questions.map(function(question) { // Changed to function for broader compatibility
                return {
                    questionId: question.id,
                    answer: answers[question.id] || ""
                };
            })
        };

        const url = `${currentDevice.forwarding_address}:${currentDevice.forwarding_port}/api/question/submit`;
        console.log("Submitting answers to:", url, JSON.stringify(payload));
        if (typeof network !== 'undefined') {
            network.post(url, JSON.stringify(payload));
        } else {
            console.error("NetworkManager 'network' is not defined.");
        }
    }
}
