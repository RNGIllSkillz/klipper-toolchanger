#!/bin/bash

KLIPPER_PATH="${HOME}/klipper"
INSTALL_PATH="${HOME}/klipper-toolchanger"
BRANCH_NAME="MyConfig"

set -eu
export LC_ALL=C

function preflight_checks {
    if [ "$EUID" -eq 0 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

function remove_existing_install {
    if [ -d "${INSTALL_PATH}" ]; then
        echo "[REMOVE] Existing installation found. Removing..."
        rm -rf "${INSTALL_PATH}"
        printf "[REMOVE] Existing installation removed!\n\n"
    fi
}

function check_download {
    local installdirname installbasename
    installdirname="$(dirname ${INSTALL_PATH})"
    installbasename="$(basename ${INSTALL_PATH})"

    echo "[DOWNLOAD] Downloading repository..."
    if git -C $installdirname clone -b $BRANCH_NAME https://github.com/RNGIllSkillz/klipper-toolchanger.git $installbasename; then
        chmod +x ${INSTALL_PATH}/install.sh
        printf "[DOWNLOAD] Download complete!\n\n"
    else
        echo "[ERROR] Download of git repository failed!"
        exit -1
    fi
}

function link_extension {
    echo "[INSTALL] Linking extension to Klipper..."
    for file in "${INSTALL_PATH}"/klipper/extras/*.py; do ln -sfn "${file}" "${KLIPPER_PATH}/klippy/extras/"; done
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}

printf "\n======================================\n"
echo "- Klipper toolchanger install script -"
printf "======================================\n\n"

# Run steps
preflight_checks
remove_existing_install
check_download
link_extension
restart_klipper
