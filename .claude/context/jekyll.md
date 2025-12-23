This site uses the **Just the Docs** theme (`just-the-docs` v0.8) with GitHub Pages. Navigation is controlled entirely through YAML front matter—**not** file/folder structure.

#### Navigation Sorting

Pages are sorted **alphabetically by title** (case-insensitive). The only exception is the "Home" page, which uses `nav_order: 1` to ensure it appears first.

#### Front Matter Properties

| Property | Purpose |
|----------|---------|
| `title` | Page name in sidebar (also used for `parent` matching and alphabetical sorting) |
| `parent` | Parent page's `title` (exact match, case-sensitive) |
| `has_children` | Set `true` if page has children (makes it collapsible) |
| `nav_order` | **Only for "Home" page** - do not use elsewhere |

#### Navigation Hierarchy Rules

1. **Top-level pages**: Only need `title` (sorted alphabetically)
2. **Parent pages**: Add `has_children: true`
3. **Child pages**: Set `parent: <ParentTitle>`
4. **Grandchild pages**: Set `parent: <ChildTitle>` (do NOT use `grand_parent`)

#### Examples

**Home page (only page with nav_order):**
```yaml
---
title: Home
nav_order: 1
---
```

**Top-level parent:**
```yaml
---
title: Research
has_children: true
---
```

**Child with children:**
```yaml
---
title: Locations
parent: Research
has_children: true
---
```

**Leaf page:**
```yaml
---
title: Athens
parent: Locations
---
```

#### Common Mistakes

- **Wrong:** Using `nav_order` on any page except "Home"
- **Wrong:** Using `grand_parent` (not supported—removed in commit efccded)
- **Wrong:** Forgetting `has_children: true` on pages that need children
- **Wrong:** Mismatched `parent` value (must exactly match another page's `title`)
- **Wrong:** Assuming nav follows folder structure (it doesn't)

#### Adding Content

##### New Location
```yaml
# research/locations/<name>/index.md
---
title: <Location Name>
parent: Locations
has_children: true  # if it will have activity sub-pages
---
```

##### New Activity
```yaml
# research/locations/<location>/activities/<activity>.md
---
title: <Activity Name>
parent: <Location Name>  # must match location's title exactly
---
```

##### New Itinerary
```yaml
# itineraries/<name>.md
---
title: <Itinerary Name>
parent: Itineraries
---
```

#### Current Site Hierarchy

```
Home (nav_order: 1 - always first)
Itineraries (alphabetical)
Planning (alphabetical)
Research (alphabetical)
└── Locations
    └── [location pages → activity sub-pages, all alphabetical]
Resources (alphabetical)
├── Global Preferences
└── Travel Parties
    ├── Andy and Kathy
    ├── Donna and Travis
    └── Ryan and Toni
```

#### Local Development

```bash
bundle install
bundle exec jekyll serve
```

Site URL: https://htxryan.github.io/greece-vacation-2026
