# Totem Timers — instructions for AI and human collaborators

**Creator / creative director:** Babuni.dev. **Current addon:** TotemTimers v1.3.7 for WoW 1.12.

## Respect the product

The authored identity is a **compact Blizzard-style Shaman status panel** for four totem elements, shield charges and weapon enchants. It is not an autocaster, combat rotation helper, buff assignment planner or modern-game UI replacement. Preserve the Earth/Water/Fire/Air visible order and the creator's modest movable, lockable frame unless the creator approves a redesign.

Read README, CONCEPT, ROADMAP, docs/ARCHITECTURE, docs/DESIGN, docs/CONTENT, docs/DECISIONS, docs/DEVLOG and **TotemTimers.lua** before code changes. Follow Vanilla 1.12/Lua 5.0 API constraints, not modern client assumptions.

## Source invariants and hazards

- **Two reliability modes:** `GetTotemInfo` when present can override local timer estimates; without it, hooks produce **predictions on attempted actions before actual game casting**, not confirmed placements.
- The code observes spell/action inputs but **does not remove global cooldown, force a cast, or validate cast success**. Fail/interruption events trigger update, not rollback.
- Current fallback table has **23 spells** split Fire 5, Earth 5, Water 6, Air 7, and recognizes three recall names. One element's new totem replaces its local slot.
- Rewraps global `CastSpell`, `CastSpellByName`, `UseAction` when wrappers change; checks at roughly **0.1 seconds**. Test other addons' wrappers and load order.
- `UnitBuff` scans first 32 buffs and uses tooltip/texture comparisons for shields; charge maxima may be raised by observed counts.
- Weapon enchants are inferred from main hand if present, otherwise off hand, scanning tooltip for four imbue names; no independent two-hand status or duration timer.
- Empty slot warnings only appear with **alwaysShow** while in combat. `alwaysShow` defaults true; `hidden` overrides all. Stored settings are account-wide.
- Non-Shaman init unregisters events without creating display; slash handlers still exist and should be tested/guarded if behavior is expanded.
- Tooltip duration/charge/enchant detection has English text dependencies; locale/provider support is **unverified**.
- Old `OctoTotemTimersDB` data requires rename migration; safeguard files before any migration.
- There is **no LICENSE file** in the inspected tree. Do not invent one or assume third-party assets may be redistributed.

## How to work and document

1. Record what Babuni.dev requested and why, including source evidence.
2. Distinguish suggested changes, explicit creator decisions, implementation, tests and remaining uncertainty.
3. Make narrowly scoped edits. Preserve the core UX and source/dependency boundaries.
4. Execute actual target-client tests for totem placement/failure/replacement/recall, shield charge/weapon cases, and hooks. Synthetic Lua harnesses are not a substitute.
5. When migrating saved files, run PowerShell fixtures first and work only on backed-up data while WoW is closed.
6. Update README, CHANGELOG, ROADMAP, CONCEPT, AGENTS, docs/DEVLOG, docs/DECISIONS, docs/DESIGN, docs/CONTENT, docs/ARCHITECTURE, docs/AI_COLLABORATION alongside substantial code changes.
7. Preserve human creative authorship; AI gets credit only for documented proposals, implementations, analyses and writing. Don't publish private chats, passwords or private game account data.

The October 27, 2026 task is **documentation-only**; no code repair was requested or performed.
