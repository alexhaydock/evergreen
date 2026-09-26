# 🌿 Evergreen

A custom Atomic Fedora build for my own workstation use.

The aim is for all the static config for my OS to live in this repo - making this my attempt at building a 'best of both worlds' somewhere between Nix's declarative config and `bootc`'s OCI-based composable images.

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

This key is also used by `podman`/`bootc` to validate image updates to the installed system (this is enforced by `/etc/containers/policy.json`).

## Development Notes

### Local testing

Test changes before pushing:

```bash
just build                    # Build container image
just build && just build-iso  # Build installation ISO
just build-qcow2              # Build VM disk image
just run-vm-qcow2             # Test in browser-based VM
```

## Troubleshooting

### Flatpaks not preinstalled after bootc switch
If Flatpaks added to the preinstall files in `/etc/flatpak/preinstall.d/*.preinstall` do not get automatically installed after a `bootc switch`, check that the `flatpak-preinstall.service` has not exited with any errors. A `systemctl restart flatpak-preinstall.service` may help.

## Future Goals
* Investigate opportunities for transparency logging (and client-side validation) using Sigstore/Sigsum
    * I think we basically get this for free with Cosign v3 signatures when Podman supports them, as the v3 default is to publish the sig to the Sigsum transparency log.
* Migrate away from GitHub infrastructure and rotate private keys which have existed as GitHub repo secrets
* Investigate re-adding SBOM generation (`finpilot` previously used Syft but it seems to choke on images this large)
* Build a clean pathway to install a stock Silverblue image and rebase directly to Evergreen without needing ot use a Bluefin or custom build ISO to install.
    * This would allow us to get all the benefits of Secure Boot etc on the upstream Fedora kernel without any downstream complexity. It relies on Silverblue rebasing from `rpm-ostree` to `bootc` first though.

## Acknowledgements
Based fairly heavily on the [finpilot](https://github.com/projectbluefin/finpilot) getting started kit by the Bluefin / Universal Blue team, with downstream modifications to fit my own purposes.

Thanks also to the [secureblue](https://github.com/secureblue/secureblue) team for some of the security hardening configs applied in this repo as well as the idea to ship without `sudo`. I've tried to leave the filenames / preambles intact where I've cherry-picked configs from the secureblue upstream.
