# Production Battle HUD

## Artwork and layout

All 47 source exports use a 1920 × 1080 canvas. Runtime art is cropped without resizing, recoloring or resampling and placed at its original alpha bounding-box origin at scale 1. Button state families use their union bounding box (7 families), so switching states cannot shift the artwork. Project stretch settings remain unchanged.

See [asset_mapping.md](asset_mapping.md) for every old → new filename and [battle_ui_layout_manifest.json](battle_ui_layout_manifest.json) for positions, sizes and SHA-256 hashes.

```text
Graphics/UI/
  common/top_menu/          20 PNGs
  battle/
    portrait/              10 PNGs
    abilities/              6 PNGs
    turn_order/             6 PNGs
    reinforcements/         1 PNG
    end_turn/               4 PNGs
  _source_full_canvas/      original files, .gdignore
```

The source archive remains local under the existing /Graphics/ Git ignore policy. The 47 exact runtime crops and their import settings are explicitly tracked; unrelated artwork and Photoshop files are excluded. Keep the source archive to rerun `python tools/ui/crop_battle_ui.py` or `python tools/ui/verify_battle_ui.py` (Pillow required). The verifier checks original hashes, exact crop pixels, family dimensions, filenames and absence of runtime references to source exports.

## Scenes and bindings

- `presentation/common/ui/common_top_menu.tscn`: shared TextureButton menu with authored normal/hover/pressed/disabled states. The rushnyk menu is always enabled and has no disabled state.
- `presentation/battle/ui/battle_hud.tscn`: fixed authored layout on BattleUI CanvasLayer. Camera shake and depth zoom affect only the world.
- `presentation/battle/ui/battle_ability_slot.tscn`: six reusable slots, hotkeys 1–6, cost and optional icon.
- `presentation/battle/ui/battle_turn_order_entry.tscn`: optional portrait and friendly/enemy frame; current entry uses the large current frame.
- `presentation/battle/abilities/battle_ability_panel.tscn`: existing public binding/selection contract retained, now implemented with six authored slots and the existing ability description builder.
- `scenes/debug/debug_battle_ability_panel.tscn`: original flexible debug panel retained for the 17-ability loadout. No abilities, effects or gameplay definitions were deleted.

Corresponding scripts implement bindings. BattleScreen and BattleFlowController connect the HUD to existing models. The existing `presentation/battle/actions/battle_ability_presentation_profile.gd` gains an optional `icon`; no duplicate profile class was introduced.

Portraits come from `CombatantDefinition.portrait`; ability icons come from the presentation profile. Missing art stays hidden. HP, stamina, max stamina, guard, statuses and ability locks update through model signals. During enemy turns the last player panel remains visible with actions disabled. Buff/debuff names use their existing polarity; no placeholder status icons were invented. The cooldown badge export is reserved, not used as a new mechanic.

Turn order reads the controller's actual order/index, omits dead actors, and shows nearest 3 past + current + nearest 3 future actors. Larger orders produce one explicit warning per HUD instance; this is a visual capacity limit, not a turn-rule change.

`BattleReinforcementController.get_pending_opposition_rows()` is a read-only query over all candidate coordinates of pending enemy spawns. Multiple candidate rows show flags simultaneously; completed spawns disappear. Flag row offsets follow authored arena slots at environment load and remain stable during camera effects. Reinforcement spawning rules are unchanged.

The common menu reuses CampaignMenuPanel, pauses the battle and closes with Escape. Existing save/load-in-battle restrictions remain and are explained in the menu. Other top-menu destinations retain disabled artwork until supported by navigation. Existing combatant/surface context panels remain; their production positions avoid the top menu, with debug defaults preserved.

## Validation (Godot 4.7 stable)

GREEN: common_top_menu_smoke, battle_hud_smoke, presentation_smoke, production_battle_smoke, production_features_smoke, campaign_production_smoke, repeatable_deep_forest_smoke, battle_time_of_day_smoke, combatant_visual_animation_smoke, tactical_marker_sprite_smoke, marker_surface_smoke, layered_impact_shake_smoke. Also verified campaign default-party animated run, editor import and standalone debug sandbox startup. No parser/runtime errors. The expected 3-entry capacity warning occurs in production_features_smoke's larger encounter.

Manual: Campaign → Дремучий лес → Начать приключение opens the production HUD. Movement passes through decorative UI and updates stamina; End Turn advances the strip and retains the player panel during enemy turns. The rushnyk opens the centered menu, pauses the game and Escape resumes it. HP/SP artwork sits within its frames; six slots, costs and hotkeys are visible. Empty portrait/icon areas reflect currently unassigned artwork. Simultaneous reinforcement rows and removal are verified by the smoke fixture; the normal Deep Forest encounter has no pending wave to display.

Screenshot artifact: `C:/Users/Danil/Documents/Codex/2026-09-15/godot-4-7-debug-battle-sandbox/outputs/battle-hud-deep-forest.png`.
