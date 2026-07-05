#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# This script is based on the "Pinehole" minimal reimplementation
# of the Pi-Hole featureset that I created for my Pinewall router
# project.
#
# See: https://github.com/alexhaydock/pinewall-config/blob/59100f056ef5017630f12fa4981509c2e9bfb4ef/config/etc/periodic/daily/pinehole
#
# Since we're shipping an image that we can build semi-declaratively,
# we don't need to run this as a service. We can just fetch and
# compile the ad list once during the build process and ship it
# within the image.

# Start an unbound config with just the `server:` block we need
echo 'server:' > /etc/unbound/conf.d/zz-pinehole.conf

# Download StevenBlack hosts file and process it into Unbound format
#
# We use NXDOMAIN here so that we sinkhole any domains underneath an
# ad domain that's on the list, rather than just serving 0.0.0.0 as an
# A record which might not be quite so robust
curl -fsSL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | \
  awk '$1=="0.0.0.0" { print "    local-zone: \"" $2 "\" always_nxdomain" }' >> /etc/unbound/conf.d/zz-pinehole.conf

# Check to ensure that the file has more than 10,000 entries
# and fail the CI run if it doesn't
if [ "$(wc -l /etc/unbound/conf.d/zz-pinehole.conf | cut -d " " -f1)" -gt "10000" ]; then
    echo "Adblock list count validated to be >10,000. Assuming we've downloaded it successfully."
else
    echo "Adblock list count is <10,000. Maybe something is broken with the download?"
    echo "Throwing error code to stop the CI build now."
    exit 10
fi

echo "::endgroup::"
