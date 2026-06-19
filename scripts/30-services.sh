#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Services (Fedora Native)
systemctl enable podman.socket

# Services (Bluefin Custom)
# See: https://github.com/ublue-os/aurorafin-shared/tree/main/system_files/shared/usr/lib/systemd
# See: https://github.com/projectbluefin/common/tree/main/system_files/bluefin/usr/lib/systemd
systemctl --global enable podman-auto-update.timer
systemctl enable dconf-update.service
systemctl enable flatpak-preinstall.service

# Universal Blue updater
systemctl enable uupd.timer

# Universal Blue setup services
systemctl --global enable ublue-user-setup.service
systemctl enable ublue-system-setup.service

# Enable fwupd
systemctl enable fwupd.service

# Enable pcscd service for use with age-plugin-yubikey
systemctl enable pcscd.service

# Disable the old rpm-ostreed-automatic.timer
systemctl disable rpm-ostreed-automatic.timer

echo "::endgroup::"
