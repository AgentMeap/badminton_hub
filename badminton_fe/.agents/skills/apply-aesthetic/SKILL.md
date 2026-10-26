---
name: apply-aesthetic
description: Apply a visual direction, an archetype (high-end agency, editorial minimal, brutalist, soft-SaaS, dark-tech) or one of 2,144 named design systems (apple, linear-app, stripe, vercel, notion, material, shadcn, spotify, tesla…), by resolving it into the token system. Use when the user wants a specific look/vibe/brand feel, or asks to make a design feel premium/expensive/non-generic.
---

> Ported from the Claude Code skill. Every path in it is relative to the project root, where the kit is installed.
> Where it says `CLAUDE.md`, the same rules are in `GEMINI.md`. A `/name` it mentions is
> the skill of that name. `/critique` exists only in Claude Code: where it is asked for, run
> `node scripts/taste_audit.mjs <file>` and `node scripts/slop_tells.mjs <file>`,
> report what they print, and say that a human read of the work is still owed.

# Skill: Apply Aesthetic

> **Step 0: is the kit here?** This skill reads files from the kit. Check once:
> `ls tokens >/dev/null 2>&1 && echo KIT_OK || echo KIT_MISSING`
> On `KIT_MISSING` only the skill folders were installed, which is what
> `npx skills add` does. Say so plainly, point the user at
> `npx ux-ui-agent-skills init` or the plugin install, and stop. Do not guess the
> contents of a file you could not open.

Choose and apply a design direction without breaking accessibility.

## Steps
1. **Brief Inference first (mandatory).** Before any tokens, name it: industry/domain, audience & tone, the one mood adjective the result must earn, motion depth, and the layout-family sequence (`taste/design-taste.md` → Brief Inference + Variance Mandate). Generating before deciding = slop.
2. Pick a direction in `taste/aesthetic-systems.md`:
   - An **archetype** (recipe mapped to our tokens), or
   - A **named library system**: browse with `python3 scripts/design_systems.py list` (or `search <term>` / `show <name>`). Then run `node scripts/library.mjs get <name>` and read the `DESIGN.md` at the path it prints. An npm install carries the index and no spec, so this is what fetches it (checked against the sha256 the kit ships); where the spec is already on disk it fetches nothing. If it prints `refused`, say the spec could not be fetched and pick from an archetype instead; never write a spec from memory.
3. Apply the **Library Contract** (in `aesthetic-systems.md`): re-point `semantic.*` tokens to the chosen system's color roles; map typography/spacing/radius/shadow/motion to `tokens/*.json`.
4. **Verify contrast** of every mapped color pair (`scripts/contrast.py` / `a11y-audit`). A brand value that fails must be adjusted. Taste never overrides POUR.
5. Add motion per `taste/motion-choreography.md`; run the pre-flight aesthetic check in `design-taste.md`.

## Output
Updated/overridden semantic tokens + notes on type/space/motion, then render via `design-code`. Confirm the result passes both the aesthetic check and accessibility.
