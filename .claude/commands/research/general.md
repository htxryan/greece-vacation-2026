# General Research Command

ULTRATHINK

Conduct general research on a topic related to our Greece October 2026 family vacation. Use this for topics that aren't specific to a single location or activity.

**Research Topic:** $ARGUMENTS

---

## Instructions

### 1. Analyze the Research Topic

Determine what type of research this is:

| Category | Examples |
|----------|----------|
| **Logistics** | Ferry routes, flight options, transportation, getting between islands |
| **Comparison** | Island comparisons, cruise vs. land travel, region pros/cons |
| **Thematic** | Best beaches, top restaurants, photography spots across Greece |
| **Practical** | Packing lists, visa/entry requirements, currency, travel insurance |
| **Seasonal** | October weather, what's open/closed, crowd levels, shoulder season tips |
| **Budget** | Cost estimates, money-saving tips, price comparisons |
| **Cultural** | Greek customs, etiquette, language basics, local traditions |
| **Itinerary** | Route planning, day-by-day logistics, time allocation |

### 2. Setup & Context Loading

Load relevant context:
- Read `./resources/global-preferences.md` for group preferences
- Read party files in `./resources/parties/` if the topic relates to preferences
- Scan `./research/locations/` to see what locations have been researched (for cross-referencing)
- Check `./notes/` for existing related research

### 3. Generate Filename

Create a URL-friendly slug from the research topic:
- Lowercase
- Replace spaces with hyphens
- Remove special characters
- Keep it concise but descriptive (3-5 words ideal)

Examples:
- "Ferry routes between islands" → `ferry-routes-between-islands.md`
- "October weather in Greece" → `october-weather-greece.md`
- "Best Greek islands for relaxation" → `best-islands-relaxation.md`
- "Packing list for October" → `packing-list-october.md`

### 4. Check for Existing Research

Look for existing files in `./notes/` that cover this topic:
- **If similar file exists**: You are in ENHANCEMENT mode. Read it and identify gaps.
- **If no similar file**: You are in INITIAL RESEARCH mode. Create from scratch.

Also check if the topic overlaps with location/activity research—avoid duplicating, instead cross-reference.

### 5. Conduct Research

Use web search extensively. Tailor your research approach to the category:

#### For Logistics Research
- Official sources (ferry companies, airlines, transit authorities)
- Current schedules and booking info
- Costs and duration
- Booking requirements and tips
- October-specific schedule changes

#### For Comparison Research
- Side-by-side feature comparison
- Pros and cons of each option
- Which option suits which party members
- Cost/time/experience trade-offs
- Recommendations based on preferences

#### For Thematic Research
- Curated lists from reputable travel sources
- Location-specific highlights
- How each item matches party preferences
- Practical visiting info

#### For Practical Research
- Official government sources for requirements
- Recent traveler experiences (2024-2025)
- Checklists and actionable items
- Common mistakes to avoid

#### For Seasonal Research
- Historical weather data for October
- What's open vs. closed in shoulder season
- Crowd expectations
- Seasonal events or festivals
- Pricing differences

#### For Budget Research
- Realistic cost breakdowns
- Price ranges (budget to luxury)
- Money-saving strategies
- What's worth splurging on
- Hidden costs to watch for

#### For Cultural Research
- Essential customs and etiquette
- Useful Greek phrases
- Tipping expectations
- Dress codes for sites
- Local sensitivities

#### For Itinerary Research
- Logical routing and connections
- Minimum time needed per location
- Avoid backtracking strategies
- Buffer time recommendations

### 6. Create/Update the Note

Create the file at `./notes/<slug>.md` with this structure:

```markdown
---
title: <Descriptive Title>
parent: Planning
nav_order: <n>
---

# <Title>

<Brief overview of what this research covers and why it matters for our trip>

## Key Findings

<Most important takeaways, bulleted or summarized>

## <Section 1 - varies by topic>

<Detailed content>

## <Section 2 - varies by topic>

<Detailed content>

## <Additional sections as needed>

<Detailed content>

## Recommendations

<Specific recommendations for our group, considering:>
- Group preferences (food, history museums, nature, views, relaxation)
- Andy & Kathy (70, 68) - cruises, accessibility needs
- Ryan & Toni (37, 36) - fine dining, photography
- October timing
- 12-day trip duration

## Related Research

<Links to related location pages, activity pages, or other notes>
- [Location Name](../research/locations/<slug>/index.md) - if relevant
- [Other Note](./other-note.md) - if relevant

## Sources

<All sources used, as clickable links>
- [Source Name](URL)
- [Source Name](URL)
```

### 7. Adapt Structure to Topic Type

Customize sections based on research category:

**Logistics:**
- Options Overview
- Comparison Table
- Booking Information
- Recommended Choice

**Comparison:**
- Comparison Criteria
- Option A Analysis
- Option B Analysis
- Side-by-Side Table
- Verdict

**Thematic:**
- Overview
- Top Picks (numbered/ranked)
- Honorable Mentions
- How to Choose

**Practical:**
- Requirements/Checklist
- Step-by-Step Guide
- Common Pitfalls
- Resources

**Seasonal:**
- Weather Overview
- What to Expect
- Seasonal Considerations
- Packing Implications

**Budget:**
- Cost Categories
- Budget Breakdown
- Saving Strategies
- Splurge-Worthy Items

**Cultural:**
- Key Customs
- Do's and Don'ts
- Useful Phrases
- Cultural Context

**Itinerary:**
- Route Overview
- Day-by-Day Framework
- Logistics Between Stops
- Flexibility Points

### 8. Cross-Reference Existing Research

Where relevant, link to:
- Existing location research in `./research/locations/`
- Existing activity research
- Other planning notes in `./notes/`

Use relative markdown links that work in Jekyll.

### 9. Summary Output

After completing research, provide:
- Confirmation of file created/updated
- Key findings summary (3-5 bullets)
- How this research impacts trip planning
- Suggested follow-up research topics
- Any locations or activities that should be researched based on findings

---

## Travel Party Quick Reference

| Party | Ages | Key Preferences | Considerations |
|-------|------|-----------------|----------------|
| Andy & Kathy | 70, 68 | Cruises | Accessibility, pace |
| Donna & Travis | 24, 30 | (General group prefs) | Leaving after group portion |
| Ryan & Toni | 37, 36 | Fine dining, unique dining, photography | Michelin stars, photo ops |

**Group Preferences**: Good food, food tours, museums (history > art), low-intensity nature, good views, people watching, relaxing, unique shopping

---

## Trip Parameters

- **When**: October 2026
- **Duration**: 12 days + 2 travel days
- **Arrival**: Athens
- **Structure**: Together first → split up → possibly reunite at end
- **Note**: Travis & Donna planning their own post-split portion

---

## Example Research Topics

Good uses for this command:
- `Ferry routes Greek islands October`
- `Best Greek islands for older travelers`
- `Athens to Santorini transportation options`
- `Greece October weather what to pack`
- `Greek island hopping itinerary 12 days`
- `Michelin star restaurants Greece 2026`
- `Greek cuisine guide must-try dishes`
- `Greece travel tips first timers`
- `Shoulder season Greece pros cons`
- `Greek island cruise options from Athens`
- `Photography spots Greece golden hour`
- `Greece accessibility guide seniors`
- `Budget breakdown Greece 2 weeks`
- `Greek phrases travelers`
- `Athens airport to city center options`

---

## Quality Checklist

Before finalizing, verify:
- [ ] Front matter has correct `parent: Planning`
- [ ] Title is clear and descriptive
- [ ] Key findings are prominently summarized
- [ ] Content is actionable, not just informational
- [ ] Recommendations consider all party members
- [ ] October 2026 timing is factored in
- [ ] Sources are cited with working links
- [ ] Related research is cross-referenced
- [ ] No duplication with existing location/activity pages
