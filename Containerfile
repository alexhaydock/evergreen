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

#################
# Context Stage # - Combine local resources from this repo and Bluefin upstreams from their published OCI images
#################
FROM scratch AS ctx

COPY scripts /scripts
COPY rootfs /rootfs

# Copy from OCI containers to distinct subdirectories to avoid conflicts
COPY --from=ghcr.io/projectbluefin/common:latest@sha256:2d45f52fbbcda5baebc9682357920878232d0b135871711fa8bc9560c1bdd47e /system_files /oci/common

###############
# Build Stage # - Use Silverblue base image and run buildscripts on top of it
###############
FROM ghcr.io/ublue-os/silverblue-main:latest@sha256:0bade6ac86765147b13ecbde36cee58122b8d7773d9dfeaf4e52ab2ac4789ae7

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/10-build.sh

# Verify final image and contents are correct
RUN bootc container lint
