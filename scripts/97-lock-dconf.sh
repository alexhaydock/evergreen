#!/usr/bin/env bash

# Iterate through the settings configured by dconf in this repo
# and lock them in dconf locks, to make this more declarative-ish

echo "::group:: ===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

set -ouex pipefail
shopt -s nullglob

mkdir -p /etc/dconf/db/distro.d/locks

for f in /etc/dconf/db/distro.d/99-*; do [ -f "$f" ] && awk '/^\[.*\]/{g=$0; gsub(/^\[|\]$/,"",g); next} /^[[:space:]]*($|#|;)/{next} /=/{k=$0; sub(/=.*/,"",k); gsub(/^[[:space:]]+|[[:space:]]+$/,"",k); print "/" g "/" k}' "$f" > "/etc/dconf/db/distro.d/locks/$(basename "$f")"; done
