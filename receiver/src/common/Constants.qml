pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property string baseUrl: "http://192.168.1.230:3000"
    readonly property string defaultTheme: "light"
    readonly property string defaultTextColor: "#2c3e50"
    readonly property string defaultSecondaryColor: "#ecf0f1"
    readonly property string defaultBackgroundColor: "#bdc3c7"
    readonly property string defaultLanguage: "en"
    readonly property bool defaultNotifyAudio: true
    readonly property bool defaultNotifyHaptic: true
    readonly property bool defaultNtifyFlash: true
}
