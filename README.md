# Totem Timers

**Author:** Babuni.dev

A compact, Blizzard-style Shaman totem display for **World of Warcraft 1.12**.

## Features

- Tracks Earth, Water, Fire, and Air totems with remaining durations
- Warns about missing totems during combat
- Shows Water, Lightning, or Earth Shield charges
- Shows the active Rockbiter, Flametongue, Frostbrand, or Windfury weapon enchant
- Supports Totemic Recall and rapid no-GCD totem casting
- Draggable, lockable, and Shaman-only

## Installation

1. Download or clone this repository.
2. Copy `TotemTimers` into `World of Warcraft\Interface\AddOns`.
3. Restart WoW or use `/reload`.

The final path should be:

```text
World of Warcraft\Interface\AddOns\TotemTimers\TotemTimers.toc
```

## Upgrade from a previous add-on name

If you used this add-on under a previous folder name, migrate your saved data
before playing with the new installation. A normal file replacement is not
enough when the folder and saved-variable names change.

1. Fully close the game. Keep the previous add-on installed for this step.
2. Install the new `TotemTimers` folder beside the previous folder.
3. Open PowerShell in `TotemTimers` and run the following, replacing both example values:

   ```powershell
   .\Upgrade-SavedData.ps1 -ClientPath "C:\Games\World of Warcraft" -PreviousAddonName "PreviousAddonFolder"
   ```

The helper reads the previous TOC, copies account-wide and per-character saved
data to the new names, and saves backups under `AddonUpgradeBackups` in the
game folder. It keeps the original files intact and refuses to overwrite
existing saved data for the new add-on. It does not execute saved Lua code.

4. Disable the previous add-on and enable **TotemTimers** before entering the world.
5. Check your settings and saved data. Keep the backups until you have verified them.

Further updates using the same add-on name keep your saved data normally.
On other operating systems, back up the files, then copy the previous add-on's
`.lua` file in each `WTF/Account/**/SavedVariables` directory to `TotemTimers.lua`.
Change only the top-level variable name declared in the old TOC to the matching
name in the new TOC; leave its table contents unchanged. Do this with the game closed.

## Commands

| Command | Description |
| --- | --- |
| `/totemtimers unlock` | Unlock and drag the display |
| `/totemtimers lock` | Lock its position |
| `/totemtimers show` | Show the complete display |
| `/totemtimers hide` | Hide the complete display |
| `/totemtimers reset` | Reset its position |

Settings and position are saved between sessions.
