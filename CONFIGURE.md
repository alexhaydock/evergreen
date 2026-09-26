## Fresh repo setup

This page details the steps required to set up a fresh Evergreen repo with Actions builds enabled, for my own reference.

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
