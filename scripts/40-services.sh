#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Apply preset files as created under /usr/lib/systemd/*-preset
systemctl preset-all
systemctl --global preset-all

# Preset files cannot mask services so to mask services we need
# to create the symlinks to /dev/null in the appropriate
# /etc/systemd subdirectory
ln -sv /dev/null /etc/systemd/user/localsearch-3.service

echo "::endgroup::"
