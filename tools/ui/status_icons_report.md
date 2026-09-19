# Semantic battle statuses and defense stats

## Assets

The user confirmed `повышение брони.png` (gold shield) for Armor Up and confirmed that status PNGs include their intended square frames/backgrounds. Individual Armor and Stamina Regeneration stat icons retain their transparent backgrounds. All production PNG bytes are unchanged; native status assets are 30×30, drawn at 20×20 in the shared component.

Full original → final mapping: [status_asset_mapping.json](status_asset_mapping.json).

```text
Graphics/UI/battle/
  portrait/stats/
    armor_icon.png
    stamina_regen_icon.png
  statuses/
    status_stun.png
    status_immobilized.png
    status_bleeding.png
    status_burning.png
    status_poison.png
    status_armor_down.png
    status_counterattack.png
    status_armor_up.png
    status_reactive_guard.png
    status_reactive_stamina.png
    status_stamina_regen_up.png
```

Deleted the explicitly identified combined sheet `иконки броня и востановление выносливости.png` and its import sidecar. The unselected `броня повышается.png` was preserved locally as `Graphics/UI/_source_full_canvas/status_armor_up_alternate.png` under the existing ignored source archive. No unrelated artwork was deleted. The temporary `Новые` directory and obsolete imports are gone. New runtime PNGs/import settings are tracked explicitly under the existing Graphics ignore policy.

## Semantics and architecture

One resolver (`BattleStatusVisualResolver`) uses stable tags, ordered as follows:

| Tag(s) | Visual |
|---|---|
| stun | Stun |
| immobilized | Immobilized |
| bleeding | Bleeding |
| burning | Burning (future content ready) |
| poison | Poison (future content ready) |
| armor_debuff | Armor Down |
| counterattack | Counterattack |
| armor_buff | Armor Up |
| reaction + guard | Reactive Guard |
| stamina_reaction | Reactive Stamina |
| stamina_regeneration_buff | Stamina Regen Up (future content ready) |

All 42 current status resources were inspected. Composite immobilized + armor_debuff definitions produce two entries. Ties are ordered by status ID; unrelated statuses with identical semantics are never aggregated. No gameplay Burning/Poison statuses were added.

Created reusable `battle_status_icon.gd/.tscn` and `battle_status_visual_resolver.gd` in `presentation/battle/combatants/statuses/`. Refactored existing `BattleStatusStrip` to use that resolver and a shared `render_into` for the HUD HBoxes. Kept `BattleStatusChip` intentionally for unmapped debug statuses. World strips show all polarities; HUD rows filter beneficial/harmful. Neutral HUD statuses retain a small text line. Stack labels appear only above one stack. HUD icons expose tooltips; world icons and their descendants ignore mouse input.

## HUD and world layout

Preserved the user's widened shelf artwork, HP/SP artwork and ability-panel offsets. The PNG shelf is 331 px wide; its inner icon area is 278 px. Updated only the status container right edges to match it: x270–548, with the existing separate row y positions. Twelve 20 px icons plus eleven 3 px gaps occupy 273 px; no cap, +N, scrolling or hidden overflow was introduced.

Existing Guard remains; added sibling Armor and StaminaRegen controls on the same third row. Values read current_guard, get_effective_armor(), and get_effective_stamina_regeneration() respectively. The latter is formatted +N. Existing player-portrait ownership and enemy-turn behavior are preserved.

Moved the editor-editable StatusAnchor immediately above the existing world HP bar, without changing world HP/Stamina/Guard bars. Player and enemy views use the same artwork/resolution as the HUD. Refresh remains signal-driven (status added/updated/removed), without frame polling.

## Stamina regeneration

Appended STAMINA_REGENERATION = 4 to BattleStatModifier.Stat; existing ordinals 0–3 are unchanged. CombatantState now resolves its base/effective regeneration through the existing modifier pipeline. restore_round_stamina uses that effective amount at the same existing cadence. Reactive stamina gain remains independent. Ability/hover stat descriptions recognize the new stat, and hover details show effective regeneration.

## Changed files

- core/battle/stats/battle_stat_modifier.gd
- core/battle/combatants/combatant_state.gd
- presentation/battle/combatants/statuses/battle_status_strip.gd/.tscn
- presentation/battle/combatants/combatant_view.tscn
- presentation/battle/combatants/battle_combatant_hover_panel.gd
- presentation/battle/abilities/battle_ability_presentation_builder.gd
- presentation/battle/ui/battle_hud.gd/.tscn
- User-authored prerequisite layout/art changes: battle_ability_panel.tscn and five portrait shelf/HP/SP PNGs.
- New focused test: tests/battle/semantic_status_hud_smoke.gd.

The earlier selected-button fix and its existing HUD-test edits are kept in the working tree, separate from this status-icon commit.

## Validation

GREEN: semantic_status_hud_smoke, common_top_menu_smoke, battle_hud_smoke, presentation_smoke, production_battle_smoke, production_features_smoke, campaign_production_smoke, repeatable_deep_forest_smoke, combatant_visual_animation_smoke, tactical_marker_sprite_smoke, marker_surface_smoke, layered_impact_shake_smoke. Editor import: no parser errors. The larger production-features encounters emit the existing expected turn-strip capacity warning.

Focused coverage includes all eleven mappings; composite entries; fallback; stack 1/2 and removal/expiry; both HUD polarity rows; player/enemy world strips; Guard; effective Armor Up/Down; effective regeneration and round restoration; unchanged enum values; reactive-vs-normal regen separation; preserved world bars; mouse filters; twelve-icon capacity.

Visual inspection used a real Deep Forest production battle launched from CampaignRuntime with test statuses applied in memory, including composite Immobilized + Armor Down, Armor Up, stacked Bleeding and a regeneration modifier. Verified separate HUD rows, all three stat values, matching world icons above bars and readable stack count. No save files or content status resources were modified by the visual fixture. This was a rendered visual inspection; click behavior is covered by automated input/interaction smoke tests.

Screenshot: `C:/Users/Danil/Documents/Codex/2026-09-15/godot-4-7-debug-battle-sandbox/outputs/status-hud-deep-forest.png`.
