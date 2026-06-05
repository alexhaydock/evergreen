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

# See: https://github.com/projectbluefin/common/tree/main
# TODO: Start migrating these files into this repo
cp -rv /ctx/oci/common/shared/. /
cp -rv /ctx/oci/common/bluefin/. /

echo "::endgroup::"

echo "::group:: Copy Custom Files"

cp -rv /ctx/rootfs/. /

echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
dnf5 install -y glow # Terminal-based Markdown reader, used by Bluefin MOTD

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

# Generate image-info.json for the MOTD to consume
/ctx/scripts/00-image-info.sh

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
