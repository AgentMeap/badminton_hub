---
name: performance
description: Optimize UI performance against Core Web Vitals (LCP, INP, CLS) with loading/code-split strategy, layout-shift prevention, and animation performance rules. Use when the user wants to improve speed, fix jank or layout shift, hit Web Vitals budgets, or make a UI feel fast on low-end devices.
---

> Ported from the Claude Code skill. Every path in it is relative to the project root, where the kit is installed.
> Where it says `CLAUDE.md`, the same rules are in `GEMINI.md`. A `/name` it mentions is
> the skill of that name. `/critique` exists only in Claude Code: where it is asked for, run
> `node scripts/taste_audit.mjs <file>` and `node scripts/slop_tells.mjs <file>`,
> report what they print, and say that a human read of the work is still owed.

# Skill: Performance

> **Step 0: is the kit here?** This skill reads files from the kit. Check once:
> `ls tokens >/dev/null 2>&1 && echo KIT_OK || echo KIT_MISSING`
> On `KIT_MISSING` only the skill folders were installed, which is what
> `npx skills add` does. Say so plainly, point the user at
> `npx ux-ui-agent-skills init` or the plugin install, and stop. Do not guess the
> contents of a file you could not open.

Make the UI fast and stable. Treat performance as an accessibility concern: slow/janky UIs fail low-end devices first.

## Steps
1. Read `workflows/performance.md` (Core Web Vitals targets, loading strategy, layout-shift, animation perf, design-system runtime cost).
2. Diagnose against budgets: **LCP ≤ 2.5s**, **INP ≤ 200ms**, **CLS ≤ 0.1**. Measure on a mid-tier mobile profile (throttle slow 4G + 4× CPU).
3. Loading: render above-fold first (SSR/Server Components), code-split by route + heavy widget, lazy-load below-fold/behind-interaction (Astro islands / Qwik), preload one critical font weight, modern responsive images.
4. Kill layout shift: size skeletons to final dimensions, reserve media space via `aspect-ratio` (`tokens/sizing.json`), never inject content above existing.
5. Animation: only `transform`/`opacity`, `will-change` sparingly, 100-300ms (`tokens/motion.json`), honor `prefers-reduced-motion`. Prefer CSS state styling over JS for low INP; tree-shake/per-component imports.

## Verification (definition of done)
- Lighthouse / field data meets LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1 on mid-tier mobile.
- First interaction stays responsive under slow-4G + 4× CPU throttle.
- Skeletons + media reserve space (zero CLS on load); no non-compositor animation in loops.
