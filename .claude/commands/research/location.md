# Research Location Command

ULTRATHINK

Research a location in Greece for our October 2026 family vacation.

**Location to research:** $ARGUMENTS

---

## Instructions

### 1. Setup & Context Loading

First, load the necessary context:
- Read `./resources/global-preferences.md` for group preferences
- Read all party files in `./resources/parties/` to understand individual preferences
- Read the location template at `./.claude/templates/location.md`
- Read the activity template at `./.claude/templates/activity.md`

### 2. Check Existing Research

Check if `./research/locations/$ARGUMENTS/index.md` already exists:
- **If it exists**: You are in ENHANCEMENT mode. Read the existing content and identify gaps or areas that need more depth.
- **If it doesn't exist**: You are in INITIAL RESEARCH mode. Create the folder structure from scratch.

### 3. Research the Location

Use web search to gather comprehensive information about the location. Focus on:

#### General Information
- Overview and character of the location
- Best time to visit (confirm October is good)
- Weather in October
- How to get there from Athens
- Getting around locally

#### Activities & Experiences (prioritize based on group preferences)
- Food tours and culinary experiences
- Historical museums and archaeological sites
- Nature spots with good views (low-intensity, no mountain hikes)
- People-watching spots and relaxing areas
- Unique local shopping
- Fine dining and Michelin restaurants (for Ryan & Toni)
- Cruise options if applicable (for Andy & Kathy)
- Photography spots (for Ryan & Toni)

#### Logistics
- Transportation from Athens (ferry, flight, etc.)
- Travel time
- Recommended length of stay
- Google Maps link

#### Visual Research
- Search for iconic views and photo spots
- Find 3-5 representative photos to download

### 4. Create/Update Folder Structure

Ensure this structure exists:
```
./research/locations/<location-slug>/
├── index.md
├── photos/
│   └── (downloaded photos)
└── activities/
    └── (activity pages, created later)
```

Use a URL-friendly slug for the folder name (lowercase, hyphens instead of spaces).

### 5. Download Photos

Download 3-5 high-quality, representative photos of the location:
- Use the Bash tool with `curl` to download images
- Save to `./research/locations/<location-slug>/photos/`
- Use descriptive filenames (e.g., `santorini-sunset-oia.jpg`)
- Prefer images from official tourism sites or Wikimedia Commons

### 6. Create/Update index.md

Follow the template at `./.claude/templates/location.md` exactly. Fill in:

- **Title & Front Matter**: Set proper Jekyll front matter with `title`, `parent: Locations`, `has_children: true` (for activities), and appropriate `nav_order`
- **Overview**: 2-3 paragraphs capturing the essence of the location
- **Who This is For**: Match location strengths to specific party members and their preferences
- **Reasons to Choose**: Compelling reasons based on group and individual preferences
- **Top Activities**: Bulleted list of 5-8 recommended activities (these become activity pages later)
- **Details**: Practical tips, suggested length of stay, best areas to stay
- **Photos**: Render downloaded photos using markdown image syntax with relative paths
- **Logistics**: Google Maps link, transportation options with times/costs
- **References**: Links to official tourism sites, travel guides, relevant articles

### 7. Summary Output

After completing research, provide a summary:
- Confirmation of what was created/updated
- List of top activities identified for potential deep-dive research
- Any concerns or notes (e.g., "October might be shoulder season here")
- Suggested next steps (e.g., "Run `/research:activity` for specific activities")

---

## Travel Party Quick Reference

| Party | Ages | Key Preferences |
|-------|------|-----------------|
| Andy & Kathy | 70, 68 | Cruises |
| Donna & Travis | 24, 30 | (General group prefs) |
| Ryan & Toni | 37, 36 | Fine dining, unique dining, photography |

**Group Preferences**: Good food, food tours, museums (history > art), low-intensity nature, good views, people watching, relaxing, unique shopping

---

## Notes

- This vacation is for October 2026 (12 days + 2 travel days)
- Flying into Athens
- First few days together, then couples split up
- Travis & Donna will plan their own post-split portion
- Focus research on locations suitable for the group portions and for Andy/Kathy and Ryan/Toni independent portions
