#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Copy sops binary
# We put this in /usr/bin rather than /usr/local/bin
# since /usr/local/bin is a symlink to /var/usrlocal
cp -fv /ctx/system_files/shared/usr/bin/sops /usr/bin/sops
chmod +x /usr/bin/sops

# Copy custom files from the rootfs/ dir in this repo
rsync -rvK /ctx/rootfs/. /

echo "::endgroup::"
