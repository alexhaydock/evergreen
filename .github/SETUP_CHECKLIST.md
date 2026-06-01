# Repository Setup Checklist

## Initial Setup

### 1. Rename Template
- [x] Update `evergreen` to your name in: Containerfile, Justfile, README.md, artifacthub-repo.yml

### 2. Enable GitHub Actions
- [x] Settings → Actions → General → Enable workflows
- [x] Set "Read and write permissions"

### 3. First Push
```bash
git add .
git commit -m "feat: initial customization"
git push origin main
```

### 4. Deploy
```bash
sudo bootc switch --transport registry ghcr.io/alexhaydock/evergreen:stable
sudo systemctl reboot
```

## Optional: Production Features

### Enable Signing (Recommended)
```bash
cosign generate-key-pair
# Add cosign.key to GitHub Secrets as SIGNING_SECRET
# Uncomment signing in .github/workflows/build.yml
```
