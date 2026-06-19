# 🌿 Evergreen

A custom Atomic Fedora build for my own workstation use.

Based fairly heavily on the [finpilot](https://github.com/projectbluefin/finpilot) getting started kit by the Bluefin / Universal Blue team, with downstream modifications to fit my own purposes.

The aim is for all the static config for my OS to live in this repo - making this my attempt at building a 'best of both worlds' somewhere between Nix's declarative config and `bootc`'s OCI-based composable images.

## Rebasing to this image

```sh
sudo bootc switch ghcr.io/alexhaydock/evergreen:stable-daily
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
just build         # Build container image
just build-iso     # Build installation ISO
just build-qcow2   # Build VM disk image
just run-vm-qcow2  # Test in browser-based VM
```

## Fresh repo setup

### Allowing Renovate to automatically update dependencies
Dependency updates are handled by self-hosted [Renovate](./.github/workflows/renovate.yml).

To set up Renovate fully:

1. Generate a PAT token scoped to just this repo in GitHub (`GitHub Settings > Developer Settings > Personal access tokens > Fine-grained tokens`) with the parameters noted below.
1. Add the PAT token to the repo secrets as `RENOVATE_TOKEN`.
1. In `Repo Settings > General`, enable `Allow auto-merge`. Auto-merging is enabled in the `renovate.json` config file.
    1. Auto-merges will use squash commits as per `renovate.json` config so the "Allowed merge methods" must contain Squash.
1. In `Repo Settings > Rules > Rulesets` select `New branch ruleset`. Auto-merging Renovate PRs depends on having at least one rule active. Add `Require status checks to pass` with a single `Build and push image` check provided by GitHub Actions to enforce merging only if the pipeline build succeeds.
1. In `Repo Settings > Actions > General`, set `Workflow permissions` so that GitHub Actions is able to "create and approve pull requests".

### Renovate PAT token requirements
To allow Renovate to operate with full powers (including creating and automerging PRs), it needs a narrowly-scoped PAT token created in GitHub with access to:
  - Actions (Read-only)
  - Commit statuses (Read-only)
  - Contents (Read and write)
  - Issues (Read and write)
  - Pull Requests (Read and write)
  - Workflows (Read and write)

See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token

### Configuring Cosign to sign built images

To generate keys with Cosign and add them to this repo:

1. Run: `cosign generate-key-pair`
1. This creates `cosign.key` (private) and `cosign.pub` (public)
1. Add `cosign.pub` to `/usr/lib/pki/containers/evergreen.pub` in this repo
1. Add `cosign.key` contents to GitHub Secrets as `SIGNING_SECRET`
1. Image verification is enforced by the files in `/etc/containers` in this repo

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
