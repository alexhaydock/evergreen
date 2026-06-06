#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

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

# Generate image-info.json for the MOTD to consume
/ctx/scripts/00-image-info.sh

# Install packages
/ctx/scripts/20-packages.sh

# Manage services
/ctx/scripts/30-services.sh

# Cleanup
/ctx/scripts/99-cleanup.sh

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
