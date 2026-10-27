# Totem Timers — visual and interaction design

**Creative direction:** Babuni.dev.  
**Source:** current UI-building Lua and original README; no screenshot assets included in this repository.

## A Blizzard-looking instrument

The addon deliberately uses **native-feeling tooltip frame styling**: a black translucent backing, muted earthy border, familiar spell icons, restrained gold countdown numbers and compact type. It sits as a movable four-column instrument rather than a conventional configuration window.

The code creates a panel sized for **four 34px elemental icons**, spaced 5px apart, with two **26px supporting icons** above it. Its visible order is **Earth, Water, Fire, Air**, distinct from the internal game/native index order. This is a genuine interaction choice, not just a technical accident.

No custom icon textures or fonts are bundled. All imagery is referenced from the game client's existing UI/spellbook, making the interface feel at home within old WoW.

## Empty state has a purpose

**alwaysShow** defaults to true, so even before the player has placed a totem the four elemental compartments show a dim familiar icon and **--** for remaining time. During combat a red exclamation appears over each missing element; outside combat the exclamation is hidden.

This is not evidence of a gameplay rule saying four totems should always be cast. It is a visual status cue. Its usefulness, annoyance or interpretation needs genuine player testing. A player can hide the whole panel with **/totemtimers hide**, then bring it back with **show**.

The auxiliary shield slot stays visible even when shield buffs are absent, with a dim Lightning Shield icon and red **!**; the weapon enchant icon hides when no temporary enchant is detected. These asymmetries match current code and should be explained in screenshots if the portfolio later adds them.

## Shields and enchants at a glance

An active shield displays a charge number in green, gold or red, inviting the player to notice a low-charge state without scanning another buff bar. A weapon imbue shows a small icon, with the item tooltip on hover.

The current implementation does not measure enchant duration or show main and off hands independently. A visual redesign should not claim these are present.

## Movement and frame ownership

Use **/totemtimers unlock** to drag with the left mouse button, **lock** to finish, and **reset** to return to the default center-relative position. The setting and anchor survive reload via account-wide SavedVariables. The **/ttimers** alias offers the same commands. There is no standalone settings screen or keybinding UI.

## Design questions for future testing

- Are time fonts readable at common UI scales and color-vision settings?
- Does a red **!** for each empty element encourage unnecessary totem casting?
- Would users want a neutral no-warning mode or only warnings for previously active elements?
- Does the shield corner show enough context when tooltip charge reads zero or Earth Shield has more than six charges?
- Is a high-frequency 0.1-second refresh necessary for every tooltip-backed auxiliary state?
- Do the side icons and tooltip hover work reliably next to other addons?

These are unapproved questions, not new features or tested accessibility conclusions.
