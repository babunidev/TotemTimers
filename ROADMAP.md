# Totem Timers — verification roadmap and open engineering tasks

**Decision maker:** Babuni.dev. **Evidence level:** source inspection only in the current documentation pass, not live execution.

## Present in version 1.3.7 source

- Single-file Lua 5.0-era addon, interface **11200**, Shaman-only display initialization and account-wide `TotemTimersDB`.
- Four elemental timer placeholders and countdowns, combat warnings, buff-derived shield charges, weapon enchant display, drag/lock/hide/restore.
- Built-in fallback timings for **23 named** totems (5 Fire / 5 Earth / 6 Water / 7 Air) with spell/action tooltip duration overrides.
- Conditional native `GetTotemInfo` four-slot polling; otherwise global spell/action wrappers for time predictions.
- Three recall spell name variations clearing predicted slots.
- Periodic hook/display refresh approximately every **0.10 seconds**.
- PowerShell migration helper and synthetic fixture test for old OctoTotemTimers SavedVariables.
- A published [v1.3.7 ZIP plus checksum](https://github.com/babunidev/TotemTimers/releases/tag/v1.3.7), with release notes **reporting** historic syntax/migration checks.

## P0 — gameplay correctness

1. Run in the intended **WoW 1.12 client**, record actual build/server and whether `GetTotemInfo` is defined. Confirm the TOC loads without Lua errors.
2. Verify all four visual slots in the intended order and check that Earth/Water/Fire/Air tooltips/icons align with their labels.
3. Cast one totem from each element by action bar, spellbook and **CastSpellByName** macro; verify timer starts and the previous totem of that element is replaced.
4. Attempt a **failed totem cast** from low mana, out of range or interrupted input. Check whether the legacy fallback incorrectly starts a timer, and determine the desired reconciliation behavior before changing code.
5. Destroy/take down a totem early and confirm whether the client has native status info or the predicted countdown remains until expiry. Compare to actual game observations.
6. Cast **Totemic Recall/Totemic Call/Recall Totems** as available. Verify predicted slots clear and native-state refresh agrees; test recall when a spell attempt itself fails.
7. Exercise rapid back-to-back casts on a custom **no-GCD** variant if supported; this addon should *observe* attempts, never claim to remove or bypass the global cooldown.
8. Verify empty-slot red **!** warnings only in combat when `alwaysShow` allows empty icons; verify `hide` supersedes the panel and `show` restores it.
9. Test Earth/Water/Lightning Shield application, charges consumed, zero-charge behavior and how the first 32 buffs are scanned. Confirm the “maximum observed” charge tracking matches the intended client.
10. Test weapon enchants with recognized **main-hand**, recognized **off-hand only**, both hands enchanted, and unknown enchant tooltips. Confirm tooltip and priority behavior.

## P1 — UI and old-client compatibility

11. Verify `/totemtimers` and `/ttimers` aliases; `lock`, `unlock`, `show`, `hide`, `reset` persistence across reloads.
12. Test account-wide saved location on multiple Shaman characters; test non-Shamans without using unsafe command paths.
13. Test `GetTotemInfo` on client variants and **absence** on original 1.12; record whether it overwrites locally inferred timer fields.
14. Test rank-specific durations and spell names; existing tooltip parser uses **English**, so check localized and custom clients explicitly.
15. Test load order alongside addons wrapping **CastSpell / CastSpellByName / UseAction**, including MeleeStartAttack; repeated rewrapping can create hook-chain complexity.
16. Profile 0.1-second buff/inventory tooltip scans and icon refresh on a low-end machine or crowded raid.
17. Check status accessibility: tiny timer digits, color contrast, shield charge colors, and red warnings that don't imply four totems are required in every fight.

## P2 — packaging and archival data

18. Run `tests/test_upgrade.ps1` in PowerShell on synthetic temporary fixtures and record actual output. Then test migration on **copies** of old OctoTotemTimers data while the game is closed.
19. Download the v1.3.7 ZIP and compare SHA256 with release checksum; inspect package TOC/module list. No such byte check was made in this audit.
20. Consider a Lua stub harness for failure/replacement/recall/tooltip state, keeping its results distinct from gameplay tests.
21. Resolve the repository's absent LICENSE if Babuni.dev intends others to reuse or redistribute source.

## Unapproved options for creator decision

- Should failed casts explicitly roll back predicted timers, even when multiple attempts overlap?
- Should a missing empty totem be a warning, a neutral icon, or individually customizable?
- Should the display separately represent off-hand enchants and enchant durations?
- Should scanning become event-driven rather than every 0.1 seconds?
- Should the default `alwaysShow=true` be user-toggleable through slash commands?
- Which specific client variants and custom totem spells are supported based on actual tests?

No AI suggestion in this document is a decision to change runtime behavior.
