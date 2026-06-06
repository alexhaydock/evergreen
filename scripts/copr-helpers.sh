#!/usr/bin/bash
set -euo pipefail

###############################################################################
# COPR Helper Functions
###############################################################################
# These helper functions follow the @ublue-os/bluefin pattern for managing
# COPR repositories in a safe, isolated manner.
###############################################################################

copr_import(){
    local copr_name="$1"
    shift
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "ERROR: No packages specified for copr_install_isolated"
        return 1
    fi

    repo_id="copr:copr.fedorainfracloud.org:${copr_name//\//:}"

    echo "Installing ${packages[*]} from COPR $copr_name (isolated)"

    dnf5 -y copr enable "$copr_name"
    dnf5 -y copr disable "$copr_name"
}

copr_install_isolated() {
    copr_import

    dnf5 -y install --enablerepo="$repo_id" "${packages[@]}"

    echo "Installed ${packages[*]} from $copr_name"
}

# Where we're replacing a package that already exists on the system
# (useful where we want to use a COPR that ships a dev version of
# a system package and we need to force dnf to take the new one)
copr_upgrade_isolated() {
    copr_import

    dnf5 -y upgraded --enablerepo="$repo_id" "${packages[@]}"

    echo "Upgraded ${packages[*]} from $copr_name"
}
