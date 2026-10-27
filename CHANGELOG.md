# Totem Timers — Git and release changelog

**Original project creator:** Babuni.dev. Commit/release dates establish recorded changes, **not** client test outcomes.

## October 27, 2026 — comprehensive documentation audit

- Replaced initial brief repository docs with a sourced concept, user guide, architecture, design, content inventory, decisions, roadmap, development narrative and AI collaboration record.
- Documented the distinction between **native `GetTotemInfo`** and the fallback's **attempt-based predicted totem durations**.
- Clarified Shaman-only display, four-element ordering, 23 fallback spells, shield/weapon behavior, warning semantics, persistent state, hook interaction risks and original Vanilla support uncertainties.
- Verified a published [v1.3.7 release](https://github.com/babunidev/TotemTimers/releases/tag/v1.3.7) with ZIP/checksum metadata. No archive byte comparison or runtime test conducted here.
- Changed **Markdown documentation only**; Lua/TOC, migration script and test remain unchanged.

## September 10, 2026 — initial committed Octo Totem Timers

Commit **`f6a0d3cd723c`**, “Initial release,” introduced **OctoTotemTimers.lua** and a TOC already declaring **version 1.3.7**, interface 11200, and `OctoTotemTimersDB`. Its 599-line Lua source already included elemental timers, empty icons, shield and weapon states, casting interception, native API option, recall handling, positioning, and Shaman-only initialization.

This is the **first visible commit**, not proof that versions 1.0–1.3.6 were each independently released or that development took a single day. Earlier local experiments, tester feedback and design conversations are not visible in Git.

## September 18 — provider-neutral name and saved-data continuity

Commit **`cdef17ea0b3f`**, “Use provider-neutral names and client compatibility descriptions,” renamed **Octo Totem Timers** to **Totem Timers**, the folder/module/frames/slash aliases, and the persisted root from `OctoTotemTimersDB` to **`TotemTimersDB`**. It retained the addon version **1.3.7**, added **Upgrade-SavedData.ps1** and **tests/test_upgrade.ps1**, and revised README instructions.

The [GitHub release v1.3.7](https://github.com/babunidev/TotemTimers/releases/tag/v1.3.7) was published September 18, containing **TotemTimers.zip** and **SHA256SUMS.txt**. Its notes state source/package syntax and migration tests passed and still recommend live-client verification. These are **historic claims**, not tests independently rerun October 27.

## October 26 — attribution and documentation skeleton

- `8d80e477`: standardized TOC author from `Local` to **Babuni.dev**.
- `f6302d15`: added creator credit in README.
- `cf9e919b`: created concept, roadmap, changelog, AGENTS, architecture, decisions and DEVLOG starter records.
- `997ccee7`: linked those documents from README.

The current audit grows that preliminary record without modifying gameplay.
