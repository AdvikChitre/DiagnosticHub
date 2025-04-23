cmake_minimum_required(VERSION 3.16)

project(
    receiver
    VERSION 0.1
    LANGUAGES CXX
)

# Set in example
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT DEFINED INSTALL_EXAMPLESDIR)
    set(INSTALL_EXAMPLESDIR "${CMAKE_INSTALL_PREFIX}/share/examples")
endif()
set(INSTALL_EXAMPLEDIR "${INSTALL_EXAMPLESDIR}/src/settings/item/settingsuiapp/DeviceUtilities/settingsapp")


add_subdirectory(src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI)
# add_subdirectory(src/QtButtonImageProvider)

# set(CMAKE_PREFIX_PATH "/Users/advik/Qt/6.8.2/macos")

# set_source_files_properties(src/SettingsUI/Globals.qml
#     PROPERTIES
#         QT_QML_SINGLETON_TYPE true
# )

find_package(
    Qt6
    REQUIRED COMPONENTS
    Gui
    Quick
    Multimedia
    Network
    NetworkSettings
    QuickControls2
)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appreceiver
    src/main.cpp
)

qt_add_qml_module(appreceiver
    URI receiver
    VERSION 1.0
    RESOURCES
        src/icon/back.svg
        src/icon/next.svg
        src/icon/select.svg
        src/icon/settings.svg
        src/icon/speak.svg
        src/icon/wearable-connection.svg
        src/icon/wearable-no-connection.svg
        src/icon/wifi-connection.svg
        src/icon/wifi-no-connection.svg
        src/devices/img/Acupebble.png
        src/audio/430811__mmoerth__strange-electronic-toilet-speech-wav.wav
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/icons/back.svg
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/icons/network.svg
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/icons/Alert_yellow_1x.png
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/icons/WifiAnim_black_2x.png
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/icons/Wifi_lightgray_2x.png
    QML_FILES
        src/Main.qml
        src/audio/SoundTest.qml
        src/background/WifiScreen.qml
        src/common/Keyboard.qml
        src/common/BackButton.qml
        src/home/HomeScreen.qml
        src/home/SettingsButton.qml
        src/onboarding/OnboardingScreen.qml
        src/settings/SettingsScreen.qml
        src/settings/SettingsProgressBar.qml
        src/settings/item/Language.qml
        src/settings/item/Colours.qml
        src/settings/item/Notifications.qml
        src/setup/SetupScreen.qml
        src/setup/DeviceCard.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Globals.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/SettingsUI.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/CustomSwitch.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/CustomTableView.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/AddressListEntry.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/ComboBoxEntry.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/EditWiredSettings.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/IpAddressTextField.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/NetworkListView.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/NetworkSettings.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/PassphraseEnter.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/WifiSelectorDelegate.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/WifiSettings.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/WifiSignalMonitor.qml
        src/settings/item/settingsuiapp/DeviceUtilities/SettingsUI/Network/WiredSettings.qml
        src/settings/item/settingsuiapp/DeviceUtilities/QtButtonImageProvider/QtButton.qml
    SOURCES
        src/devices/device.h src/devices/device.cpp
        src/background/notification.h src/background/notification.cpp
        src/devices/devicelist.h src/devices/devicelist.cpp
        src/background/wifimanager.h src/background/wifimanager.cpp
        src/background/audioplayer.h src/background/audioplayer.cpp
        src/settings/item/settingsuiapp/DeviceUtilities/QtButtonImageProvider/plugin_p.h src/settings/item/settingsuiapp/DeviceUtilities/QtButtonImageProvider/plugin.cpp
        src/settings/item/settingsuiapp/DeviceUtilities/QtButtonImageProvider/qtbuttonimageprovider.h src/settings/item/settingsuiapp/DeviceUtilities/QtButtonImageProvider/qtbuttonimageprovider.cpp
    # IMPORT_PATH
    #     src/SettingsUI
    #     src/SettingsUI/Network
)

target_link_libraries(appreceiver
    PRIVATE
        Qt6::Gui
        Qt6::Quick
        Qt6::Multimedia
        Qt6::Network
        Qt6::NetworkSettings
        Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appreceiver
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
