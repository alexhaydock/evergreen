#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

set -ouex pipefail
shopt -s nullglob

# Download StevenBlack hosts file and process it into Unbound format
#
# We use NXDOMAIN here so that we sinkhole any domains underneath an
# ad domain that's on the list, rather than just serving 0.0.0.0 as an
# A record which might not be quite so robust
curl -fsSL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | \
  awk '$1=="0.0.0.0" { print "local-zone: \"" $2 "\" always_nxdomain" }' > "/etc/unbound/adblock.list"

shopt -u nullglob
