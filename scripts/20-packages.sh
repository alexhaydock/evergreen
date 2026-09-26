#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Source helper functions
# shellcheck source=/dev/null
source /ctx/scripts/copr-helpers.sh

# Install Universal Blue update service
copr_install_isolated "ublue-os/packages" "uupd"

# Bring in NetworkManager dev branch for access to CLAT
#copr_upgrade_isolated "networkmanager/NetworkManager-main" "NetworkManager"

# Define package install set
FEDORA_PACKAGES=(
    ShellCheck
    age
    ansible
    ansible-lint
    bat # Like cat, but cooler
    beets
    below
    binwalk
    bpftop
    conntrack-tools
    crun-krun # Provides krun backend for Podman to start microVMs
    fakeroot
    fastfetch
    go
    hadolint
    iperf3
    just
    links2
    make
    mediainfo
    nmap
    nyancat
    opentofu
    optipng
    pre-commit
    quickemu # Also pulls in QEMU
    rpi-imager # Flatpak updates too slowly: https://github.com/flathub/org.raspberrypi.rpi-imager/issues/66
    rpminspect
    socat
    sshfs
    tcpdump
    vhs # For creating shell recordings for documentation
    waypipe # Wayland session forwarding
    wireshark
    yamllint
    yq
    yt-dlp
)

# Install all Fedora packages (bulk - safe from COPR injection)
echo "Installing ${#FEDORA_PACKAGES[@]} packages from Fedora repos..."
dnf -y install --allowerasing "${FEDORA_PACKAGES[@]}"

# Packages to exclude - common to all versions
EXCLUDED_PACKAGES=(
    cups
    fedora-bookmarks
    fedora-chromium-config
    fedora-chromium-config-gnome
    gnome-extensions-app
    gnome-shell-extension-background-logo
    gnome-software
    gnome-software-rpm-ostree
    gnome-terminal-nautilus
    gnome-tour
    podman-docker
    sssd-client
    sssd-common
    sssd-kcm
    sssd-krb5-common
    sssd-nfs-idmap
    yelp
)

# Remove excluded packages if they are installed
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    readarray -t INSTALLED_EXCLUDED < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}" 2>/dev/null || true)
    if [[ "${#INSTALLED_EXCLUDED[@]}" -gt 0 ]]; then
        dnf -y remove "${INSTALLED_EXCLUDED[@]}"
    else
        echo "No excluded packages found to remove."
    fi
fi

# Add the Flathub Flatpak remote
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "::endgroup::"
