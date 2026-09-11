# Materials logistics and C2 Supply

Base verified before edits: local main and freshly fetched origin/main both
45d3d4409902b33ea8d4e0c20169c0ec16f34d37. No Agreement unlock or HOME artwork changes.

## Inventory and stockpile

The existing inventory was unlimited and stored individual item instances without
stacks. It now has a shared, saved `slot_capacity` (DEV default 12). Every instance,
including owned/equipped equipment, counts once. Buying, commissioning, adventure
pickup and battle rewards respect that same limit; there is no material-only bag.

The existing item/instance infrastructure is reused with a non-equippable CARGO
category and `material_value`. `material_bundle.tres` supplies 4 materials per item
(DEV). No stack merging exists, so 2 bundles always use 2 slots. Cargo is not sold
through equipment trading and cannot be equipped. Whole bundles are validated.

External 8/12/24 material caches now yield 2/3/6 physical bundles. A full bag leaves
the exploration reward unclaimed and available for a later visit. A single confirmed
HOME unload removes all material cargo and credits the stockpile exactly once.
C2 is not required. Existing construction/forge costs still use `state.materials`,
which is now explicitly the HOME stockpile. No service spends bundles automatically.

For battle loot, items that fit are acquired in roll order; excess items stay behind.
The victory screen warns about this before returning, the result records their names,
and a full bag cannot prevent resolving victory. Existing gold rewards are unchanged.
Sell ordinary equipment or unload cargo to make room. There is no stash simulation.

## Supplier and prices

One real contact: existing village innkeeper/trader. His description already includes
local trade and travelling goods. An authored dialogue establishes a free relationship;
ordering stays in a separate Supply Panel. No new character or quest was introduced.

Reputation is currently a global campaign integer. Supply reuses the trader's existing
reputation tier selector: base price below 10, x0.9 at 10, x0.8 at 20. The supplier
sets a configurable floor of x0.8 and prices round up. No separate reputation state.
Supplier/package requirements are runtime rules. Existing authored campaign conditions
can express later quest/contact requirements without a new progression system.

DEV offers (all authored resources, subject to balance later):

| Package | Materials | Base gold | Time | Required reputation |
|---|---:|---:|---:|---:|
| Small | 5 | 30 | 1 day | 0 |
| Standard | 10 | 55 | 2 days | 5 |
| Large | 20 | 100 | 3 days | 10 |

At reputation 20: prices 24 / 44 / 80. Exploration remains free but consumes travel
and carrying space; supply pays for delivery convenience. Capacity, bundle yield,
prices and delivery times need later playtest balance, not automatic expansion now.

## Delivery and save contract

A confirmed order deducts money once and saves supplier/package, amount, paid gold,
order time and arrival time. Membership in `active_deliveries` implies paid; there is
no redundant paid boolean or duplicated reputation. One active delivery per supplier,
with independent different suppliers allowed. Arrival does not depend on party location
or rechecking access/reputation after payment. Normal runtime time advancement credits
HOME and removes completed deliveries once, after successful time processing.

Format 14 strictly saves capacity, relationships, deliveries and left-behind battle
loot alongside ordinary item instances. Old format 13 is rejected: start a new debug
campaign. Invalid/duplicate suppliers, changed package amounts, invalid payment/times,
missing fields and invalid capacity are rejected. No arbitrary warehouse capacity,
passive production or new cheats were added. C2 remains gated by the carpenter Agreement.

## Main changes

- Inventory and item definition: shared slots and CARGO material value.
- Adventure service/content: physical rewards with transactional rollback.
- Trading, commissions and loot: capacity checks.
- `core/campaign/supply/`: supplier/package definitions, delivery state and service.
- Campaign definition/state/runtime/save: relationships, unloading, payment and arrivals.
- Innkeeper dialogue: authored supplier agreement.
- `CampaignSupplyPanel`: inventory list, unload confirmation, suppliers, prices,
  requirements, order confirmation, transit timer. Accessible via ГРУЗ / ПОСТАВКИ.
- HUD distinguishes HOME stockpile, carried materials and occupied slots.
- Old early-progression tests now unload their materials before building.

## Checks

Godot --headless --path <project> --script res://tests/campaign/<name>.gd:

- logistics_smoke: physical pickup, full bag, equipment competing for capacity,
  non-equippable cargo, excess battle loot, unload, early B1+C1, C2/relationship/rep
  gates, capped prices, insufficient money, one payment, delayed exact arrival away
  from HOME, active and completed saves, no duplicate credit, two supplier fixtures,
  invalid saves and old version rejection, unchanged C2 content gate.
- logistics_ui_smoke: actual campaign navigation/panel, unload confirmation, no supplier,
  innkeeper dialogue, locked reputation, discount prices, order confirmation, timer,
  active save/load and direct HOME arrival. Uses an isolated test fixture for C2.
- Regression: construction_smoke, forge_smoke, forge_ui_smoke, carpenter_smoke,
  carpenter_quest_smoke, respec_smoke, respec_ui_smoke, debug_sabre_smoke.

Rendered Godot-window flow was also executed and screenshots inspected for pickup,
unload confirmation, empty supplier state, actual innkeeper dialogue, reputation locks,
prices/discount, order confirmation, active timer and completed delivery. Test saves
use unique paths and are removed. Player saves are not overwritten by tests.
