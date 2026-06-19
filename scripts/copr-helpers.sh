#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# COPR Helper Functions
###############################################################################
# These helper functions are adapted from the @ublue-os/bluefin pattern for
# managing COPR repositories in a safe, isolated manner.
###############################################################################

copr_do_isolated() {
    local action="$1"
    shift

    local copr_name="$1"
    shift
    local packages=("$@")

    local repo_id="copr:copr.fedorainfracloud.org:${copr_name//\//:}"

    dnf5 -y copr enable "$copr_name"
    dnf5 -y copr disable "$copr_name"

    dnf5 -y "$action" --enablerepo="$repo_id" "${packages[@]}"
}

copr_install_isolated() {
    copr_do_isolated install "$@"
}

# Where we're replacing a package that already exists on the system
# (useful where we want to use a COPR that ships a dev version of
# a system package and we need to force dnf to take the new one)
copr_upgrade_isolated() {
    copr_do_isolated upgrade "$@"
}
