import QtQuick
import QtQuick.Controls

Column {
    id: root // Give an id to the root Column to access its members
    spacing: 20
    property ButtonGroup themeGroup: ButtonGroup {}

    property var translations: {
        "en_US": { "title": "Select Colour Scheme", "light": "Light", "contrast": "Contrast", "dark": "Dark" },
        "es_ES": { "title": "Seleccionar Tema de Color", "light": "Claro", "contrast": "Contraste", "dark": "Oscuro" },
        "fr_FR": { "title": "Choisir le Thème de Couleur", "light": "Clair", "contrast": "Contraste", "dark": "Sombre" },
        "de_DE": { "title": "Farbschema Auswählen", "light": "Hell", "contrast": "Kontrast", "dark": "Dunkel" }
    }

    // Function to get the translated text dynamically
    // Assumes appStorage.selectedLanguage is accessible globally or passed appropriately
    function getText(key) {
        var lang = appStorage.selectedLanguage; // Make sure appStorage is accessible here

        if (translations.hasOwnProperty(lang) && translations[lang].hasOwnProperty(key)) {
            return translations[lang][key];
        }
        // Fallback to English if the language or key is not found
        if (translations["en_US"] && translations["en_US"].hasOwnProperty(key)) {
           return translations["en_US"][key];
        }
        // Ultimate fallback
        return key; // Or some "Translation not found" message
    }

    Text {
        // Use the getText function for the title as well for consistency
        text: root.getText("title")
        color: appStorage.selectedTextColor
        font.pixelSize: 32
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListModel {
        id: themeModel
        ListElement {
            nameKey: "light"
            // A classic light theme: off-white background with dark text.
            textColor: "#2c3e50"  // Very dark blue/grey (almost black)
            bgColor: "#ecf0f1"  // Light, soft grey
            borderColor: "#bdc3c7"  // A slightly darker grey for the border
        }
        ListElement {
            nameKey: "contrast"
            // A true high-contrast theme: pure black and white for maximum readability.
            textColor: "#ffffff"  // Pure white
            bgColor: "#000000"  // Pure black
            borderColor: "#CF6679"  // White border to be visible against a dark background
        }
        ListElement {
            nameKey: "dark"
            // A popular dark theme: dark background with light text and a vibrant accent.
            textColor: "#ecf0f1"  // Light grey (same as light theme's bg)
            bgColor: "#34495e"      // Dark slate blue
            borderColor: "#00a8ff"  // A modern, bright blue for an accent border
        }
    }

    Repeater {
        model: themeModel

        Row {
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter
            height: 60 // It's good practice to define a height for rows in a Repeater if content size varies

            RadioButton {
                id: radio
                checked: appStorage.selectedTheme === model.nameKey // Or use index if that's how you determine the default
                ButtonGroup.group: root.themeGroup // Refer to themeGroup via root id
                anchors.verticalCenter: parent.verticalCenter

                // When a radio button is clicked, update the application's selected theme
                onCheckedChanged: {
                    if (checked) {
                        console.log("Selected theme:", model.nameKey)
                        appStorage.selectedTheme = model.nameKey
                        appStorage.selectedTextColor = model.textColor
                        appStorage.selectedBgColor = model.bgColor
                        appStorage.selectedBorderColor = model.borderColor
                    }
                }
            }

            SchemePreview {
                anchors.verticalCenter: parent.verticalCenter
                textColor: model.textColor
                bgColor: model.bgColor
                borderColor: model.borderColor
                // Use the getText function to dynamically get the translated name
                exampleText: root.getText(model.nameKey)
                borderWidth: 12 // Corrected from your previous example, assuming this is what you meant.
                                // If SchemePreview doesn't have borderWidth, this might be an error or for an inner element.
                radius: 5
                width: 250
                height: 60 // Ensure SchemePreview's height is consistent or managed

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        radio.checked = true; // This will also trigger radio.onClicked
                    }
                }
            }
        }
    }
}
