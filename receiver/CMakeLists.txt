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
set(INSTALL_EXAMPLEDIR "${INSTALL_EXAMPLESDIR}/src/settings/item/settingsapp/DeviceUtilities/settingsapp")

find_package(
    Qt6
    REQUIRED COMPONENTS
        Gui
        Quick
        Multimedia
        Network
        QuickControls2
        Bluetooth
        Sql
)

qt_standard_project_setup(REQUIRES 6.5)

# add_subdirectory(extern/qtotaupdate)

qt_add_executable(appreceiver
    src/main.cpp
)

# Add include directory for the project's source files
target_include_directories(appreceiver PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
INCLUDE_DIRECTORIES("src/background/ble")
INCLUDE_DIRECTORIES("src/background/buffer")

set_source_files_properties(src/common/Constants.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
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
        src/background/ble/assets/busy_dark.png
    QML_FILES
        src/Main.qml
        src/audio/SoundTest.qml
        src/background/ble/Characteristics.qml
        src/background/ble/Devices.qml
        src/background/ble/Dialog.qml
        src/background/ble/Header.qml
        src/background/ble/Label.qml
        src/background/ble/BLETest.qml
        src/background/ble/Menu.qml
        src/background/ble/Services.qml
        src/common/Constants.qml
        src/common/Keyboard.qml
        src/common/AutoScroller.qml
        src/common/BackButton.qml
        src/home/HomeScreen.qml
        src/home/SettingsButton.qml
        src/onboarding/OnboardingScreen.qml
        src/settings/SettingsScreen.qml
        src/settings/SettingsProgressBar.qml
        src/settings/item/Language.qml
        src/settings/item/colours/Colours.qml
        src/settings/item/colours/SchemePreview.qml
        src/settings/item/notifications/Notifications.qml
        src/settings/item/notifications/RoundedSwitch.qml
        src/settings/item/wifi/WifiScreen.qml
        src/settings/item/wifi/PassphraseEnter.qml
        src/setup/SetupScreen.qml
        src/setup/DeviceCard.qml
        src/setup/ActivationScreen.qml
        src/setup/DateOfBirthPopup.qml
        src/setup/DateDigitField.qml
    SOURCES
        src/background/notification/notification.h src/background/notification/notification.cpp
        src/background/audioplayer.h src/background/audioplayer.cpp
        src/background/ble/characteristicinfo.h src/background/ble/characteristicinfo.cpp
        src/background/ble/device.h src/background/ble/device.cpp
        src/background/ble/deviceinfo.h src/background/ble/deviceinfo.cpp
        src/background/ble/serviceinfo.h src/background/ble/serviceinfo.cpp
        src/request/networkmanager.h src/request/networkmanager.cpp
        src/background/buffer/buffer.h src/background/buffer/buffer.cpp
        src/background/buffer/database.h src/background/buffer/database.cpp
        src/background/buffer/datapacket.h
        src/background/buffer/senderworker.h
        src/background/ble/connectionworker.h src/background/ble/connectionworker.cpp
)

target_link_libraries(appreceiver
    PRIVATE
        Qt6::Gui
        Qt6::Quick
        Qt6::Multimedia
        Qt6::Network
        Qt6::QuickControls2
        # QtOtaUpdate
        Qt6::Bluetooth
        Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appreceiver
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
