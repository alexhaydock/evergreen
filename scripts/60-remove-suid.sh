#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Primarily based on secureblue's approach to doing this upstream:
# https://github.com/secureblue/secureblue/blob/971b5b1a66e2a9b054cafa30decf405280207805/files/scripts/removesuid.sh#L16

# I don't use an exclusion list here like secureblue do, since
# I have no need for nvidia nonsense and I'm not shipping
# hardened_malloc like they do

set_caps_if_present() {
    local caps="$1"
    local binary_path="$2"
    if [[ -f "${binary_path}" ]]; then
        echo "Setting caps ${caps} on ${binary_path}"
        setcap "${caps}" "${binary_path}"
        echo "Set caps ${caps} on ${binary_path}"
    fi
}

# Strip SUID/SGID bit from executables
find /usr -type f -perm /6000 -print0 | while IFS= read -r -d '' binary; do
    echo "Removing setuid/setgid bits from ${binary}"
    chmod ug-s "${binary}"
done

# Remove some executables we specifically don't want
rm -f /usr/bin/chsh /usr/bin/chfn /usr/bin/pkexec /usr/bin/sudo /usr/bin/su

# Set capabilities on some binaries that need them
set_caps_if_present "cap_sys_admin=ep" "/usr/bin/fusermount3"
set_caps_if_present "cap_dac_read_search,cap_audit_write=ep" "/usr/sbin/unix_chkpwd"

# spice-client-glib-usb-acl-helper drops all capabilities except CAP_FOWNER:
# https://gitlab.freedesktop.org/spice/spice-gtk/-/blob/7a2779182b003ec5e8192dc5186f0b1c3eb8e831/src/spice-client-glib-usb-acl-helper.c#L304
set_caps_if_present "cap_fowner=ep" "/usr/libexec/spice-gtk-$(uname -m)/spice-client-glib-usb-acl-helper"

echo "::endgroup::"
