#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Imported from: https://github.com/secureblue/secureblue/blob/971b5b1a66e2a9b054cafa30decf405280207805/files/scripts/setup-dnsconfd.sh#L9

# This is usually done by `dnsconfd config install`, which fails if
# NetworkManager.service is not running. We imitate this by:
# - installing /etc/NetworkManager/conf.d/dnsconfd.conf manually, which tells
#   NetworkManager to use com.redhat.dnsconfd instead of
#   org.freedesktop.resolve1, and
# - setting the permissions of /etc/resolv.conf manually here.
echo '' > /etc/resolv.conf # Do not include this as a file or it will be used by the container during the build process and breaks DNS resolution for package installs
chown dnsconfd:root /etc/resolv.conf

echo "::endgroup::"
