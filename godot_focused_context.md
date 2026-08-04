# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/statuses/battle_status_definition.gd', 'core/battle/statuses/battle_status_instance.gd', 'core/battle/turns/battle_turn_controller.gd', 'core/battle/effects/apply_status_effect.gd', 'core/battle/effects/damage_effect.gd', 'core/battle/effects/effect_resolver.gd', 'core/battle/movement/battle_movement_service.gd', 'core/battle/restrictions/battle_action_restriction.gd', 'core/battle/targeting/ability_targeting_definition.gd', 'content/statuses/debug/debug_immobilized.tres', 'content/abilities/debug/debug_hamstring.tres', 'content/abilities/debug/debug_stunning_blow.tres', 'content/heroes/bayda/bayda_hero.tres', 'content/heroes/bayda/debug_bayda_core_hero.tres']`
- Allow addons: `False`
- Included files planned: `14`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── agents
│   └── AGENTS.md
├── content
│   ├── abilities
│   │   ├── debug
│   │   │   ├── debug_bandage.tres
│   │   │   ├── debug_battle_focus.tres
│   │   │   ├── debug_fire_line.tres
│   │   │   ├── debug_full_cleanse.tres
│   │   │   ├── debug_full_dispel.tres
│   │   │   ├── debug_guaranteed_critical.tres
│   │   │   ├── debug_guard_stance.tres
│   │   │   ├── debug_hamstring.tres
│   │   │   ├── debug_place_fire_surface.tres
│   │   │   ├── debug_raider_chop.tres
│   │   │   ├── debug_rending_cut.tres
│   │   │   ├── debug_sabre_slash.tres
│   │   │   ├── debug_shield_bash.tres
│   │   │   ├── debug_spirit_mend.tres
│   │   │   ├── debug_stunning_blow.tres
│   │   │   ├── debug_swap_positions.tres
│   │   │   ├── debug_sweeping_slash.tres
│   │   │   └── debug_teleport.tres
│   │   └── heroes
│   │       └── bayda
│   │           ├── .gitkeep
│   │           └── bayda_blood_payment.tres
│   ├── campaign
│   │   └── debug
│   │       ├── .gitkeep
│   │       └── debug_campaign_definition.tres
│   ├── combatants
│   │   ├── debug
│   │   │   ├── debug_protected_shaman.tres
│   │   │   ├── debug_steppe_basher.tres
│   │   │   ├── debug_steppe_cleanser.tres
│   │   │   ├── debug_steppe_disabler.tres
│   │   │   ├── debug_steppe_guarder.tres
│   │   │   ├── debug_steppe_healer.tres
│   │   │   ├── debug_steppe_pyromancer.tres
│   │   │   ├── debug_steppe_raider.tres
│   │   │   └── debug_wooden_wall.tres
│   │   ├── heroes
│   │   │   └── bayda
│   │   │       ├── .gitkeep
│   │   │       └── bayda_base_combatant.tres
│   │   └── prototype
│   │       ├── proto_steppe_raider.tres
│   │       └── proto_steppe_shieldbearer.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
│   │       ├── debug_campaign_party_encounter.tres
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   ├── equipment
│   │   └── debug
│   │       ├── .gitkeep
│   │       ├── debug_heavy_berdysh.tres
│   │       ├── debug_heavy_berdysh_instance.tres
│   │       ├── debug_old_sabre.tres
│   │       ├── debug_old_sabre_instance.tres
│   │       ├── debug_steppe_armor.tres
│   │       ├── debug_steppe_armor_instance.tres
│   │       ├── debug_traveler_charm.tres
│   │       └── debug_traveler_charm_instance.tres
│   ├── heroes
│   │   ├── bayda
│   │   │   ├── .gitkeep
│   │   │   ├── bayda_core_module.tres
│   │   │   ├── bayda_hero.tres
│   │   │   └── debug_bayda_core_hero.tres
│   │   ├── debug
│   │   │   ├── .gitkeep
│   │   │   ├── debug_sechevik_hero.tres
│   │   │   ├── debug_sechevik_progression.tres
│   │   │   └── debug_sechevik_progression_purchase_test.tres
│   │   └── placeholders
│   │       ├── .gitkeep
│   │       ├── placeholder_bayda.tres
│   │       ├── placeholder_chugaister_bearer.tres
│   │       ├── placeholder_cossack_schemonk.tres
│   │       ├── placeholder_marsh_hunter.tres
│   │       ├── placeholder_mavka.tres
│   │       ├── placeholder_plastunka.tres
│   │       ├── placeholder_powder_markswoman.tres
│   │       └── placeholder_wolf_shepherd.tres
│   ├── loadouts
│   │   ├── debug
│   │   │   ├── debug_sechevik_loadout.tres
│   │   │   ├── debug_steppe_basher_loadout.tres
│   │   │   ├── debug_steppe_cleanser_loadout.tres
│   │   │   ├── debug_steppe_disabler_loadout.tres
│   │   │   ├── debug_steppe_guarder_loadout.tres
│   │   │   ├── debug_steppe_healer_loadout.tres
│   │   │   ├── debug_steppe_pyromancer_loadout.tres
│   │   │   ├── debug_steppe_raider_loadout.tres
│   │   │   └── debug_sweeping_sechevik_loadout.tres
│   │   └── prototype
│   │       ├── proto_steppe_raider_loadout.tres
│   │       └── proto_steppe_shieldbearer_loadout.tres
│   ├── locations
│   │   └── debug
│   │       ├── .gitkeep
│   │       └── debug_forest_edge_location.tres
│   ├── skill_grids
│   │   └── debug
│   │       ├── .gitkeep
│   │       └── debug_sechevik_skill_grid.tres
│   ├── statuses
│   │   └── debug
│   │       ├── debug_battle_focus.tres
│   │       ├── debug_bleeding.tres
│   │       ├── debug_cracked_defense.tres
│   │       ├── debug_immobilized.tres
│   │       ├── debug_regeneration.tres
│   │       └── debug_stunned.tres
│   └── surfaces
│       └── debug
│           └── debug_fire_surface.tres
├── core
│   ├── battle
│   │   ├── abilities
│   │   │   ├── ability_definition.gd
│   │   │   └── growth
│   │   │       ├── ability_growth_rank_definition.gd
│   │   │       ├── ability_growth_table_definition.gd
│   │   │       └── ability_runtime_resolver.gd
│   │   ├── actions
│   │   │   ├── battle_action_command.gd
│   │   │   ├── battle_action_result.gd
│   │   │   ├── battle_action_service.gd
│   │   │   └── battle_effect_result.gd
│   │   ├── ai
│   │   │   └── utility
│   │   │       ├── battle_ai_plan.gd
│   │   │       ├── battle_ai_plan_evaluator.gd
│   │   │       ├── battle_ai_plan_generator.gd
│   │   │       ├── battle_ai_planning_report.gd
│   │   │       └── battle_ai_score_breakdown.gd
│   │   ├── combatants
│   │   │   ├── combatant_definition.gd
│   │   │   └── combatant_state.gd
│   │   ├── damage
│   │   │   ├── battle_damage_kind.gd
│   │   │   └── damage_calculator.gd
│   │   ├── effects
│   │   │   ├── apply_status_effect.gd
│   │   │   ├── battle_effect.gd
│   │   │   ├── damage_effect.gd
│   │   │   ├── effect_resolver.gd
│   │   │   ├── forced_movement_effect.gd
│   │   │   ├── grant_guard_effect.gd
│   │   │   ├── heal_effect.gd
│   │   │   ├── health_cost_effect.gd
│   │   │   ├── place_surface_effect.gd
│   │   │   ├── remove_status_effect.gd
│   │   │   ├── restore_stamina_effect.gd
│   │   │   ├── swap_positions_effect.gd
│   │   │   └── teleport_effect.gd
│   │   ├── encounters
│   │   │   ├── battle_encounter_definition.gd
│   │   │   ├── battle_reinforcement_wave_definition.gd
│   │   │   ├── battle_surface_spawn_definition.gd
│   │   │   └── combatant_spawn_definition.gd
│   │   ├── grid
│   │   │   ├── battle_grid.gd
│   │   │   └── battle_grid_cell.gd
│   │   ├── loadouts
│   │   │   ├── combatant_loadout_definition.gd
│   │   │   └── combatant_loadout_runtime_resolver.gd
│   │   ├── movement
│   │   │   ├── battle_forced_movement_resolution.gd
│   │   │   ├── battle_forced_movement_service.gd
│   │   │   ├── battle_movement_plan.gd
│   │   │   ├── battle_movement_service.gd
│   │   │   ├── battle_relocation_result.gd
│   │   │   └── battle_relocation_service.gd
│   │   ├── previews
│   │   │   ├── battle_action_preview_result.gd
│   │   │   ├── battle_action_preview_service.gd
│   │   │   ├── battle_preview_combatant_state.gd
│   │   │   ├── battle_preview_grid_state.gd
│   │   │   ├── battle_surface_placement_preview.gd
│   │   │   └── battle_target_preview.gd
│   │   ├── reinforcements
│   │   │   └── battle_reinforcement_controller.gd
│   │   ├── restrictions
│   │   │   └── battle_action_restriction.gd
│   │   ├── session
│   │   │   ├── battle_session.gd
│   │   │   └── battle_session_factory.gd
│   │   ├── sides
│   │   │   └── battle_side_rules.gd
│   │   ├── simulation
│   │   │   ├── battle_action_simulation_request.gd
│   │   │   ├── battle_action_simulation_result.gd
│   │   │   └── battle_action_simulation_service.gd
│   │   ├── stats
│   │   │   └── battle_stat_modifier.gd
│   │   ├── statuses
│   │   │   ├── battle_status_definition.gd
│   │   │   ├── battle_status_instance.gd
│   │   │   ├── battle_status_periodic_processor.gd
│   │   │   ├── battle_status_periodic_trigger.gd
│   │   │   └── battle_status_periodic_trigger_result.gd
│   │   ├── surfaces
│   │   │   ├── battle_surface_effect_controller.gd
│   │   │   ├── battle_surface_effect_definition.gd
│   │   │   ├── battle_surface_effect_instance.gd
│   │   │   └── battle_surface_trigger_result.gd
│   │   ├── targeting
│   │   │   ├── ability_targeting_definition.gd
│   │   │   ├── battle_targeting_result.gd
│   │   │   └── battle_targeting_service.gd
│   │   └── turns
│   │       └── battle_turn_controller.gd
│   ├── campaign
│   │   ├── battle
│   │   │   ├── .gitkeep
│   │   │   ├── campaign_battle_request.gd
│   │   │   └── campaign_battle_result.gd
│   │   ├── campaign_definition.gd
│   │   ├── equipment
│   │   │   ├── .gitkeep
│   │   │   ├── campaign_equipment_change_result.gd
│   │   │   └── campaign_equipment_service.gd
│   │   ├── heroes
│   │   │   ├── .gitkeep
│   │   │   └── campaign_hero_state.gd
│   │   ├── inventory
│   │   │   ├── .gitkeep
│   │   │   └── campaign_inventory_state.gd
│   │   ├── locations
│   │   │   ├── .gitkeep
│   │   │   └── campaign_location_definition.gd
│   │   ├── party
│   │   │   ├── .gitkeep
│   │   │   ├── campaign_party_change_result.gd
│   │   │   └── campaign_party_service.gd
│   │   ├── runtime
│   │   │   ├── .gitkeep
│   │   │   └── campaign_runtime.gd
│   │   └── state
│   │       ├── .gitkeep
│   │       ├── campaign_state.gd
│   │       └── campaign_state_factory.gd
│   └── heroes
│       ├── builds
│       │   ├── .gitkeep
│       │   ├── hero_battle_build.gd
│       │   ├── hero_battle_build_resolver.gd
│       │   └── hero_build_stat_bonuses.gd
│       ├── core
│       │   ├── .gitkeep
│       │   ├── bayda
│       │   │   ├── .gitkeep
│       │   │   ├── bayda_core_module_definition.gd
│       │   │   └── bayda_core_runtime_state.gd
│       │   ├── hero_core_module_definition.gd
│       │   └── hero_core_runtime_state.gd
│       ├── equipment
│       │   ├── hero_equipment_change_result.gd
│       │   ├── hero_equipment_item_definition.gd
│       │   ├── hero_equipment_item_instance.gd
│       │   ├── hero_equipment_resolution.gd
│       │   ├── hero_equipment_resolver.gd
│       │   ├── hero_equipment_service.gd
│       │   └── hero_equipment_state.gd
│       ├── hero_definition.gd
│       ├── hero_progression_state.gd
│       ├── loadouts
│       │   ├── hero_personal_loadout_change_result.gd
│       │   └── hero_personal_loadout_service.gd
│       └── skill_grid
│           ├── .gitkeep
│           ├── skill_grid_definition.gd
│           ├── skill_grid_node_definition.gd
│           ├── skill_grid_purchase_result.gd
│           ├── skill_grid_purchase_service.gd
│           ├── skill_grid_resolution.gd
│           └── skill_grid_resolver.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   ├── battle
│   │   ├── abilities
│   │   │   ├── battle_ability_panel.gd
│   │   │   ├── battle_ability_panel.tscn
│   │   │   └── battle_ability_presentation_builder.gd
│   │   ├── actions
│   │   │   ├── battle_ability_presentation_profile.gd
│   │   │   ├── battle_action_outcome.gd
│   │   │   └── battle_action_runner.gd
│   │   ├── ai
│   │   │   ├── battle_ai_planning_debug_formatter.gd
│   │   │   ├── battle_utility_ai_turn_outcome.gd
│   │   │   └── battle_utility_ai_turn_runner.gd
│   │   ├── combatants
│   │   │   ├── battle_combatant_hover_panel.gd
│   │   │   ├── battle_combatant_hover_panel.tscn
│   │   │   ├── battle_combatant_presenter.gd
│   │   │   ├── combatant_view.gd
│   │   │   ├── combatant_view.tscn
│   │   │   ├── combatant_visual.gd
│   │   │   ├── placeholder_combatant_visual.tscn
│   │   │   └── statuses
│   │   │       ├── battle_status_chip.gd
│   │   │       ├── battle_status_chip.tscn
│   │   │       ├── battle_status_strip.gd
│   │   │       └── battle_status_strip.tscn
│   │   ├── grid
│   │   │   ├── battle_grid_overlay_presenter.gd
│   │   │   ├── battle_grid_view.gd
│   │   │   └── battle_grid_view.tscn
│   │   ├── movement
│   │   │   ├── battle_movement_outcome.gd
│   │   │   └── battle_movement_runner.gd
│   │   ├── previews
│   │   │   ├── battle_action_preview_badge.gd
│   │   │   ├── battle_action_preview_badge.tscn
│   │   │   ├── battle_action_preview_formatter.gd
│   │   │   └── battle_action_preview_presenter.gd
│   │   └── surfaces
│   │       ├── battle_surface_hover_panel.gd
│   │       └── battle_surface_hover_panel.tscn
│   ├── campaign
│   │   ├── hero_preparation
│   │   │   ├── .gitkeep
│   │   │   ├── hero_build_summary_panel.gd
│   │   │   ├── hero_equipment_panel.gd
│   │   │   ├── hero_loadout_panel.gd
│   │   │   ├── hero_preparation_panel.gd
│   │   │   ├── hero_preparation_panel.tscn
│   │   │   └── hero_skill_grid_panel.gd
│   │   └── party
│   │       ├── .gitkeep
│   │       └── campaign_party_panel.gd
│   └── common
│       └── controls
│           └── collapsible_panel_controller.gd
├── project.godot
└── scenes
    ├── campaign
    │   ├── .gitkeep
    │   ├── campaign_sandbox.gd
    │   └── campaign_sandbox.tscn
    ├── debug
    │   ├── battle_grid_sandbox.gd
    │   ├── battle_grid_sandbox.tscn
    │   ├── bayda_core_debug_sandbox.gd
    │   ├── bayda_core_debug_sandbox.tscn
    │   ├── controllers
    │   │   └── battle_sandbox_interaction_controller.gd
    │   ├── presentation
    │   │   └── battle_debug_log_presenter.gd
    │   ├── skill_grid_debug_sandbox.gd
    │   └── skill_grid_debug_sandbox.tscn
    └── debug_sechevik.tres
```

---

## 📌 INCLUDED FILES

## FILE: `content/abilities/debug/debug_hamstring.tres`
```text
[gd_resource type="Resource" script_class="AbilityDefinition" format=3 uid="uid://h4ya3an67co3"]

[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="1_ability"]
[ext_resource type="Script" uid="uid://36m0bduhwx85" path="res://core/battle/targeting/ability_targeting_definition.gd" id="2_targeting"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="3_effect"]
[ext_resource type="Script" uid="uid://djty1vj4ucxrn" path="res://core/battle/effects/damage_effect.gd" id="4_damage"]
[ext_resource type="Script" uid="uid://bnwv71blsmx3l" path="res://core/battle/effects/apply_status_effect.gd" id="5_apply_status"]
[ext_resource type="Resource" uid="uid://bi6tr2n7c1623" path="res://content/statuses/debug/debug_immobilized.tres" id="6_immobilized"]

[sub_resource type="Resource" id="Resource_hamstring_damage"]
script = ExtResource("4_damage")
base_damage = 2
strength_scaling = 0.4
effect_id = &"effect_hamstring_damage"

[sub_resource type="Resource" id="Resource_hamstring_status"]
script = ExtResource("5_apply_status")
status_definition = ExtResource("6_immobilized")
effect_id = &"effect_hamstring_status"

[sub_resource type="Resource" id="Resource_hamstring_targeting"]
script = ExtResource("2_targeting")
aim_offsets = Array[Vector2i]([Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)])

[resource]
script = ExtResource("1_ability")
ability_id = &"ability_hamstring"
display_name = "Подсечка"
description = "Наносит урон и запрещает цели двигаться в течение двух её ходов."
stamina_cost = 3
targeting = SubResource("Resource_hamstring_targeting")
effects = Array[ExtResource("3_effect")]([SubResource("Resource_hamstring_damage"), SubResource("Resource_hamstring_status")])
```

---

## FILE: `content/abilities/debug/debug_stunning_blow.tres`
```text
[gd_resource type="Resource" script_class="AbilityDefinition" format=3 uid="uid://caxifmduofpsb"]

[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="1_ability"]
[ext_resource type="Script" uid="uid://36m0bduhwx85" path="res://core/battle/targeting/ability_targeting_definition.gd" id="2_targeting"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="3_effect"]
[ext_resource type="Script" uid="uid://djty1vj4ucxrn" path="res://core/battle/effects/damage_effect.gd" id="4_damage"]
[ext_resource type="Script" uid="uid://bnwv71blsmx3l" path="res://core/battle/effects/apply_status_effect.gd" id="5_apply_status"]
[ext_resource type="Resource" uid="uid://b56wvs8w1o26c" path="res://content/statuses/debug/debug_stunned.tres" id="6_stunned"]

[sub_resource type="Resource" id="Resource_stunning_damage"]
script = ExtResource("4_damage")
strength_scaling = 0.25
effect_id = &"effect_stunning_blow_damage"

[sub_resource type="Resource" id="Resource_stunning_status"]
script = ExtResource("5_apply_status")
status_definition = ExtResource("6_stunned")
effect_id = &"effect_stunning_blow_status"

[sub_resource type="Resource" id="Resource_stunning_targeting"]
script = ExtResource("2_targeting")
aim_offsets = Array[Vector2i]([Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)])

[resource]
script = ExtResource("1_ability")
ability_id = &"ability_stunning_blow"
display_name = "Оглушающий удар"
description = "Наносит небольшой урон и заставляет цель пропустить следующий ход."
stamina_cost = 5
initial_lock_turns = 1
cooldown_turns = 2
targeting = SubResource("Resource_stunning_targeting")
effects = Array[ExtResource("3_effect")]([SubResource("Resource_stunning_damage"), SubResource("Resource_stunning_status")])
```

---

## FILE: `content/heroes/bayda/bayda_hero.tres`
```text
[gd_resource type="Resource" script_class="HeroDefinition" format=3]

[ext_resource type="Script" path="res://core/heroes/hero_definition.gd" id="1_hero"]
[ext_resource type="Script" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" path="res://content/combatants/heroes/bayda/bayda_base_combatant.tres" id="3_combatant"]
[ext_resource type="Resource" path="res://content/heroes/bayda/bayda_core_module.tres" id="4_core"]
[ext_resource type="Resource" path="res://content/skill_grids/debug/debug_sechevik_skill_grid.tres" id="5_grid"]
[ext_resource type="Resource" path="res://content/abilities/debug/debug_sabre_slash.tres" id="6_sabre"]
[ext_resource type="Resource" path="res://content/abilities/debug/debug_spirit_mend.tres" id="7_mend"]
[ext_resource type="Resource" path="res://content/abilities/heroes/bayda/bayda_blood_payment.tres" id="8_blood_payment"]

[resource]
script = ExtResource("1_hero")
hero_id = &"hero_bayda"
display_name = "Байда-характерник"
description = "Первый настоящий герой. Core Module реализован, способности и Skill Grid пока используют временный debug-контент."
base_combatant_definition = ExtResource("3_combatant")
core_module = ExtResource("4_core")
skill_grid = ExtResource("5_grid")
personal_abilities = Array[ExtResource("2_ability")]([ExtResource("6_sabre"), ExtResource("8_blood_payment"), ExtResource("7_mend")])
starting_known_ability_ids = Array[StringName]([&"ability_sabre_slash", &"ability_bayda_blood_payment"])
default_ability_id = &"ability_sabre_slash"
starting_active_slot_count = 2
maximum_active_slot_count = 6
```

---

## FILE: `content/heroes/bayda/debug_bayda_core_hero.tres`
```text
[gd_resource type="Resource" script_class="HeroDefinition" format=3]

[ext_resource type="Script" path="res://core/heroes/hero_definition.gd" id="1_hero"]
[ext_resource type="Script" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" path="res://content/combatants/heroes/bayda/bayda_base_combatant.tres" id="3_combatant"]
[ext_resource type="Resource" path="res://content/heroes/bayda/bayda_core_module.tres" id="4_core"]
[ext_resource type="Resource" path="res://content/skill_grids/debug/debug_sechevik_skill_grid.tres" id="5_grid"]
[ext_resource type="Resource" path="res://content/abilities/debug/debug_sabre_slash.tres" id="6_sabre"]
[ext_resource type="Resource" path="res://content/abilities/debug/debug_spirit_mend.tres" id="7_mend"]
[ext_resource type="Resource" path="res://content/abilities/heroes/bayda/bayda_blood_payment.tres" id="8_blood_payment"]

[resource]
script = ExtResource("1_hero")
hero_id = &"hero_debug_bayda_core"
display_name = "Байда-характерник"
description = "Временная версия Байды для проверки Hero Core."
base_combatant_definition = ExtResource("3_combatant")
core_module = ExtResource("4_core")
skill_grid = ExtResource("5_grid")
personal_abilities = Array[ExtResource("2_ability")]([ExtResource("6_sabre"), ExtResource("8_blood_payment"), ExtResource("7_mend")])
starting_known_ability_ids = Array[StringName]([&"ability_sabre_slash", &"ability_bayda_blood_payment"])
default_ability_id = &"ability_sabre_slash"
starting_active_slot_count = 2
maximum_active_slot_count = 6
```

---

## FILE: `content/statuses/debug/debug_immobilized.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" format=3 uid="uid://bi6tr2n7c1623"]

[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://bg2aiwnxjuvig" path="res://core/battle/statuses/battle_status_periodic_trigger.gd" id="2_joij2"]
[ext_resource type="Script" uid="uid://b06rnp4fjl0um" path="res://core/battle/restrictions/battle_action_restriction.gd" id="2_restriction"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="4_idydg"]

[sub_resource type="Resource" id="Resource_immobilized_restriction"]
script = ExtResource("2_restriction")
block_movement = true

[resource]
script = ExtResource("1_status")
status_id = &"debug_immobilized"
display_name = "Обездвиживание"
description = "Боец не может двигаться, но сохраняет возможность атаковать."
polarity = 2
tags = Array[StringName]([&"debuff", &"control", &"movement_control", &"immobilized"])
duration_turns = 2
action_restriction = SubResource("Resource_immobilized_restriction")
```

---

## FILE: `core/battle/effects/apply_status_effect.gd`
```gdscript
@tool
class_name ApplyStatusEffect
extends BattleEffect


@export_group("Status")

@export
var status_definition: BattleStatusDefinition


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if status_definition == null:
		errors.append(
			"Status definition is not assigned."
		)

		return errors

	for status_error in (
		status_definition.get_validation_errors()
	):
		errors.append(
			"Status: %s"
			% status_error
		)

	return errors
```

---

## FILE: `core/battle/effects/damage_effect.gd`
```gdscript
@tool
class_name DamageEffect
extends BattleEffect
enum CritMode {
	DISABLED,
	STANDARD,
	GUARANTEED,
}


@export_group("Damage")

@export_range(0, 9999, 1)
var base_damage: int = 1

## Устаревшее поле для совместимости со старым debug-контентом.
## Новые способности масштабируются только через
## Skill Growth Table.
@export_range(0.0, 20.0, 0.05)
var strength_scaling: float = 0.0

@export_range(0, 999, 1)
var armor_piercing: int = 0

@export_range(0, 999, 1)
var minimum_damage: int = 1

@export_group("Critical Hit")

## Может ли этот конкретный эффект наносить критический урон.
@export
var crit_mode: CritMode = CritMode.STANDARD

## Дополнительный шанс крита конкретного эффекта.
## При стандартном крите входит в общий лимит 35%.
@export_range(-100, 100, 1)
var crit_chance_bonus_percent: int = 0

## Множитель сырого урона при критическом попадании.
@export_range(1.0, 10.0, 0.05)
var critical_multiplier: float = 1.5

func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if base_damage < 0:
		errors.append("Base damage cannot be negative.")

	if strength_scaling < 0.0:
		errors.append("Strength scaling cannot be negative.")

	if armor_piercing < 0:
		errors.append("Armor piercing cannot be negative.")

	if minimum_damage < 0:
		errors.append("Minimum damage cannot be negative.")

	if critical_multiplier < 1.0:
		errors.append(
			"Critical multiplier cannot be lower than 1.0."
		)

	return errors
```

---

## FILE: `core/battle/effects/effect_resolver.gd`
```gdscript
class_name EffectResolver
extends RefCounted
enum StandardCriticalMode {
	RANDOM,
	NEVER,
	ALWAYS,
}

const FAILURE_INVALID_EFFECT: StringName = &"invalid_effect"
const FAILURE_INVALID_SOURCE: StringName = &"invalid_source"
const FAILURE_INVALID_TARGET: StringName = &"invalid_target"
const FAILURE_HEALTH_COST_CANNOT_BE_PAID: StringName = (
	&"health_cost_cannot_be_paid"
)
const FAILURE_UNSUPPORTED_EFFECT: StringName = &"unsupported_effect"
const FAILURE_SURFACE_PLACEMENT_FAILED: StringName = (
	&"surface_placement_failed"
)

const FAILURE_INVALID_STATUS_DEFINITION: StringName = (
	&"invalid_status_definition"
)

const FAILURE_STATUS_APPLICATION_FAILED: StringName = (
	&"status_application_failed"
)


var damage_calculator := DamageCalculator.new()

var forced_movement_service := (
	BattleForcedMovementService.new()
)

var relocation_service := (
	BattleRelocationService.new()
)

var random_number_generator: RandomNumberGenerator


func _init(
	p_random_number_generator: RandomNumberGenerator = null
) -> void:
	if p_random_number_generator != null:
		random_number_generator = (
			p_random_number_generator
		)

		return

	random_number_generator = (
		RandomNumberGenerator.new()
	)

	random_number_generator.randomize()

func can_resolve(
	effect: BattleEffect
) -> bool:
	return (
		effect is DamageEffect
		or effect is HealEffect
		or effect is GrantGuardEffect
		or effect is HealthCostEffect
		or effect is RestoreStaminaEffect
		or effect is ApplyStatusEffect
		or effect is RemoveStatusEffect
		or effect is ForcedMovementEffect
		or effect is PlaceSurfaceEffect
		or effect is SwapPositionsEffect
		or effect is TeleportEffect
	)


func get_effect_recipient(
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState
) -> CombatantState:
	if effect == null:
		return null

	if effect.targets_source():
		return source

	return target


func requires_combatant_target(
	effect: BattleEffect
) -> bool:
	if effect == null:
		return false

	if effect.targets_source():
		return false

	return (
		not effect is PlaceSurfaceEffect
		and not effect is TeleportEffect
	)


func get_runtime_validation_failure(
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState
) -> StringName:
	if effect == null:
		return FAILURE_INVALID_EFFECT

	if source == null:
		return FAILURE_INVALID_SOURCE

	var recipient := get_effect_recipient(
		effect,
		source,
		target
	)

	if recipient == null:
		return FAILURE_INVALID_TARGET

	if effect is HealthCostEffect:
		var health_cost_effect := (
			effect as HealthCostEffect
		)

		if not recipient.can_pay_health_cost(
			health_cost_effect.health_cost,
			health_cost_effect
				.minimum_remaining_health
		):
			return (
				FAILURE_HEALTH_COST_CANNOT_BE_PAID
			)

	return &""

func resolve(
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession = null,
	bypass_guard: bool = false,
	allow_critical: bool = true,
	target_coordinate: Vector2i = BattleGrid.INVALID_COORDINATE,
	standard_critical_mode: int = StandardCriticalMode.RANDOM,
	damage_kind: StringName = BattleDamageKind.DIRECT
) -> BattleEffectResult:
	if effect == null:
		return _create_failure_result(
			FAILURE_INVALID_EFFECT,
			effect,
			source,
			target
		)

	if source == null:
		return _create_failure_result(
			FAILURE_INVALID_SOURCE,
			effect,
			source,
			target
		)

	if effect is PlaceSurfaceEffect:
		return _resolve_place_surface(
			effect as PlaceSurfaceEffect,
			source,
			target,
			session,
			target_coordinate
		)

	if effect is TeleportEffect:
		return _resolve_teleport(
			effect as TeleportEffect,
			source,
			session,
			target_coordinate
		)

	var resolved_target := get_effect_recipient(
		effect,
		source,
		target
	)

	if resolved_target == null:
		return _create_failure_result(
			FAILURE_INVALID_TARGET,
			effect,
			source,
			resolved_target
		)

	var runtime_failure := (
		get_runtime_validation_failure(
			effect,
			source,
			target
		)
	)

	if runtime_failure != &"":
		return _create_failure_result(
			runtime_failure,
			effect,
			source,
			resolved_target
		)

	if effect is SwapPositionsEffect:
		return _resolve_swap_positions(
			effect as SwapPositionsEffect,
			source,
			resolved_target,
			session
		)

	if effect is HealthCostEffect:
		return _resolve_health_cost(
			effect as HealthCostEffect,
			source,
			resolved_target
		)

	if effect is RestoreStaminaEffect:
		return _resolve_restore_stamina(
			effect as RestoreStaminaEffect,
			source,
			resolved_target
		)

	if effect is DamageEffect:
		return _resolve_damage(
			effect as DamageEffect,
			source,
			resolved_target,
			bypass_guard,
			allow_critical,
			standard_critical_mode,
			damage_kind
		)

	if effect is HealEffect:
		return _resolve_heal(
			effect as HealEffect,
			source,
			resolved_target
		)

	if effect is GrantGuardEffect:
		return _resolve_grant_guard(
			effect as GrantGuardEffect,
			source,
			resolved_target
		)

	if effect is ApplyStatusEffect:
		return _resolve_apply_status(
			effect as ApplyStatusEffect,
			source,
			resolved_target
		)

	if effect is RemoveStatusEffect:
		return _resolve_remove_status(
			effect as RemoveStatusEffect,
			source,
			resolved_target
		)

	if effect is ForcedMovementEffect:
		return _resolve_forced_movement(
			effect as ForcedMovementEffect,
			source,
			resolved_target,
			session
		)

	return _create_failure_result(
		FAILURE_UNSUPPORTED_EFFECT,
		effect,
		source,
		resolved_target
	)

func _resolve_health_cost(
	effect: HealthCostEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"health_cost"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = effect.health_cost
	result.resolved_amount = effect.health_cost

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = (
		target.pay_health_cost(
			effect.health_cost,
			effect.minimum_remaining_health
		)
	)

	result.current_value = (
		target.current_health
	)

	if result.applied_amount != effect.health_cost:
		result.failure_code = (
			FAILURE_HEALTH_COST_CANNOT_BE_PAID
		)

		return result

	result.is_successful = true
	return result


func _resolve_restore_stamina(
	effect: RestoreStaminaEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"restore_stamina"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = effect.stamina_amount
	result.resolved_amount = effect.stamina_amount

	result.previous_stamina = (
		target.current_stamina
	)

	result.previous_value = (
		target.current_stamina
	)

	result.previous_stamina_restoration_debt = (
		target.get_stamina_restoration_debt()
	)

	result.applied_amount = (
		target.restore_stamina(
			effect.stamina_amount,
			&"ability_effect"
		)
	)

	result.current_stamina = (
		target.current_stamina
	)

	result.current_value = (
		target.current_stamina
	)

	result.current_stamina_restoration_debt = (
		target.get_stamina_restoration_debt()
	)

	result.stamina_restoration_debt_paid_amount = maxi(
		0,
		result.previous_stamina_restoration_debt
			- result
				.current_stamina_restoration_debt
	)

	result.is_successful = true
	return result
	
func _resolve_swap_positions(
	effect: SwapPositionsEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"swap_positions"

	result.source_id = source.instance_id
	result.target_id = target.instance_id
	result.secondary_target_id = target.instance_id
	result.relocation_kind = &"swap"

	var relocation_result := relocation_service.swap(
		session,
		source,
		target,
		true,
		false,
		0
	)

	if not relocation_result.is_successful:
		result.failure_code = (
			relocation_result.failure_code
		)

		return result

	result.movement_origin = (
		relocation_result.primary_origin
	)

	result.movement_destination = (
		relocation_result.primary_destination
	)

	result.secondary_movement_origin = (
		relocation_result.secondary_origin
	)

	result.secondary_movement_destination = (
		relocation_result.secondary_destination
	)

	if not source.is_alive:
		result.relocation_defeated_ids.append(
			source.instance_id
		)

	if not target.is_alive:
		result.relocation_defeated_ids.append(
			target.instance_id
		)

	result.target_died = not target.is_alive
	result.applied_amount = 1
	result.is_successful = true

	return result


func _resolve_teleport(
	effect: TeleportEffect,
	source: CombatantState,
	session: BattleSession,
	target_coordinate: Vector2i
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"teleport"

	result.source_id = source.instance_id
	result.target_id = source.instance_id
	result.relocation_kind = &"teleport"

	var relocation_result := relocation_service.teleport(
		session,
		source,
		target_coordinate,
		0
	)

	if not relocation_result.is_successful:
		result.failure_code = (
			relocation_result.failure_code
		)

		return result

	result.movement_origin = (
		relocation_result.primary_origin
	)

	result.movement_destination = (
		relocation_result.primary_destination
	)

	if not source.is_alive:
		result.relocation_defeated_ids.append(
			source.instance_id
		)

	result.target_died = not source.is_alive
	result.applied_amount = 1
	result.is_successful = true

	return result

func _resolve_place_surface(
	effect: PlaceSurfaceEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession,
	target_coordinate: Vector2i
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"place_surface"

	result.source_id = source.instance_id
	result.effect_coordinate = target_coordinate

	if target != null:
		result.target_id = target.instance_id

	if (
		session == null
		or session.surface_effect_controller == null
	):
		result.failure_code = (
			BattleSurfaceEffectController
				.FAILURE_INVALID_SESSION
		)

		return result

	var definition := effect.surface_definition

	if definition != null:
		result.surface_effect_id = (
			definition.surface_effect_id
		)

		result.surface_display_name = (
			definition.display_name
		)

	var surface_controller := (
		session.surface_effect_controller
	)

	var placement_failure := (
		surface_controller.get_placement_failure(
			session,
			target_coordinate,
			definition
		)
	)

	if placement_failure != &"":
		result.failure_code = placement_failure
		return result

	var existing_instance := (
		surface_controller.get_effect_at(
			target_coordinate,
			definition.surface_effect_id
		)
	)

	if existing_instance != null:
		result.previous_surface_remaining_rounds = (
			existing_instance.remaining_rounds
		)

	var placed_instance := (
		surface_controller.place_effect(
			session,
			target_coordinate,
			definition,
			source.instance_id,
			source.team_id
		)
	)

	if placed_instance == null:
		result.failure_code = (
			FAILURE_SURFACE_PLACEMENT_FAILED
		)

		return result

	result.surface_was_added = (
		existing_instance == null
	)

	result.surface_was_updated = (
		existing_instance != null
	)

	result.surface_is_permanent = (
		placed_instance.is_permanent
	)

	result.current_surface_remaining_rounds = (
		placed_instance.remaining_rounds
	)

	result.applied_amount = 1
	result.is_successful = true

	return result

	
func _resolve_damage(
	effect: DamageEffect,
	source: CombatantState,
	target: CombatantState,
	bypass_guard: bool,
	allow_critical: bool,
	standard_critical_mode: int,
	damage_kind: StringName
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"damage"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.target_base_armor = (
		target.armor
	)

	result.target_status_armor_modifier = (
		target.get_stat_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	result.target_modified_armor = (
		target.get_effective_armor()
	)

	result.armor_piercing = (
		effect.armor_piercing
	)

	result.effective_armor = (
		damage_calculator.calculate_effective_armor(
			target,
			effect
		)
	)

	result.raw_amount_before_critical = (
		damage_calculator.calculate_raw_damage(
			source,
			effect
		)
	)

	result.critical_was_enabled = (
		allow_critical
		and effect.crit_mode
			!= DamageEffect.CritMode.DISABLED
	)

	result.critical_multiplier = (
		effect.critical_multiplier
	)

	result.critical_chance_percent = (
		damage_calculator
		.calculate_critical_chance_percent(
			source,
			effect,
			allow_critical
		)
	)

	if result.critical_was_enabled:
		match effect.crit_mode:
			DamageEffect.CritMode.GUARANTEED:
				result.critical_was_guaranteed = true
				result.was_critical = true

			DamageEffect.CritMode.STANDARD:
				if (
					result
						.critical_chance_percent
					> 0
				):
					match standard_critical_mode:
						StandardCriticalMode.NEVER:
							pass

						StandardCriticalMode.ALWAYS:
							result.was_critical = true

						_:
							result.critical_roll_percent = (
								random_number_generator
									.randi_range(
										1,
										100
									)
							)

							result.was_critical = (
								result
									.critical_roll_percent
								<= result
									.critical_chance_percent
							)

	result.raw_amount = (
		result.raw_amount_before_critical
	)

	if result.was_critical:
		result.raw_amount = (
			damage_calculator
			.apply_critical_multiplier(
				result
					.raw_amount_before_critical,
				result.critical_multiplier
			)
		)

	result.resolved_amount = (
		damage_calculator
		.calculate_resolved_damage_from_raw(
			target,
			effect,
			result.raw_amount
		)
	)

	result.mitigated_amount = maxi(
		0,
		result.raw_amount
		- result.resolved_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.guard_was_bypassed = (
		bypass_guard
	)

	result.previous_value = (
		target.current_health
	)

	result.previous_stamina = (
		target.current_stamina
	)

	result.previous_stamina_restoration_debt = (
		target.get_stamina_restoration_debt()
	)

	result.applied_amount = (
		target.apply_resolved_damage(
			result.resolved_amount,
			bypass_guard,
			damage_kind
		)
	)

	result.current_stamina = (
		target.current_stamina
	)

	result.current_stamina_restoration_debt = (
		target.get_stamina_restoration_debt()
	)

	result.stamina_drained_amount = maxi(
		0,
		result.previous_stamina
		- result.current_stamina
	)

	result.stamina_restoration_debt_added_amount = maxi(
		0,
		result.current_stamina_restoration_debt
		- result.previous_stamina_restoration_debt
	)

	if (
		damage_kind == BattleDamageKind.PERIODIC
		and result.applied_amount == 0
	):
		result.redirected_damage_amount = mini(
			result.resolved_amount,
			result.stamina_drained_amount
			+ result
				.stamina_restoration_debt_added_amount
		)

		result.damage_was_redirected_from_health = (
			result.redirected_damage_amount > 0
		)

	result.current_guard = (
		target.current_guard
	)

	if bypass_guard:
		result.guard_absorbed_amount = 0

	else:
		result.guard_absorbed_amount = maxi(
			0,
			result.previous_guard
			- result.current_guard
		)

	result.current_value = (
		target.current_health
	)

	result.target_died = (
		result.previous_value > 0
		and result.current_value == 0
	)

	result.is_successful = true

	return result


func _resolve_heal(
	effect: HealEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"heal"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.base_healing
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = target.heal(
		result.resolved_amount
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true

	return result
	
func _resolve_grant_guard(
	effect: GrantGuardEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"grant_guard"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.guard_amount
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.previous_value = (
		target.current_guard
	)

	result.applied_amount = target.grant_guard(
		result.resolved_amount
	)

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_guard
	)

	result.is_successful = true

	return result
	
func _resolve_apply_status(
	effect: ApplyStatusEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"apply_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	if (
		effect.status_definition == null
		or not effect
		.status_definition
		.is_valid_definition()
	):
		result.failure_code = (
			FAILURE_INVALID_STATUS_DEFINITION
		)

		return result

	var status_definition := (
		effect.status_definition
	)

	result.status_id = (
		status_definition.status_id
	)

	result.status_display_name = (
		status_definition.display_name
	)

	result.status_polarity = (
		status_definition.polarity
	)

	if target.definition != null:
		if target.definition.has_status_id_immunity(
			status_definition.status_id
		):
			result.status_application_blocked_by_immunity = true
			result.status_immunity_kind = &"status_id"
			result.status_immunity_value = (
				status_definition.status_id
			)

			result.is_successful = true
			return result

		var matching_immunity_tag := (
			target.definition
			.get_matching_status_immunity_tag(
				status_definition
			)
		)

		if matching_immunity_tag != &"":
			result.status_application_blocked_by_immunity = true
			result.status_immunity_kind = &"tag"
			result.status_immunity_value = (
				matching_immunity_tag
			)

			result.is_successful = true
			return result

	var existing_status := target.get_status(
		status_definition.status_id
	)

	result.status_was_added = (
		existing_status == null
	)

	if existing_status != null:
		result.previous_status_stack_count = (
			existing_status.stack_count
		)

		result.previous_status_remaining_turns = (
			existing_status.remaining_turns
		)

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	var applied_status := target.add_status(
		status_definition,
		source.instance_id
	)

	if applied_status == null:
		result.failure_code = (
			FAILURE_STATUS_APPLICATION_FAILED
		)

		return result

	result.current_status_stack_count = (
		applied_status.stack_count
	)

	result.current_status_remaining_turns = (
		applied_status.remaining_turns
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true

	return result
	

func _resolve_remove_status(
	effect: RemoveStatusEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"remove_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	var removed_statuses := (
		target.remove_statuses_matching(
			effect,
			&"removed_by_effect"
		)
	)

	for removed_status in removed_statuses:
		if (
			removed_status == null
			or removed_status.definition == null
		):
			continue

		result.removed_status_ids.append(
			removed_status.status_id
		)

		result.removed_status_display_names.append(
			removed_status.definition.display_name
		)

		result.removed_status_polarities.append(
			removed_status.definition.polarity
		)
	result.applied_amount = (
		result.removed_status_ids.size()
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true
	return result

func _resolve_forced_movement(
	effect: ForcedMovementEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"forced_movement"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.requested_movement_distance = (
		effect.distance
	)

	result.movement_origin = (
		target.grid_position
	)

	if session == null or session.grid == null:
		result.failure_code = (
			&"invalid_session"
		)

		return result

	var resolution := (
		forced_movement_service
		.create_resolution(
			session.grid,
			source,
			target,
			effect
		)
	)

	if not resolution.is_valid:
		result.failure_code = (
			resolution.failure_code
		)

		return result

	var surface_trigger_results: Array[BattleSurfaceTriggerResult] = []

	var surface_step_callback := Callable(
		self,
		"_on_forced_movement_surface_step"
	).bind(
		session,
		surface_trigger_results
	)

	var committed := (
		forced_movement_service
		.commit_resolution(
			session.grid,
			target,
			resolution,
			surface_step_callback
		)
	)

	if not committed:
		result.failure_code = (
			&"forced_movement_commit_failed"
		)

		return result

	## Копируем данные после commit, потому что опасная
	## клетка могла обрезать исходный путь.
	result.movement_origin = (
		resolution.origin
	)

	result.movement_destination = (
		resolution.destination
	)

	result.movement_direction = (
		resolution.direction
	)

	result.movement_path = (
		resolution.path.duplicate()
	)

	result.applied_movement_distance = (
		resolution.get_applied_distance()
	)

	result.movement_was_blocked = (
		resolution.was_blocked
	)

	result.movement_block_reason = (
		resolution.block_reason
	)

	result.target_died = (
		not target.is_alive
	)

	result.surface_trigger_results = (
		surface_trigger_results.duplicate()
	)

	result.is_successful = true
	return result

func _on_forced_movement_surface_step(
	target: CombatantState,
	_coordinate: Vector2i,
	session: BattleSession,
	surface_trigger_results: Array[BattleSurfaceTriggerResult]
) -> bool:
	if (
		session == null
		or target == null
		or not target.is_alive
	):
		return false

	if session.surface_effect_controller == null:
		return true

	var trigger_results := (
		session
		.surface_effect_controller
		.trigger_for_combatant(
			session,
			target,
			BattleSurfaceEffectDefinition
				.TriggerTiming
				.ON_ENTER
		)
	)

	for trigger_result in trigger_results:
		if trigger_result != null:
			surface_trigger_results.append(
				trigger_result
			)

	if not target.is_alive:
		return false

	for trigger_result in trigger_results:
		if (
			trigger_result != null
			and trigger_result.stops_movement
		):
			return false

	return true

func _create_failure_result(
	failure_code: StringName,
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.failure_code = failure_code

	if effect != null:
		result.effect_id = effect.effect_id

	if source != null:
		result.source_id = source.instance_id

	if target != null:
		result.target_id = target.instance_id

	return result
```

---

## FILE: `core/battle/movement/battle_movement_service.gd`
```gdscript
class_name BattleMovementService
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_COMBATANT: StringName = &"invalid_combatant"
const FAILURE_DEAD_COMBATANT: StringName = &"dead_combatant"
const FAILURE_MOVEMENT_RESTRICTED: StringName = (
	&"movement_restricted"
)
const FAILURE_INVALID_COST: StringName = &"invalid_cost"
const FAILURE_INVALID_START: StringName = &"invalid_start"
const FAILURE_TARGET_OUTSIDE_GRID: StringName = &"target_outside_grid"
const FAILURE_TARGET_OUTSIDE_TEAM_SIDE: StringName = (
	&"target_outside_team_side"
)
const FAILURE_TARGET_IS_START: StringName = &"target_is_start"
const FAILURE_TARGET_BLOCKED: StringName = &"target_blocked"
const FAILURE_NO_PATH: StringName = &"no_path"
const FAILURE_NOT_ENOUGH_STAMINA: StringName = &"not_enough_stamina"


var side_rules: BattleSideRules
var relocation_service := BattleRelocationService.new()


func _init(
	p_side_rules: BattleSideRules
) -> void:
	assert(
		p_side_rules != null,
		"BattleMovementService requires BattleSideRules."
	)

	side_rules = p_side_rules


func create_plan(
	grid: BattleGrid,
	combatant: CombatantState,
	target_coordinate: Vector2i,
	stamina_cost_per_step: int = 1
) -> BattleMovementPlan:
	var plan := BattleMovementPlan.new()

	plan.target_coordinate = target_coordinate
	plan.stamina_cost_per_step = stamina_cost_per_step

	if grid == null:
		plan.failure_code = FAILURE_INVALID_GRID
		return plan

	if combatant == null:
		plan.failure_code = FAILURE_INVALID_COMBATANT
		return plan

	plan.combatant_id = combatant.instance_id
	plan.start_coordinate = combatant.grid_position

	if not combatant.is_alive:
		plan.failure_code = FAILURE_DEAD_COMBATANT
		return plan

	if combatant.is_movement_restricted():
		plan.failure_code = (
			FAILURE_MOVEMENT_RESTRICTED
		)

		return plan

	if stamina_cost_per_step <= 0:
		plan.failure_code = FAILURE_INVALID_COST
		return plan

	if not grid.is_inside(combatant.grid_position):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if not _is_coordinate_allowed(
		grid,
		combatant.team_id,
		combatant.grid_position
	):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if (
		not grid.has_occupant(combatant.instance_id)
		or grid.get_occupant_position(
			combatant.instance_id
		) != combatant.grid_position
	):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if not grid.is_inside(target_coordinate):
		plan.failure_code = FAILURE_TARGET_OUTSIDE_GRID
		return plan

	if target_coordinate == combatant.grid_position:
		plan.failure_code = FAILURE_TARGET_IS_START
		return plan

	if not _is_coordinate_allowed(
		grid,
		combatant.team_id,
		target_coordinate
	):
		plan.failure_code = (
			FAILURE_TARGET_OUTSIDE_TEAM_SIDE
		)

		return plan

	var target_cell := grid.get_cell(target_coordinate)

	if target_cell == null or not target_cell.is_walkable():
		plan.failure_code = FAILURE_TARGET_BLOCKED
		return plan

	plan.path = find_shortest_path(
		grid,
		combatant.grid_position,
		target_coordinate,
		combatant.team_id
	)

	if plan.path.is_empty():
		plan.failure_code = FAILURE_NO_PATH
		return plan

	plan.stamina_cost = (
		plan.path.size()
		* stamina_cost_per_step
	)

	if not combatant.can_spend_stamina(
		plan.stamina_cost
	):
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return plan

	plan.is_valid = true
	return plan


func commit_plan(
	grid: BattleGrid,
	combatant: CombatantState,
	plan: BattleMovementPlan
) -> bool:
	if grid == null or combatant == null or plan == null:
		return false

	if not plan.is_valid:
		return false

	if combatant.instance_id != plan.combatant_id:
		return false

	if combatant.is_movement_restricted():
		return false

	if combatant.grid_position != plan.start_coordinate:
		return false

	if not combatant.can_spend_stamina(
		plan.stamina_cost
	):
		return false

	if not _is_path_currently_valid(
		grid,
		combatant.team_id,
		plan.start_coordinate,
		plan.path
	):
		return false

	if not combatant.spend_stamina(
		plan.stamina_cost
	):
		return false

	for step_coordinate in plan.path:
		var moved := grid.try_move_occupant(
			combatant.instance_id,
			step_coordinate
		)

		if not moved:
			_rollback_failed_movement(
				grid,
				combatant,
				plan
			)

			return false

		combatant.set_grid_position(
			step_coordinate
		)

	return true


func commit_step(
	grid: BattleGrid,
	combatant: CombatantState,
	target_coordinate: Vector2i,
	stamina_cost: int
) -> bool:
	if (
		grid == null
		or combatant == null
		or not combatant.is_alive
		or combatant.is_movement_restricted()
		or stamina_cost <= 0
	):
		return false

	var source_coordinate := (
		combatant.grid_position
	)

	if (
		not grid.is_inside(
			source_coordinate
		)
		or not grid.is_inside(
			target_coordinate
		)
	):
		return false

	if not grid.are_orthogonally_adjacent(
		source_coordinate,
		target_coordinate
	):
		return false

	if not _is_coordinate_allowed(
		grid,
		combatant.team_id,
		target_coordinate
	):
		return false

	if (
		not grid.has_occupant(
			combatant.instance_id
		)
		or grid.get_occupant_position(
			combatant.instance_id
		) != source_coordinate
	):
		return false

	var target_cell := grid.get_cell(
		target_coordinate
	)

	if (
		target_cell == null
		or not target_cell.is_walkable()
	):
		return false

	if not combatant.can_spend_stamina(
		stamina_cost
	):
		return false

	if not combatant.spend_stamina(
		stamina_cost
	):
		return false

	if not grid.try_move_occupant(
		combatant.instance_id,
		target_coordinate
	):
		combatant.restore_stamina(
			stamina_cost
		)

		return false

	combatant.set_grid_position(
		target_coordinate
	)

	return true
	

func get_ally_swap_failure(
	session: BattleSession,
	active: CombatantState,
	ally: CombatantState,
	stamina_cost: int
) -> StringName:
	return relocation_service.get_swap_failure(
		session,
		active,
		ally,
		true,
		true,
		stamina_cost
	)


func can_swap_with_ally(
	session: BattleSession,
	active: CombatantState,
	ally: CombatantState,
	stamina_cost: int
) -> bool:
	return get_ally_swap_failure(
		session,
		active,
		ally,
		stamina_cost
	) == &""


func commit_ally_swap(
	session: BattleSession,
	active: CombatantState,
	ally: CombatantState,
	stamina_cost: int
) -> BattleRelocationResult:
	return relocation_service.swap(
		session,
		active,
		ally,
		true,
		true,
		stamina_cost
	)
	
func find_shortest_path(
	grid: BattleGrid,
	start_coordinate: Vector2i,
	target_coordinate: Vector2i,
	team_id: StringName
) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []

	if grid == null:
		return empty_path

	if not side_rules.is_team_supported(
		team_id
	):
		return empty_path

	if (
		not grid.is_inside(start_coordinate)
		or not grid.is_inside(target_coordinate)
	):
		return empty_path

	if (
		not _is_coordinate_allowed(
			grid,
			team_id,
			start_coordinate
		)
		or not _is_coordinate_allowed(
			grid,
			team_id,
			target_coordinate
		)
	):
		return empty_path

	if start_coordinate == target_coordinate:
		return empty_path

	var target_cell := grid.get_cell(target_coordinate)

	if target_cell == null or not target_cell.is_walkable():
		return empty_path

	var frontier: Array[Vector2i] = [
		start_coordinate
	]

	var frontier_index: int = 0

	var came_from: Dictionary = {
		start_coordinate: start_coordinate,
	}

	while frontier_index < frontier.size():
		var current_coordinate: Vector2i = (
			frontier[frontier_index]
		)

		frontier_index += 1

		if current_coordinate == target_coordinate:
			break

		var neighbors := grid.get_orthogonal_neighbors(
			current_coordinate,
			true
		)

		for neighbor_coordinate in neighbors:
			if not _is_coordinate_allowed(
				grid,
				team_id,
				neighbor_coordinate
			):
				continue

			if came_from.has(neighbor_coordinate):
				continue

			came_from[neighbor_coordinate] = (
				current_coordinate
			)

			frontier.append(
				neighbor_coordinate
			)

	if not came_from.has(target_coordinate):
		return empty_path

	var reversed_path: Array[Vector2i] = []
	var cursor := target_coordinate

	while cursor != start_coordinate:
		reversed_path.append(cursor)

		var previous_coordinate: Vector2i = (
			came_from[cursor]
		)

		cursor = previous_coordinate

	reversed_path.reverse()

	return reversed_path


func get_reachable_coordinates(
	grid: BattleGrid,
	start_coordinate: Vector2i,
	maximum_steps: int,
	team_id: StringName
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if grid == null:
		return result

	if maximum_steps <= 0:
		return result

	if not side_rules.is_team_supported(
		team_id
	):
		return result

	if not grid.is_inside(start_coordinate):
		return result

	if not _is_coordinate_allowed(
		grid,
		team_id,
		start_coordinate
	):
		return result

	var frontier: Array[Vector2i] = [
		start_coordinate
	]

	var frontier_index: int = 0

	var distances: Dictionary = {
		start_coordinate: 0,
	}

	while frontier_index < frontier.size():
		var current_coordinate: Vector2i = (
			frontier[frontier_index]
		)

		frontier_index += 1

		var current_distance: int = (
			distances[current_coordinate]
		)

		if current_distance >= maximum_steps:
			continue

		var neighbors := grid.get_orthogonal_neighbors(
			current_coordinate,
			true
		)

		for neighbor_coordinate in neighbors:
			if not _is_coordinate_allowed(
				grid,
				team_id,
				neighbor_coordinate
			):
				continue

			if distances.has(neighbor_coordinate):
				continue

			var neighbor_distance := (
				current_distance + 1
			)

			distances[neighbor_coordinate] = (
				neighbor_distance
			)

			frontier.append(
				neighbor_coordinate
			)

			result.append(
				neighbor_coordinate
			)

	return result


func _is_path_currently_valid(
	grid: BattleGrid,
	team_id: StringName,
	start_coordinate: Vector2i,
	path: Array[Vector2i]
) -> bool:
	if path.is_empty():
		return false

	if not _is_coordinate_allowed(
		grid,
		team_id,
		start_coordinate
	):
		return false

	var previous_coordinate := start_coordinate

	for step_coordinate in path:
		if not grid.are_orthogonally_adjacent(
			previous_coordinate,
			step_coordinate
		):
			return false

		if not _is_coordinate_allowed(
			grid,
			team_id,
			step_coordinate
		):
			return false

		var step_cell := grid.get_cell(
			step_coordinate
		)

		if step_cell == null or not step_cell.is_walkable():
			return false

		previous_coordinate = step_coordinate

	return true


func _is_coordinate_allowed(
	grid: BattleGrid,
	team_id: StringName,
	coordinate: Vector2i
) -> bool:
	if grid == null or side_rules == null:
		return false

	return side_rules.is_coordinate_allowed(
		team_id,
		coordinate,
		grid.rows,
		grid.columns
	)


func _rollback_failed_movement(
	grid: BattleGrid,
	combatant: CombatantState,
	plan: BattleMovementPlan
) -> void:
	var current_coordinate := (
		grid.get_occupant_position(
			combatant.instance_id
		)
	)

	if current_coordinate != BattleGrid.INVALID_COORDINATE:
		grid.try_move_occupant(
			combatant.instance_id,
			plan.start_coordinate
		)

	combatant.set_grid_position(
		plan.start_coordinate
	)

	combatant.restore_stamina(
		plan.stamina_cost
	)
```

---

## FILE: `core/battle/restrictions/battle_action_restriction.gd`
```gdscript
@tool
class_name BattleActionRestriction
extends Resource


@export_group("Turn")

@export
var skip_owner_turn: bool = false


@export_group("Actions")

@export
var block_movement: bool = false

@export
var block_all_abilities: bool = false

@export
var blocked_ability_ids: Array[StringName] = []


func prevents_movement() -> bool:
	return (
		skip_owner_turn
		or block_movement
	)


func prevents_ability(
	ability_id: StringName
) -> bool:
	if (
		skip_owner_turn
		or block_all_abilities
	):
		return true

	return (
		ability_id != &""
		and blocked_ability_ids.has(
			ability_id
		)
	)


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if (
		not skip_owner_turn
		and not block_movement
		and not block_all_abilities
		and blocked_ability_ids.is_empty()
	):
		errors.append(
			"Action restriction does not restrict anything."
		)

	var used_ability_ids: Dictionary = {}

	for ability_id in blocked_ability_ids:
		if ability_id == &"":
			errors.append(
				"Blocked ability ID cannot be empty."
			)

			continue

		if used_ability_ids.has(
			ability_id
		):
			errors.append(
				"Duplicate blocked ability ID: %s."
				% ability_id
			)

			continue

		used_ability_ids[
			ability_id
		] = true

	return errors
```

---

## FILE: `core/battle/statuses/battle_status_definition.gd`
```gdscript
@tool
class_name BattleStatusDefinition
extends Resource
enum Polarity {
	NEUTRAL,
	BENEFICIAL,
	HARMFUL,
}

enum ReapplyRule {
	REFRESH_DURATION,
	ADD_STACK_AND_REFRESH,
	KEEP_EXISTING,
}


@export_group("Identity")

@export
var status_id: StringName = &""

@export
var display_name: String = "Unnamed Status"

@export_multiline
var description: String = ""

@export_group("Classification")

## Общий характер статуса.
## Используется будущими cleanse/dispel-эффектами.
@export
var polarity: Polarity = Polarity.NEUTRAL

## Стабильные системные категории:
## bleeding, control, stun, regeneration и другие.
@export
var tags: Array[StringName] = []

@export_group("Lifetime")

## Количество завершённых ходов носителя,
## после которых статус исчезнет.
@export_range(1, 999, 1)
var duration_turns: int = 1

@export_range(1, 99, 1)
var max_stacks: int = 1

@export
var reapply_rule: ReapplyRule = (
	ReapplyRule.REFRESH_DURATION
)


@export_group("Action Restrictions")

@export
var action_restriction: BattleActionRestriction

@export_group("Periodic Effects")

@export
var periodic_triggers: Array[BattleStatusPeriodicTrigger] = []


@export_group("Stat Modifiers")

@export
var stat_modifiers: Array[BattleStatModifier] = []


func has_tag(
	tag: StringName
) -> bool:
	return (
		tag != &""
		and tags.has(tag)
	)

func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if status_id == &"":
		errors.append(
			"Status ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Status display name is empty."
		)

	if duration_turns <= 0:
		errors.append(
			"Status duration must be greater than zero."
		)

	if max_stacks <= 0:
		errors.append(
			"Maximum status stacks must be greater than zero."
		)

	var used_tags: Dictionary = {}

	for tag_index in range(
		tags.size()
	):
		var tag := tags[tag_index]

		if tag == &"":
			errors.append(
				"Status tag at index %d is empty."
				% tag_index
			)

			continue

		if used_tags.has(tag):
			errors.append(
				"Status tag '%s' is duplicated."
				% tag
			)

			continue

		used_tags[tag] = true
		
	for modifier_index in range(
		stat_modifiers.size()
	):
		var modifier := stat_modifiers[
			modifier_index
		]

		if modifier == null:
			errors.append(
				"Stat modifier at index %d is null."
				% modifier_index
			)

			continue

		for modifier_error in (
			modifier.get_validation_errors()
		):
			errors.append(
				"Stat modifier %d: %s"
				% [
					modifier_index,
					modifier_error,
				]
			)

	for trigger_index in range(
		periodic_triggers.size()
	):
		var trigger := periodic_triggers[
			trigger_index
		]

		if trigger == null:
			errors.append(
				"Periodic trigger at index %d is null."
				% trigger_index
			)

			continue

		for trigger_error in (
			trigger.get_validation_errors()
		):
			errors.append(
				"Periodic trigger %d: %s"
				% [
					trigger_index,
					trigger_error,
				]
			)

	if action_restriction != null:
		for restriction_error in (
			action_restriction
			.get_validation_errors()
		):
			errors.append(
				"Action restriction: %s"
				% restriction_error
			)

	return errors
```

---

## FILE: `core/battle/statuses/battle_status_instance.gd`
```gdscript
class_name BattleStatusInstance
extends RefCounted


var definition: BattleStatusDefinition

var source_instance_id: StringName = &""

var stack_count: int = 1
var remaining_turns: int = 0


var status_id: StringName:
	get:
		if definition == null:
			return &""

		return definition.status_id


var is_expired: bool:
	get:
		return remaining_turns <= 0


func _init(
	p_definition: BattleStatusDefinition,
	p_source_instance_id: StringName = &""
) -> void:
	assert(
		p_definition != null,
		"BattleStatusInstance requires a definition."
	)

	assert(
		p_definition.is_valid_definition(),
		"BattleStatusInstance requires "
		+"a valid status definition."
	)

	definition = p_definition
	source_instance_id = p_source_instance_id

	stack_count = 1
	remaining_turns = definition.duration_turns


func reapply(
	p_source_instance_id: StringName = &""
) -> void:
	if definition == null:
		return

	if p_source_instance_id != &"":
		source_instance_id = (
			p_source_instance_id
		)

	match definition.reapply_rule:
		BattleStatusDefinition.ReapplyRule.REFRESH_DURATION:
			remaining_turns = (
				definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH:
			stack_count = mini(
				definition.max_stacks,
				stack_count + 1
			)

			remaining_turns = (
				definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.KEEP_EXISTING:
			pass


func advance_owner_turn() -> void:
	if remaining_turns <= 0:
		return

	remaining_turns -= 1
```

---

## FILE: `core/battle/targeting/ability_targeting_definition.gd`
```gdscript
@tool
class_name AbilityTargetingDefinition
extends Resource


enum AimRequirement {
	ANY_CELL,
	OCCUPIED_CELL,
	EMPTY_CELL,
}


enum RelationMask {
	SELF = 1,
	ALLY = 2,
	ENEMY = 4,
}


const ALL_RELATIONS: int = (
	RelationMask.SELF
	| RelationMask.ALLY
	| RelationMask.ENEMY
)


@export_group("Aim")

@export
var aim_requirement: AimRequirement = (
	AimRequirement.OCCUPIED_CELL
)

@export_flags("Self", "Allies", "Enemies")
var aim_relation_mask: int = RelationMask.ENEMY

## Координаты относительно атакующего,
## когда атакующий смотрит вправо.
## Для правой команды X автоматически зеркалится.
@export
var aim_offsets: Array[Vector2i] = [
	Vector2i(1, 0),
]


@export_group("Impact")

@export_flags("Self", "Allies", "Enemies")
var affected_relation_mask: int = RelationMask.ENEMY

## Координаты относительно выбранной клетки.
## Vector2i.ZERO означает саму выбранную клетку.
@export
var impact_offsets: Array[Vector2i] = [
	Vector2i.ZERO,
]


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if aim_offsets.is_empty():
		errors.append(
			"Targeting must contain at least one aim offset."
		)

	if impact_offsets.is_empty():
		errors.append(
			"Targeting must contain at least one impact offset."
		)

	if (
		aim_relation_mask < 0
		or (
			aim_relation_mask
			& ALL_RELATIONS
		) != aim_relation_mask
	):
		errors.append(
			"Aim relation mask contains unsupported flags."
		)

	if (
		affected_relation_mask < 0
		or (
			affected_relation_mask
			& ALL_RELATIONS
		) != affected_relation_mask
	):
		errors.append(
			"Affected relation mask contains unsupported flags."
		)

	if (
		aim_requirement
		!= AimRequirement.EMPTY_CELL
		and aim_relation_mask == 0
	):
		errors.append(
			"Occupied aim cells require at least one "
			+"allowed relation."
		)

	_append_duplicate_offset_errors(
		aim_offsets,
		"Aim",
		errors
	)

	_append_duplicate_offset_errors(
		impact_offsets,
		"Impact",
		errors
	)

	return errors


func is_single_enemy_targeting() -> bool:
	return (
		aim_requirement
		== AimRequirement.OCCUPIED_CELL
		and aim_relation_mask
		== RelationMask.ENEMY
		and affected_relation_mask
		== RelationMask.ENEMY
		and impact_offsets.size() == 1
		and impact_offsets[0] == Vector2i.ZERO
	)


func _append_duplicate_offset_errors(
	offsets: Array[Vector2i],
	label: String,
	errors: PackedStringArray
) -> void:
	var used_offsets: Dictionary = {}

	for offset in offsets:
		if used_offsets.has(offset):
			errors.append(
				"%s offsets contain duplicate coordinate: %s."
				% [
					label,
					offset,
				]
			)

			continue

		used_offsets[offset] = true
```

---

## FILE: `core/battle/turns/battle_turn_controller.gd`
```gdscript
class_name BattleTurnController
extends RefCounted


signal battle_started
signal round_started(round_number: int)

signal turn_starting(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_started(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_skipped(
	combatant: CombatantState,
	round_number: int,
	turn_index: int,
	restriction_status_ids: Array[StringName]
)

signal turn_ending(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_ended(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal periodic_status_effects_resolved(
	combatant: CombatantState,
	timing: int,
	results: Array[BattleStatusPeriodicTriggerResult]
)

signal battle_finished(
	winning_team_id: StringName
)


var session: BattleSession
var reinforcement_controller: BattleReinforcementController

var periodic_status_processor: BattleStatusPeriodicProcessor

var round_number: int = 0
var active_combatant: CombatantState
var winning_team_id: StringName = &""


var is_running: bool:
	get:
		return _started and not _finished


var is_finished: bool:
	get:
		return _finished


var _turn_order: Array[CombatantState] = []
var _current_turn_index: int = -1

var _started: bool = false
var _finished: bool = false

var _is_processing_periodic_statuses: bool = false
var _is_processing_surface_effects: bool = false

## Бойцы начинают свой первый ход с Start Stamina.
## Восстановление за раунд начинается только
## со второго собственного хода бойца.
var _combatant_ids_with_started_turn: Dictionary = {}


func _init(
	p_periodic_status_processor: BattleStatusPeriodicProcessor = null
) -> void:
	periodic_status_processor = (
		p_periodic_status_processor
		if p_periodic_status_processor != null
		else BattleStatusPeriodicProcessor.new()
	)


func start(
	p_session: BattleSession,
	p_reinforcement_controller: BattleReinforcementController = null
) -> bool:
	if _started:
		return false

	if p_session == null:
		return false

	session = p_session
	reinforcement_controller = (
		p_reinforcement_controller
	)

	_started = true
	_finished = false

	round_number = 0
	winning_team_id = &""

	_combatant_ids_with_started_turn.clear()

	_connect_session_signals()

	battle_started.emit()

	return _start_round(1)


func end_current_turn() -> bool:
	if not is_running:
		return false

	if active_combatant == null:
		return false

	var ended_combatant := active_combatant
	var ended_index := _current_turn_index

	turn_ending.emit(
		ended_combatant,
		round_number,
		ended_index
	)

	_process_periodic_status_effects(
		ended_combatant,
		BattleStatusPeriodicTrigger
		.Timing
		.OWNER_TURN_END
	)

	if ended_combatant.is_alive:
		ended_combatant.advance_statuses_after_owner_turn()

	_process_surface_effects(
		ended_combatant,
		BattleSurfaceEffectDefinition
			.TriggerTiming
			.OWNER_TURN_END
	)

	ended_combatant.advance_ability_cooldowns_after_owner_turn()

	turn_ended.emit(
		ended_combatant,
		round_number,
		ended_index
	)

	active_combatant = null

	if evaluate_battle_state():
		return true

	return _advance_to_next_turn()


func evaluate_battle_state() -> bool:
	if not _started:
		return false

	if _finished:
		return true

	var living_combatants := (
		session.get_living_combatants()
	)

	if living_combatants.is_empty():
		if (
			reinforcement_controller != null
			and reinforcement_controller
			.has_pending_reinforcements()
		):
			return false

		_finish_battle(&"")
		return true

	var living_team_ids: Dictionary = {}

	for combatant in living_combatants:
		living_team_ids[
			combatant.team_id
		] = true

	if living_team_ids.size() > 1:
		return false

	var possible_winner: StringName = (
		living_team_ids.keys()[0]
	)

	if (
		reinforcement_controller != null
		and reinforcement_controller
		.has_pending_opposition_to(
			possible_winner
		)
	):
		return false

	_finish_battle(
		possible_winner
	)

	return true


func is_combatant_active(
	combatant: CombatantState
) -> bool:
	return (
		is_running
		and combatant != null
		and combatant == active_combatant
	)


func get_turn_order() -> Array[CombatantState]:
	return _turn_order.duplicate()


func get_current_turn_index() -> int:
	return _current_turn_index


func _start_round(
	new_round_number: int
) -> bool:
	if not is_running:
		return false

	round_number = new_round_number
	active_combatant = null
	_current_turn_index = -1

	if (
		session != null
		and session.surface_effect_controller != null
	):
		session.surface_effect_controller.advance_to_round(
			session,
			round_number
		)

	if reinforcement_controller != null:
		reinforcement_controller.process_round(
			round_number
		)

	_rebuild_turn_order()

	if evaluate_battle_state():
		return true

	if _turn_order.is_empty():
		return false

	round_started.emit(
		round_number
	)

	_current_turn_index = 0

	_begin_turn(
		_turn_order[_current_turn_index]
	)

	return true


func _advance_to_next_turn() -> bool:
	var next_index := (
		_current_turn_index + 1
	)

	while next_index < _turn_order.size():
		var candidate := _turn_order[next_index]

		if (
			candidate != null
			and candidate.is_alive
		):
			_current_turn_index = next_index

			_begin_turn(
				candidate
			)

			return true

		next_index += 1

	return _start_next_round()


func _start_next_round() -> bool:
	return _start_round(
		round_number + 1
	)


func _begin_turn(
	combatant: CombatantState
) -> void:
	if (
		combatant == null
		or not combatant.is_alive
	):
		return

	active_combatant = combatant

	turn_starting.emit(
		combatant,
		round_number,
		_current_turn_index
	)

	_process_periodic_status_effects(
		combatant,
		BattleStatusPeriodicTrigger
		.Timing
		.OWNER_TURN_START
	)

	_process_surface_effects(
		combatant,
		BattleSurfaceEffectDefinition
			.TriggerTiming
			.OWNER_TURN_START
	)

	if not combatant.is_alive:
		active_combatant = null

		if evaluate_battle_state():
			return

		_advance_to_next_turn()
		return

	if _combatant_ids_with_started_turn.has(
		combatant.instance_id
	):
		combatant.restore_round_stamina()
	else:
		_combatant_ids_with_started_turn[
			combatant.instance_id
		] = true

	var skip_status_ids := (
		combatant.get_turn_skip_status_ids()
	)

	if not skip_status_ids.is_empty():
		turn_skipped.emit(
			combatant,
			round_number,
			_current_turn_index,
			skip_status_ids
		)

		end_current_turn()
		return

	turn_started.emit(
		combatant,
		round_number,
		_current_turn_index
	)


func _process_periodic_status_effects(
	combatant: CombatantState,
	timing: int
) -> Array[BattleStatusPeriodicTriggerResult]:
	var results: Array[BattleStatusPeriodicTriggerResult] = []

	if periodic_status_processor == null:
		return results

	_is_processing_periodic_statuses = true

	results = (
		periodic_status_processor
		.process_owner_timing(
			session,
			combatant,
			timing
		)
	)

	_is_processing_periodic_statuses = false

	if not results.is_empty():
		periodic_status_effects_resolved.emit(
			combatant,
			timing,
			results
		)

	return results


func _process_surface_effects(
	combatant: CombatantState,
	timing: int
) -> Array[BattleSurfaceTriggerResult]:
	var results: Array[BattleSurfaceTriggerResult] = []

	if (
		session == null
		or session.surface_effect_controller == null
		or combatant == null
		or not combatant.is_alive
	):
		return results

	_is_processing_surface_effects = true

	results = (
		session
		.surface_effect_controller
		.trigger_for_combatant(
			session,
			combatant,
			timing
		)
	)

	_is_processing_surface_effects = false

	return results

func _rebuild_turn_order() -> void:
	_turn_order.clear()

	for combatant in (
		session.get_living_combatants()
	):
		if (
			combatant == null
			or combatant.definition == null
		):
			continue

		if not (
			combatant
			.definition
			.participates_in_turn_order
		):
			continue

		_turn_order.append(
			combatant
		)

	_turn_order.sort_custom(
		Callable(
			self,
			"_has_higher_turn_priority"
		)
	)


func _has_higher_turn_priority(
	first: CombatantState,
	second: CombatantState
) -> bool:
	if first.initiative != second.initiative:
		return first.initiative > second.initiative

	return (
		String(first.instance_id)
		< String(second.instance_id)
	)


func _connect_session_signals() -> void:
	var callback := Callable(
		self,
		"_on_combatant_defeated"
	)

	if not session.is_connected(
		&"combatant_defeated",
		callback
	):
		session.connect(
			&"combatant_defeated",
			callback
		)


func _on_combatant_defeated(
	_combatant: CombatantState
) -> void:
	if (
		_is_processing_periodic_statuses
		or _is_processing_surface_effects
	):
		return

	evaluate_battle_state()


func _finish_battle(
	p_winning_team_id: StringName
) -> void:
	if _finished:
		return

	_finished = true
	winning_team_id = p_winning_team_id
	active_combatant = null

	battle_finished.emit(
		winning_team_id
	)
```

---


## ✅ STATS
- Total files in tree: 268
- Readable files: 240
- Included files written: 14
- Trimmed files: 0
- Total lines written: 3175
