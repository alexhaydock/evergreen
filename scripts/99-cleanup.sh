#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# CLEAN_ROOT: filesystem prefix applied to all paths.
# Defaults to "/" so the variable is never empty (satisfies SC2115).
# Set to a temp directory during unit tests.
CLEAN_ROOT="${CLEAN_ROOT:-/}"

# Revert back to upstream defaults
dnf5 config-manager setopt keepcache=0
dnf5 versionlock clear

# Make sure profile files are executable
chmod +x /etc/profile.d/*.sh

# Hide unwanted Desktop Files. Hidden removes mime associations
for file in htop nvtop; do
    if [[ -f "/usr/share/applications/$file.desktop" ]]; then
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/"$file".desktop
    fi
done

# Disable third-party repos
for repo in negativo17-fedora-multimedia tailscale fedora-cisco-openh264; do
    if [[ -f "/etc/yum.repos.d/${repo}.repo" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
    fi
done

# Disable all COPR repos (should already be disabled by helpers, but ensure)
for i in /etc/yum.repos.d/_copr:*.repo; do
    if [[ -f "$i" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "$i"
    fi
done

# Disable RPM Fusion repos
for i in /etc/yum.repos.d/rpmfusion-*.repo; do
    if [[ -f "$i" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "$i"
    fi
done

# Disable fedora-coreos-pool if it exists
if [ -f /etc/yum.repos.d/fedora-coreos-pool.repo ]; then
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-coreos-pool.repo
fi

# Remove the deprecated old motd method that's still shipped
# upstream for some reason
if [ -f /etc/profile.d/ublue-motd.sh ]; then
    rm -v /etc/profile.d/ublue-motd.sh
fi
if [ -f /etc/profile.d/user-motd.sh ]; then
    rm -v /etc/profile.d/user-motd.sh
fi

# Remove any remnants of Homebrew config
if [ -d /usr/share/ublue-os/homebrew ]; then
    rm -rv /usr/share/ublue-os/homebrew
fi
if [ -d /var/cache/homebrew ]; then
    rm -rv /var/cache/homebrew
fi
if [ -d /var/lib/homebrew ]; then
    rm -rv /var/lib/homebrew
fi
if [ -d /var/home/linuxbrew ]; then
    rm -rv /var/home/linuxbrew
fi

# This comes last because we can't *ever* afford to ship fedora flatpaks on the image
systemctl disable flatpak-add-fedora-repos.service
systemctl mask flatpak-add-fedora-repos.service
rm -f "${CLEAN_ROOT}/usr/lib/systemd/system/flatpak-add-fedora-repos.service"

rm -rf "${CLEAN_ROOT}/.gitkeep"
find "${CLEAN_ROOT}/var"/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find "${CLEAN_ROOT}/var/cache"/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;

# Clear tmpfs-backed runtime directories without deleting the directories
# themselves. Buildah may have bind mounts in these paths during RUN, so
# replacing the mountpoint can fail with EBUSY.
for runtime_dir in tmp boot; do
    mkdir -p "${CLEAN_ROOT:?}/${runtime_dir}"
    find "${CLEAN_ROOT:?}/${runtime_dir}" -mindepth 1 -maxdepth 1 -print0 |
        while IFS= read -r -d '' entry; do
            if mountpoint -q "${entry}" 2>/dev/null; then
                continue
            fi
            rm -rf "${entry}"
        done
done

# /run can contain nested bind mounts created by the build container. Walk it
# depth-first so we can remove image-owned files like /run/dnf while leaving
# mounted files and any directories that still contain them alone.
mkdir -p "${CLEAN_ROOT:?}/run"
find "${CLEAN_ROOT:?}/run" -mindepth 1 -depth -print0 |
    while IFS= read -r -d '' entry; do
        if mountpoint -q "${entry}" 2>/dev/null; then
            continue
        fi
        if [[ -d "${entry}" ]]; then
            rmdir "${entry}" 2>/dev/null || true
            continue
        fi
        rm -f "${entry}"
    done

echo "::endgroup::"
