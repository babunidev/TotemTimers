# Totem Timers — supported spells, visuals and saved state

**Creator:** Babuni.dev. **Source:** `TotemTimers.lua` v1.3.7 as committed.

## Recognized totem-name fallback table

**Names are literal English keys** (with trailing Rank suffix removed), not class-independent IDs. Durations in the table are used when the addon can't derive duration from a spell/action tooltip. Client-specific totem changes and rank-specific durations require verification.

| Element | Named totem | Fallback |
| --- | --- | --- |
| Fire | Searing Totem | 30s |
| Fire | Fire Nova Totem | 5s |
| Fire | Magma Totem | 20s |
| Fire | Flametongue Totem | 120s |
| Fire | Frost Resistance Totem | 120s |
| Earth | Stoneskin Totem | 120s |
| Earth | Earthbind Totem | 45s |
| Earth | Stoneclaw Totem | 15s |
| Earth | Strength of Earth Totem | 120s |
| Earth | Tremor Totem | 120s |
| Water | Healing Stream Totem | 60s |
| Water | Mana Spring Totem | 60s |
| Water | Disease Cleansing Totem | 120s |
| Water | Poison Cleansing Totem | 120s |
| Water | Fire Resistance Totem | 120s |
| Water | Mana Tide Totem | 12s |
| Air | Grounding Totem | 45s |
| Air | Windfury Totem | 120s |
| Air | Grace of Air Totem | 120s |
| Air | Nature Resistance Totem | 120s |
| Air | Windwall Totem | 120s |
| Air | Tranquil Air Totem | 120s |
| Air | Sentry Totem | 300s |

**Total:** 23 spell names (Fire 5, Earth 5, Water 6, Air 7). This is a mapping inventory, **not a verified claim all spells or durations exist identically on every Vanilla variant**.

**Recall aliases:** Totemic Recall, Totemic Call, Recall Totems. On recognized attempts, these clear the predicted four-slot state.

## Shields and weapon-imbue spell names

**Shields:** Lightning Shield (default max **3**), Water Shield (**3**), Earth Shield (**6**). The addon reads applied charges from `UnitBuff` or tooltip; these are character buffs, not totem names. Actual buff textures can be refreshed from the player's spellbook.

**Weapon effects:** Rockbiter Weapon, Flametongue Weapon, Frostbrand Weapon, Windfury Weapon. Recognition scans main-hand tooltip first; it only checks off-hand tooltip if no main-hand temporary enchant is present. Game icons are referenced from the spellbook or hard-coded Vanilla icon paths.

**Other UI text:** four element names; **--** for an empty countdown; red **!** for missing totems while in combat and shield absence; gold/yellow timer/charge numbers; tooltip labels for recognized element and buff.

## Data storage

The TOC declares account-wide **SavedVariables: TotemTimersDB**. The source reads/writes:
- `locked`: whether the frame can be dragged.
- `hidden`: entire display visibility.
- `alwaysShow`: whether empty elemental slots remain visible (default true).
- `point`, `relativePoint`, `x`, `y`: frame placement.

**Not persisted:** per-totem timestamps, active cast predictions, shield charges, which enchant is active, historical combat events, player names or a log of placements.

## Content rights

The Git tree contains only the Lua source, TOC, Markdown, migration tooling and its PowerShell test. **No custom screenshots or artwork** were found in this repo. Displayed icons are loaded from the game's assets, not original imagery bundled for reuse. A LICENSE file was **not found**; creator licensing and upstream image rights remain unresolved.
