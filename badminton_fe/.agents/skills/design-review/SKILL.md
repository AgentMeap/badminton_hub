---
name: design-review
description: Review or audit a design/UI across 6 weighted dimensions with Nielsen's 10 heuristics and a prioritized findings table. Use when the user wants a design critique, quality score, heuristic evaluation, or audit of an existing screen, page, or product before/after build.
---

> Ported from the Claude Code skill. Every path in it is relative to the project root, where the kit is installed.
> Where it says `CLAUDE.md`, the same rules are in `GEMINI.md`. A `/name` it mentions is
> the skill of that name. `/critique` exists only in Claude Code: where it is asked for, run
> `node scripts/taste_audit.mjs <file>` and `node scripts/slop_tells.mjs <file>`,
> report what they print, and say that a human read of the work is still owed.

# Skill: Design Review

> **Step 0: is the kit here?** This skill reads files from the kit. Check once:
> `ls tokens >/dev/null 2>&1 && echo KIT_OK || echo KIT_MISSING`
> On `KIT_MISSING` only the skill folders were installed, which is what
> `npx skills add` does. Say so plainly, point the user at
> `npx ux-ui-agent-skills init` or the plugin install, and stop. Do not guess the
> contents of a file you could not open.

Run a structured, scored review.

## Steps
1. Read `workflows/design-review.md` (rubric, scoring guide, Nielsen heuristics, process).
2. Gather context: the screen(s)/flow, target users, platform, constraints.
3. Score the 6 dimensions (Visual Hierarchy 20%, Consistency 20%, Accessibility 20%, Usability 20%, Responsiveness 10%, Performance 10%); compute the weighted overall.
4. Run the accessibility lens with `accessibility/wcag-checklist.md`; use `scripts/contrast.py` for any color-pair doubts.
5. Check against the anti-slop tells in `taste/design-taste.md` (Banned Defaults checklist).
6. Apply Nielsen's 10 heuristics; flag violations by number.

## Output
- The 6-dimension scored table + overall score.
- A prioritized findings table: # · Severity (Critical → Major → Minor → Enhancement) · Finding · Recommendation.
- Concrete, token-referenced fixes.
