# 🌿 Evergreen

A custom Atomic Fedora build for my own workstation use.

The aim is for all the static config for my OS to live in this repo - making this my attempt at building a 'best of both worlds' somewhere between Nix's declarative config and `bootc`'s OCI-based composable images.

This image is crafted specfically for my own use and isn't intended for public consumption, but I post it publicly since it might be interesting to some or useful as a base to build your own version from.

## Rebasing to this image

### Daily channel
Daily images are published immediately any time a successful CI run completes.

```sh
sudo bootc switch ghcr.io/alexhaydock/evergreen:stable-daily
```

### Weekly channel
Weekly images are promoted on Tuesdays when a successful `stable-daily` build completes on that day.

```sh
sudo bootc switch ghcr.io/alexhaydock/evergreen:stable
```

## Validating this image locally
Evergreen images are signed using Cosign and can be validated manually as follows:

```sh
cosign verify \
  --new-bundle-format=false \
  --insecure-ignore-tlog=true \
  --key https://raw.githubusercontent.com/alexhaydock/evergreen/refs/heads/main/rootfs/usr/lib/pki/containers/evergreen.pub \
  ghcr.io/alexhaydock/evergreen:stable-daily
```

This uses the old Cosign signing format until [this Podman issue](https://github.com/podman-container-tools/container-libs/issues/388) gets resolved.

This key is also used by `podman`/`bootc` to validate image updates to the installed system (this is enforced by `/etc/containers/policy.json`).

## Future Goals
* Investigate opportunities for transparency logging (and client-side validation) using Sigstore/Sigsum
    * I think we basically get this for free with Cosign v3 signatures when Podman supports them, as the v3 default is to publish the sig to the Sigsum transparency log.
* Migrate away from GitHub infrastructure and rotate private keys which have existed as GitHub repo secrets
* Investigate re-adding SBOM generation (`finpilot` previously used Syft but it seems to choke on images this large)
* Build a clean pathway to install a stock Silverblue image and rebase directly to Evergreen without needing ot use a Bluefin or custom build ISO to install.
    * This would allow us to get all the benefits of Secure Boot etc on the upstream Fedora kernel without any downstream complexity. It relies on Silverblue rebasing from `rpm-ostree` to `bootc` first though.

## Acknowledgements
The initial version of this repo was based fairly heavily on the [finpilot](https://github.com/projectbluefin/finpilot) getting started kit by the Bluefin / Universal Blue team, with downstream modifications to fit my own purposes. A lot of the CI jobs are still imported directly from Universal Blue.

Thanks also to the [secureblue](https://github.com/secureblue/secureblue) team for some of the security hardening configs applied in this repo as well as the idea to ship without `sudo`. I've tried to leave the filenames / preambles intact where I've cherry-picked configs from the secureblue upstream.
