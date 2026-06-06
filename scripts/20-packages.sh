#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Source helper functions
# shellcheck source=/dev/null
source /ctx/scripts/copr-helpers.sh

# Install Universal Blue update service
copr_install_isolated "ublue-os/packages" "uupd"

# Bring in NetworkManager dev branch for access to CLAT
copr_install_isolated "networkmanager/NetworkManager-main" "NetworkManager"
dnf -y install NetworkManager # Make sure to install it to get the latest

# Define package install set
FEDORA_PACKAGES=(
    age
    ansible
    ansible-lint
    bat # Like cat, but cooler
    beets
    below
    bpftop
    conntrack-tools
    fastfetch
    go
    hadolint
    iperf3
    links2
    make
    nmap
    nyancat
    opentofu
    optipng
    pcsc-lite # Provides `pcscd.service` for use with `age-plugin-yubikey`
    pre-commit
    quickemu # Also pulls in QEMU
    rpminspect
    socat
    sshfs
    vhs # For creating shell recordings for documentation
    waypipe # Wayland session forwarding
    wireshark
    yamllint
    yt-dlp
)

# Install all Fedora packages (bulk - safe from COPR injection)
echo "Installing ${#FEDORA_PACKAGES[@]} packages from Fedora repos..."
dnf -y install "${FEDORA_PACKAGES[@]}"

# Packages to exclude - common to all versions
EXCLUDED_PACKAGES=(
    cosign
    cups
    fedora-bookmarks
    fedora-chromium-config
    fedora-chromium-config-gnome
    firefox
    firefox-langpacks
    gnome-extensions-app
    gnome-shell-extension-background-logo
    gnome-software
    gnome-software-rpm-ostree
    gnome-terminal-nautilus
    podman-docker
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

echo "::endgroup::"
