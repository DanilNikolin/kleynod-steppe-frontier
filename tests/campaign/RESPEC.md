# B2: free full Skill Grid respec

Runtime APIs: `get_hero_respec_error(hero_id)` and `respec_hero_skills(hero_id)`.
Requires valid campaign/hero, HOME, active `party_respec_access`, and at least one
purchased node or attached branch. Battles, travel and placeholder heroes are rejected.
B2 construction/Agreement remains closed; no settlement content or HOME art changed.

The existing purchase model deducts each node's `skill_point_cost`; attachments are
free. Reset sums those costs, refunds them once, and clears nodes and attachments.
It prepares a separate progression resource, preserves equipment references and all
unrelated fields, removes unavailable personal abilities and respects reduced slots.
Existing build resolvers validate both original and candidate. Invalid candidates
or refunds beyond the existing save limit (999 free SP) are refused without edits.
Campaign validation after the swap restores the original resource if needed.
No money, materials, consumables, campaign time, or usage counter is involved.
Save format stays 13; ordinary progression fields represent the result.

Hero Preparation receives the runtime through its existing campaign binding. Before
B2 the action is hidden; afterwards its disabled reason explains location/empty grid.
Confirmation rechecks the hero and runtime gates. Placeholder roster entries remain
locked `???`. The legacy QA reset is restricted to standalone non-campaign panels.

Checks (Godot `--headless --path . --script res://tests/campaign/<name>.gd`):
- `respec_smoke`: no effect, outside HOME, unknown/placeholder hero, exact refund,
  complete encoded campaign preservation except reset fields, overflow transaction
  refusal, valid derived build, repeat safety, save/load, reset of a free attachment.
- `respec_ui_smoke`: hidden/available/confirmation/reset/repeat states, old QA reset
  cannot bypass the campaign gate, and leaving HOME before confirming is rejected.
- Regression: Forge backend/UI and construction. Old local-UI tests now address
  the immersive host introduced by the preceding HOME presentation change.

Rendered Godot-window checks used an isolated B2 fixture: Skill Grid with three
purchases and five free SP, confirmation, cleared grid with eight SP, repeat disabled,
and outside-HOME refusal. No production cheat or B2 unlock was added. The ordinary
player campaign will expose this capability when the story eventually unlocks B2.
