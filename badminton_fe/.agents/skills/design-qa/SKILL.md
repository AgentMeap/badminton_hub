---
name: design-qa
description: Set up or run design QA gates for token + hardcoded-value lint, automated a11y (axe), contrast, visual regression across variants/states/themes/RTL, and the manual a11y checklist. Use when the user wants CI quality gates, to prevent design regressions, or to QA a component/screen before shipping.
---

> Ported from the Claude Code skill. Every path in it is relative to the project root, where the kit is installed.
> Where it says `CLAUDE.md`, the same rules are in `GEMINI.md`. A `/name` it mentions is
> the skill of that name. `/critique` exists only in Claude Code: where it is asked for, run
> `node scripts/taste_audit.mjs <file>` and `node scripts/slop_tells.mjs <file>`,
> report what they print, and say that a human read of the work is still owed.

# Skill: Design QA

> **Step 0: is the kit here?** This skill reads files from the kit. Check once:
> `ls tokens >/dev/null 2>&1 && echo KIT_OK || echo KIT_MISSING`
> On `KIT_MISSING` only the skill folders were installed, which is what
> `npx skills add` does. Say so plainly, point the user at
> `npx ux-ui-agent-skills init` or the plugin install, and stop. Do not guess the
> contents of a file you could not open.

Stand up the automated + manual gates that stop quality from regressing.

## Steps
1. Read `workflows/design-qa.md` (the QA pyramid: token/lint gates → automated a11y → visual regression → manual a11y).
2. Wire the **fast gates** first (every commit/PR): `python3 scripts/validate_tokens.py`, `python3 scripts/validate_contrast.py` (batch WCAG over the token pairs), and `python3 scripts/lint_hardcodes.py <src>` (no raw hex/px/timing in component code). The repo's `.github/workflows/ci.yml` runs these.
3. Add **automated a11y** (axe-core / Pa11y) over each component's states (error/loading/disabled/expanded/selected), zero serious/critical to merge. Run the **real-render contrast gate** `node scripts/gate.mjs measure_render.mjs <file.html>` (and `--dark`). It opens the page in headless Chromium, disables transitions, and measures the true computed-style + alpha-composited contrast of every text element (catches what static token checks miss).
4. Add **visual regression** snapshots across variants × sizes × states × light/dark + key breakpoints + RTL; freeze animations + deterministic data.
5. Sign off the **manual a11y** checklist per release (keyboard, screen reader, 400% reflow, 200% text-spacing, reduced-motion, forced-colors; `accessibility/*`).

## Verification (definition of done)
- An unreviewed PR cannot introduce an unresolved token alias, a contrast failure, a raw hex/px, or an axe violation: a gate blocks each.
- Snapshots cover dark mode + RTL + the semantic-changing states, not just the happy path.
- Manual a11y checklist signed off for the release.
