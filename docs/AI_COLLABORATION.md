# Totem Timers — human/AI collaboration and provenance

**Original creator / creative decision-maker:** Babuni.dev.

## Authorship and historical limits

The first September 10, 2026 commit and README establish a Shaman-centric visual addon: a four-element totem timer, shield and weapon auxiliary icons, red missing warnings, native-looking styling and drag/lock commands. The project idea and creative authority remain with **Babuni.dev**.

The source does not record every earlier private discussion, alternate UI sketch, uncommitted version or which AI—if any—generated an earlier Lua function. The visible version was already **1.3.7** at first commit; it would be inaccurate to invent versions 1.0–1.3.6 as separately documented releases.

The Sept 18 rename was a recorded technical operation with consequences for users' saved state. The migration script is credited as committed project work; the October editorial assistant does not claim to have implemented it.

## Documented assistant contribution — October 27, 2026

The assistant:
- Confirmed **TotemTimers** as repository **#22** of the current numbered Babuni.dev audit, explicitly skipping #21 GroupBuffToggle.
- Examined the 600-line `TotemTimers.lua`, manifest, existing documentation, PowerShell saved-data tool and fixture, and the two substantive September Git commits.
- Verified public **v1.3.7 release metadata** including ZIP and checksum links.
- Distinguished native `GetTotemInfo` reads from **cast-attempt-based timer prediction** and documented possible failed-cast drift and global wrapper behavior.
- Mapped 23 fallback totems, 4 element ordering, three shield names, four weapon enchant names, commands and SavedVariables.
- Authored/revised 11 Markdown files and checked them against the current source without editing any executable code.

This is **research, technical interpretation and documentation**, not a claim of original conception, 2026 gameplay testing, a fix for timer accuracy, creator approval of any new feature, or verification of binary releases.

## Future work must preserve the collaboration

For each material future change, record:
1. **User direction:** desired player experience, reason and restrictions.
2. **AI suggestion/implementation:** actual alternatives and code/document contributions.
3. **Creative iteration:** mistakes, competing approaches, tests, rejected solutions.
4. **Creator decision:** explicit accepted/rejected/deferred outcome.
5. **Implementation:** exact source, documentation and commit identifiers.
6. **Verification:** actual game client, test setup, screenshots, observed results and unknowns.

Public portfolio entries should be **narrative summaries**, not raw private conversations or client credentials/account data. Do not imply feature proposals in ROADMAP are authorized decisions.

No Lua, TOC, saved-data utility or regression fixture was changed by this October 27 documentation audit.
