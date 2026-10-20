#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

set -ouex pipefail
shopt -s nullglob

# Imported from: https://github.com/secureblue/secureblue/blob/971b5b1a66e2a9b054cafa30decf405280207805/files/scripts/setup-dnsconfd.sh#L9

# This is usually done by `dnsconfd config install`, which fails if
# NetworkManager.service is not running. We imitate this by:
# - installing /etc/NetworkManager/conf.d/dnsconfd.conf manually, which tells
#   NetworkManager to use com.redhat.dnsconfd instead of
#   org.freedesktop.resolve1, and
# - setting the permissions of /etc/resolv.conf manually here.
chown dnsconfd:root /etc/resolv.conf

# Download StevenBlack hosts file and process it into Unbound format
#
# We use NXDOMAIN here so that we sinkhole any domains underneath an
# ad domain that's on the list, rather than just serving 0.0.0.0 as an
# A record which might not be quite so robust
curl -fsSL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | \
  awk '$1=="0.0.0.0" { print "local-zone: \"" $2 "\" always_nxdomain" }' > "/etc/unbound/adblock.list"

shopt -u nullglob
