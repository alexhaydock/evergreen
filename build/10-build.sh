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
source /ctx/build/copr-helpers.sh

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

echo "::group:: Copy Bluefin Config from Common"

# Copy just files from @projectbluefin/common (includes 00-entry.just which imports 60-custom.just)
mkdir -p /usr/share/ublue-os/just/
shopt -s nullglob
cp -r /ctx/oci/common/bluefin/usr/share/ublue-os/just/* /usr/share/ublue-os/just/
shopt -u nullglob

echo "::endgroup::"

echo "::group:: Copy Custom Files"

# Consolidate custom Justfiles
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just

# Copy Flatpak preinstall files
mkdir -p /etc/flatpak/preinstall.d/
cp /ctx/custom/flatpaks/*.preinstall /etc/flatpak/preinstall.d/

# Copy Bluefin common files
# See: https://github.com/projectbluefin/common/tree/main
# TODO: Start migrating these files into this repo
cp -fvr /ctx/oci/common/shared/. /
cp -fvr /ctx/oci/common/bluefin/. /

echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
dnf5 install -y glow # Terminal-based Markdown reader, used by Bluefin motd

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

echo "::group:: System Configuration"

# Services (Fedora Native)
systemctl enable podman.socket

# Services (Bluefin Custom)
# See: https://github.com/ublue-os/aurorafin-shared/tree/main/system_files/shared/usr/lib/systemd
# See: https://github.com/projectbluefin/common/tree/main/system_files/bluefin/usr/lib/systemd
systemctl enable flatpak-preinstall.service

echo "::endgroup::"

# Generate image-info.json for the MOTD to consume
/ctx/build/00-image-info.sh

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
