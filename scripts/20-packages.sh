#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Source helper functions
# shellcheck source=/dev/null
source /ctx/scripts/copr-helpers.sh

# Install Universal Blue update service
copr_install_isolated "ublue-os/packages" "uupd"

# Bring in NetworkManager dev branch for access to CLAT
copr_upgrade_isolated "networkmanager/NetworkManager-main" "NetworkManager"

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
    crun-krun # Provides krun backend for Podman to start microVMs
    fastfetch
    go
    hadolint
    iperf3
    libcurl.x86_64 # Install full libcurl to obsolete libcurl-minimal (remove when resolved upstream: https://forge.fedoraproject.org/atomic-desktops/tracker/issues/120) - Sidenote I have no idea why it needs the .x86_64 but it was installing the .i686 version otherwise
    links2
    make
    nmap
    nyancat
    opentofu
    optipng
    pre-commit
    quickemu # Also pulls in QEMU
    rpminspect
    ShellCheck
    socat
    sshfs
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
    firefox
    firefox-langpacks
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
