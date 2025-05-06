#!/usr/bin/env bash
# Setup device from fresh yocto image

# Add raspberry pi configurations for DFRobot touchscreen to /boot/config.txt
sudo tee -a /boot/config.txt <<'EOF'

#### remove black borders
disable_overscan=1

#### set specific CVT mode
hdmi_cvt 1024 600 60 6 0 0 0

#### set CVT as default
hdmi_group=2
hdmi_mode=87
EOF


# Wifi module
echo 'IMAGE_INSTALL:append = " networkmanager wpa-supplicant"' >> local.conf

# HTTPS
# TODO: check if needed
echo 'IMAGE_INSTALL:append = " openssl"' >> local.conf
echo 'IMAGE_INSTALL:append = " ca-certificates"' >> local.conf

# BLE
rfkill unblock bluetooth
