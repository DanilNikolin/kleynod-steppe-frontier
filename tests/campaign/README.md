# Carpenter smoke tests

Run with Godot 4.7 from the project root:

```text
Godot --headless --path . --script res://tests/campaign/carpenter_smoke.gd
Godot --headless --path . --script res://tests/campaign/carpenter_quest_smoke.gd
Godot --headless --path . --script res://tests/campaign/construction_smoke.gd
```

Checks the real debug campaign, wandering before acquaintance, innkeeper clue,
pin across long detours, first/repeat conversations, local resident card,
save/load before and after meeting, invalid saved locations, and recruitment gate.
Temporary test saves use unique names and are removed; the player save is untouched.

## Current slice

- Carpenter jobs alternate between the existing village and city every three days.
  This is DEV pacing and an initial early-location pool, not final world content.
- An innkeeper clue reserves the current location until the first conversation.
  It has no expiring travel deadline. Closing the first conversation still counts
  as acquaintance; subsequent meetings remain at that location.
- The personal quest reveals two sites on the Old Homestead: recovering tools and
  hearing a witness's account of the missing family. Both are required for turn-in.
  Tools are recorded as quest progress, not a sellable item. The family lead is
  retained in the completed site and HOME dialogue; finding them is a later quest.
- Turn-in unlocks an invitation. A1/B1/C1 are required at the service level; the
  invitation moves the carpenter to HOME with distinct HOME_GUEST status.
  Arrival now opens the temporary worksite and the first forge-shell construction
  loop, described in [CONSTRUCTION.md](CONSTRUCTION.md).
- Save format is now 13. Start a new debug campaign; older versions are rejected by the
  existing strict loader rather than silently losing resident state.

Manual F5 check: start a new campaign, visit the village innkeeper, ask where the
carpenter is, follow the named location and accept his quest. Travel from the village
to Old Homestead, explore both sites, return to the carpenter and report. Prepare
the campfire, party shelter and common shelter, then invite him. At HOME the guest
must be available for conversation. His nearby temporary worksite opens construction.

Forge I and DEBUG Sabre: see [FORGE.md](FORGE.md) for architecture, provisional values and checks.

Materials logistics / C2: see [LOGISTICS.md](LOGISTICS.md). Current save format: 14; start a new debug campaign. External materials must now be carried and unloaded in HOME.
