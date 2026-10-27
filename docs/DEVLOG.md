# Totem Timers — creative and technical development journal

**Creator and creative director:** Babuni.dev  
**Retrospective prepared:** October 27, 2026, from the current Git tree, TOC, full 600-line Lua implementation, September commit diffs, published release metadata and README. The original human/AI planning dialogues were not recovered; this journal does **not** invent them.

## The Shaman's four-part attention problem

The idea behind Totem Timers is one of those interface improvements that appears small because it responds to a very specific gameplay experience. A Shaman can place totems tied to four elements, each with its own duration and purpose. In combat, remembering every placement, its remaining lifetime and the state of nearby personal enhancements means looking at several different places in the client or mentally counting time.

Babuni.dev's project brings that information into a **Blizzard-looking, draggable instrument**. Four familiar icons organize Earth, Water, Fire and Air into one compact row. Above them, two smaller status icons track shield charges and temporary weapon enchants. Empty elements don't disappear by default: the frame's silhouette stays complete. During combat, an empty elemental position gets a red exclamation, giving an at-a-glance sign that no totem is currently known in that category.

The point isn't to play the class for the player. The source doesn't select totems, automatically cast spells or change the global cooldown. It tries to make existing Shaman state legible. Whether every empty element should prompt a warning remains a gameplay/UX question, not a demonstrated rule that all four must be used.

## September 10, 2026 — an initial commit with a mature-looking source

The first Git commit, **`f6a0d3cd723c`** on September 10, is titled “Initial release.” It uploaded **OctoTotemTimers.lua**, an Octo-named TOC and an original README. The TOC was already **version 1.3.7**, and the Lua file was roughly **599 lines**. It provided the element row, expected timers, shield and weapon identification, cast hooks, positioning, combat warnings and class gating.

This is important for honest historical writing. A file called version 1.3.7 implies that development may have occurred before it was placed in this Git repository, but **the repo doesn't contain commits showing versions 1.0 through 1.3.6**. We cannot turn that version number into a fictional sequence of changes, tests and approvals. The first *visible* implementation is already broad; older sketches or uncommitted experiments are unknown.

The original first-commit title used the name **Octo Totem Timers** and a particular custom WoW provider reference. This is a development context, not proof that every later 1.12-compatible client behaves identically.

## Reading an old client's limited information

The central technical challenge is discovering which totem exists in the world. Modern-compatible clients may expose `GetTotemInfo`, allowing actual four-slot duration/state reads. The source checks for this API and prefers it when present.

But the classic 1.12 surface is more limited. The implementation therefore wraps **CastSpell**, **CastSpellByName** and **UseAction**. When the player *tries* to use a recognized totem, the addon first records the attempt with a start time and duration (from the tooltip if possible, otherwise a fallback list). The original game function is then invoked.

This solution supports rapid back-to-back actions without waiting for a fixed cooldown tick. The original README described “rapid no-GCD totem casting”; the code itself **does not remove or bypass the global cooldown**. It observes eligible attempts made by the player.

There is a price. The addon **predicts** a totem instead of confirming one was placed. A failed cast can create a convincing countdown in legacy mode, and the registered failure/interrupted events don't actually roll that countdown back. A totem destroyed early can likewise appear until local expiry. If the native API exists it replaces the predicted status at refresh, but availability and slot semantics depend on the client. The documentation treats this as a verification need, not as proof of a live defect on the creator's client.

The spelling of names and fallback seconds mattered. The code has **23** recognized totem spells, divided among Fire, Earth, Water and Air. For spellbook/action buttons it attempts to read duration phrases from a hidden tooltip. For `CastSpellByName` it uses its known table. Recognizing a new same-element totem replaces the old local slot; known recall variants clear all four estimates.

The code further checks a player's first **32 buff slots** for Lightning, Water or Earth Shield and extracts observed charge counts. It scans temporary weapon enchants through equipped-item tooltips, prioritizing main hand. Those represent a desire for one readable Shaman status widget rather than unrelated addon popups. Charge text uses simple green, yellow and red states to help the player notice depletion.

## Visual logic rather than a full interface replacement

The panel uses built-in WoW tooltip borders and backgrounds, 34-pixel totem icons and 26-pixel secondary status icons. Internal indices follow Fire/Earth/Water/Air, but display order is **Earth/Water/Fire/Air**. This deliberate mapping brings the elements into the visual order found in the original source rather than blindly exposing the game's internal enumeration.

The countdown changes format as expiry approaches: **minutes:seconds** above a minute, whole seconds down to ten, then tenths. The panel can be dragged and locked and remembers placement and visibility in account-wide **TotemTimersDB**. The saved `alwaysShow` preference defaults to true, preserving empty positions; `hidden` can hide everything.

This is the kind of work for which the development itself belongs in a portfolio. The result may simply look like four icons, but the code balances old-client API limits, tooltip-derived metadata, time predictions, auxiliary buff identification, and interoperability with independently written addons.

The hook management is one unresolved concern. Roughly every **0.10 seconds**, the addon checks whether another addon changed its hooked global functions, and if so it wraps them again while delegating. That preserves the attempt to keep receiving casts, but can create complex nested hook chains when multiple addons use similar strategies. No recursion or frame-rate issue has been demonstrated in this audit; it deserves actual joint-addon testing.

## September 18 — broadening the name without erasing settings

On September 18, commit **`cdef17ea0b3f`** changed **Octo Totem Timers** into **Totem Timers**. The source, TOC title, frame globals, commands and SavedVariables root were renamed from **OctoTotemTimersDB** to **TotemTimersDB**. The manifest version remained **1.3.7**.

A creator-facing design consequence was the risk of losing the previously saved frame placement, lock state and visibility. The repository therefore added **Upgrade-SavedData.ps1**, which reads old and new manifests, makes backups, copies old files under the new addon name, changes only root assignments and refuses to overwrite an existing new save. Its PowerShell fixture builds temporary account/per-character paths and checks Unicode, retention, backups and refusal conditions.

A public **v1.3.7** release was published on GitHub September 18 with a ZIP and checksum text. Its notes report successful packaging/syntax and saved-variable migration tests. Those historical notes **do not mean** this documentation assistant ran the tests, downloaded the ZIP or played a Shaman in WoW. The source remains a record of functionality implemented, not of every behavior verified in game.

## October 26–27 — preserving the work as part of Babuni.dev

October 26 commits standardized the author field from **Local** to **Babuni.dev**, credited the creator in README and created a brief concept/roadmap/architecture/decisions/journal scaffolding. In the October 27 documentation session, the assistant examined the current source and its two substantive September commits, the saved-data migration tool and test, and release metadata, then authored fuller explanations.

**Human contribution:** the Totem Timers idea, original product direction and creative authority. **AI contribution in this session:** repository research, interpretation of code and history, assessment of source-level limitations, editing and committing documentation. Git alone does not prove which specific human or AI wrote every earlier Lua routine; this narrative does not invent such claims.

**Current verification:** inspection of source, commit history and public release metadata; after committing, checking changed blobs and internal links. **Not done:** executing WoW, pressing actual Totem Recall, testing buff/enchant changes, exercising addon hook chains, running the PowerShell fixture or byte-verifying the public ZIP.

## A future chapter should come from actual play

The most useful next evidence would be real tests from the intended game client: cast a Fire totem with low mana, switch element positions, remove a totem early, recall all, watch shield charges and try main-hand/off-hand imbues. The tests should distinguish what the addon **predicts** from what the character visibly owns and what the game API confirms.

The deeper portfolio story is about **making uncertainty usable**. The creator chose a tiny visual surface for a complicated four-element class, and the software's development shows how old game data limits can shape both what the interface promises and what its documentation must be careful not to promise.
