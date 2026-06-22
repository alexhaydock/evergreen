#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Copy Bluefin / Universal Blue configs from upstream common container
# See: https://github.com/ublue-os/bluefin/blob/0fa8f9031075742c035d634d1a9c49d59ecfd21b/build_files/shared/build.sh#L19
#
# I previously did this indiscriminately but I'm now doing it more selectively
# so that I'm not bringing in unnecessary udev rules, Brew configs etc
#
# See: https://github.com/ublue-os/bluefin/tree/main/system_files
# See: https://github.com/ublue-os/aurorafin-shared/tree/main/system_files

# Might as well bring in the Bazaar branding
rsync -rvK /ctx/system_files/shared/etc/bazaar/ /etc/bazaar/

# Bring in container registry YAMLs and pubkeys
# We don't need the Bluefin policy.json since I'm already
# shipping my own version of that file
mkdir -p /etc/containers
rsync -rvK /ctx/system_files/shared/etc/containers/registries.d/ /etc/containers/registries.d/
mkdir -p /usr/lib/pki
rsync -rvK /ctx/system_files/shared/usr/lib/pki/containers/ /usr/lib/pki/containers/

# Bring in ujust
cp -fv /ctx/system_files/shared/usr/bin/ujust /usr/bin/ujust
chmod +x /usr/bin/ujust

# Bring in systemd preset files
rsync -rvK /ctx/system_files/shared/usr/lib/systemd/ /usr/lib/systemd/

# Import Flatpak config override for Bazaar
cp -fv /ctx/system_files/shared/usr/lib/tmpfiles.d/bazaar-flatpak.conf /usr/lib/tmpfiles.d/bazaar-flatpak.conf
mkdir -p /usr/share/ublue-os/flatpak-overrides
cp -fv /ctx/system_files/shared/usr/share/ublue-os/flatpak-overrides/io.github.kolunmi.Bazaar /usr/share/ublue-os/flatpak-overrides/io.github.kolunmi.Bazaar

# Copy sops
# We put this in /usr/bin rather than /usr/local/bin
# since /usr/local/bin is a symlink to /var/usrlocal
cp -fv /ctx/system_files/shared/usr/bin/sops /usr/bin/sops
chmod +x /usr/bin/sops

# Might as well bring in the wallpapers and branding
rsync -rvK /ctx/system_files/shared/usr/share/backgrounds/bluefin/ /usr/share/backgrounds/bluefin/
rsync -rvK /ctx/system_files/shared/usr/share/gnome-background-properties/ /usr/share/gnome-background-properties/
rsync -rvK /ctx/system_files/shared/usr/share/icons/ /usr/share/icons/
rsync -rvK /ctx/system_files/shared/usr/share/pixmaps/ /usr/share/pixmaps/
rsync -rvK /ctx/system_files/shared/usr/share/plymouth/themes/ /usr/share/plymouth/themes/
rsync -rvK /ctx/system_files/shared/usr/share/ublue-os/bluefin-logos/ /usr/share/ublue-os/bluefin-logos/

# Copy custom files from this repo (doing this second allows us to override
# any files from the Bluefin config above by putting them in this repo)
rsync -rvK /ctx/rootfs/. /

echo "::endgroup::"
