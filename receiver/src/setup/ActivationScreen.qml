import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
// import QtQuick.VirtualKeyboard 2.15 // Assuming 'keyboard' ID is from Main.qml or globally available
// import QtQuick.VirtualKeyboard.Settings
import Network
import "../common"

Item {
    id: root
    signal activation()

    width: parent.width
    height: parent.height

    // --- Translation Setup ---
    property var translations: {
        "en_US": { "title": "Activate Device", "enterCode": "Enter Provided Activation Code", "activateButton": "ACTIVATE", "unknownError": "An unknown error occurred", "configError": "Configuration error, please try again later" },
        "es_ES": { "title": "Activar Dispositivo", "enterCode": "Ingrese el Código de Activación Proporcionado", "activateButton": "ACTIVAR", "unknownError": "Ocurrió un error desconocido", "configError": "Error de configuración, por favor intente más tarde" },
        "fr_FR": { "title": "Activer l'Appareil", "enterCode": "Entrez le Code d'Activation Fourni", "activateButton": "ACTIVER", "unknownError": "Une erreur inconnue s'est produite", "configError": "Erreur de configuration, veuillez réessayer plus tard" },
        "de_DE": { "title": "Gerät Aktivieren", "enterCode": "Geben Sie den Aktivierungscode ein", "activateButton": "AKTIVIEREN", "unknownError": "Ein unbekannter Fehler ist aufgetreten", "configError": "Konfigurationsfehler, bitte versuchen Sie es später erneut" }
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
        console.warn("Translation key not found:", key);
        return key;
    }

    // Manages HTTP request for activation
    NetworkManager {
        id: network
        onResponseDataChanged: {
            console.log("Activation Response:", network.responseData);
            var response;
            try {
                response = JSON.parse(network.responseData);
            } catch (e) {
                console.error("Failed to parse activation response JSON:", e, network.responseData);
                if (dateOfBirthPopup) dateOfBirthPopup.errorMessage = root.getText("unknownError");
                return;
            }
            var targetDeviceName = response.wearableName;
            if (targetDeviceName && typeof appStorage !== 'undefined') {
                var updatedDevices = appStorage.approvedDevices.slice();
                if (!updatedDevices.includes(targetDeviceName)) { updatedDevices.push(targetDeviceName); }
                appStorage.approvedDevices = updatedDevices;
                console.log("Approved Devices Count:", appStorage.approvedDevices.length);
            } else {
                console.warn("Target device name not found or appStorage undefined. Response:", JSON.stringify(response));
            }
            if (dateOfBirthPopup) dateOfBirthPopup.visible = false;
            root.activation();
        }
        onErrorOccurred: {
            console.error("Activation Network Error:", network.error, "Response data:", network.responseData);
            if (dateOfBirthPopup) {
                dateOfBirthPopup.errorMessage = network.error || root.getText("unknownError");
                dateOfBirthPopup.visible = true;
            }
        }
    }

    property bool isValid: code.length === 6
    property string code: codeField1.text + codeField2.text + codeField3.text +
                         codeField4.text + codeField5.text + codeField6.text
    property string birthDate: ""

    // Main container for all interactive UI elements that need to move with keyboard
    Item {
        id: mainUiContentContainer
        width: parent.width * 0.85 // Content takes up 85% of screen width
        height: contentColumn.implicitHeight // Height adjusts to content
        anchors.centerIn: parent
        // To push everything slightly lower than true center, you can add an offset:
        // anchors.verticalCenterOffset: 30 // Pushes the center down by 30 pixels

        transform: Translate {
            id: keyboardOffsetTransform
            // Adjust the -150 value as needed to ensure input fields are visible above keyboard
            // This value might depend on your virtual keyboard's height.
            y: (typeof keyboard !== 'undefined' && keyboard.active) ? -150 : 0
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
        }

        ColumnLayout {
            id: contentColumn // Holds title, code entry section, and button
            width: parent.width // Takes width from mainUiContentContainer
            spacing: 35 // Increased spacing between major sections

            Text { // Title
                id: titleText
                text: root.getText("title")
                color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
                font.pixelSize: 38
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                // Layout.topMargin: 10 // Optional additional margin to push content down further
            }

            // Activation Code Section
            ColumnLayout {
                id: codeEntryLayout
                spacing: 15 // Spacing between instruction text and code fields row
                Layout.alignment: Qt.AlignHCenter // Center this block within contentColumn

                Text { // Instruction text
                    text: root.getText("enterCode")
                    color: typeof appStorage !== 'undefined' ? appStorage.selectedTextColor : "black"
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 20
                }

                Row { // Row of input boxes
                    id: codeFieldsRow
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter // Center this Row within codeEntryLayout

                    // DateDigitFields: Assuming they are custom components.
                    // Their internal text alignment and theming needs to be handled within DateDigitField.qml
                    // For centering text *inside* DateDigitField, it would typically use:
                    // TextInput { anchors.fill: parent; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    DateDigitField { id: codeField1; width: 60; height: 80; font.pixelSize: 32; nextField: codeField2; onEnterPressed: { if (root.isValid && dateOfBirthPopup) dateOfBirthPopup.showPopup(); } }
                    DateDigitField { id: codeField2; width: 60; height: 80; font.pixelSize: 32; prevField: codeField1; nextField: codeField3; onEnterPressed: { if (root.isValid && dateOfBirthPopup) dateOfBirthPopup.showPopup(); } }
                    DateDigitField { id: codeField3; width: 60; height: 80; font.pixelSize: 32; prevField: codeField2; nextField: codeField4; onEnterPressed: { if (root.isValid && dateOfBirthPopup) dateOfBirthPopup.showPopup(); } }
                    DateDigitField { id: codeField4; width: 60; height: 80; font.pixelSize: 32; prevField: codeField3; nextField: codeField5; onEnterPressed: { if (root.isValid && dateOfBirthPopup) dateOfBirthPopup.showPopup(); } }
                    DateDigitField { id: codeField5; width: 60; height: 80; font.pixelSize: 32; prevField: codeField4; nextField: codeField6; onEnterPressed: { if (root.isValid && dateOfBirthPopup) dateOfBirthPopup.showPopup(); } }
                    DateDigitField { id: codeField6; width: 60; height: 80; font.pixelSize: 32; prevField: codeField5; onEnterPressed: { if (root.isValid && dateOfBirthPopup) dateOfBirthPopup.showPopup(); } }
                }
            }

            // Submit Button
            Button {
                id: activateButton
                text: root.getText("activateButton")
                font.pixelSize: 22
                font.bold: true
                enabled: root.isValid
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 280
                Layout.preferredHeight: 65

                background: Rectangle {
                    radius: 10
                    color: activateButton.enabled ?
                               (typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "#0078d4") :
                               (typeof appStorage !== 'undefined' ? Qt.lighter(appStorage.themeBackgroundColor, 1.3) : "#cccccc")
                    border.color: activateButton.enabled ?
                                    (typeof appStorage !== 'undefined' ? Qt.darker(appStorage.selectedBorderColor, 1.2) : Qt.darker("#0078d4", 1.2)) :
                                    (typeof appStorage !== 'undefined' ? appStorage.selectedBorderColor : "#bbbbbb")
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: typeof appStorage !== 'undefined' ?
                               (activateButton.enabled ? (Qt.colorBrightness(appStorage.selectedBorderColor) > 0.5 ? "black" : "white")
                                                     : appStorage.selectedTextColor)
                               : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: { if (dateOfBirthPopup) dateOfBirthPopup.showPopup(); }
            }
        }
    }


    DateOfBirthPopup {
        id: dateOfBirthPopup
        anchors.fill: parent
        onAccepted: function(birthDateString) {
            root.birthDate = birthDateString;
            if (typeof Constants !== 'undefined' && Constants.baseUrl) {
                const jsonData = JSON.stringify({ activationCode: root.code, DoB: birthDateString });
                network.post(Constants.baseUrl + "/api/studies/confirm", jsonData);
            } else {
                console.error("Constants or Constants.baseUrl not defined for network post.");
                dateOfBirthPopup.errorMessage = root.getText("configError");
            }
        }
        onCanceled: {
            root.birthDate = "";
            visible = false;
        }
    }

    function reset() {
        codeField1.text = ""; codeField2.text = ""; codeField3.text = "";
        codeField4.text = ""; codeField5.text = ""; codeField6.text = "";
        birthDate = "";
        if (codeField1) codeField1.forceActiveFocus();
    }

    BackButton {
        anchors { top: parent.top; left: parent.left; margins: 20 }
        // Remember to theme BackButton internally or by passing properties
    }
}
