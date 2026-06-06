# evergreen

A custom Bluefin-based Atomic Fedora build for my own workstation use.

Based on the [finpilot](https://github.com/projectbluefin/finpilot) getting started kit by the Bluefin / Universal Blue team, with heavy downstream modifications to fit my own purposes.

## Notes
* Dependency updates are handled by self-hosted [Renovate](./.github/workflows/renovate.yml).
  * See the `renovate.yml` for notes on the PAT token requirements to allow Renovate sufficient repo access to open Issues and PRs etc.
  * To auto-merge Renovate PRs to update digests etc, go to the repository `Settings > General` and enable `Allow auto-merge`. Auto-merging is enabled in the `renovate.json5` config file.
  * Auto-merging in GitHub also requires branch protection rules set on the target branch (`Settings > Branches > Add branch ruleset`). The ruleset can be weak, but it needs to exist and there needs to be at least one rule, for example "Require status checks to pass" with a single "Build and push image" check.
  * Auto-merges will use squash commits so the "Allowed merge methods" must contain Squash.
* Builds are not based on top of Bluefin. They use Silverblue as a base, but do selectively pull in some of the Bluefin/uBlue tweaks/configs/tooling.
* Image signing uses Cosign.
* Image SBOMs can be produced with Syft but the current Syft Action in `build.yml` seems to overload the GitHub Actions free runners and builds start failing. So this might need some work or self-hosted runners before I can turn it on properly.

## Local Testing

Test changes before pushing:

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## Troubleshooting

### Flatpaks not preinstalled after bootc switch
If Flatpaks added to the preinstall files in [custom/flatpaks/](./custom/flatpaks/) do not get automatically installed after a `bootc switch`, check that the `flatpak-preinstall.service` has not exited with any errors. A `systemctl restart flatpak-preinstall.service` may help.

## Roadmap / TODO
* Enable image signing with Cosign
* Enable transparency log using Sigstore/Sigsum
* Enable SBOM attestation
