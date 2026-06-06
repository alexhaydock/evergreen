#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/scripts/copr-helpers.sh

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::group:: Copy Bluefin Config from Common"

# See: https://github.com/ublue-os/bluefin/blob/0fa8f9031075742c035d634d1a9c49d59ecfd21b/build_files/shared/build.sh#L19
# TODO: Consider migrating these files into this repo
rsync -rvK /ctx/system_files/shared/ /

echo "::endgroup::"

echo "::group:: Copy Custom Files"

cp -rv /ctx/rootfs/. /

echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
dnf5 install -y glow # Terminal-based Markdown reader, used by Bluefin MOTD

# Install Universal Blue update service
copr_install_isolated "ublue-os/packages" "uupd"

echo "::endgroup::"

echo "::group:: System Configuration"

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

# Disable the old rpm-ostreed-automatic.timer
systemctl disable rpm-ostreed-automatic.timer

# Hide unwanted Desktop Files. Hidden removes mime associations
for file in htop nvtop; do
    if [[ -f "/usr/share/applications/$file.desktop" ]]; then
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/"$file".desktop
    fi
done

# Add the Flathub Flatpak remote and remove the Fedora Flatpak remote
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
systemctl disable flatpak-add-fedora-repos.service

# Disable third-party repos
for repo in negativo17-fedora-multimedia tailscale fedora-cisco-openh264; do
    if [[ -f "/etc/yum.repos.d/${repo}.repo" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
    fi
done

# Disable all COPR repos (should already be disabled by helpers, but ensure)
for i in /etc/yum.repos.d/_copr:*.repo; do
    if [[ -f "$i" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "$i"
    fi
done

# Disable RPM Fusion repos
for i in /etc/yum.repos.d/rpmfusion-*.repo; do
    if [[ -f "$i" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "$i"
    fi
done

# Disable fedora-coreos-pool if it exists
if [ -f /etc/yum.repos.d/fedora-coreos-pool.repo ]; then
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-coreos-pool.repo
fi

# Generate image-info.json for the MOTD to consume
/ctx/scripts/00-image-info.sh

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
