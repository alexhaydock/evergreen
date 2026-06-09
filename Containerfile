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

################
# Import Stage # - Import the common image from Bluefin/Universal Blue upstream
################
FROM ghcr.io/projectbluefin/common:latest@sha256:c1a66676fb10d323384b9ea5c967bad6e06ff841950cd9505c756958b388fbcc AS common
FROM ghcr.io/getsops/sops:v3.13.1-alpine@sha256:032061a34e728c635b0d1830f9d26b844022e1284efe7707736e7ef52b49ba38 as sops
FROM ghcr.io/sigstore/cosign/cosign:v3.1.1@sha256:6bbe0d281d955c79f85b325f0f7e651c1bcab5a4fa4ad4903d74955178a3b2eb as cosign

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

# Copy cosign binary into container
COPY --from=cosign /ko-app/cosign /system_files/shared/usr/local/bin/cosign

###############
# Build Stage # - Use Silverblue base image and run buildscripts on top of it
###############
FROM ghcr.io/ublue-os/silverblue-main:latest@sha256:e537c4c6c121526d5ca3806c0c9126a12e2760aa9865b936c5c4066931604c2b

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/build.sh

# Verify final image and contents are correct
RUN bootc container lint
