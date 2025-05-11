pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property string baseUrl: "http://192.168.1.230:3000/"
    readonly property string defaultPrimaryColor: "#000000"
    readonly property string defaultSecondaryColor: "#000000"
    readonly property string defaultBackgroundColor: "#000000"
    readonly property string defaultLanguage: "en"
    readonly property string defaultTheme: "light"
}
