#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

set -ouex pipefail
shopt -s nullglob

# Imported from: https://github.com/secureblue/secureblue/blob/971b5b1a66e2a9b054cafa30decf405280207805/files/scripts/setup-dnsconfd.sh#L9

# Empty the resolv.conf file
# We do this as one of the last scripts that runs rather than
# shipping a blank file in the rootfs directory tree since
# doing so ends up killing DNS resolution for the rest of the
# build so we can't resolve any domains we need to resolve
# while building.
echo '' > /etc/resolv.conf

# This is usually done by `dnsconfd config install`, which fails if
# NetworkManager.service is not running. We imitate this by:
# - installing /etc/NetworkManager/conf.d/dnsconfd.conf manually, which tells
#   NetworkManager to use com.redhat.dnsconfd instead of
#   org.freedesktop.resolve1, and
# - setting the permissions of /etc/resolv.conf manually here.
chown dnsconfd:root /etc/resolv.conf

shopt -u nullglob
