# GitHub Pages Deployment

**How it works:** Pushing to `main` triggers GitHub's built-in `pages-build-deployment` workflow. No custom workflow needed—GitHub Pages automatically builds Jekyll sites with `remote_theme`.

**Live site:** https://htxryan.github.io/greece-vacation-2026

## Monitoring with GitHub API

Assumes `GITHUB_TOKEN` env var contains a personal access token.

```bash
# Base URL and auth header (reuse in commands below)
API="https://api.github.com/repos/htxryan/greece-vacation-2026"
AUTH="Authorization: Bearer $GITHUB_TOKEN"

# Check Pages status
curl -s -H "$AUTH" "$API/pages" | jq '{status, url, build_type}'

# Get latest Pages build
curl -s -H "$AUTH" "$API/pages/builds/latest" | jq '{status, created_at, error: .error.message}'

# List recent Pages builds
curl -s -H "$AUTH" "$API/pages/builds" | jq '.[:5] | .[] | {status, created_at}'

# List recent workflow runs (pages-build-deployment)
curl -s -H "$AUTH" "$API/actions/runs?per_page=5" | jq '.workflow_runs[] | {id, status, conclusion, created_at}'

# Get specific workflow run details (replace RUN_ID)
curl -s -H "$AUTH" "$API/actions/runs/RUN_ID" | jq '{status, conclusion, html_url}'

# Download logs for a failed run (replace RUN_ID)
curl -sL -H "$AUTH" "$API/actions/runs/RUN_ID/logs" -o logs.zip && unzip -p logs.zip
```

### One-liner: Check if latest deploy succeeded

```bash
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/htxryan/greece-vacation-2026/pages/builds/latest" \
  | jq -r '"Build: \(.status) at \(.created_at)"'
```

## Troubleshooting

| Issue | API Check |
|-------|-----------|
| Build fails | Check `/pages/builds/latest` for `error.message` |
| Changes not showing | Verify `/pages/builds/latest` status is `built` |
| 404 on pages | Check `/pages` returns `status: built` |
| Stuck in queue | Check `/actions/runs` for pending runs |
