# Forge I

Scope: one building shell + one derived resident master + one saved major module.
No building level changes on recruitment, no Forge II/III, no passive forge income.

## Architecture and content

- `core/campaign/forge/`: module definition and operational/retool rules.
- Settlement definition identifies the workplace and allowed modules. Settlement
  state stores only `forge_major_module_id` (empty, weapon_equipment, armor_equipment).
- `CampaignResidentDefinition.is_forge_master` opts a resident into the forge.
  Existing resident/workplace readiness chooses the first eligible master in content
  order. The runtime and UI contain no Ostap ID dependency. No second master added.
- Personal commissions remain on each resident. `required_forge_module_id` gates
  that master's recipe; a module never supplies recipes independently of its master.
- Ostap requires the constructed `forge_shell`. His original forged sabre is unchanged
  and works without a module. Weapon equipment adds the existing debug heavy berdysh;
  armor equipment adds the existing debug steppe armor.
- `CampaignRuntimeService` reuses atomic commission creation and time advancement.
  Retooling also completes synchronously. There is no persistent unfinished order;
  a transient shared busy guard prevents reentrant equipment work. Stale panel
  revisions and expected current module prevent duplicate callbacks charging twice.
- `CampaignForgePanel` owns equipment and order actions. The shell interaction and
  the resident's HOME card open it. Talk opens the existing dialogue and returns to
  the forge on closure. Carpenter is not needed for retooling.
- Save format 13 requires the module field. Empty module is valid; unknown modules,
  modules without a shell, missing fields and old format 12 are rejected. Master
  and unlocked catalog are derived from the restored resident/workplace/module.

## Provisional values

Install or switch either module: 20 gold, 4 materials, 240 minutes.
Specialized orders: 60 gold, 3 materials, 240 minutes.
Existing basic order: 120 gold, 4 materials, 360 minutes (unchanged).
DEV notes are visible in game and content. These are not production balance.
The grove's one-time abandoned cart supplies 24 additional materials: earlier
supplies total 20 and are exhausted by the primitive camp and forge shell. This
extra debug supply supports both modules, sample orders and a reverse switch;
it is not a new replenishing economy.

The starting DEBUG Sabre is a separate item with a 50-base-damage ability. It is
not autoequipped, has no trade/loot value and belongs to neither loot nor stock.

## Verification

Run Godot with `--headless --path <project> --script res://tests/campaign/<test>.gd`:

- `debug_sabre_smoke`: starting item, damage, excluded from loot and trade.
- `forge_smoke`: shell/master separation, basic and specialized item creation,
  one slot, both retool directions, exact payment/time, repeated/stale request,
  insufficient resources, shared busy guard, calendar overflow, no ID-hardcoded
  master, absent personal recipe, valid saves for all three module states, invalid
  module and missing-field rejection, old version rejection.
- `forge_ui_smoke`: actual local action buttons open the separate panel; inactive,
  basic, weapon, armor states; order callback and stale callback; talk and return;
  resident card opens forge instead of exposing old direct order buttons.
- Regression: `construction_smoke`, `carpenter_smoke`, `carpenter_quest_smoke`.
- Headless `--check-only --quit`, startup `--quit-after 3`, editor resource import.

Visual integration was run in a real rendered Godot window with the campaign scene
and temporary fixtures. Screenshots inspected: no master, basic only, weapon order
available / armor locked, produced item, armor available / weapon locked, existing
Ostap dialogue, return to the forge. Fixtures and screenshots do not alter player saves.

## F5 player path

1. Start a NEW debug campaign (format 13). Equip DEBUG Sabre from inventory if desired.
2. Complete the existing carpenter/building flow; inspect the finished shell before
   inviting Ostap: the forge says it requires a smith and all services are disabled.
3. Complete Ostap's existing invitation and return HOME. Open the forge: Ostap is
   master; slot 0/1; forged sabre available; both specialized commissions locked.
4. Collect the abandoned cart in Nearby Grove if materials are needed.
5. Install weapon equipment; order a berdysh; confirm item and one cost/time advance.
6. Switch to armor: weapon order locks, armor opens, basic sabre remains available.
7. Save/load and verify the selected module/catalog. Switch back to weapon.
8. Talk to Ostap from the forge, finish the conversation, then close the forge.
