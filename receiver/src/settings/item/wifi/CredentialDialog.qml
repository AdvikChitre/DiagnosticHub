import QtQuick
import QtQuick.Controls

Dialog {
    id: passDialog
    property alias serviceName: title
    property string passphrase
    signal passphraseEntered(string pass)
    title: "Enter Passphrase"

    Column {
        spacing: 10
        padding: 10
        TextInput { id: input; placeholderText: "Passphrase"; echoMode: TextInput.Password }
        Row {
            spacing: 10
            Button { text: "Cancel"; onClicked: passDialog.close() }
            Button {
                text: "OK"
                onClicked: {
                    passDialog.passphraseEntered(input.text);
                    passDialog.close();
                }
            }
        }
    }

    function openPassphraseDialog(name) {
        passDialog.title = "Passphrase for " + name;
        passDialog.open();
        passDialog.passphraseEntered.connect(function(p) { passDialog.passphraseEntered.disconnect(); pass = p; });
        return pass;
    }
}
