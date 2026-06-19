#!/usr/bin/env bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Enable nullglob for all glob operations to prevent failures on empty matches
shopt -s nullglob

# Generate image-info.json for the MOTD to consume
/ctx/scripts/00-image-info.sh

# Copy configs into container
/ctx/scripts/10-config.sh

# Install packages
/ctx/scripts/20-packages.sh

# Cleanup
/ctx/scripts/99-cleanup.sh

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
