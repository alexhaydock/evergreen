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
FROM ghcr.io/sigstore/cosign/cosign:v3.0.6@sha256:de9c65609e6bde17e6b48de485ee788407c9502fa08b8f4459f595b21f56cd00 as cosign

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
FROM ghcr.io/ublue-os/silverblue-main:latest@sha256:8e8d7641b5b9d7daa0fa679cbb90f5c70411fb54ba99125188627fa678942266

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/build.sh

# Verify final image and contents are correct
RUN bootc container lint
