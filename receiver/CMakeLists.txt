cmake_minimum_required(VERSION 3.16)

project(
    receiver
    VERSION 0.1
    LANGUAGES CXX
)

# Enable Qt’s AUTOMOC and set C++17
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# (Your existing INSTALL_EXAMPLESDIR logic)
if(NOT DEFINED INSTALL_EXAMPLESDIR)
    set(INSTALL_EXAMPLESDIR "${CMAKE_INSTALL_PREFIX}/share/examples")
endif()
set(INSTALL_EXAMPLEDIR "${INSTALL_EXAMPLESDIR}/src/settings/item/settingsapp/DeviceUtilities/settingsapp")

#
# ─── Find Qt6 modules (no PkgConfig here) ─────────────────────────────────────────
#
find_package(
    Qt6
    REQUIRED
        COMPONENTS
            Gui
            Quick
            Multimedia
            Network
            QuickControls2
            Bluetooth
            Sql
            VncServer
            Concurrent
)

qt_standard_project_setup(REQUIRES 6.5)

# #
# # ─── Locate libgpiodcxx manually ───────────────────────────────────────────────────
# #
# # 1) Look for the C++ header <gpiod.hpp>
# find_path(LIBGPIODCXX_INCLUDE_DIR
#     NAMES gpiod.hpp
#     PATHS
#         /usr/include
#         /usr/include/gpiod
#         ${CMAKE_SYSROOT}/usr/include
#         ${CMAKE_SYSROOT}/usr/include/gpiod
# )

# # 2) Look for the shared library libgpiodcxx.so (or static .a)
# find_library(LIBGPIODCXX_LIBRARY
#     NAMES gpiodcxx
#     PATHS
#         /usr/lib
#         /usr/lib64
#         /usr/lib/aarch64-linux-gnu
#         ${CMAKE_SYSROOT}/usr/lib
#         ${CMAKE_SYSROOT}/usr/lib64
#         ${CMAKE_SYSROOT}/usr/lib/aarch64-linux-gnu
# )

# if(NOT LIBGPIODCXX_INCLUDE_DIR OR NOT LIBGPIODCXX_LIBRARY)
#     message(FATAL_ERROR
#         "Could not find libgpiodcxx:\n"
#         "  - Header (gpiod.hpp) in: ${LIBGPIODCXX_INCLUDE_DIR}\n"
#         "  - Library (libgpiodcxx.so) in: ${LIBGPIODCXX_LIBRARY}\n"
#         "Make sure libgpiodcxx is installed in your sysroot."
#     )
# endif()

# message(STATUS "Found libgpiodcxx include dir: ${LIBGPIODCXX_INCLUDE_DIR}")
# message(STATUS "Found libgpiodcxx library:    ${LIBGPIODCXX_LIBRARY}")

#
# ─── Create the executable ──────────────────────────────────────────────────────────
#
qt_add_executable(appreceiver
    src/main.cpp
    # gpiod_example.cpp            # your GPIO‐using code
    # … (you can add other .cpp/.h here) …
)

# Add your project root, BLE and buffer dirs, and the libgpiod include dir
target_include_directories(appreceiver PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}                  # project root
    # ${LIBGPIODCXX_INCLUDE_DIR}                   # for <gpiod.hpp>
    ${CMAKE_CURRENT_SOURCE_DIR}/src/background/ble
    ${CMAKE_CURRENT_SOURCE_DIR}/src/background/buffer
)

# Link against Qt6 modules + libgpiodcxx
target_link_libraries(appreceiver
    PRIVATE
        Qt6::Gui
        Qt6::Quick
        Qt6::Multimedia
        Qt6::Network
        Qt6::QuickControls2
        Qt6::Bluetooth
        Qt6::Sql
        Qt6::VncServer
        Qt6::Concurrent
        # ${LIBGPIODCXX_LIBRARY}      # e.g. /usr/lib/libgpiodcxx.so
)

#
# ─── QML module setup (unchanged) ──────────────────────────────────────────────────
#
set_source_files_properties(src/common/Constants.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(appreceiver
    URI receiver
    VERSION 1.0
    RESOURCES
        src/icon/back.svg
        src/icon/next.svg
        src/icon/arrow-left.svg
        src/icon/arrow-right.svg
        src/icon/cancel.svg
        src/icon/settings.svg
        src/icon/speak.svg
        src/icon/wearable-connection.svg
        src/icon/wearable-no-connection.svg
        src/icon/wifi-connection.svg
        src/icon/wifi-no-connection.svg
        src/icon/finger.svg
        src/icon/wearable.svg
        src/icon/receiver.svg
        src/icon/tick.svg
        src/devices/img/Acupebble.png
        src/audio/430811__mmoerth__strange-electronic-toilet-speech-wav.wav
        src/background/notification/alert.wav
        src/background/ble/assets/busy_dark.png
        src/icon/flag/en_US.svg
        src/icon/flag/es_ES.svg
        src/icon/flag/fr_FR.svg
        src/icon/flag/de_DE.svg
        src/icon/settings/step-1.svg
        src/icon/settings/step-2.svg
        src/icon/settings/step-3.svg
        src/icon/settings/step-4.svg
        src/icon/settings/step-5.svg
        src/icon/settings/step-6.svg
        src/icon/settings/step-7.svg
        src/video/example.mp4
    QML_FILES
        src/Main.qml
        src/audio/SoundTest.qml
        src/common/Constants.qml
        src/common/Keyboard.qml
        src/common/AutoScroller.qml
        src/common/BackButton.qml
        src/common/TapHint.qml
        src/home/HomeScreen.qml
        src/home/SettingsButton.qml
        src/onboarding/OnboardingScreen.qml
        src/question/QuestionScreen.qml
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
        src/setup/ConnectScreen.qml
        src/video/VideoScreen.qml
    SOURCES
        src/background/notification/mmapgpio.h
        src/background/notification/notificationmanager.h
        src/background/notification/notificationmanager.cpp
        src/background/audioplayer.h
        src/background/audioplayer.cpp
        src/background/ble/characteristicinfo.h
        src/background/ble/characteristicinfo.cpp
        src/background/ble/device.h
        src/background/ble/device.cpp
        src/background/ble/deviceinfo.h
        src/background/ble/deviceinfo.cpp
        src/background/ble/serviceinfo.h
        src/background/ble/serviceinfo.cpp
        src/request/networkmanager.h
        src/request/networkmanager.cpp
        src/background/buffer/buffer.h
        src/background/buffer/buffer.cpp
        src/background/buffer/database.h
        src/background/buffer/database.cpp
        src/background/buffer/datapacket.h
        src/background/buffer/senderworker.h
        src/background/ble/connectionworker.h
        src/background/ble/connectionworker.cpp
        src/background/hardware/power.h
        src/background/hardware/power.cpp
        src/background/diagnostic/fpsmonitor.h src/background/diagnostic/fpsmonitor.cpp
        src/background/thread/mainthreadbridge.h src/background/thread/mainthreadbridge.cpp

)

#
# ─── Installation rules (unchanged) ────────────────────────────────────────────────
#
include(GNUInstallDirs)
install(TARGETS appreceiver
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
