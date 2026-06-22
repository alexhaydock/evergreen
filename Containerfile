###############################################################################
# PROJECT NAME CONFIGURATION
###############################################################################
# Name: evergreen
#
# This name should be used consistently throughout the repository in:
#   - Justfile: export image_name := env("IMAGE_NAME", "your-name-here")
#   - README.md: # your-name-here (title)
#   - artifacthub-repo.yml: repositoryID: your-name-here
#   - custom/ujust/README.md: localhost/your-name-here:stable (in bootc switch example)
#
# The project name defined here is the single source of truth for your
# custom image's identity. When changing it, update all references above
# to maintain consistency.
###############################################################################

###############################################################################
# MULTI-STAGE BUILD ARCHITECTURE
###############################################################################
# This Containerfile follows the Bluefin architecture pattern as implemented in
# @projectbluefin/distroless. The architecture layers OCI containers together:
#
# 1. Context Stage (ctx) - Combines resources from:
#    - Local build scripts and custom files
#    - @projectbluefin/common - Desktop configuration shared with Aurora 
#
# 2. Base Image Options:
#    - `ghcr.io/ublue-os/silverblue-main:latest` (Fedora and GNOME)
#    - `ghcr.io/ublue-os/base-main:latest` (Fedora and no desktop 
#    - `quay.io/centos-bootc/centos-bootc:stream10 (CentOS-based)` 
#
# See: https://docs.projectbluefin.io/contributing/ for architecture diagram
###############################################################################

##################
# Image Identity # - these define how bootc, fastfetch, and the ublue ecosystem recognize your image. Change these to match your project name.
##################
ARG BASE_IMAGE_NAME="silverblue"
ARG FEDORA_MAJOR_VERSION="44"
ARG IMAGE_NAME="evergreen"
ARG IMAGE_PRETTY_NAME="Evergreen"
ARG IMAGE_VENDOR="alexhaydock"
ARG UBLUE_IMAGE_TAG="stable"

################
# Import Stage # - Import the common image from Bluefin/Universal Blue upstream
################
FROM ghcr.io/projectbluefin/common:latest@sha256:c1ab315776c85f342dc6641f59e4bf3e5037eaa6ea05d64192e34fe60da96644 AS common
FROM ghcr.io/getsops/sops:v3.13.1-alpine@sha256:032061a34e728c635b0d1830f9d26b844022e1284efe7707736e7ef52b49ba38 as sops

#################
# Context Stage # - Combine local resources from this repo and Bluefin upstreams from their published OCI images
#################
FROM scratch AS ctx

COPY scripts /scripts
COPY rootfs /rootfs

# Copy from common container as Bluefin itself does upstream
# See: https://github.com/ublue-os/bluefin/blob/0fa8f9031075742c035d634d1a9c49d59ecfd21b/Containerfile#L16-L17
COPY --from=common /system_files/shared /system_files/shared
COPY --from=common /system_files/bluefin /system_files/shared

# Copy sops binary into container
COPY --from=sops /usr/local/bin/sops /system_files/shared/usr/local/bin/sops

###############
# Build Stage # - Use Silverblue base image and run buildscripts on top of it
###############
FROM ghcr.io/ublue-os/silverblue-main:latest@sha256:a56a83eae6f7d99bd6dc5835595e9754b0103d993936accb62750091737c20cd

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
