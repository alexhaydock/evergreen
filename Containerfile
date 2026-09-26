##################
# Image Identity #
##################
ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="44"
ARG IMAGE_NAME="evergreen"
ARG IMAGE_PRETTY_NAME="Evergreen"
ARG IMAGE_VENDOR="alexhaydock"
ARG UBLUE_IMAGE_TAG="stable"

################
# Import Stage #
################
FROM ghcr.io/getsops/sops:v3.13.3-alpine@sha256:ae501277bf742f1662e0f881f43dd8fd6798b489a8058e921dbf6cda597140ea as sops

#################
# Context Stage #
#################
FROM scratch AS ctx

COPY scripts /scripts
COPY rootfs /rootfs

# Copy sops binary into container
COPY --from=sops /usr/local/bin/sops /system_files/shared/usr/bin/sops

###############
# Build Stage #
###############
FROM quay.io/fedora-ostree-desktops/silverblue:44

# Re-declare ARGs for this stage (Docker requires ARG re-declaration per stage)
ARG BASE_IMAGE_NAME
ARG FEDORA_MAJOR_VERSION
ARG IMAGE_NAME
ARG IMAGE_PRETTY_NAME
ARG IMAGE_VENDOR
ARG UBLUE_IMAGE_TAG

# Per-build metadata - redeclare separately so they don't bust the base cache
ARG SHA_HEAD_SHORT=""
ARG VERSION=""

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=secret,id=GITHUB_TOKEN \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/tmp \
    bash -euo pipefail -c ' \
        dnf5 config-manager setopt keepcache=1 install_weak_deps=0 && \
        /ctx/scripts/build.sh \
    '

### /opt
## Makes /opt writeable by default. Needs to be here to make the main image
## build strict (no /opt there). This is for downstream images/stuff like k0s.
## If you need /opt as an immutable real directory for build-time packages
## (e.g. google-chrome, docker-desktop), replace the next line with:
##   RUN rm /opt && mkdir /opt
RUN rm -rf /opt && ln -s /var/opt /opt

### INIT
## Required for bootc images
CMD ["/sbin/init"]

## Verify final image and contents are correct. --fatal-warnings catches issues.
RUN bootc container lint --fatal-warnings
