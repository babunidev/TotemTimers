# Octo Totem Timers

A compact, Blizzard-style Shaman totem display for **OctoWoW / Vanilla 1.12**.

## Features

- Tracks Earth, Water, Fire, and Air totems with remaining durations
- Warns about missing totems during combat
- Shows Water, Lightning, or Earth Shield charges
- Shows the active Rockbiter, Flametongue, Frostbrand, or Windfury weapon enchant
- Supports Totemic Recall and rapid no-GCD totem casting
- Draggable, lockable, and Shaman-only

## Installation

1. Download or clone this repository.
2. Copy `OctoTotemTimers` into `World of Warcraft\Interface\AddOns`.
3. Restart WoW or use `/reload`.

The final path should be:

```text
World of Warcraft\Interface\AddOns\OctoTotemTimers\OctoTotemTimers.toc
```

## Commands

| Command | Description |
| --- | --- |
| `/octototems unlock` | Unlock and drag the display |
| `/octototems lock` | Lock its position |
| `/octototems show` | Show the complete display |
| `/octototems hide` | Hide the complete display |
| `/octototems reset` | Reset its position |

Settings and position are saved between sessions.
