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

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

echo "::group:: System Configuration"

# Services (Fedora Native)
systemctl enable podman.socket

# Services (Bluefin Custom)
# See: https://github.com/ublue-os/aurorafin-shared/tree/main/system_files/shared/usr/lib/systemd
# See: https://github.com/projectbluefin/common/tree/main/system_files/bluefin/usr/lib/systemd
systemctl enable dconf-update.service
systemctl enable flatpak-preinstall.service
systemctl enable rechunker-group-fix.service
systemctl enable ublue-system-setup.service
systemctl enable ublue-user-setup.service

# Generate image-info.json for the MOTD to consume
/ctx/scripts/00-image-info.sh

echo "::endgroup::"

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
