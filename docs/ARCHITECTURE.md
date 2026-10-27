# Totem Timers — architecture and state accuracy

**Audited:** `TotemTimers.lua` (600 lines), `TotemTimers.toc`, migration script/test, September Git diffs, October 27, 2026. This is **static inspection**, not gameplay verification.

## Installed package and state

```text
TotemTimers.toc (Interface 11200 / Version 1.3.7)
    SavedVariables: TotemTimersDB
    TotemTimers.lua
      ├── static spell/element duration and texture tables
      ├── cast/action hooks and native-to-tem state option
      ├── UnitBuff shield and inventory-tooltip enchant lookups
      ├── 4-element visual row + shield/weapon icons
      └── events and repeating ~0.10s refresh
```

The native-totem query is `GetTotemInfo` if defined. It is **not guaranteed in original Vanilla 1.12**. No external library, network communication, image asset directory or server interaction is bundled.

## Class gating and event lifecycle

The frame subscribes to `VARIABLES_LOADED`, `PLAYER_ENTERING_WORLD`, spellcast stop/fail/interrupted, player totem changes, combat state, aura/inventory and spellbook changes. On world entry `InitializeAddon` checks the second return of `UnitClass("player")` for **SHAMAN**. Non-Shamans unregister addon events; Shamans create one display, scan tooltip, initialize global cast wrappers, then refresh on event or **0.10-second OnUpdate**.

The code registers both slash aliases **/totemtimers** and **/ttimers** globally even when initialization doesn't create the panel. This asymmetry could affect command use on non-Shamans; test before asserting full class-gated command behavior.

## Four-element state

The totem table stores a **slot index** and fallback duration for 23 recognized English spell names. Internally the order is:
- **1 Fire**
- **2 Earth**
- **3 Water**
- **4 Air**

The displayed `DISPLAY_ORDER={2,3,1,4}` produces **Earth, Water, Fire, Air**. Default empty textures and earth/water/fire/air-color hints are associated with internal indices, not visible column numbering.

`QueueTotem(name,duration,texture)` normalizes a trailing “(Rank X)” and, for a recognized totem, stores a new entry in its elemental slot with `GetTime()`-based `startTime` and `expires`. Casting a new same-element totem **overwrites its previous estimate**. The names `Totemic Recall`, `Totemic Call` and `Recall Totems` clear all four estimates.

`ScanSpell` asks a hidden GameTooltip for `SetSpell` title and duration. `ScanAction` uses `SetAction`. `CastSpellByName` passes the incoming name to the same queue without scanning a tooltip, so it always uses the fallback duration for a known named totem. If the tooltip gives no duration or is an unsupported locale, built-in seconds are used.

### Native versus predicted status

```text
OnUpdate or status-relevant event
   -> EnsureCastingHooks()
   -> UpdateDisplay()
         -> if hidden: hide and return
         -> if GetTotemInfo exists:
              for 1..4 native slots:
                  copy server/client-provided name/start/duration/texture
                  or clear
         -> else:
              use predictions from CastSpell / CastSpellByName / UseAction
         -> check shield UnitBuff and enchant tooltip
         -> update four countdowns and empty warnings
```

**Potential correctness problem:** all three wrappers call `QueueTotem` **before** delegating to the original spell/action API. A missed/failed cast can therefore begin a local timer. `SPELLCAST_FAILED` and `SPELLCAST_INTERRUPTED` are listened to but only cause a display refresh, **not rollback of the predicted slot**. Similarly, if a totem is destroyed early or expires unpredictably and native info isn't available, the estimate can remain until its deadline.

The native status path `UpdateFromNativeAPI` overwrites all four slots on each visible refresh. That is more authoritative *when actually supported by the client*, but does not prove server-specific versions/slot indexes are compatible in every variant.

## Global wrappers and interop

`EnsureCastingHooks` checks whether the globals `CastSpell`, `CastSpellByName` and `UseAction` still equal this addon's wrapper. If not, it captures their current function and sets a new wrapper that looks up a totem first then delegates. This check runs about ten times per second after initialization.

Because different addons can wrap these same globals, chains can be composed more than once if a second addon repeatedly rewraps a global; the source does not have an explicit chain-depth cap. This is a **potential interoperability/performance risk**, not a demonstrated infinite recursion from a real client.

## Shield observations and limitations

The addon inspects the first **32 UnitBuff("player", index)** slots. For each it uses texture matching against dynamically refreshed spellbook textures, or a cleaned tooltip title, to recognize **Lightning, Water and Earth Shield**. It reads a charge count from UnitBuff applications or the tooltip's “N charges” text, defaulting to zero if unavailable.

Max-charge defaults are **3 / 3 / 6** but increase if a higher observed count appears. The UI paints current charges green when at/above max, yellow with 2..max-1, red at 0 or 1; absent shield becomes a dim placeholder plus a warning. No exact shield uptime timer is displayed.

## Weapon enchant observations

`GetWeaponEnchantInfo` checks a temporary main-hand enchant, else an off-hand enchant. It scans inventory slot **16** or **17** tooltip lines for one of **Rockbiter, Flametongue, Frostbrand, Windfury**. Matching names select a spellbook icon when present, falling back to a known game icon. An unrecognized temporary enchant can display as “Weapon Enchant” using its equipped item texture; no two-hand list, enchant count or remaining-duration clock exists.

## Layout and persistence

The backing panel uses WoW's tooltip backgrounds/borders, four **34px** elemental buttons and two **26px** auxiliary shield/weapon buttons. The frame is draggable when `TotemTimersDB.locked` isn't set. Position saves `point`, `relativePoint`, `x`, `y`; `hidden` overrides all drawing, while `alwaysShow` defaults true and leaves empty element placeholders visible.

`UpdateDisplay` clears an expired estimated slot, formats time as `m:ss`, seconds or tenths below ten seconds, and shows missing-element red **!** only in combat when empty slots are enabled.

## Migration and tests

On September 18 the project switched from **OctoTotemTimersDB** to **TotemTimersDB** and added `Upgrade-SavedData.ps1`. It reads TOC declarations, backs up discovered saved files, rewrites root assignments in copies and refuses overwrite. `tests/test_upgrade.ps1` creates temporary synthetic account/per-character fixtures with Unicode and checks backups/overwrite/path refusals. The historic v1.3.7 release notes report tests passed; **they were not rerun in this audit**, and no live client was used.
