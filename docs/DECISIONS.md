# Totem Timers — decisions register and unresolved tradeoffs

**Decision authority:** Babuni.dev. **Evidence:** September 10 initial source, September 18 rename and October 26 attribution/doc commits. Git does not preserve all early brainstorming.

## Choices that exist in code

| Choice | Source evidence | Qualification |
| --- | --- | --- |
| Compact native-style four-element UI | `CreateDisplay`, original README | Designed/implemented; no UX test in this audit |
| Visible order Earth/Water/Fire/Air | `DISPLAY_ORDER={2,3,1,4}` | Different from internal Fire/Earth/Water/Air index |
| Shaman-only initialized frame | `InitializeAddon` class check | Slash handlers exist regardless; unsupported classes need testing |
| Empty element placeholders by default | `alwaysShow = true`, `UpdateDisplay` | Red ! while in combat, never proof that four totems are necessary |
| Tooltip duration before defaults | `ScanSpell`, `ScanAction`, 23-name `TOTEMS` table | Attempt-based estimation, English phrase recognition |
| Native totem API if present | `UpdateFromNativeAPI` | More authoritative, but client API presence/semantics unverified |
| Shield/weapon auxiliary icons | `UnitBuff`, `GetWeaponEnchantInfo` | Counts/known names; no enchant duration |
| Global cast/action wrappers | `EnsureCastingHooks` every ~0.1s | Interop/performance risk, not demonstrated conflict |
| Saved position/visibility | `TotemTimersDB` account-wide | No per-character separate profile |
| Rename with migration | Sep 18 `cdef17e` | OctoTotemTimersDB → TotemTimersDB, safe-data helper |
| No additional dependency | Manifest loads one Lua script | Does not mean every client API used is available |

## The visible timeline—and its limits

**September 10, 2026:** `f6a0d3c` “Initial release” checked in a full nearly 600-line implementation already labeled **1.3.7**. Versions 1.0–1.3.6 were **not** individually recorded in this Git repo. Don't invent earlier milestones or tester disagreements.

**September 18:** `cdef17e` generalized the title from **Octo Totem Timers** to **Totem Timers**; script, saved-variable root, slash commands and frames followed. A PowerShell helper/test preserved old settings. A public 1.3.7 ZIP/checksum release appeared the same day.

**October 26:** author attribution and a basic Markdown documentation scaffold were committed. The October 27 review expands the record; it is not a gameplay feature revision.

## Engineering problems to resolve with the creator

**Attempt versus confirmed totem:** Wrapping functions is low-friction but can show failed casts as real countdowns. Native API availability determines whether that estimate is corrected. A server/client-tested repair might reconcile failures and destruction, but the creator has not approved one.

**Fast detection versus safe hooks:** Polling and wrapping globals every 0.1s can coexist with some addons yet also risks accumulating wrapper chains in an arms race with another hook manager. Test before claiming this is an observed failure.

**Missing reminders versus player choice:** A combat exclamation for every empty element might support awareness but could create unhelpful pressure; a future opt-out isn't approved yet.

**Localization and custom clients:** Some shield/enchant names and tooltip duration patterns are English literals; compatibility is not universal by declaration alone.

**Account-wide versus personal placement:** Keeping one setting across all characters is efficient, but per-character layouts are a possible alternative only if chosen.

## Open questions, not user approvals

Should the stop/missing warnings become customizable? Should a confirmed client event replace attempt-based predictions? Are both hand enchants needed? Should hook scan frequency change? Is there a preferred documented code license? Keep answers pending until Babuni.dev explicitly decides and runtime outcomes are observed.
