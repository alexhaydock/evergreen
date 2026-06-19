#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Copy Bluefin / Universal Blue configs from upstream common container
# See: https://github.com/ublue-os/bluefin/blob/0fa8f9031075742c035d634d1a9c49d59ecfd21b/build_files/shared/build.sh#L19
# TODO: Consider migrating these files selectively into this repo
#
# See: https://github.com/ublue-os/bluefin/tree/main/system_files
# See: https://github.com/ublue-os/aurorafin-shared/tree/main/system_files
rsync -rvK /ctx/system_files/shared/ /

# Copy custom files from this repo (doing this second allows us to override
# any files from the Bluefin config above by putting them in this repo)
rsync -rvK /ctx/rootfs/. /

echo "::endgroup::"
