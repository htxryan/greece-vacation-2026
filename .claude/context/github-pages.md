# GitHub Pages Deployment

**How it works:** Pushing to `main` triggers GitHub's built-in `pages-build-deployment` workflow. No custom workflow needed—GitHub Pages automatically builds Jekyll sites with `remote_theme`.

**Live site:** https://htxryan.github.io/greece-vacation-2026

## Monitoring with `gh` CLI

```bash
# List recent deployments
gh run list --workflow=pages-build-deployment

# Watch current deployment in real-time
gh run watch

# View latest deployment details
gh run view

# Check pages status
gh api repos/:owner/:repo/pages --jq '.status'

# View logs if build failed
gh run view --log-failed
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Build fails | Run `gh run view --log-failed` for errors |
| Changes not showing | Wait 1-2 min; check `gh run list` |
| 404 on pages | Verify `baseurl` matches repo name |
| Theme not loading | Check `remote_theme` spelling |
