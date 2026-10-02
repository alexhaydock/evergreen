#!/usr/bin/env bash

# Based on the script from Bazzite here:
# https://github.com/ublue-os/bazzite/blob/main/build_files/build-initramfs

set -eoux pipefail

echo "::group::Executing build-initramfs"
trap 'echo "::endgroup::"' EXIT

QUALIFIED_KERNEL="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' "kernel${KERNEL_SUFFIX:+-${KERNEL_SUFFIX}}")"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree --add fido2 -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img
