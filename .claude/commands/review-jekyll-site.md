# Review Jekyll Site

Review the Jekyll site configuration, navigation structure, and validate visually using a local browser.

---

## Instructions

### Step 1: Enable Playwright MCP Server

First, enable the Playwright MCP server for this session:

```
/mcp enable playwright
```

Wait for confirmation that the server is enabled before proceeding.

### Step 2: Delegate to Jekyll Reviewer Agent

Use the Task tool with:
- `subagent_type`: `jekyll-reviewer`
- `prompt`: The full review request below

### Task Prompt for Agent

```
Perform a comprehensive review of this Jekyll site:

1. **Configuration Review**
   - Read and analyze `_config.yml`
   - Verify theme, baseurl, exclusions, and navigation settings

2. **Navigation Structure Analysis**
   - Scan all .md files for front matter
   - Build and display the navigation tree
   - Identify any issues:
     - Orphaned pages (parent doesn't match any title)
     - Missing `has_children: true` on parent pages
     - Incorrect `grand_parent` usage (not supported)
     - Duplicate nav_order values

3. **Local Server Validation**
   - Start Jekyll with: bundle exec jekyll serve
   - Wait for server to be ready

4. **Browser Validation with Playwright**
   - Navigate to http://127.0.0.1:4000/greece-vacation-2026/
   - Take screenshots of:
     - Home page
     - Sidebar navigation
     - Key child pages
   - Validate:
     - Sidebar renders correctly
     - All navigation items appear
     - Child pages expand properly
     - Links work correctly

5. **Generate Report**
   - Configuration status
   - Navigation tree visualization
   - Issues found with file paths
   - Browser validation checklist
   - Screenshots from validation
   - Recommendations for fixes

6. **Cleanup**
   - Stop the Jekyll server when done
```

---

## What This Command Does

This command invokes the `jekyll-reviewer` agent which:

1. Has access to **Playwright MCP** for browser automation (other agents do not)
2. Understands Just the Docs theme navigation rules
3. Can start Jekyll locally and validate the rendered site
4. Provides detailed reports with screenshots

### Step 3: Disable Playwright MCP Server (Optional)

After the review is complete, disable the Playwright MCP server:

```
/mcp disable playwright
```

## Architecture Note

The Playwright MCP server is configured in `.mcp.json` but **disabled by default**. This means:

- The main conversation does not have Playwright tools available normally
- The server must be explicitly enabled with `/mcp enable playwright`
- Once enabled, the `jekyll-reviewer` agent can use browser automation
- After the review, disable it to return to normal operation

This design keeps browser automation isolated to site review tasks only.
