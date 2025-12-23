# Research Activity Command

ULTRATHINK

Research a specific activity at a location in Greece for our October 2026 family vacation.

**Arguments:** $ARGUMENTS

Parse the arguments as: `<location> <activity-name-or-description>`

Examples:
- `Santorini sunset cruise in Oia`
- `Athens Acropolis Museum`
- `Mykonos food tour`

---

## Instructions

### 1. Parse Arguments

Extract from `$ARGUMENTS`:
- **Location**: The first word (or known location name like "Santorini", "Athens", "Mykonos")
- **Activity**: Everything after the location name

If parsing is ambiguous, make a reasonable interpretation and note your assumption.

### 2. Setup & Context Loading

Load the necessary context:
- Read `./resources/global-preferences.md` for group preferences
- Read all party files in `./resources/parties/` to understand individual preferences
- Read the activity template at `./.claude/templates/activity.md`
- Read the location's index.md at `./research/locations/<location-slug>/index.md` if it exists (for context)

### 3. Determine Location Slug

Convert the location name to a URL-friendly slug:
- Lowercase
- Replace spaces with hyphens
- Examples: "Santorini" → "santorini", "Naxos Island" → "naxos-island"

### 4. Check Existing Research

Check if the activity file already exists in `./research/locations/<location-slug>/activities/`:
- **If it exists**: You are in ENHANCEMENT mode. Read the existing content and identify gaps or areas needing more depth.
- **If it doesn't exist**: You are in INITIAL RESEARCH mode. Create the file from scratch.

### 5. Research the Activity

Use web search to gather comprehensive information. Focus on:

#### Core Information
- What exactly is this activity/experience?
- What makes it special or unique?
- Why do visitors recommend it?
- Best time of day/week to do it
- October-specific considerations (weather, crowds, availability)

#### Experience Details
- Duration (how long does it take?)
- Physical requirements (walking, standing, accessibility)
- What to expect step-by-step
- What's included vs. extra costs
- Food/drink involved?
- Photo opportunities

#### Practical Logistics
- **Address**: Full address for Google Maps
- **Hours**: Days/hours of operation (check October 2026 if possible)
- **Cost**: Entry fees, tour costs, typical spending
- **Booking**: Is advance booking required? How far ahead?
- **Getting there**: From typical accommodation areas

#### Reviews & Tips
- Common praise points
- Common complaints or warnings
- Insider tips from recent visitors
- What to bring/wear

### 6. Ensure Folder Structure

Verify this structure exists (create if needed):
```
./research/locations/<location-slug>/
└── activities/
    └── <activity-slug>.md
```

### 7. Create/Update Activity File

Follow the template at `./.claude/templates/activity.md` exactly. Fill in:

#### Front Matter
```yaml
---
title: <Activity Name>
parent: <Location Name>  # Must match location's title exactly
nav_order: <n>
---
```

#### Sections

- **Overview**: 2-3 paragraphs describing the activity, what makes it special, and the experience
- **Who This is For**: Match activity characteristics to specific party members:
  - Is it good for Andy & Kathy (70, 68)? Consider physical demands, cruise-related
  - Is it good for Donna & Travis (24, 30)? General appeal
  - Is it good for Ryan & Toni (37, 36)? Fine dining, photography opportunities
  - Is it good for the whole group together?
- **Reasons to Choose**: 3-5 compelling bullet points based on group/individual preferences
- **Details**:
  - Duration and best timing
  - What to expect
  - Tips and recommendations
  - What to bring
  - October-specific notes
- **Logistics**:
  - Hours of operation
  - Address (with Google Maps link)
  - Cost breakdown
  - Booking requirements
  - How to get there
- **References**: Links to official website, booking platforms, relevant reviews/articles

### 8. Update Location's Top Activities (Optional)

If the location's index.md exists and doesn't already list this activity in "Top Activities", consider noting this as a suggested addition.

### 9. Summary Output

After completing research, provide:
- Confirmation of what was created/updated
- Quick verdict: Who is this activity best for?
- Any concerns (accessibility, October availability, booking lead time)
- Related activities that might be worth researching

---

## Travel Party Quick Reference

| Party | Ages | Key Preferences | Physical Considerations |
|-------|------|-----------------|------------------------|
| Andy & Kathy | 70, 68 | Cruises | May need accessible options |
| Donna & Travis | 24, 30 | (General group prefs) | No limitations |
| Ryan & Toni | 37, 36 | Fine dining, unique dining, photography | No limitations |

**Group Preferences**: Good food, food tours, museums (history > art), low-intensity nature, good views, people watching, relaxing, unique shopping

---

## Activity Categories to Consider

When researching, identify which category/categories apply:

- **Culinary**: Food tours, cooking classes, wine tasting, restaurant experiences
- **Cultural**: Museums, archaeological sites, historical tours, local traditions
- **Nature**: Scenic walks, beaches, viewpoints, boat trips
- **Relaxation**: Spas, beaches, cafes, scenic spots for people-watching
- **Shopping**: Local markets, artisan shops, unique finds
- **Photography**: Iconic views, golden hour spots, unique compositions
- **Cruises/Boats**: Day cruises, sunset sails, island hopping

---

## Notes

- This vacation is for October 2026
- Low-intensity activities preferred (no mountain hikes)
- Consider accessibility for the 68-70 age range
- Photography opportunities are a plus for Ryan & Toni
- Food experiences are always welcome
