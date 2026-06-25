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

# Execute all numbered scripts in the scripts/
# directory (in numbered preference order)
for i in /ctx/scripts/[0-9][0-9]-*.sh; do
  [[ -f "$i" ]] || continue
  "$i"
done

# Restore default glob behavior
shopt -u nullglob

echo "Custom build complete!"
