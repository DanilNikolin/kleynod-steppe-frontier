# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/campaign/campaign_definition.gd', 'core/campaign/state/campaign_state.gd', 'core/campaign/state/campaign_state_factory.gd', 'core/campaign/runtime/campaign_runtime.gd', 'core/campaign/locations/campaign_location_definition.gd', 'core/campaign/heroes/campaign_hero_state.gd', 'core/campaign/inventory/campaign_inventory_state.gd', 'scenes/campaign/campaign_sandbox.gd', 'presentation/campaign/hero_preparation/hero_preparation_panel.gd', 'presentation/campaign/hero_preparation/hero_equipment_panel.gd', 'content/campaign/debug/debug_campaign_definition.tres', 'core/battle/encounters/battle_encounter_definition.gd', 'content/encounters/debug/debug_skirmish_2v2.tres', 'content/heroes/debug/debug_sechevik_hero.tres', 'content/heroes/debug/debug_sechevik_progression_purchase_test.tres']`
- Allow addons: `False`
- Included files planned: `15`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── agents
│   └── AGENTS.md
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_bandage.tres
│   │       ├── debug_battle_focus.tres
│   │       ├── debug_fire_line.tres
│   │       ├── debug_full_cleanse.tres
│   │       ├── debug_full_dispel.tres
│   │       ├── debug_guaranteed_critical.tres
│   │       ├── debug_guard_stance.tres
│   │       ├── debug_hamstring.tres
│   │       ├── debug_place_fire_surface.tres
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_rending_cut.tres
│   │       ├── debug_sabre_slash.tres
│   │       ├── debug_shield_bash.tres
│   │       ├── debug_spirit_mend.tres
│   │       ├── debug_stunning_blow.tres
│   │       ├── debug_swap_positions.tres
│   │       ├── debug_sweeping_slash.tres
│   │       └── debug_teleport.tres
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
│   │   └── prototype
│   │       ├── proto_steppe_raider.tres
│   │       └── proto_steppe_shieldbearer.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
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
│   │   └── debug
│   │       ├── .gitkeep
│   │       ├── debug_sechevik_hero.tres
│   │       ├── debug_sechevik_progression.tres
│   │       └── debug_sechevik_progression_purchase_test.tres
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
│   │   │   └── damage_calculator.gd
│   │   ├── effects
│   │   │   ├── apply_status_effect.gd
│   │   │   ├── battle_effect.gd
│   │   │   ├── damage_effect.gd
│   │   │   ├── effect_resolver.gd
│   │   │   ├── forced_movement_effect.gd
│   │   │   ├── grant_guard_effect.gd
│   │   │   ├── heal_effect.gd
│   │   │   ├── place_surface_effect.gd
│   │   │   ├── remove_status_effect.gd
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
│   │   ├── heroes
│   │   │   ├── .gitkeep
│   │   │   └── campaign_hero_state.gd
│   │   ├── inventory
│   │   │   ├── .gitkeep
│   │   │   └── campaign_inventory_state.gd
│   │   ├── locations
│   │   │   ├── .gitkeep
│   │   │   └── campaign_location_definition.gd
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
│   │   └── hero_preparation
│   │       ├── .gitkeep
│   │       ├── hero_build_summary_panel.gd
│   │       ├── hero_equipment_panel.gd
│   │       ├── hero_loadout_panel.gd
│   │       ├── hero_preparation_panel.gd
│   │       ├── hero_preparation_panel.tscn
│   │       └── hero_skill_grid_panel.gd
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

## FILE: `content/campaign/debug/debug_campaign_definition.tres`
```text
[gd_resource type="Resource" script_class="CampaignDefinition" format=3 uid="uid://c62cq0t20ags4"]

[ext_resource type="Script" uid="uid://c0tpixraq1bbo" path="res://core/campaign/campaign_definition.gd" id="1_campaign"]
[ext_resource type="Script" uid="uid://d1trmhrixtrn1" path="res://core/campaign/heroes/campaign_hero_state.gd" id="2_hero_state"]
[ext_resource type="Resource" uid="uid://t0hlrh42rfly" path="res://content/heroes/debug/debug_sechevik_hero.tres" id="3_hero"]
[ext_resource type="Resource" uid="uid://5mlrljx6pow5" path="res://content/heroes/debug/debug_sechevik_progression_purchase_test.tres" id="4_progression"]
[ext_resource type="Script" uid="uid://b057wdv6pu3ma" path="res://core/campaign/locations/campaign_location_definition.gd" id="5_location_script"]
[ext_resource type="Resource" uid="uid://bv4l8i720765u" path="res://content/locations/debug/debug_forest_edge_location.tres" id="6_location"]
[ext_resource type="Script" uid="uid://dunmh05cf1m3b" path="res://core/heroes/equipment/hero_equipment_item_instance.gd" id="7_item_script"]
[ext_resource type="Resource" uid="uid://bikqcfmppncw" path="res://content/equipment/debug/debug_old_sabre_instance.tres" id="8_sabre"]
[ext_resource type="Resource" uid="uid://vh4oqfulnv38" path="res://content/equipment/debug/debug_steppe_armor_instance.tres" id="9_armor"]
[ext_resource type="Resource" uid="uid://i3gpoobv8ldh" path="res://content/equipment/debug/debug_traveler_charm_instance.tres" id="10_charm"]
[ext_resource type="Resource" uid="uid://ue6xhoflef4w" path="res://content/equipment/debug/debug_heavy_berdysh_instance.tres" id="11_berdysh"]

[sub_resource type="Resource" id="CampaignHero_sechevik"]
script = ExtResource("2_hero_state")
hero_definition = ExtResource("3_hero")
progression_state = ExtResource("4_progression")

[resource]
script = ExtResource("1_campaign")
campaign_id = &"debug_campaign"
display_name = "Клейнод — Campaign Sandbox"
starting_heroes = Array[ExtResource("2_hero_state")]([SubResource("CampaignHero_sechevik")])
starting_active_hero_id = &"hero_debug_sechevik"
starting_inventory_items = Array[ExtResource("7_item_script")]([ExtResource("8_sabre"), ExtResource("9_armor"), ExtResource("10_charm"), ExtResource("11_berdysh")])
locations = Array[ExtResource("5_location_script")]([ExtResource("6_location")])
```

---

## FILE: `content/encounters/debug/debug_skirmish_2v2.tres`
```text
[gd_resource type="Resource" script_class="BattleEncounterDefinition" format=3 uid="uid://c48wssa8p4wp1"]

[ext_resource type="Script" uid="uid://btrmmugs1t8yq" path="res://core/battle/encounters/battle_encounter_definition.gd" id="1_encounter"]
[ext_resource type="Script" uid="uid://blbixnlpyjeaf" path="res://core/battle/encounters/combatant_spawn_definition.gd" id="2_spawn"]
[ext_resource type="Resource" uid="uid://b3fmtemw5g732" path="res://scenes/debug_sechevik.tres" id="3_player"]
[ext_resource type="Resource" uid="uid://cvjqcjyhusucr" path="res://content/combatants/prototype/proto_steppe_raider.tres" id="4_raider"]
[ext_resource type="Script" uid="uid://cv0u875s12ql" path="res://core/battle/encounters/battle_reinforcement_wave_definition.gd" id="5_rxsgo"]
[ext_resource type="Resource" uid="uid://co8lwfk1guhba" path="res://content/combatants/prototype/proto_steppe_shieldbearer.tres" id="5_shieldbearer"]
[ext_resource type="Script" uid="uid://2apyueuevyjk" path="res://core/battle/sides/battle_side_rules.gd" id="6_side_rules"]
[ext_resource type="Script" uid="uid://cmu30nbvdwynk" path="res://core/battle/encounters/battle_surface_spawn_definition.gd" id="8_tps1g"]

[sub_resource type="Resource" id="Resource_player_1"]
script = ExtResource("2_spawn")
instance_id = &"player_1"
combatant_definition = ExtResource("3_player")
team_id = &"team_player"
coordinate = Vector2i(1, 0)

[sub_resource type="Resource" id="Resource_player_2"]
script = ExtResource("2_spawn")
instance_id = &"player_2"
combatant_definition = ExtResource("3_player")
team_id = &"team_player"
coordinate = Vector2i(1, 2)

[sub_resource type="Resource" id="Resource_enemy_raider"]
script = ExtResource("2_spawn")
instance_id = &"enemy_raider"
combatant_definition = ExtResource("4_raider")
team_id = &"team_enemy"
coordinate = Vector2i(4, 0)

[sub_resource type="Resource" id="Resource_enemy_shieldbearer"]
script = ExtResource("2_spawn")
instance_id = &"enemy_shieldbearer"
combatant_definition = ExtResource("5_shieldbearer")
team_id = &"team_enemy"
coordinate = Vector2i(4, 2)

[sub_resource type="Resource" id="Resource_side_rules"]
script = ExtResource("6_side_rules")

[resource]
script = ExtResource("1_encounter")
encounter_id = &"debug_skirmish_2v2"
display_name = "Прототип боя 2v2"
description = "Первый нормальный мини-бой: два Сечевика против степного рубаки и щитоносца."
side_rules = SubResource("Resource_side_rules")
combatant_spawns = Array[ExtResource("2_spawn")]([SubResource("Resource_player_1"), SubResource("Resource_player_2"), SubResource("Resource_enemy_raider"), SubResource("Resource_enemy_shieldbearer")])
```

---

## FILE: `content/heroes/debug/debug_sechevik_hero.tres`
```text
[gd_resource type="Resource" script_class="HeroDefinition" format=3 uid="uid://t0hlrh42rfly"]

[ext_resource type="Script" uid="uid://bldck1o3mhuyn" path="res://core/heroes/hero_definition.gd" id="1_hero"]
[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" uid="uid://b3fmtemw5g732" path="res://scenes/debug_sechevik.tres" id="3_combatant"]
[ext_resource type="Resource" uid="uid://cvv0xgjjefuwd" path="res://content/skill_grids/debug/debug_sechevik_skill_grid.tres" id="4_grid"]
[ext_resource type="Resource" uid="uid://bh0xtv0ndcte4" path="res://content/abilities/debug/debug_sabre_slash.tres" id="5_sabre"]
[ext_resource type="Resource" uid="uid://bnk0vuvlj8iqp" path="res://content/abilities/debug/debug_spirit_mend.tres" id="6_mend"]

[resource]
script = ExtResource("1_hero")
hero_id = &"hero_debug_sechevik"
display_name = "Отладочный Сечевик"
description = "Герой для проверки Skill Grid и Hero Battle Build."
base_combatant_definition = ExtResource("3_combatant")
skill_grid = ExtResource("4_grid")
personal_abilities = Array[ExtResource("2_ability")]([ExtResource("5_sabre"), ExtResource("6_mend")])
starting_known_ability_ids = Array[StringName]([&"ability_sabre_slash"])
default_ability_id = &"ability_sabre_slash"
```

---

## FILE: `content/heroes/debug/debug_sechevik_progression_purchase_test.tres`
```text
[gd_resource type="Resource" script_class="HeroProgressionState" format=3 uid="uid://5mlrljx6pow5"]

[ext_resource type="Script" uid="uid://pb2qoxxjae71" path="res://core/heroes/hero_progression_state.gd" id="1_progression"]

[resource]
script = ExtResource("1_progression")
level = 10
unspent_skill_points = 9
```

---

## FILE: `core/battle/encounters/battle_encounter_definition.gd`
```gdscript
@tool
class_name BattleEncounterDefinition
extends Resource


@export_group("Identity")

@export
var encounter_id: StringName = &""

@export
var display_name: String = "Unnamed Encounter"

@export_multiline
var description: String = ""


@export_group("Grid")

@export_range(1, 100, 1)
var rows: int = 3

@export_range(1, 100, 1)
var columns: int = 6

@export_group("Sides")

@export
var side_rules: BattleSideRules = BattleSideRules.new()

@export_group("Initial Combatants")

@export
var combatant_spawns: Array[CombatantSpawnDefinition] = []


@export_group("Initial Surfaces")

@export
var surface_spawns: Array[BattleSurfaceSpawnDefinition] = []


@export_group("Reinforcements")

@export
var reinforcement_waves: Array[BattleReinforcementWaveDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if encounter_id == &"":
		errors.append(
			"Encounter ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Encounter display name is empty."
		)

	if rows <= 0:
		errors.append(
			"Encounter must contain at least one row."
		)

	if columns <= 0:
		errors.append(
			"Encounter must contain at least one column."
		)

	if side_rules == null:
		errors.append(
			"Battle side rules are not assigned."
		)

	else:
		for side_error in (
			side_rules.get_validation_errors(
				columns
			)
		):
			errors.append(
				"Battle sides: %s"
				% side_error
			)
	if combatant_spawns.is_empty():
		errors.append(
			"Encounter must contain at least one "
			+"initial combatant."
		)

	var used_instance_ids: Dictionary = {}
	var initial_teams_by_instance_id: Dictionary = {}

	var used_initial_coordinates: Dictionary = {}
	var used_surface_ids_by_coordinate: Dictionary = {}

	var used_team_ids: Dictionary = {}
	var used_wave_ids: Dictionary = {}

	for spawn_index in range(
		combatant_spawns.size()
	):
		var spawn := combatant_spawns[spawn_index]

		if spawn == null:
			errors.append(
				"Initial combatant spawn at index %d is null."
				% spawn_index
			)

			continue

		for spawn_error in spawn.get_validation_errors():
			errors.append(
				"Initial combatant spawn %d: %s"
				% [
					spawn_index,
					spawn_error,
				]
			)

		if spawn.instance_id != &"":
			if used_instance_ids.has(
				spawn.instance_id
			):
				errors.append(
					"Duplicate combatant instance ID: %s."
					% spawn.instance_id
				)

			else:
				used_instance_ids[
					spawn.instance_id
				] = true

				initial_teams_by_instance_id[
					spawn.instance_id
				] = spawn.team_id

		if not is_coordinate_inside(
			spawn.coordinate
		):
			errors.append(
				"Initial combatant '%s' has an invalid "
				% spawn.instance_id
				+"start coordinate: %s."
				% spawn.coordinate
			)

		elif used_initial_coordinates.has(
			spawn.coordinate
		):
			errors.append(
				"Multiple initial combatants use "
				+"coordinate %s."
				% spawn.coordinate
			)

		else:
			used_initial_coordinates[
				spawn.coordinate
			] = true

		if spawn.team_id != &"":
			used_team_ids[
				spawn.team_id
			] = true

		if (
			side_rules != null
			and spawn.team_id != &""
		):
			if not side_rules.is_team_supported(
				spawn.team_id
			):
				errors.append(
					"Initial combatant '%s' uses "
					% spawn.instance_id
					+"unsupported team ID: %s."
					% spawn.team_id
				)

			elif (
				is_coordinate_inside(
					spawn.coordinate
				)
				and not side_rules.is_coordinate_allowed(
					spawn.team_id,
					spawn.coordinate,
					rows,
					columns
				)
			):
				errors.append(
					"Initial combatant '%s' starts "
					% spawn.instance_id
					+"outside its team side: %s."
					% spawn.coordinate
				)

	for surface_spawn_index in range(
		surface_spawns.size()
	):
		var surface_spawn := surface_spawns[
			surface_spawn_index
		]

		if surface_spawn == null:
			errors.append(
				"Initial surface spawn at index %d is null."
				% surface_spawn_index
			)

			continue

		for spawn_error in (
			surface_spawn.get_validation_errors()
		):
			errors.append(
				"Initial surface spawn %d: %s"
				% [
					surface_spawn_index,
					spawn_error,
				]
			)

		if not is_coordinate_inside(
			surface_spawn.coordinate
		):
			errors.append(
				"Initial surface spawn %d has an invalid "
				% surface_spawn_index
				+"coordinate: %s."
				% surface_spawn.coordinate
			)

		var surface_definition := (
			surface_spawn.surface_definition
		)

		if (
			surface_definition != null
			and surface_definition.surface_effect_id
				!= &""
			and is_coordinate_inside(
				surface_spawn.coordinate
			)
		):
			var used_surface_ids: Dictionary = (
				used_surface_ids_by_coordinate.get(
					surface_spawn.coordinate,
					{}
				)
			)

			if used_surface_ids.has(
				surface_definition.surface_effect_id
			):
				errors.append(
					"Duplicate initial surface '%s' "
					% surface_definition.surface_effect_id
					+"at coordinate %s."
					% surface_spawn.coordinate
				)

			else:
				used_surface_ids[
					surface_definition.surface_effect_id
				] = true

				used_surface_ids_by_coordinate[
					surface_spawn.coordinate
				] = used_surface_ids

		if (
			surface_spawn.source_team_id != &""
			and side_rules != null
			and not side_rules.is_team_supported(
				surface_spawn.source_team_id
			)
		):
			errors.append(
				"Initial surface spawn %d uses "
				% surface_spawn_index
				+"unsupported source team ID: %s."
				% surface_spawn.source_team_id
			)

		if surface_spawn.source_instance_id != &"":
			if not initial_teams_by_instance_id.has(
				surface_spawn.source_instance_id
			):
				errors.append(
					"Initial surface spawn %d references "
					% surface_spawn_index
					+"unknown initial source combatant: %s."
					% surface_spawn.source_instance_id
				)

			else:
				var combatant_team_id: StringName = (
					initial_teams_by_instance_id.get(
						surface_spawn.source_instance_id,
						&""
					)
				)

				if (
					surface_spawn.source_team_id != &""
					and surface_spawn.source_team_id
						!= combatant_team_id
				):
					errors.append(
						"Initial surface spawn %d source "
						% surface_spawn_index
						+"team does not match combatant '%s'."
						% surface_spawn.source_instance_id
					)

		if (
			surface_definition != null
			and surface_definition.target_relation
				!= BattleSurfaceEffectDefinition
					.TargetRelation
					.ALL
			and surface_spawn.source_instance_id == &""
			and surface_spawn.source_team_id == &""
		):
			errors.append(
				"Initial surface spawn %d requires "
				% surface_spawn_index
				+"a source combatant or source team "
				+"for its target relation."
			)
			
	for wave_index in range(
		reinforcement_waves.size()
	):
		var wave := reinforcement_waves[wave_index]

		if wave == null:
			errors.append(
				"Reinforcement wave at index %d is null."
				% wave_index
			)

			continue

		for wave_error in wave.get_validation_errors():
			errors.append(
				"Reinforcement wave %d: %s"
				% [
					wave_index,
					wave_error,
				]
			)

		if wave.wave_id != &"":
			if used_wave_ids.has(
				wave.wave_id
			):
				errors.append(
					"Duplicate reinforcement wave ID: %s."
					% wave.wave_id
				)
			else:
				used_wave_ids[
					wave.wave_id
				] = true

		for spawn_index in range(
			wave.combatant_spawns.size()
		):
			var spawn := (
				wave.combatant_spawns[
					spawn_index
				]
			)

			if spawn == null:
				continue

			if spawn.instance_id != &"":
				if used_instance_ids.has(
					spawn.instance_id
				):
					errors.append(
						"Duplicate combatant instance ID "
						+"across encounter: %s."
						% spawn.instance_id
					)
				else:
					used_instance_ids[
						spawn.instance_id
					] = true

			if spawn.team_id != &"":
				used_team_ids[
					spawn.team_id
				] = true

			if (
				side_rules != null
				and spawn.team_id != &""
				and not side_rules.is_team_supported(
					spawn.team_id
				)
			):
				errors.append(
					"Reinforcement combatant '%s' uses "
					% spawn.instance_id
					+"unsupported team ID: %s."
					% spawn.team_id
				)

			for candidate_coordinate in (
				spawn.get_candidate_coordinates()
			):
				if not is_coordinate_inside(
					candidate_coordinate
				):
					errors.append(
						"Reinforcement combatant '%s' "
						% spawn.instance_id
						+"has an invalid candidate "
						+"coordinate: %s."
						% candidate_coordinate
					)

					continue

				if (
					side_rules != null
					and side_rules.is_team_supported(
						spawn.team_id
					)
					and not side_rules.is_coordinate_allowed(
						spawn.team_id,
						candidate_coordinate,
						rows,
						columns
					)
				):
					errors.append(
						"Reinforcement combatant '%s' "
						% spawn.instance_id
						+"has a candidate outside "
						+"its team side: %s."
						% candidate_coordinate
					)

	if used_team_ids.size() < 2:
		errors.append(
			"Encounter must contain combatants "
			+"from at least two teams, including "
			+"reinforcement waves."
		)

	return errors


func is_coordinate_inside(
	coordinate: Vector2i
) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)
```

---

## FILE: `core/campaign/campaign_definition.gd`
```gdscript
@tool
class_name CampaignDefinition
extends Resource


@export_group("Identity")

@export
var campaign_id: StringName = &""

@export
var display_name: String = "Unnamed Campaign"


@export_group("Heroes")

@export
var starting_heroes: Array[CampaignHeroState] = []

@export
var starting_active_hero_id: StringName = &""


@export_group("Inventory")

@export
var starting_inventory_items: Array[HeroEquipmentItemInstance] = []


@export_group("Locations")

@export
var locations: Array[CampaignLocationDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if campaign_id == &"":
		errors.append(
			"Campaign ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Campaign display name is empty."
		)

	if starting_heroes.is_empty():
		errors.append(
			"Campaign has no starting heroes."
		)

	var used_hero_ids: Dictionary = {}

	for hero_index in range(
		starting_heroes.size()
	):
		var hero_state := starting_heroes[
			hero_index
		]

		if hero_state == null:
			errors.append(
				"Starting hero at index %d is null."
				% hero_index
			)

			continue

		for hero_error in (
			hero_state.get_validation_errors()
		):
			errors.append(
				"Starting hero %d: %s"
				% [
					hero_index,
					hero_error,
				]
			)

		var hero_id := hero_state.get_hero_id()

		if hero_id == &"":
			continue

		if used_hero_ids.has(
			hero_id
		):
			errors.append(
				"Duplicate starting hero ID: %s."
				% hero_id
			)

			continue

		used_hero_ids[
			hero_id
		] = true

	if starting_active_hero_id == &"":
		errors.append(
			"Starting active hero ID is empty."
		)

	elif not used_hero_ids.has(
		starting_active_hero_id
	):
		errors.append(
			"Starting active hero '%s' does not exist."
			% starting_active_hero_id
		)

	var used_inventory_item_ids: Dictionary = {}

	for item_index in range(
		starting_inventory_items.size()
	):
		var item := starting_inventory_items[
			item_index
		]

		if item == null:
			errors.append(
				"Starting inventory item at index %d is null."
				% item_index
			)

			continue

		for item_error in item.get_validation_errors():
			errors.append(
				"Starting inventory item %d: %s"
				% [
					item_index,
					item_error,
				]
			)

		if item.instance_id == &"":
			continue

		if used_inventory_item_ids.has(
			item.instance_id
		):
			errors.append(
				"Duplicate starting inventory item ID: %s."
				% item.instance_id
			)

			continue

		used_inventory_item_ids[
			item.instance_id
		] = true

	if locations.is_empty():
		errors.append(
			"Campaign has no available locations."
		)

	var used_location_ids: Dictionary = {}

	for location_index in range(
		locations.size()
	):
		var location := locations[
			location_index
		]

		if location == null:
			errors.append(
				"Campaign location at index %d is null."
				% location_index
			)

			continue

		for location_error in (
			location.get_validation_errors()
		):
			errors.append(
				"Campaign location %d: %s"
				% [
					location_index,
					location_error,
				]
			)

		if used_location_ids.has(
			location.location_id
		):
			errors.append(
				"Duplicate campaign location ID: %s."
				% location.location_id
			)

			continue

		used_location_ids[
			location.location_id
		] = true

	return errors


func get_location(
	location_id: StringName
) -> CampaignLocationDefinition:
	if location_id == &"":
		return null

	for location in locations:
		if (
			location != null
			and location.location_id == location_id
		):
			return location

	return null
```

---

## FILE: `core/campaign/heroes/campaign_hero_state.gd`
```gdscript
@tool
class_name CampaignHeroState
extends Resource


@export_group("Hero")

@export
var hero_definition: HeroDefinition

@export
var progression_state: HeroProgressionState


func get_hero_id() -> StringName:
	if hero_definition == null:
		return &""

	return hero_definition.hero_id


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if hero_definition == null:
		errors.append(
			"Campaign hero definition is not assigned."
		)

	elif not hero_definition.is_valid_definition():
		errors.append(
			"Campaign hero definition is invalid."
		)

	if progression_state == null:
		errors.append(
			"Campaign hero progression is not assigned."
		)

	elif not progression_state.is_valid_state():
		errors.append(
			"Campaign hero progression is invalid."
		)

	return errors
```

---

## FILE: `core/campaign/inventory/campaign_inventory_state.gd`
```gdscript
@tool
class_name CampaignInventoryState
extends Resource


@export_group("Items")

@export
var items: Array[HeroEquipmentItemInstance] = []


func get_item(
	instance_id: StringName
) -> HeroEquipmentItemInstance:
	if instance_id == &"":
		return null

	for item in items:
		if (
			item != null
			and item.instance_id == instance_id
		):
			return item

	return null


func has_item(
	instance_id: StringName
) -> bool:
	return get_item(
		instance_id
	) != null


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	var used_instance_ids: Dictionary = {}

	for item_index in range(
		items.size()
	):
		var item := items[
			item_index
		]

		if item == null:
			errors.append(
				"Inventory item at index %d is null."
				% item_index
			)

			continue

		for item_error in item.get_validation_errors():
			errors.append(
				"Inventory item %d: %s"
				% [
					item_index,
					item_error,
				]
			)

		if item.instance_id == &"":
			continue

		if used_instance_ids.has(
			item.instance_id
		):
			errors.append(
				"Duplicate inventory instance ID: %s."
				% item.instance_id
			)

			continue

		used_instance_ids[
			item.instance_id
		] = true

	return errors
```

---

## FILE: `core/campaign/locations/campaign_location_definition.gd`
```gdscript
@tool
class_name CampaignLocationDefinition
extends Resource


@export_group("Identity")

@export
var location_id: StringName = &""

@export
var display_name: String = "Unnamed Location"

@export_multiline
var description: String = ""


@export_group("Battle")

@export
var encounter_definition: BattleEncounterDefinition

## Instance ID игрока внутри encounter.
## При запуске кампании его HeroDefinition и
## HeroProgressionState заменяются состоянием кампании.
@export
var player_spawn_instance_id: StringName = &"debug_hero"


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if location_id == &"":
		errors.append(
			"Campaign location ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Campaign location display name is empty."
		)

	if encounter_definition == null:
		errors.append(
			"Campaign location encounter is not assigned."
		)

	elif not encounter_definition.is_valid_definition():
		errors.append(
			"Campaign location encounter is invalid."
		)

	if player_spawn_instance_id == &"":
		errors.append(
			"Campaign location player spawn ID is empty."
		)

	elif encounter_definition != null:
		var has_player_spawn := false

		for spawn in encounter_definition.combatant_spawns:
			if (
				spawn != null
				and spawn.instance_id
					== player_spawn_instance_id
			):
				has_player_spawn = true
				break

		if not has_player_spawn:
			errors.append(
				"Campaign location player spawn '%s' "
				% player_spawn_instance_id
				+"does not exist in the encounter."
			)

	return errors
```

---

## FILE: `core/campaign/runtime/campaign_runtime.gd`
```gdscript
class_name CampaignRuntimeService
extends Node


const PLAYER_TEAM_ID: StringName = &"team_player"

const CAMPAIGN_SCENE_PATH: String = (
	"res://scenes/campaign/campaign_sandbox.tscn"
)

const BATTLE_SCENE_PATH: String = (
	"res://scenes/debug/battle_grid_sandbox.tscn"
)

const DEBUG_CAMPAIGN_DEFINITION_PATH: String = (
	"res://content/campaign/debug/"
	+"debug_campaign_definition.tres"
)


var campaign_definition: CampaignDefinition
var campaign_state: CampaignState

var pending_battle_request: CampaignBattleRequest

var state_factory := CampaignStateFactory.new()

var _battle_request_counter: int = 0


func _ready() -> void:
	ensure_campaign_started()


func ensure_campaign_started() -> bool:
	if campaign_state != null:
		return true

	return start_new_campaign()


func start_new_campaign() -> bool:
	var loaded_definition := load(
		DEBUG_CAMPAIGN_DEFINITION_PATH
	)

	campaign_definition = (
		loaded_definition as CampaignDefinition
	)

	if (
		campaign_definition == null
		or not campaign_definition.is_valid_definition()
	):
		push_error(
			"CampaignRuntime failed to load "
			+"a valid CampaignDefinition."
		)

		return false

	campaign_state = (
		state_factory.create_from_definition(
			campaign_definition
		)
	)

	if campaign_state == null:
		push_error(
			"CampaignRuntime failed to create "
			+"CampaignState."
		)

		return false

	pending_battle_request = null
	_battle_request_counter = 0

	return true


func get_campaign_state() -> CampaignState:
	return campaign_state


func get_inventory_state() -> CampaignInventoryState:
	if campaign_state == null:
		return null

	return campaign_state.inventory_state


func get_active_hero_state() -> CampaignHeroState:
	if campaign_state == null:
		return null

	return campaign_state.get_active_hero()


func get_location(
	location_id: StringName
) -> CampaignLocationDefinition:
	if campaign_definition == null:
		return null

	return campaign_definition.get_location(
		location_id
	)


func get_available_locations() -> Array[CampaignLocationDefinition]:
	var result: Array[CampaignLocationDefinition] = []

	if campaign_definition == null:
		return result

	for location in campaign_definition.locations:
		if location == null:
			continue

		result.append(
			location
		)

	return result


func has_pending_battle() -> bool:
	return (
		pending_battle_request != null
		and pending_battle_request
			.encounter_definition != null
	)


func get_pending_battle_encounter() -> BattleEncounterDefinition:
	if pending_battle_request == null:
		return null

	return pending_battle_request.encounter_definition


func start_location(
	location_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		push_warning(
			"Campaign battle request is already active."
		)

		return false

	var location := get_location(
		location_id
	)

	if (
		location == null
		or not location.is_valid_definition()
	):
		push_warning(
			"Cannot start unknown or invalid location: %s."
			% location_id
		)

		return false

	var active_hero := get_active_hero_state()

	if (
		active_hero == null
		or not active_hero.is_valid_state()
	):
		push_warning(
			"Cannot start location without "
			+"a valid active hero."
		)

		return false

	var runtime_encounter := (
		location
			.encounter_definition
			.duplicate(true)
		as BattleEncounterDefinition
	)

	if runtime_encounter == null:
		push_warning(
			"Campaign encounter could not be duplicated."
		)

		return false

	var player_spawn: CombatantSpawnDefinition

	for spawn in runtime_encounter.combatant_spawns:
		if (
			spawn != null
			and spawn.instance_id
				== location.player_spawn_instance_id
		):
			player_spawn = spawn
			break

	if player_spawn == null:
		push_warning(
			"Campaign encounter has no player spawn '%s'."
			% location.player_spawn_instance_id
		)

		return false

	player_spawn.hero_definition = (
		active_hero.hero_definition
	)

	player_spawn.hero_progression_state = (
		active_hero.progression_state
	)

	player_spawn.combatant_definition = (
		active_hero
			.hero_definition
			.base_combatant_definition
	)

	if not runtime_encounter.is_valid_definition():
		push_warning(
			"Runtime campaign encounter is invalid."
		)

		return false

	_battle_request_counter += 1

	var request := CampaignBattleRequest.new()

	request.request_id = StringName(
		"campaign_battle_%d"
		% _battle_request_counter
	)

	request.location_id = (
		location.location_id
	)

	request.active_hero_id = (
		active_hero.get_hero_id()
	)

	request.player_spawn_instance_id = (
		location.player_spawn_instance_id
	)

	request.encounter_definition = (
		runtime_encounter
	)

	pending_battle_request = request

	var scene_error := get_tree().change_scene_to_file(
		BATTLE_SCENE_PATH
	)

	if scene_error != OK:
		pending_battle_request = null

		push_error(
			"Failed to change to campaign battle scene."
		)

		return false

	return true


func complete_pending_battle_and_return(
	winning_team_id: StringName
) -> bool:
	if (
		campaign_state == null
		or pending_battle_request == null
	):
		return false

	var result := CampaignBattleResult.new()

	result.request_id = (
		pending_battle_request.request_id
	)

	result.location_id = (
		pending_battle_request.location_id
	)

	result.winning_team_id = (
		winning_team_id
	)

	if (
		pending_battle_request
			.encounter_definition != null
	):
		result.encounter_id = (
			pending_battle_request
				.encounter_definition
				.encounter_id
		)

	if winning_team_id == PLAYER_TEAM_ID:
		result.outcome = (
			CampaignBattleResult.Outcome.VICTORY
		)

	elif winning_team_id == &"":
		result.outcome = (
			CampaignBattleResult.Outcome.DRAW
		)

	else:
		result.outcome = (
			CampaignBattleResult.Outcome.DEFEAT
		)

	campaign_state.last_battle_result = (
		result
	)

	campaign_state.current_location_id = (
		pending_battle_request.location_id
	)

	campaign_state.completed_battle_count += 1

	pending_battle_request = null

	call_deferred(
		"_change_to_campaign_scene"
	)

	return true


func _change_to_campaign_scene() -> void:
	var scene_error := get_tree().change_scene_to_file(
		CAMPAIGN_SCENE_PATH
	)

	if scene_error != OK:
		push_error(
			"Failed to return to campaign scene."
		)
```

---

## FILE: `core/campaign/state/campaign_state.gd`
```gdscript
class_name CampaignState
extends RefCounted


var campaign_id: StringName = &""

var heroes: Array[CampaignHeroState] = []

var inventory_state: CampaignInventoryState

var active_hero_id: StringName = &""
var current_location_id: StringName = &""

var completed_battle_count: int = 0

var last_battle_result: CampaignBattleResult


func get_hero(
	hero_id: StringName
) -> CampaignHeroState:
	if hero_id == &"":
		return null

	for hero_state in heroes:
		if (
			hero_state != null
			and hero_state.get_hero_id() == hero_id
		):
			return hero_state

	return null


func get_active_hero() -> CampaignHeroState:
	return get_hero(
		active_hero_id
	)
```

---

## FILE: `core/campaign/state/campaign_state_factory.gd`
```gdscript
class_name CampaignStateFactory
extends RefCounted


func create_from_definition(
	definition: CampaignDefinition
) -> CampaignState:
	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return null

	var result := CampaignState.new()

	result.campaign_id = definition.campaign_id
	result.active_hero_id = (
		definition.starting_active_hero_id
	)

	result.inventory_state = _create_inventory(
		definition
	)

	if result.inventory_state == null:
		return null

	for hero_template in (
		definition.starting_heroes
	):
		if hero_template == null:
			return null

		var progression_copy := (
			hero_template
				.progression_state
				.duplicate(true)
			as HeroProgressionState
		)

		if progression_copy == null:
			return null

		if progression_copy.equipment_state == null:
			progression_copy.equipment_state = (
				HeroEquipmentState.new()
			)

		elif not _remap_equipment_to_inventory(
			progression_copy.equipment_state,
			result.inventory_state
		):
			return null

		var hero_state := CampaignHeroState.new()

		hero_state.hero_definition = (
			hero_template.hero_definition
		)

		hero_state.progression_state = (
			progression_copy
		)

		if not hero_state.is_valid_state():
			return null

		result.heroes.append(
			hero_state
		)

	if result.get_active_hero() == null:
		return null

	return result


func _create_inventory(
	definition: CampaignDefinition
) -> CampaignInventoryState:
	var result := CampaignInventoryState.new()

	for item_template in (
		definition.starting_inventory_items
	):
		if item_template == null:
			return null

		var item_copy := (
			item_template.duplicate(true)
			as HeroEquipmentItemInstance
		)

		if (
			item_copy == null
			or not item_copy.is_valid_instance()
		):
			return null

		result.items.append(
			item_copy
		)

	if not result.is_valid_state():
		return null

	return result


func _remap_equipment_to_inventory(
	equipment_state: HeroEquipmentState,
	inventory_state: CampaignInventoryState
) -> bool:
	if (
		equipment_state == null
		or inventory_state == null
	):
		return false

	for slot in HeroEquipmentState.get_all_slots():
		var equipped_item := equipment_state.get_item(
			slot
		)

		if equipped_item == null:
			continue

		var inventory_item := inventory_state.get_item(
			equipped_item.instance_id
		)

		if inventory_item == null:
			return false

		equipment_state.set_item(
			slot,
			inventory_item
		)

	return equipment_state.is_valid_state()
```

---

## FILE: `presentation/campaign/hero_preparation/hero_equipment_panel.gd`
```gdscript
class_name HeroEquipmentPanel
extends PanelContainer


signal state_changed


var progression: HeroProgressionState
var inventory_state: CampaignInventoryState

var equipment_service := (
	HeroEquipmentService.new()
)


func bind(
	p_progression: HeroProgressionState,
	p_inventory_state: CampaignInventoryState
) -> void:
	progression = p_progression
	inventory_state = p_inventory_state

	if (
		progression != null
		and progression.equipment_state == null
	):
		progression.equipment_state = (
			HeroEquipmentState.new()
		)

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	var outer := VBoxContainer.new()

	outer.add_theme_constant_override(
		"separation",
		10
	)

	add_child(
		outer
	)

	var title := Label.new()

	title.text = "ИНВЕНТАРЬ И ЭКИПИРОВКА"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	outer.add_child(
		title
	)

	if (
		progression == null
		or progression.equipment_state == null
		or inventory_state == null
	):
		var error_label := Label.new()

		error_label.text = (
			"Инвентарь или Equipment State недоступны."
		)

		outer.add_child(
			error_label
		)

		return

	var slots_title := Label.new()

	slots_title.text = "ЭКИПИРОВАННЫЕ СЛОТЫ"

	outer.add_child(
		slots_title
	)

	for slot in HeroEquipmentState.get_all_slots():
		outer.add_child(
			_create_equipped_slot_row(
				slot
			)
		)

	outer.add_child(
		HSeparator.new()
	)

	var inventory_title := Label.new()

	inventory_title.text = "ПРЕДМЕТЫ КАМПАНИИ"

	outer.add_child(
		inventory_title
	)

	var scroll := ScrollContainer.new()

	scroll.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	outer.add_child(
		scroll
	)

	var inventory_content := VBoxContainer.new()

	inventory_content.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	inventory_content.add_theme_constant_override(
		"separation",
		10
	)

	scroll.add_child(
		inventory_content
	)

	if inventory_state.items.is_empty():
		var empty_label := Label.new()

		empty_label.text = "Инвентарь пуст."

		inventory_content.add_child(
			empty_label
		)

		return

	for item in inventory_state.items:
		if (
			item == null
			or item.definition == null
		):
			continue

		inventory_content.add_child(
			_create_inventory_item_row(
				item
			)
		)


func _create_equipped_slot_row(
	slot: int
) -> Control:
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		8
	)

	var slot_label := Label.new()

	slot_label.custom_minimum_size = Vector2(
		100,
		0
	)

	slot_label.text = (
		HeroEquipmentState.get_slot_display_name(
			slot
		)
	)

	row.add_child(
		slot_label
	)

	var item := progression.equipment_state.get_item(
		slot
	)

	var item_label := Label.new()

	item_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	if (
		item == null
		or item.definition == null
	):
		item_label.text = "—"

	else:
		item_label.text = (
			item.definition.display_name
		)

	row.add_child(
		item_label
	)

	var remove_button := Button.new()

	remove_button.text = "Снять"
	remove_button.disabled = item == null

	remove_button.pressed.connect(
		_on_unequip_pressed.bind(
			slot
		)
	)

	row.add_child(
		remove_button
	)

	return row


func _create_inventory_item_row(
	item: HeroEquipmentItemInstance
) -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		6
	)

	panel.add_child(
		content
	)

	var name_label := Label.new()

	name_label.text = (
		item.definition.display_name
	)

	content.add_child(
		name_label
	)

	var description := Label.new()

	description.text = item.definition.description
	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		description
	)

	var button_row := HBoxContainer.new()

	button_row.add_theme_constant_override(
		"separation",
		6
	)

	content.add_child(
		button_row
	)

	for slot in equipment_service.get_compatible_slots(
		item
	):
		var equip_button := Button.new()

		equip_button.text = _get_equip_button_text(
			item,
			slot
		)

		equip_button.pressed.connect(
			_on_equip_pressed.bind(
				item.instance_id,
				slot
			)
		)

		button_row.add_child(
			equip_button
		)

	return panel


func _get_equip_button_text(
	item: HeroEquipmentItemInstance,
	slot: int
) -> String:
	if (
		item.definition.category
			== HeroEquipmentItemDefinition.Category.WEAPON
		and item.definition.is_two_handed
	):
		return "В обе руки"

	match slot:
		HeroEquipmentState.Slot.WEAPON_1:
			return "Weapon 1"

		HeroEquipmentState.Slot.WEAPON_2:
			return "Weapon 2"

		HeroEquipmentState.Slot.RING_1:
			return "Ring 1"

		HeroEquipmentState.Slot.RING_2:
			return "Ring 2"

	return "Экипировать"


func _on_equip_pressed(
	item_instance_id: StringName,
	slot: int
) -> void:
	var item := inventory_state.get_item(
		item_instance_id
	)

	if item == null:
		push_warning(
			"Inventory does not contain item '%s'."
			% item_instance_id
		)

		return

	var result := equipment_service.equip(
		progression.equipment_state,
		item,
		slot
	)

	if not result.is_successful:
		push_warning(
			"Equipment failed: %s"
			% result.failure_code
		)

		return

	state_changed.emit()


func _on_unequip_pressed(
	slot: int
) -> void:
	var result := equipment_service.unequip(
		progression.equipment_state,
		slot
	)

	if not result.is_successful:
		push_warning(
			"Unequip failed: %s"
			% result.failure_code
		)

		return

	state_changed.emit()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()
```

---

## FILE: `presentation/campaign/hero_preparation/hero_preparation_panel.gd`
```gdscript
class_name HeroPreparationPanel
extends Control


signal close_requested
signal hero_state_changed


var hero_state: CampaignHeroState
var inventory_state: CampaignInventoryState

var close_button_text: String = "Вернуться в лагерь"


func bind(
	p_hero_state: CampaignHeroState,
	p_inventory_state: CampaignInventoryState,
	p_close_button_text: String = "Вернуться в лагерь"
) -> void:
	hero_state = p_hero_state
	inventory_state = p_inventory_state
	close_button_text = p_close_button_text

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	var background := ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.055,
		0.06,
		0.07,
		1.0
	)

	add_child(
		background
	)

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left",
		24
	)

	margin.add_theme_constant_override(
		"margin_top",
		24
	)

	margin.add_theme_constant_override(
		"margin_right",
		24
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		24
	)

	add_child(
		margin
	)

	var root_column := VBoxContainer.new()

	root_column.add_theme_constant_override(
		"separation",
		16
	)

	margin.add_child(
		root_column
	)

	var header := _create_header()

	root_column.add_child(
		header
	)

	if (
		hero_state == null
		or not hero_state.is_valid_state()
	):
		var error_label := Label.new()

		error_label.text = (
			"Hero Preparation не получил "
			+"валидного CampaignHeroState."
		)

		root_column.add_child(
			error_label
		)

		return

	var main_row := HBoxContainer.new()

	main_row.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	main_row.add_theme_constant_override(
		"separation",
		20
	)

	root_column.add_child(
		main_row
	)

	var skill_grid_panel := HeroSkillGridPanel.new()

	skill_grid_panel.custom_minimum_size = Vector2(
		520,
		0
	)

	skill_grid_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	skill_grid_panel.state_changed.connect(
		_on_section_state_changed
	)

	main_row.add_child(
		skill_grid_panel
	)

	skill_grid_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var center_column := VBoxContainer.new()

	center_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	center_column.add_theme_constant_override(
		"separation",
		16
	)

	main_row.add_child(
		center_column
	)

	var summary_panel := HeroBuildSummaryPanel.new()

	summary_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	summary_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	center_column.add_child(
		summary_panel
	)

	summary_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var loadout_panel := HeroLoadoutPanel.new()

	loadout_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	loadout_panel.state_changed.connect(
		_on_section_state_changed
	)

	center_column.add_child(
		loadout_panel
	)

	loadout_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var equipment_panel := HeroEquipmentPanel.new()

	equipment_panel.custom_minimum_size = Vector2(
		430,
		0
	)

	equipment_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	equipment_panel.state_changed.connect(
		_on_section_state_changed
	)

	main_row.add_child(
		equipment_panel
	)

	equipment_panel.bind(
		hero_state.progression_state,
		inventory_state
	)


func _create_header() -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		row
	)

	var title := Label.new()

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	if (
		hero_state != null
		and hero_state.hero_definition != null
	):
		title.text = (
			"ПОДГОТОВКА ГЕРОЯ · %s"
			% hero_state.hero_definition.display_name
		)

	else:
		title.text = "ПОДГОТОВКА ГЕРОЯ"

	title.add_theme_font_size_override(
		"font_size",
		26
	)

	row.add_child(
		title
	)

	var close_button := Button.new()

	close_button.text = close_button_text

	close_button.pressed.connect(
		_on_close_pressed
	)

	row.add_child(
		close_button
	)

	return panel


func _on_section_state_changed() -> void:
	hero_state_changed.emit()

	call_deferred(
		"_rebuild_interface"
	)


func _on_close_pressed() -> void:
	close_requested.emit()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()
```

---

## FILE: `scenes/campaign/campaign_sandbox.gd`
```gdscript
class_name CampaignSandbox
extends Control


const HERO_PREPARATION_PANEL_SCENE: PackedScene = preload(
	"res://presentation/campaign/hero_preparation/"
	+"hero_preparation_panel.tscn"
)


var build_resolver := (
	HeroBattleBuildResolver.new()
)

var _is_preparation_open: bool = false



func _ready() -> void:
	if not CampaignRuntime.ensure_campaign_started():
		_show_initialization_error()
		return

	_rebuild_interface()


func _rebuild_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	if _is_preparation_open:
		_show_preparation_interface()
		return

	var background := ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.055,
		0.06,
		0.07,
		1.0
	)

	add_child(
		background
	)

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left",
		48
	)

	margin.add_theme_constant_override(
		"margin_top",
		36
	)

	margin.add_theme_constant_override(
		"margin_right",
		48
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		36
	)

	add_child(
		margin
	)

	var root_column := VBoxContainer.new()

	root_column.add_theme_constant_override(
		"separation",
		20
	)

	margin.add_child(
		root_column
	)

	var header := _create_header_panel()

	root_column.add_child(
		header
	)

	var body_row := HBoxContainer.new()

	body_row.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_theme_constant_override(
		"separation",
		20
	)

	root_column.add_child(
		body_row
	)

	var hero_panel := _create_hero_panel()

	hero_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_child(
		hero_panel
	)

	var locations_panel := _create_locations_panel()

	locations_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_child(
		locations_panel
	)

	var result_panel := _create_result_panel()

	root_column.add_child(
		result_panel
	)


func _create_header_panel() -> Control:
	var panel := PanelContainer.new()
	var content := HBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = "ЛАГЕРЬ · CAMPAIGN FLOW SANDBOX"

	title.add_theme_font_size_override(
		"font_size",
		28
	)

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	content.add_child(
		title
	)

	var reset_button := Button.new()

	reset_button.text = "Новая debug-кампания"

	reset_button.pressed.connect(
		_on_reset_campaign_pressed
	)

	content.add_child(
		reset_button
	)

	return panel


func _create_hero_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = "АКТИВНЫЙ ГЕРОЙ"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	content.add_child(
		title
	)

	var hero_state := (
		CampaignRuntime.get_active_hero_state()
	)

	if (
		hero_state == null
		or not hero_state.is_valid_state()
	):
		var error_label := Label.new()

		error_label.text = (
			"Активный герой отсутствует "
			+"или имеет ошибочное состояние."
		)

		content.add_child(
			error_label
		)

		return panel

	var hero_name := Label.new()

	hero_name.text = (
		hero_state.hero_definition.display_name
	)

	hero_name.add_theme_font_size_override(
		"font_size",
		20
	)

	content.add_child(
		hero_name
	)

	var build := build_resolver.resolve(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var summary := Label.new()

	summary.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	if build == null:
		summary.text = (
			"Hero Battle Build не удалось собрать."
		)

	else:
		summary.text = _get_build_summary(
			build
		)

	content.add_child(
		summary
	)

	var preparation_button := Button.new()

	preparation_button.text = "Подготовить героя"

	preparation_button.pressed.connect(
		_on_preparation_pressed
	)

	content.add_child(
		preparation_button
	)

	return panel


func _create_locations_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = "ДОСТУПНЫЕ ЛОКАЦИИ"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	content.add_child(
		title
	)

	for location in (
		CampaignRuntime.get_available_locations()
	):
		content.add_child(
			_create_location_card(
				location
			)
		)

	return panel


func _create_location_card(
	location: CampaignLocationDefinition
) -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		8
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = location.display_name

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	content.add_child(
		title
	)

	var description := Label.new()

	description.text = location.description

	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		description
	)

	var start_button := Button.new()

	start_button.text = "Отправиться"

	start_button.pressed.connect(
		_on_location_pressed.bind(
			location.location_id
		)
	)

	content.add_child(
		start_button
	)

	return panel


func _create_result_panel() -> Control:
	var panel := PanelContainer.new()
	var content := HBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		content
	)

	var state := CampaignRuntime.get_campaign_state()

	var title := Label.new()

	title.text = "ПОСЛЕДНИЙ ПОХОД"

	title.custom_minimum_size = Vector2(
		220,
		0
	)

	content.add_child(
		title
	)

	var result_label := Label.new()

	result_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	if (
		state == null
		or state.last_battle_result == null
	):
		result_label.text = (
			"Походов ещё не было."
		)

	else:
		var location := CampaignRuntime.get_location(
			state.last_battle_result.location_id
		)

		var location_name := (
			location.display_name
			if location != null
			else String(
				state.last_battle_result.location_id
			)
		)

		result_label.text = (
			"%s · %s · завершено боёв: %d"
			% [
				location_name,
				state
					.last_battle_result
					.get_outcome_display_name(),
				state.completed_battle_count,
			]
		)

	content.add_child(
		result_label
	)

	return panel


func _get_build_summary(
	build: HeroBattleBuild
) -> String:
	var ability_names := PackedStringArray()

	for ability in build.loadout.get_abilities():
		ability_names.append(
			"• %s"
			% ability.display_name
		)

	var item_names := PackedStringArray()

	for item in build.equipped_items:
		if (
			item == null
			or item.definition == null
		):
			continue

		item_names.append(
			"• %s"
			% item.definition.display_name
		)

	if item_names.is_empty():
		item_names.append(
			"—"
		)

	return (
		"Уровень: %d\n"
		% CampaignRuntime
			.get_active_hero_state()
			.progression_state
			.level
		+"\n"
		+"Сила: %d\n"
		% build.strength_rank
		+"Спритность: %d\n"
		% build.agility_rank
		+"Воля: %d\n"
		% build.spirit_rank
		+"\n"
		+"HP: %d\n"
		% build.combatant_definition.max_health
		+"Armor: %d\n"
		% build.combatant_definition.base_armor
		+"Stamina: %d/%d · Regen %d\n"
		% [
			build.combatant_definition.start_stamina,
			build.combatant_definition.max_stamina,
			build
				.combatant_definition
				.stamina_regeneration,
		]
		+"\n"
		+"Боевые способности:\n%s\n"
		% "\n".join(
			ability_names
		)
		+"\n"
		+"Экипировка:\n%s"
		% "\n".join(
			item_names
		)
	)


func _show_preparation_interface() -> void:
	var panel := (
		HERO_PREPARATION_PANEL_SCENE.instantiate()
		as HeroPreparationPanel
	)

	if panel == null:
		_is_preparation_open = false
		_show_initialization_error()
		return

	add_child(
		panel
	)

	panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	panel.close_requested.connect(
		_on_preparation_closed
	)

	panel.bind(
		CampaignRuntime.get_active_hero_state(),
		CampaignRuntime.get_inventory_state()
	)


func _on_preparation_pressed() -> void:
	_is_preparation_open = true

	_rebuild_interface()


func _on_preparation_closed() -> void:
	_is_preparation_open = false

	_rebuild_interface()


func _on_location_pressed(
	location_id: StringName
) -> void:
	var started := CampaignRuntime.start_location(
		location_id
	)

	if not started:
		push_warning(
			"Campaign location could not be started."
		)


func _on_reset_campaign_pressed() -> void:
	_is_preparation_open = false

	if not CampaignRuntime.start_new_campaign():
		push_warning(
			"Campaign could not be reset."
		)

		return

	_rebuild_interface()


func _show_initialization_error() -> void:
	var label := Label.new()

	label.text = (
		"Campaign Flow Sandbox "
		+"не смог создать состояние кампании."
	)

	label.position = Vector2(
		32,
		32
	)

	add_child(
		label
	)
```

---


## ✅ STATS
- Total files in tree: 231
- Readable files: 212
- Included files written: 15
- Trimmed files: 0
- Total lines written: 2849
