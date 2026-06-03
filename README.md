# evergreen

A custom Bluefin-based Atomic Fedora build for my own workstation use.

Based heavily on the [finpilot](https://github.com/projectbluefin/finpilot) getting started kit by the Bluefin / Universal Blue team.

## Notes
* Dependency updates are handled by self-hosted [Renovate](./.github/workflows/renovate.yml).
  * See the `renovate.yml` for notes on the PAT token requirements to allow Renovate sufficient repo access to open Issues and PRs etc.
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
