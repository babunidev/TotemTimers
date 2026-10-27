# Totem Timers

**Creator / creative director:** Babuni.dev  
**Release:** 1.3.7 · **WoW client target:** Vanilla 1.12 / interface 11200 · **Author in TOC:** Babuni.dev  
**Historical name:** Octo Totem Timers (renamed September 18, 2026)  
**Current source:** [TotemTimers.lua](TotemTimers.lua) and [TotemTimers.toc](TotemTimers.toc)  
**Audit basis:** code, Git history, metadata and migration helper inspected October 27, 2026; no in-game tests run in this audit.

Totem Timers is a compact, movable **Shaman-specific** status panel for four elemental totem slots, shield charges, and weapon imbues. Its style takes cues from Blizzard's own frames rather than asking the player to maintain a separate settings-heavy interface. During combat it can draw a red **!** over an empty totem element.

It tracks **what the client reports or what the player attempted to cast**. On an older 1.12 client without a native totem-status API, its totem countdowns are predictions: a failed cast may still create a timer, and destroying or removing a totem early may not be detected. It does **not** grant faster casting, remove the global cooldown, cast spells for you, or independently verify the server has spawned a totem.

## Install and run

```text
World of Warcraft/
└── Interface/
    └── AddOns/
        └── TotemTimers/
            ├── TotemTimers.toc
            └── TotemTimers.lua
```

The [published v1.3.7 release](https://github.com/babunidev/TotemTimers/releases/tag/v1.3.7) contains a [TotemTimers.zip](https://github.com/babunidev/TotemTimers/releases/download/v1.3.7/TotemTimers.zip) and a checksum file. Extract the **TotemTimers** folder into Interface/AddOns or copy the two files above from this repo. Restart the client or use `/reload`. The manifest loads **one Lua source** and uses no external addon dependency.

The code checks `UnitClass("player")` when entering the world. If the player is **not a Shaman**, it unregisters addon events and does not create the display. That does not mean every slash command is gated by class; commands are registered outside the class check and should not be used on unsupported classes without testing.

## What the panel displays

| Location | Content | Behavior |
| --- | --- | --- |
| **Earth** | A current Earth totem / blank placeholder | 34px icon, remaining time or `--`, red exclamation while in combat and empty |
| **Water** | Water totem | Same, with water-specific placeholder color |
| **Fire** | Fire totem | Same; replaces a previous Fire timer when another Fire totem is attempted |
| **Air** | Air totem | Same |
| **Upper-left smaller icon** | Lightning Shield, Water Shield or Earth Shield | Reads player buff texture, tooltip and available charge information |
| **Upper-right smaller icon** | Weapon enchant | Rockbiter, Flametongue, Frostbrand or Windfury, recognized by a weapon tooltip |

**Display order is Earth → Water → Fire → Air**, even though the code's internal element indices and native API order are **Fire → Earth → Water → Air**. The panel deliberately maps the two orders.

A shield slot displays a gray Lightning Shield placeholder and red exclamation when no recognized shield is found. For an active shield, charge text is green at the observed maximum, gold with more than one charge but fewer than maximum, or red at one/zero. Recognized default maxima: Lightning Shield **3**, Water Shield **3**, Earth Shield **6**; higher observed counts can raise those maxima within the session.

Weapon enchant display checks for enchant presence, scans the equipped weapon tooltip for the four named imbues, and displays that item's tooltip on hover. It checks **main hand first**, then off hand only if no main-hand enchant is present. It does not maintain separate main/off-hand enchant timers or a precise enchant duration.

The fallback table recognizes **23 named totems**: 5 Fire, 5 Earth, 6 Water and 7 Air. These are documented individually in [content inventory](docs/CONTENT.md). A spell/action tooltip duration is preferred; the named fallback durations are used when a tooltip cannot supply one. Tooltip parsing expects English phrases such as “Lasts 30 sec”; localization/custom spell text may affect timing.

## Commands

| Slash command | Effect |
| --- | --- |
| `/totemtimers unlock` | Allow left-button dragging |
| `/totemtimers lock` | Prevent dragging |
| `/totemtimers show` | Show the full panel, even with empty elemental slots |
| `/totemtimers hide` | Hide the panel completely |
| `/totemtimers reset` | Restore the original center-relative position |
| `/ttimers ...` | Short alias for the same command set |
| `/totemtimers` | Print command help |

The addon stores `locked`, `hidden`, `alwaysShow`, and placement (`point`, `relativePoint`, `x`, `y`) in account-wide `TotemTimersDB`. **alwaysShow defaults to true**, so all four empty elemental slots are visible; `hide` overrides everything. The only implemented `show` mode sets both hidden=false and alwaysShow=true; there is **no current slash toggle** to make `alwaysShow` false.

**Totemic Recall:** attempts under the names `Totemic Recall`, `Totemic Call` and `Recall Totems` clear all four predicted slots. If native `GetTotemInfo` is available, the next refresh replaces predictions with that API's state. A normal totem cast replaces the estimate for its elemental slot.

## How timing works

There are two paths, with important different reliability:

1. **Native API path:** if the particular client supplies `GetTotemInfo`, the addon queries four slots on refresh and uses the reported name, start, duration and icon; empty slots are cleared.
2. **Legacy prediction path:** it wraps global `CastSpell`, `CastSpellByName` and `UseAction` to detect a recognized spell **before** delegating to the game's original function. It reads a tooltip or falls back to its duration table, and starts a local `GetTime()` deadline. The hooks are rechecked roughly every **0.10 seconds** so other addon wrappers can be noticed.

In legacy prediction mode a pressed ability may be resisted, fail for mana/range, or never place a totem. The code registers failure/interruption events but does **not** reconcile those events against its predicted slot state. Totem destruction and range/expiration differences also need in-game verification. “Supports rapid no-GCD totem casting” in the historic README means the code can notice multiple quick attempts; **this addon does not remove GCD restrictions**.

Shield state is read through `UnitBuff` and tooltips; weapon enchant presence through `GetWeaponEnchantInfo` and inventory tooltips. These are observations, not perfect verification across custom servers or all languages.

## Upgrade from Octo Totem Timers

If you played under the older **OctoTotemTimers** folder and **OctoTotemTimersDB** variable, you need to migrate SavedVariables when moving to **TotemTimers / TotemTimersDB**. Merely renaming the addon folder does not load older settings.

With WoW **closed**, retain the old installed folder and run the supplied helper from the new addon directory:

```powershell
.\Upgrade-SavedData.ps1 -ClientPath "C:\Games\World of Warcraft" -PreviousAddonName "OctoTotemTimers"
```

The script reads the old and new TOC, backs up originals under `AddonUpgradeBackups`, creates renamed files without overwriting existing ones, and replaces top-level SavedVariables declarations without running the Lua contents. It keeps original saved files. This source behavior was inspected; **the helper was not executed during this audit**. Its test fixture is [tests/test_upgrade.ps1](tests/test_upgrade.ps1). Test with backups before using real settings.

If using Linux, manually copy a **backup** of `WTF/Account/.../SavedVariables/OctoTotemTimers.lua` to the new file name and rewrite **only the top-level** variable assignment to `TotemTimersDB`, with WoW closed. Preserve the old file until successful verification.

## Current limitations and testing

- **Predictive cast detection** is not a guarantee a totem spawned. Failed casts, destroys and nonstandard totem effects can drift in old clients.
- Native `GetTotemInfo` is **optional** and cannot be assumed on an ordinary original 1.12 client.
- Tooltip parsing uses some **English phrases** and Shaman spell names; full multilingual support hasn't been tested here.
- Global wrappers can interact with other addons wrapping the same functions. Rapid 0.1s rewrapping deserves compatibility/performance tests.
- The shield scan only inspects the first **32** player buffs; charge data can be missing or interpreted differently on custom clients.
- The weapon effect display prioritizes the main-hand enchant and only scans known names; unusual enchants use a generic label.
- There is **no LICENSE** in this repository; public source does not automatically grant reuse rights.
- The release notes report historical syntax/migration checks, but the release ZIP and checksum were **not** independently downloaded/verified in this documentation session, and **no game tests were run**.

## Development and attribution

Totem Timers originally appeared as **Octo Totem Timers** on September 10, 2026, already at version **1.3.7**. The September 18 rename standardized names and introduced migration tooling, followed by Babuni.dev attribution and a small documentation scaffold on October 26. The current audit expands that into a publishable, source-grounded project record.

[Concept](CONCEPT.md) · [Roadmap](ROADMAP.md) · [Changelog](CHANGELOG.md) · [Architecture](docs/ARCHITECTURE.md) · [Design](docs/DESIGN.md) · [Content](docs/CONTENT.md) · [Decisions](docs/DECISIONS.md) · [Development journal](docs/DEVLOG.md) · [AI collaboration](docs/AI_COLLABORATION.md) · [Development rules](AGENTS.md)

**Creative vision and final decisions:** Babuni.dev. **AI contribution in this audit:** code/history interpretation and documentation only; no creative idea or prior code was retroactively attributed to the assistant.
