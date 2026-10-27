# Totem Timers — creative concept

**Creator / creative director:** Babuni.dev  
**Platform:** WoW 1.12, Shaman class, original 1.12 API constraints.

## Make four invisible commitments understandable

A Shaman can maintain several short-lived elemental tools at once. The game makes these abilities powerful and characterful, but the player must remember which Earth, Water, Fire and Air totem is still in the world and how soon each will vanish. Totem Timers condenses that attention problem into a **small, movable quartet of icons with countdowns**.

The visual intention is modest and specific: a **Blizzard-style frame**, not an alien productivity overlay. A brown/gold-bordered dark backing and familiar spell icons make it seem close to the game's existing interface. Empty elemental slots remain visible by default, so the player can see the complete four-part structure rather than merely remembering what's active. In combat, an absent element gets a red **!**.

This design does not insist that four totems always be active. A missing marker is a visual cue, **not a gameplay recommendation** to spend resources or drop a strategically unnecessary totem. The player remains in charge.

## Extend the same glance to adjacent Shaman states

Two smaller icons above the elemental row answer related questions: Is a Lightning/Water/Earth Shield active, and with how many charges? Is the weapon imbued with Rockbiter, Flametongue, Frostbrand or Windfury?

These are the sorts of details a Shaman can otherwise track across buff icons, inventory tooltips and memory. Bringing them into a compact arrangement offers a more legible combat instrument without automating spells or modifying the game world.

## Respect the old client, and its uncertainty

Original 1.12 does not necessarily expose a modern native totem-status API. The project handles this by observing which spell or action was *attempted*, reading its tooltip for a duration and tracking a local expiration estimate. When `GetTotemInfo` exists on a compatible variant, the code uses that stronger source.

This tradeoff is central to the concept: **help the player read the fight** despite limited data, while not asserting that a timer predicted from an attempted cast is proof that a totem actually spawned. Failures, recalls, destruction, spell renames and custom-client behavior complicate certainty.

## A small, authored interface

The code's presentation order is **Earth, Water, Fire, Air**, mapping an internal Fire/Earth/Water/Air model to the intended human-readable layout. The panel can be dragged, locked, hidden or restored; its position and choices persist account-wide. A 0.1-second display refresh keeps timers smooth without introducing a complex settings surface.

The original purpose, interaction goals and creative authority belong to **Babuni.dev**. This concept is an interpretation of the September 2026 source and documentation; the exact first ideation conversation was not recovered. No future changes have been approved simply by recording them as options.
