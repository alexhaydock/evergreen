#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

set -ouex pipefail
shopt -s nullglob

# Empty the resolv.conf file
# We do this as one of the last scripts that runs rather than
# shipping a blank file in the rootfs directory tree since
# doing so ends up killing DNS resolution for the rest of the
# build so we can't resolve any domains we need to resolve
# while building.
echo '' > /etc/resolv.conf

shopt -u nullglob
