This site uses the **Just the Docs** theme (`just-the-docs` v0.8) with GitHub Pages. Navigation is controlled entirely through YAML front matter—**not** file/folder structure.

#### Front Matter Properties

| Property | Purpose |
|----------|---------|
| `title` | Page name in sidebar (also used for `parent` matching) |
| `nav_order` | Position in nav (lower = higher) |
| `parent` | Parent page's `title` (exact match, case-sensitive) |
| `has_children` | Set `true` if page has children (makes it collapsible) |

#### Navigation Hierarchy Rules

1. **Top-level pages**: Only need `nav_order`
2. **Parent pages**: Add `has_children: true`
3. **Child pages**: Set `parent: <ParentTitle>`
4. **Grandchild pages**: Set `parent: <ChildTitle>` (do NOT use `grand_parent`)

#### Examples

**Top-level parent:**
```yaml
---
title: Research
nav_order: 3
has_children: true
---
```

**Child with children:**
```yaml
---
title: Locations
parent: Research
nav_order: 1
has_children: true
---
```

**Leaf page:**
```yaml
---
title: Athens
parent: Locations
nav_order: 1
---
```

#### Common Mistakes

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
nav_order: <n>
has_children: true  # if it will have activity sub-pages
---
```

##### New Activity
```yaml
# research/locations/<location>/activities/<activity>.md
---
title: <Activity Name>
parent: <Location Name>  # must match location's title exactly
nav_order: <n>
---
```

##### New Itinerary
```yaml
# itineraries/<name>.md
---
title: <Itinerary Name>
parent: Itineraries
nav_order: <n>
---
```

#### Current Site Hierarchy

```
Home (nav_order: 1)
Resources (nav_order: 2)
├── Global Preferences
└── Travel Parties
    ├── Andy and Kathy
    ├── Donna and Travis
    └── Ryan and Toni
Research (nav_order: 3)
└── Locations
    └── [location pages → activity sub-pages]
Planning (nav_order: 4)
Itineraries (nav_order: 5)
```

#### Local Development

```bash
bundle install
bundle exec jekyll serve
```

Site URL: https://htxryan.github.io/greece-vacation-2026
