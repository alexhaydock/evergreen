#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

systemctl preset-all
systemctl --global preset-all

echo "::endgroup::"
