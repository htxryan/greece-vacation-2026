# Review Jekyll Site

Review the Jekyll site configuration, navigation structure, and validate visually using a local browser.

---

## Instructions

Delegate this task to the **jekyll-reviewer** agent, which has exclusive access to Playwright browser automation.

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

## Architecture Note

The Playwright MCP server is configured at the project level (`.mcp.json`) but is only accessible to the `jekyll-reviewer` agent through tool scoping. This means:

- The main conversation does not have direct access to Playwright tools
- Other agents (like `web-researcher`) do not have Playwright access
- Only the `jekyll-reviewer` agent can perform browser automation

This design keeps browser automation isolated to site review tasks only.
