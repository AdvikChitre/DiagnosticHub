import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtTextToSpeech
import Qt5Compat.GraphicalEffects

Item {
    id: root
    signal submit()

    property var currentDevice: null
    property int currentQuestionIndex: 0
    property var answers: ({})
    property var questions: []

    // --- Translation Setup ---
    property var translations: {
        "en_US": {
            "noQuestions": "No questions available",
            "placeholderAnswer": "Tap here to answer...",
            "previousButton": "Previous",
            "nextButton": "Next",
            "submitButton": "Submit",
            "readQuestionHint": "Read question aloud"
        },
        "es_ES": {
            "noQuestions": "No hay preguntas disponibles",
            "placeholderAnswer": "Toca aquí para responder...",
            "previousButton": "Anterior",
            "nextButton": "Siguiente",
            "submitButton": "Enviar",
            "readQuestionHint": "Leer pregunta en voz alta"
        },
        "fr_FR": {
            "noQuestions": "Aucune question disponible",
            "placeholderAnswer": "Touchez ici pour répondre...",
            "previousButton": "Précédent",
            "nextButton": "Suivant",
            "submitButton": "Soumettre",
            "readQuestionHint": "Lire la question à haute voix"
        },
        "de_DE": {
            "noQuestions": "Keine Fragen verfügbar",
            "placeholderAnswer": "Zum Antworten hier tippen...",
            "previousButton": "Vorherige",
            "nextButton": "Nächste",
            "submitButton": "Senden",
            "readQuestionHint": "Frage vorlesen"
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

    // --- TextToSpeech Engine ---
    TextToSpeech {
        id: tts
        volume: 1.0 // 0.0 to 1.0
        pitch: 0    // -1 to 1
        rate: -0.4  // -1 to 1
        // You might want to set locale based on appStorage.selectedLanguage if voices are available
        // locale: appStorage.selectedLanguage.replace("_", "-") // e.g., "en-US"
        // onStateChanged: console.log("TTS State:", state)
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
        width: parent.width * 0.85
        spacing: 30

        transform: Translate {
            id: keyboardOffsetTransform
            y: (typeof keyboard !== 'undefined' && keyboard.active) ? -150 : 0
            Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        // --- Question Text and TTS Button ---
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 15 // Space between question text and TTS button

            Text {
                id: questionText
                text: questions.length > 0 && currentQuestionIndex < questions.length
                      ? questions[currentQuestionIndex].question
                      : root.getText("noQuestions")
                color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true // Allow text to take available width in RowLayout
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 32
                font.bold: true
            }

            Item { // Container for the TTS button icon
                id: ttsButtonContainer
                width: 40 // Size of the button
                height: 40
                Layout.alignment: Qt.AlignVCenter // Align with text vertically

                Image {
                    id: ttsIconSource
                    source: "../icon/speak.svg" // Ensure you have this icon
                    anchors.fill: parent
                    visible: false
                    fillMode: Image.PreserveAspectFit
                }
                ColorOverlay {
                    anchors.fill: ttsIconSource
                    source: ttsIconSource
                    color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "grey"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (tts.state === TextToSpeech.Ready && questionText.text !== root.getText("noQuestions")) {
                            tts.say(questionText.text)
                        } else if (tts.state === TextToSpeech.Speaking) {
                            tts.stop()
                        } else {
                            console.log("TTS not ready or no question to speak. State:", tts.state)
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: root.getText("readQuestionHint")
                }
                visible: questions.length > 0 && currentQuestionIndex < questions.length // Only show if there's a question
            }
        }
        // --- End of Question Text and TTS Button ---


        TextField {
            id: answerField
            placeholderText: root.getText("placeholderAnswer")
            placeholderTextColor: typeof appStorage !== 'undefined' ? Qt.rgba(appStorage.selectedTextColor.r, appStorage.selectedTextColor.g, appStorage.selectedTextColor.b, 0.5) : "gray"
            color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            font.pixelSize: 24
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter

            background: Rectangle {
                radius: 15
                color: typeof appStorage !== 'undefined' ? Qt.lighter(appStorage.themeBackgroundColor, 1.1) : "#f0f0f0"
                border.color: typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "#cccccc"
                border.width: answerField.activeFocus ? 2 : 1
            }

            onTextChanged: {
                if (questions.length > currentQuestionIndex && questions[currentQuestionIndex]) {
                    answers[questions[currentQuestionIndex].id] = text;
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = true;
                    console.log("Enter Pressed in answerField");
                    if (currentQuestionIndex < questions.length - 1) {
                        currentQuestionIndex++;
                        answerField.text = answers[questions[currentQuestionIndex].id] || "";
                        answerField.forceActiveFocus();
                    } else {
                        if (answerField.text.trim() !== "" || questions.length === 0) {
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
                    color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
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
                enabled: answerField.text.trim() !== "" || (questions.length === 0 && currentQuestionIndex === 0)
                implicitWidth: 180
                implicitHeight: 70
                font.pixelSize: 24

                background: Rectangle {
                    radius: 35
                    color: nextButton.enabled ?
                               (typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "#0078d4") :
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
                if (devices[i] && devices[i].name === deviceName) {
                    return devices[i];
                }
            }
        } catch (e) {
            console.error("Error parsing or searching devices:", e);
        }
        return null;
    }

    function submitAnswers() {
        if (!currentDevice || typeof Constants === 'undefined' || !Constants.baseUrl) {
            console.error("Cannot submit answers: currentDevice or Constants.baseUrl not defined.");
            return;
        }
        const payload = {
            deviceId: currentDevice.id,
            answers: questions.map(function(question) {
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
