cmake_minimum_required(VERSION 3.16)

project(receiver VERSION 0.1 LANGUAGES CXX)

set(CMAKE_PREFIX_PATH "/Users/advik/Qt/6.8.2/macos")

find_package(Qt6 REQUIRED COMPONENTS Gui Quick)

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
    QML_FILES
        src/Main.qml
        src/onboarding/OnboardingScreen.qml
        src/setup/SetupScreen.qml
        src/home/HomeScreen.qml
        src/common/Keyboard.qml
        src/common/BackButton.qml
        src/settings/SettingsScreen.qml
        src/setup/DeviceCard.qml
        src/home/SettingsButton.qml
    SOURCES
        src/devices/device.h src/devices/device.cpp
        src/background/notification.h src/background/notification.cpp
        src/devices/devicelist.h src/devices/devicelist.cpp
        SOURCES src/background/wifimanager.h src/background/wifimanager.cpp
        SOURCES src/background/audio.h src/background/audio.cpp
)

target_link_libraries(appreceiver
    PRIVATE Qt6::Gui Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appreceiver
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
