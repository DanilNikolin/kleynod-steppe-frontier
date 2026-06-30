# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['presentation/battle/abilities/battle_ability_panel.gd', 'presentation/battle/abilities/battle_ability_panel.tscn', 'scenes/debug/battle_grid_sandbox.gd', 'scenes/debug/battle_grid_sandbox.tscn', 'scenes/debug/controllers/battle_sandbox_interaction_controller.gd']`
- Allow addons: `False`
- Included files planned: `24`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_sabre_slash.tres
│   │       └── debug_sweeping_slash.tres
│   ├── combatants
│   │   └── debug
│   │       └── debug_steppe_raider.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   ├── loadouts
│   │   └── debug
│   │       ├── debug_sechevik_loadout.tres
│   │       ├── debug_steppe_raider_loadout.tres
│   │       └── debug_sweeping_sechevik_loadout.tres
│   └── statuses
│       └── debug
│           └── debug_cracked_defense.tres
├── core
│   └── battle
│       ├── abilities
│       │   └── ability_definition.gd
│       ├── actions
│       │   ├── battle_action_command.gd
│       │   ├── battle_action_result.gd
│       │   ├── battle_action_service.gd
│       │   └── battle_effect_result.gd
│       ├── ai
│       │   ├── basic_melee_ai_controller.gd
│       │   └── basic_melee_ai_turn_plan.gd
│       ├── combatants
│       │   ├── combatant_definition.gd
│       │   └── combatant_state.gd
│       ├── damage
│       │   └── damage_calculator.gd
│       ├── effects
│       │   ├── apply_status_effect.gd
│       │   ├── battle_effect.gd
│       │   ├── damage_effect.gd
│       │   └── effect_resolver.gd
│       ├── encounters
│       │   ├── battle_encounter_definition.gd
│       │   ├── battle_reinforcement_wave_definition.gd
│       │   └── combatant_spawn_definition.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── loadouts
│       │   └── combatant_loadout_definition.gd
│       ├── movement
│       │   ├── battle_movement_plan.gd
│       │   └── battle_movement_service.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
│       ├── session
│       │   ├── battle_session.gd
│       │   └── battle_session_factory.gd
│       ├── sides
│       │   └── battle_side_rules.gd
│       ├── stats
│       │   └── battle_stat_modifier.gd
│       ├── statuses
│       │   ├── battle_status_definition.gd
│       │   └── battle_status_instance.gd
│       ├── targeting
│       │   ├── ability_targeting_definition.gd
│       │   ├── battle_targeting_result.gd
│       │   └── battle_targeting_service.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   └── battle
│       ├── abilities
│       │   ├── battle_ability_panel.gd
│       │   └── battle_ability_panel.tscn
│       ├── actions
│       │   ├── battle_action_outcome.gd
│       │   └── battle_action_runner.gd
│       ├── ai
│       │   ├── basic_melee_ai_turn_outcome.gd
│       │   └── basic_melee_ai_turn_runner.gd
│       ├── combatants
│       │   ├── battle_combatant_presenter.gd
│       │   ├── combatant_view.gd
│       │   ├── combatant_view.tscn
│       │   ├── combatant_visual.gd
│       │   └── placeholder_combatant_visual.tscn
│       ├── grid
│       │   ├── battle_grid_overlay_presenter.gd
│       │   ├── battle_grid_view.gd
│       │   └── battle_grid_view.tscn
│       └── movement
│           ├── battle_movement_outcome.gd
│           └── battle_movement_runner.gd
├── project.godot
└── scenes
	├── debug
	│   ├── battle_grid_sandbox.gd
	│   ├── battle_grid_sandbox.tscn
	│   ├── controllers
	│   │   └── battle_sandbox_interaction_controller.gd
	│   └── presentation
	│       └── battle_debug_log_presenter.gd
	└── debug_sechevik.tres
```

---

## 📌 INCLUDED FILES

## FILE: `content/combatants/debug/debug_steppe_raider.tres`
```text
[gd_resource type="Resource" script_class="CombatantDefinition" load_steps=4 format=3 uid="uid://b4a26r5s863rx"]

[ext_resource type="Script" uid="uid://djbs8im0vo51" path="res://core/battle/combatants/combatant_definition.gd" id="1_definition"]
[ext_resource type="PackedScene" uid="uid://frc3c1tiqsau" path="res://presentation/battle/combatants/placeholder_combatant_visual.tscn" id="2_visual"]
[ext_resource type="Resource" uid="uid://byd2vij4ptc86" path="res://content/loadouts/debug/debug_steppe_raider_loadout.tres" id="3_loadout"]

[resource]
script = ExtResource("1_definition")
definition_id = &"combatant_debug_steppe_raider"
display_name = "Степной рубака"
description = "Временный противник для проверки базового ближнего боя."
default_loadout = ExtResource("3_loadout")
base_strength = 3
base_agility = 2
max_health = 12
base_armor = 2
max_stamina = 8
stamina_regeneration = 3
base_initiative = 4
visual_scene = ExtResource("2_visual")
visual_tint = Color(1, 0.32, 0.26, 1)
```

---

## FILE: `content/encounters/debug/debug_reinforcement_encounter.tres`
```text
[gd_resource type="Resource" script_class="BattleEncounterDefinition" load_steps=14 format=3 uid="uid://bcg0f3qjyahde"]

[ext_resource type="Script" uid="uid://btrmmugs1t8yq" path="res://core/battle/encounters/battle_encounter_definition.gd" id="1_encounter"]
[ext_resource type="Script" uid="uid://blbixnlpyjeaf" path="res://core/battle/encounters/combatant_spawn_definition.gd" id="2_spawn"]
[ext_resource type="Script" uid="uid://cv0u875s12ql" path="res://core/battle/encounters/battle_reinforcement_wave_definition.gd" id="3_wave"]
[ext_resource type="Resource" uid="uid://b3fmtemw5g732" path="res://scenes/debug_sechevik.tres" id="4_player"]
[ext_resource type="Resource" uid="uid://b4a26r5s863rx" path="res://content/combatants/debug/debug_steppe_raider.tres" id="5_enemy"]
[ext_resource type="Script" uid="uid://2apyueuevyjk" path="res://core/battle/sides/battle_side_rules.gd" id="6_side_rules"]

[sub_resource type="Resource" id="Resource_player_1"]
script = ExtResource("2_spawn")
instance_id = &"player_1"
combatant_definition = ExtResource("4_player")
team_id = &"team_player"
coordinate = Vector2i(1, 1)

[sub_resource type="Resource" id="Resource_player_2"]
script = ExtResource("2_spawn")
instance_id = &"player_2"
combatant_definition = ExtResource("4_player")
team_id = &"team_player"
coordinate = Vector2i(1, 3)

[sub_resource type="Resource" id="Resource_enemy_initial"]
script = ExtResource("2_spawn")
instance_id = &"enemy_initial"
combatant_definition = ExtResource("5_enemy")
team_id = &"team_enemy"
coordinate = Vector2i(7, 2)

[sub_resource type="Resource" id="Resource_enemy_wave_1"]
script = ExtResource("2_spawn")
instance_id = &"enemy_wave_1"
combatant_definition = ExtResource("5_enemy")
team_id = &"team_enemy"
coordinate = Vector2i(9, 0)
fallback_coordinates = Array[Vector2i]([Vector2i(9, 1), Vector2i(8, 0), Vector2i(8, 1)])

[sub_resource type="Resource" id="Resource_enemy_wave_2"]
script = ExtResource("2_spawn")
instance_id = &"enemy_wave_2"
combatant_definition = ExtResource("5_enemy")
team_id = &"team_enemy"
coordinate = Vector2i(9, 4)
fallback_coordinates = Array[Vector2i]([Vector2i(9, 3), Vector2i(8, 4), Vector2i(8, 3)])

[sub_resource type="Resource" id="Resource_wave_round_2"]
script = ExtResource("3_wave")
wave_id = &"enemy_reinforcements_round_2"
display_name = "Вражеское подкрепление"
combatant_spawns = Array[ExtResource("2_spawn")]([SubResource("Resource_enemy_wave_1"), SubResource("Resource_enemy_wave_2")])

[sub_resource type="Resource" id="Resource_side_rules"]
script = ExtResource("6_side_rules")

[resource]
script = ExtResource("1_encounter")
encounter_id = &"debug_reinforcements"
display_name = "Проверка подкреплений"
description = "Два бойца игрока против одного врага и волны из двух врагов на втором раунде."
side_rules = SubResource("Resource_side_rules")
combatant_spawns = Array[ExtResource("2_spawn")]([SubResource("Resource_player_1"), SubResource("Resource_player_2"), SubResource("Resource_enemy_initial")])
reinforcement_waves = Array[ExtResource("3_wave")]([SubResource("Resource_wave_round_2")])
```

---

## FILE: `content/loadouts/debug/debug_sechevik_loadout.tres`
```text
[gd_resource type="Resource" script_class="CombatantLoadoutDefinition" load_steps=5 format=3 uid="uid://cl0uv1vtgisk5"]

[ext_resource type="Script" uid="uid://bis4duqvyinf4" path="res://core/battle/loadouts/combatant_loadout_definition.gd" id="1_loadout"]
[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" uid="uid://bh0xtv0ndcte4" path="res://content/abilities/debug/debug_sabre_slash.tres" id="3_sabre"]
[ext_resource type="Resource" uid="uid://bl21cyxngsid0" path="res://content/abilities/debug/debug_sweeping_slash.tres" id="4_sweeping"]

[resource]
script = ExtResource("1_loadout")
loadout_id = &"loadout_debug_sechevik"
display_name = "Сечевик с двумя ударами"
default_ability_id = &"ability_sabre_slash"
abilities = Array[ExtResource("2_ability")]([ExtResource("3_sabre"), ExtResource("4_sweeping")])
```

---

## FILE: `content/loadouts/debug/debug_steppe_raider_loadout.tres`
```text
[gd_resource type="Resource" script_class="CombatantLoadoutDefinition" load_steps=4 format=3 uid="uid://byd2vij4ptc86"]

[ext_resource type="Script" uid="uid://bis4duqvyinf4" path="res://core/battle/loadouts/combatant_loadout_definition.gd" id="1_loadout"]
[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" uid="uid://bfgvpavod3dxb" path="res://content/abilities/debug/debug_raider_chop.tres" id="3_chop"]

[resource]
script = ExtResource("1_loadout")
loadout_id = &"loadout_debug_steppe_raider"
display_name = "Степной рубака"
default_ability_id = &"ability_raider_chop"
abilities = Array[ExtResource("2_ability")]([ExtResource("3_chop")])
```

---

## FILE: `content/statuses/debug/debug_cracked_defense.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" load_steps=4 format=3 uid="uid://biy4yp5jjdsj0"]

[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="2_modifier"]

[sub_resource type="Resource" id="Resource_armor_modifier"]
script = ExtResource("2_modifier")
amount_per_stack = -2

[resource]
script = ExtResource("1_status")
status_id = &"status_debug_cracked_defense"
display_name = "Расколотая защита"
description = "Броня снижена на 2. Повторное применение обновляет длительность."
duration_turns = 2
stat_modifiers = Array[ExtResource("2_modifier")]([SubResource("Resource_armor_modifier")])
```

---

## FILE: `core/battle/combatants/combatant_definition.gd`
```gdscript
@tool
class_name CombatantDefinition
extends Resource


@export_group("Identity")

@export
var definition_id: StringName = &""

@export
var display_name: String = "Unnamed Combatant"

@export_multiline
var description: String = ""


@export_group("Battle")

@export
var default_loadout: CombatantLoadoutDefinition


@export_group("Primary Attributes")

@export_range(0, 999, 1)
var base_strength: int = 1

@export_range(0, 999, 1)
var base_agility: int = 1

@export_range(0, 999, 1)
var base_spirit: int = 1


@export_group("Secondary Attributes")

@export_range(1, 9999, 1)
var max_health: int = 10

@export_range(0, 999, 1)
var base_armor: int = 0

@export_range(1, 999, 1)
var max_stamina: int = 10

@export_range(0, 999, 1)
var stamina_regeneration: int = 4

@export_range(0, 999, 1)
var base_initiative: int = 0

@export_range(0, 99, 1)
var base_morale: int = 2


@export_group("Presentation")

@export
var visual_scene: PackedScene

@export
var visual_tint: Color = Color.WHITE

@export
var portrait: Texture2D


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if definition_id == &"":
		errors.append("Definition ID is empty.")

	if display_name.strip_edges().is_empty():
		errors.append("Display name is empty.")

	if max_health <= 0:
		errors.append("Maximum health must be greater than zero.")

	if max_stamina <= 0:
		errors.append("Maximum stamina must be greater than zero.")

	if stamina_regeneration < 0:
		errors.append("Stamina regeneration cannot be negative.")

	if default_loadout == null:
		errors.append(
			"Default combatant loadout is not assigned."
		)

	elif not default_loadout.is_valid_definition():
		errors.append(
			"Default combatant loadout is invalid."
		)

	if visual_scene == null:
		errors.append("Visual scene is not assigned.")

	return errors
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
var rows: int = 5

@export_range(1, 100, 1)
var columns: int = 10

@export_group("Sides")

@export
var side_rules: BattleSideRules = BattleSideRules.new()

@export_group("Initial Combatants")

@export
var combatant_spawns: Array[CombatantSpawnDefinition] = []


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
	var used_initial_coordinates: Dictionary = {}
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

## FILE: `core/battle/encounters/battle_reinforcement_wave_definition.gd`
```gdscript
@tool
class_name BattleReinforcementWaveDefinition
extends Resource


@export_group("Identity")

@export
var wave_id: StringName = &""

@export
var display_name: String = "Reinforcement Wave"


@export_group("Schedule")

@export_range(1, 1000, 1)
var round_number: int = 2


@export_group("Combatants")

@export
var combatant_spawns: Array[CombatantSpawnDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if wave_id == &"":
		errors.append(
			"Reinforcement wave ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Reinforcement wave display name is empty."
		)

	if round_number <= 0:
		errors.append(
			"Reinforcement wave round must be positive."
		)

	if combatant_spawns.is_empty():
		errors.append(
			"Reinforcement wave has no combatants."
		)

	var used_instance_ids: Dictionary = {}

	for spawn_index in range(
		combatant_spawns.size()
	):
		var spawn := combatant_spawns[spawn_index]

		if spawn == null:
			errors.append(
				"Reinforcement spawn at index %d is null."
				% spawn_index
			)

			continue

		for spawn_error in spawn.get_validation_errors():
			errors.append(
				"Reinforcement spawn %d: %s"
				% [
					spawn_index,
					spawn_error,
				]
			)

		if spawn.instance_id == &"":
			continue

		if used_instance_ids.has(
			spawn.instance_id
		):
			errors.append(
				"Duplicate reinforcement instance ID: %s."
				% spawn.instance_id
			)
		else:
			used_instance_ids[
				spawn.instance_id
			] = true

	return errors
```

---

## FILE: `core/battle/encounters/combatant_spawn_definition.gd`
```gdscript
@tool
class_name CombatantSpawnDefinition
extends Resource


@export_group("Identity")

@export
var instance_id: StringName = &""

@export
var combatant_definition: CombatantDefinition

@export
var team_id: StringName = &""


@export_group("Loadout")

@export
var loadout_override: CombatantLoadoutDefinition


@export_group("Placement")

@export
var coordinate: Vector2i = Vector2i.ZERO

@export
var fallback_coordinates: Array[Vector2i] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if instance_id == &"":
		errors.append(
			"Combatant instance ID is empty."
		)

	if combatant_definition == null:
		errors.append(
			"Combatant definition is not assigned."
		)

	elif not combatant_definition.is_valid_definition():
		errors.append(
			"Combatant definition is invalid."
		)

	if team_id == &"":
		errors.append(
			"Team ID is empty."
		)

	var effective_loadout := (
		get_effective_loadout()
	)

	if effective_loadout == null:
		errors.append(
			"Combatant loadout is not assigned."
		)

	elif not effective_loadout.is_valid_definition():
		errors.append(
			"Combatant loadout is invalid."
		)

	var used_coordinates: Dictionary = {
		coordinate: true,
	}

	for fallback_coordinate in fallback_coordinates:
		if used_coordinates.has(
			fallback_coordinate
		):
			errors.append(
				"Duplicate spawn candidate coordinate: %s."
				% fallback_coordinate
			)

			continue

		used_coordinates[
			fallback_coordinate
		] = true

	return errors
func get_effective_loadout() -> CombatantLoadoutDefinition:
	if loadout_override != null:
		return loadout_override

	if combatant_definition == null:
		return null

	return combatant_definition.default_loadout



func get_candidate_coordinates() -> Array[Vector2i]:
	var result: Array[Vector2i] = [
		coordinate,
	]

	for fallback_coordinate in fallback_coordinates:
		if result.has(
			fallback_coordinate
		):
			continue

		result.append(
			fallback_coordinate
		)

	return result
```

---

## FILE: `core/battle/sides/battle_side_rules.gd`
```gdscript
@tool
class_name BattleSideRules
extends Resource


@export_group("Teams")

@export
var left_team_id: StringName = &"team_player"

@export
var right_team_id: StringName = &"team_enemy"


@export_group("Divider")

## Первый столбец правой стороны.
## При значении 5 левая сторона занимает 0–4,
## правая сторона занимает 5–9.
@export_range(1, 99, 1)
var divider_column: int = 5


func is_valid_for_grid(
	columns: int
) -> bool:
	return get_validation_errors(
		columns
	).is_empty()


func get_validation_errors(
	columns: int
) -> PackedStringArray:
	var errors := PackedStringArray()

	if left_team_id == &"":
		errors.append(
			"Left team ID is empty."
		)

	if right_team_id == &"":
		errors.append(
			"Right team ID is empty."
		)

	if (
		left_team_id != &""
		and left_team_id == right_team_id
	):
		errors.append(
			"Left and right team IDs must be different."
		)

	if columns < 2:
		errors.append(
			"Side-based grid requires at least two columns."
		)

	elif (
		divider_column <= 0
		or divider_column >= columns
	):
		errors.append(
			"Divider column must be inside the grid."
		)

	return errors


func is_team_supported(
	team_id: StringName
) -> bool:
	return (
		team_id == left_team_id
		or team_id == right_team_id
	)


func is_coordinate_allowed(
	team_id: StringName,
	coordinate: Vector2i,
	rows: int,
	columns: int
) -> bool:
	if (
		coordinate.x < 0
		or coordinate.x >= columns
		or coordinate.y < 0
		or coordinate.y >= rows
	):
		return false

	if team_id == left_team_id:
		return coordinate.x < divider_column

	if team_id == right_team_id:
		return coordinate.x >= divider_column

	return false


func get_forward_direction(
	team_id: StringName
) -> int:
	if team_id == left_team_id:
		return 1

	if team_id == right_team_id:
		return -1

	return 0
```

---

## FILE: `core/battle/stats/battle_stat_modifier.gd`
```gdscript
@tool
class_name BattleStatModifier
extends Resource


enum Stat {
	ARMOR,
	STRENGTH,
	AGILITY,
	SPIRIT,
	INITIATIVE,
}


@export_group("Stat")

@export
var stat: Stat = Stat.ARMOR

## Изменение характеристики за каждый стак статуса.
## Например, -2 брони при одном стаке.
@export_range(-999, 999, 1)
var amount_per_stack: int = 0


func get_total_amount(
	stack_count: int
) -> int:
	return (
		amount_per_stack
		* maxi(0, stack_count)
	)


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if amount_per_stack == 0:
		errors.append(
			"Stat modifier amount cannot be zero."
		)

	return errors
```

---

## FILE: `core/battle/statuses/battle_status_definition.gd`
```gdscript
@tool
class_name BattleStatusDefinition
extends Resource


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


@export_group("Stat Modifiers")

@export
var stat_modifiers: Array[BattleStatModifier] = []


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

	return errors
```

---

## FILE: `presentation/battle/abilities/battle_ability_panel.gd`
```gdscript
class_name BattleAbilityPanel
extends PanelContainer


signal ability_selected(
	ability: AbilityDefinition
)


@onready
var actor_label: Label = (
	$ContentMargin/VBoxContainer/ActorLabel
)

@onready
var ability_grid: GridContainer = (
	$ContentMargin/VBoxContainer/AbilityGrid
)

@onready
var description_label: Label = (
	$ContentMargin/VBoxContainer/DescriptionLabel
)


var _combatant: CombatantState

var _abilities: Array[AbilityDefinition] = []
var _buttons: Array[Button] = []

var _selected_ability_id: StringName = &""
var _interactable: bool = true

var _button_group: ButtonGroup

var _stamina_changed_callback: Callable


func _ready() -> void:
	_stamina_changed_callback = Callable(
		self,
		"_on_combatant_stamina_changed"
	)

	visible = false


func bind_combatant(
	combatant: CombatantState,
	selected_ability: AbilityDefinition = null
) -> void:
	_disconnect_combatant_signals()

	_combatant = combatant

	if (
		_combatant == null
		or not _combatant.is_alive
		or _combatant.loadout == null
	):
		clear_combatant()
		return

	_combatant.stamina_changed.connect(
		_stamina_changed_callback
	)

	actor_label.text = (
		"%s — способности"
		% _combatant.definition.display_name
	)

	_rebuild_buttons()

	if (
		selected_ability != null
		and _combatant.has_ability(
			selected_ability.ability_id
		)
	):
		_selected_ability_id = (
			selected_ability.ability_id
		)

	else:
		var default_ability := (
			_combatant.loadout
			.get_default_ability()
		)

		_selected_ability_id = (
			default_ability.ability_id
			if default_ability != null
			else &""
		)

	_refresh_visual_state()

	visible = true


func clear_combatant() -> void:
	_disconnect_combatant_signals()

	_combatant = null
	_selected_ability_id = &""

	_clear_buttons()

	actor_label.text = ""
	description_label.text = ""

	visible = false


func set_selected_ability(
	ability: AbilityDefinition
) -> bool:
	if _combatant == null:
		return false

	if ability == null:
		return false

	if not _combatant.has_ability(
		ability.ability_id
	):
		return false

	_selected_ability_id = (
		ability.ability_id
	)

	_refresh_visual_state()
	return true


func select_ability_by_index(
	ability_index: int,
	emit_selection_signal: bool = true
) -> bool:
	if not _interactable:
		return false

	if (
		ability_index < 0
		or ability_index >= _abilities.size()
	):
		return false

	if _combatant == null:
		return false

	var ability := _abilities[
		ability_index
	]

	if ability == null:
		return false

	if not _combatant.can_spend_stamina(
		ability.stamina_cost
	):
		return false

	_selected_ability_id = ability.ability_id

	_refresh_visual_state()

	if emit_selection_signal:
		ability_selected.emit(
			ability
		)

	return true


func set_interactable(
	interactable: bool
) -> void:
	_interactable = interactable
	_refresh_visual_state()


func get_selected_ability() -> AbilityDefinition:
	for ability in _abilities:
		if (
			ability != null
			and ability.ability_id
			== _selected_ability_id
		):
			return ability

	return null


func _rebuild_buttons() -> void:
	_clear_buttons()

	if _combatant == null:
		return

	_abilities = (
		_combatant.loadout
		.get_abilities()
	)

	_button_group = ButtonGroup.new()
	_button_group.allow_unpress = false

	for ability_index in range(
		_abilities.size()
	):
		var ability := _abilities[
			ability_index
		]

		if ability == null:
			continue

		var button := Button.new()

		button.custom_minimum_size = Vector2(
			220.0,
			72.0
		)

		button.toggle_mode = true
		button.button_group = _button_group

		button.text = (
			"%d. %s\nВыносливость: %d"
			% [
				ability_index + 1,
				ability.display_name,
				ability.stamina_cost,
			]
		)

		button.tooltip_text = (
			ability.description
		)

		button.pressed.connect(
			_on_ability_button_pressed.bind(
				ability_index
			)
		)

		ability_grid.add_child(
			button
		)

		_buttons.append(
			button
		)


func _clear_buttons() -> void:
	for child in ability_grid.get_children():
		ability_grid.remove_child(
			child
		)

		child.queue_free()

	_buttons.clear()
	_abilities.clear()

	_button_group = null


func _refresh_visual_state() -> void:
	if _combatant == null:
		return

	for ability_index in range(
		_buttons.size()
	):
		if ability_index >= _abilities.size():
			continue

		var button := _buttons[
			ability_index
		]

		var ability := _abilities[
			ability_index
		]

		if button == null or ability == null:
			continue

		var affordable := (
			_combatant.can_spend_stamina(
				ability.stamina_cost
			)
		)

		button.disabled = (
			not _interactable
			or not affordable
		)

		button.set_pressed_no_signal(
			ability.ability_id
			== _selected_ability_id
		)

	_refresh_description()


func _refresh_description() -> void:
	var selected_ability := (
		get_selected_ability()
	)

	if selected_ability == null:
		description_label.text = (
			"Способность не выбрана."
		)

		return

	var affordability_text := (
		"доступно"
		if (
			_combatant != null
			and _combatant.can_spend_stamina(
				selected_ability.stamina_cost
			)
		)
		else "не хватает выносливости"
	)

	description_label.text = (
		"Выбрано: %s | Цена: %d | %s\n%s"
		% [
			selected_ability.display_name,
			selected_ability.stamina_cost,
			affordability_text,
			selected_ability.description,
		]
	)


func _disconnect_combatant_signals() -> void:
	if _combatant == null:
		return

	if not _stamina_changed_callback.is_valid():
		return

	if _combatant.is_connected(
		&"stamina_changed",
		_stamina_changed_callback
	):
		_combatant.disconnect(
			&"stamina_changed",
			_stamina_changed_callback
		)


func _on_ability_button_pressed(
	ability_index: int
) -> void:
	select_ability_by_index(
		ability_index,
		true
	)


func _on_combatant_stamina_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	_refresh_visual_state()
```

---

## FILE: `presentation/battle/abilities/battle_ability_panel.tscn`
```text
[gd_scene load_steps=2 format=3 uid="uid://bgg8ap77su8v1"]

[ext_resource type="Script" uid="uid://gy6q3opjvjqv" path="res://presentation/battle/abilities/battle_ability_panel.gd" id="1_panel"]

[node name="BattleAbilityPanel" type="PanelContainer"]
visible = false
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -500.0
offset_top = -230.0
offset_right = 500.0
offset_bottom = -24.0
grow_horizontal = 2
grow_vertical = 0
script = ExtResource("1_panel")

[node name="ContentMargin" type="MarginContainer" parent="."]
layout_mode = 2
theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 12
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 12

[node name="VBoxContainer" type="VBoxContainer" parent="ContentMargin"]
layout_mode = 2
theme_override_constants/separation = 8

[node name="ActorLabel" type="Label" parent="ContentMargin/VBoxContainer"]
layout_mode = 2
text = "Способности"
horizontal_alignment = 1

[node name="AbilityGrid" type="GridContainer" parent="ContentMargin/VBoxContainer"]
layout_mode = 2
theme_override_constants/h_separation = 8
theme_override_constants/v_separation = 8
columns = 4

[node name="DescriptionLabel" type="Label" parent="ContentMargin/VBoxContainer"]
custom_minimum_size = Vector2(0, 46)
layout_mode = 2
text = "Способность не выбрана."
horizontal_alignment = 1
vertical_alignment = 1
autowrap_mode = 2
```

---

## FILE: `presentation/battle/combatants/combatant_view.gd`
```gdscript
@tool
class_name CombatantView
extends Node2D


signal movement_finished


@export_group("Movement")

@export_range(0.01, 2.0, 0.01)
var movement_duration: float = 0.16


@export_group("Footprint")

@export
var show_footprint: bool = true:
	set(value):
		show_footprint = value
		queue_redraw()

@export_range(4.0, 100.0, 1.0)
var footprint_radius: float = 28.0:
	set(value):
		footprint_radius = maxf(4.0, value)
		queue_redraw()

@export
var footprint_color: Color = Color(0.0, 0.0, 0.0, 0.22):
	set(value):
		footprint_color = value
		queue_redraw()


@export_group("Selection")

@export
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()

@export
var hovered: bool = false:
	set(value):
		hovered = value
		queue_redraw()

@export
var selected_color: Color = Color(1.0, 0.84, 0.25, 0.95):
	set(value):
		selected_color = value
		queue_redraw()

@export
var hovered_color: Color = Color(0.75, 0.9, 1.0, 0.85):
	set(value):
		hovered_color = value
		queue_redraw()

@export_range(1.0, 12.0, 0.5)
var outline_width: float = 3.0:
	set(value):
		outline_width = maxf(1.0, value)
		queue_redraw()


@onready
var visual_container: Node2D = $VisualContainer

@onready
var name_label: Label = (
	$InterfaceRoot/VBoxContainer/NameLabel
)

@onready
var health_bar: ProgressBar = (
	$InterfaceRoot/VBoxContainer/HealthRow/HealthBar
)

@onready
var health_value_label: Label = (
	$InterfaceRoot/VBoxContainer/HealthRow/HealthValueLabel
)

@onready
var stamina_bar: ProgressBar = (
	$InterfaceRoot/VBoxContainer/StaminaRow/StaminaBar
)

@onready
var stamina_value_label: Label = (
	$InterfaceRoot/VBoxContainer/StaminaRow/StaminaValueLabel
)


var state: CombatantState
var visual: CombatantVisual

var _movement_tween: Tween


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	if show_footprint:
		draw_circle(
			Vector2.ZERO,
			footprint_radius,
			footprint_color,
			true
		)

	if hovered:
		draw_circle(
			Vector2.ZERO,
			footprint_radius,
			hovered_color,
			false,
			outline_width,
			true
		)

	if selected:
		draw_circle(
			Vector2.ZERO,
			footprint_radius + 3.0,
			selected_color,
			false,
			outline_width,
			true
		)


func bind_state(new_state: CombatantState) -> void:
	if state == new_state:
		refresh_from_state()
		return

	_disconnect_state_signals()

	state = new_state

	_connect_state_signals()
	_rebuild_visual()
	refresh_from_state()


func _connect_state_signals() -> void:
	if state == null:
		return

	state.connect(
		&"health_changed",
		Callable(self, "_on_health_changed")
	)

	state.connect(
		&"stamina_changed",
		Callable(self, "_on_stamina_changed")
	)

	state.connect(
		&"morale_changed",
		Callable(self, "_on_morale_changed")
	)

	state.connect(
		&"died",
		Callable(self, "_on_died")
	)


func _disconnect_state_signals() -> void:
	if state == null:
		return

	var connections: Array[Array] = [
		[
			&"health_changed",
			Callable(self, "_on_health_changed")
		],
		[
			&"stamina_changed",
			Callable(self, "_on_stamina_changed")
		],
		[
			&"morale_changed",
			Callable(self, "_on_morale_changed")
		],
		[
			&"died",
			Callable(self, "_on_died")
		],
	]

	for connection_data in connections:
		var signal_name: StringName = connection_data[0]
		var callback: Callable = connection_data[1]

		if state.is_connected(signal_name, callback):
			state.disconnect(signal_name, callback)


func _rebuild_visual() -> void:
	if visual != null:
		visual.queue_free()
		visual = null

	if state == null:
		return

	var definition := state.definition

	if definition == null:
		return

	if definition.visual_scene == null:
		push_error(
			"Combatant '%s' has no visual scene."
			% state.instance_id
		)
		return

	var visual_instance := (
		definition.visual_scene.instantiate()
	)

	if not (visual_instance is CombatantVisual):
		push_error(
			"Visual scene for '%s' must inherit CombatantVisual."
			% state.instance_id
		)

		visual_instance.queue_free()
		return

	visual = visual_instance as CombatantVisual
	visual_container.add_child(visual)

	visual.modulate = definition.visual_tint
	visual.play_idle()


func refresh_from_state() -> void:
	if not is_node_ready():
		return

	if state == null:
		name_label.text = "No Combatant"

		health_bar.max_value = 1
		health_bar.value = 0
		health_value_label.text = "0 / 0"

		stamina_bar.max_value = 1
		stamina_bar.value = 0
		stamina_value_label.text = "0 / 0"

		return

	name_label.text = state.definition.display_name

	health_bar.max_value = state.max_health
	health_bar.value = state.current_health

	health_value_label.text = "%d / %d" % [
		state.current_health,
		state.max_health,
	]

	stamina_bar.max_value = state.max_stamina
	stamina_bar.value = state.current_stamina

	stamina_value_label.text = "%d / %d" % [
		state.current_stamina,
		state.max_stamina,
	]


func set_selected_state(value: bool) -> void:
	selected = value


func set_hovered_state(value: bool) -> void:
	hovered = value


func set_facing_direction(direction: int) -> void:
	if visual != null:
		visual.set_facing_direction(direction)


func play_visual_animation(
	animation_key: StringName,
	fallback_key: StringName = &"idle"
) -> bool:
	if visual == null:
		return false

	return visual.play_animation(
		animation_key,
		fallback_key
	)


func snap_to_local_position(
	target_position: Vector2
) -> void:
	_stop_movement_tween()
	position = target_position


func move_to_local_position(
	target_position: Vector2,
	animated: bool = true
) -> void:
	var local_path: Array[Vector2] = [
		target_position
	]

	move_along_local_path(
		local_path,
		animated
	)


func move_along_local_path(
	local_path: Array[Vector2],
	animated: bool = true
) -> void:
	_stop_movement_tween()

	if local_path.is_empty():
		movement_finished.emit()
		return

	if not animated:
		for target_position in local_path:
			_face_toward_position(
				target_position
			)

			position = target_position

		movement_finished.emit()
		return

	if visual != null:
		visual.play_move()

	_movement_tween = create_tween()

	_movement_tween.set_trans(
		Tween.TRANS_QUAD
	)

	_movement_tween.set_ease(
		Tween.EASE_IN_OUT
	)

	for target_position in local_path:
		_movement_tween.tween_callback(
			Callable(
				self,
				"_face_toward_position"
			).bind(target_position)
		)

		_movement_tween.tween_property(
			self,
			"position",
			target_position,
			movement_duration
		)

	_movement_tween.finished.connect(
		_on_movement_tween_finished
	)


func _face_toward_position(
	target_position: Vector2
) -> void:
	var horizontal_distance := (
		target_position.x - position.x
	)

	if is_zero_approx(horizontal_distance):
		return

	set_facing_direction(
		1 if horizontal_distance > 0.0 else -1
	)


func _stop_movement_tween() -> void:
	if _movement_tween == null:
		return

	if _movement_tween.is_valid():
		_movement_tween.kill()

	_movement_tween = null


func _on_movement_tween_finished() -> void:
	_movement_tween = null

	if visual != null:
		visual.play_idle()

	movement_finished.emit()


func _on_health_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_stamina_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_morale_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_died() -> void:
	if visual != null:
		visual.play_death()

	refresh_from_state()
```

---

## FILE: `presentation/battle/combatants/combatant_view.tscn`
```text
[gd_scene load_steps=2 format=3 uid="uid://dogan5u1eqtfl"]

[ext_resource type="Script" uid="uid://c7bb0h5o5mji0" path="res://presentation/battle/combatants/combatant_view.gd" id="1_view"]

[node name="CombatantView" type="Node2D"]
script = ExtResource("1_view")

[node name="VisualContainer" type="Node2D" parent="."]

[node name="EffectsAnchor" type="Marker2D" parent="."]
position = Vector2(0, -38)

[node name="StatusAnchor" type="Node2D" parent="."]
position = Vector2(0, -92)

[node name="IntentAnchor" type="Node2D" parent="."]
position = Vector2(0, -125)

[node name="InterfaceRoot" type="Control" parent="."]
layout_mode = 3
anchors_preset = 0
offset_left = -75.0
offset_top = -128.0
offset_right = 75.0
offset_bottom = -72.0
mouse_filter = 2

[node name="VBoxContainer" type="VBoxContainer" parent="InterfaceRoot"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 2

[node name="NameLabel" type="Label" parent="InterfaceRoot/VBoxContainer"]
layout_mode = 2
text = "Combatant"
horizontal_alignment = 1

[node name="HealthRow" type="HBoxContainer" parent="InterfaceRoot/VBoxContainer"]
layout_mode = 2
theme_override_constants/separation = 4

[node name="HealthCaption" type="Label" parent="InterfaceRoot/VBoxContainer/HealthRow"]
layout_mode = 2
text = "HP"

[node name="HealthBar" type="ProgressBar" parent="InterfaceRoot/VBoxContainer/HealthRow"]
custom_minimum_size = Vector2(82, 14)
layout_mode = 2
size_flags_horizontal = 3
mouse_filter = 2
max_value = 24.0
value = 24.0
show_percentage = false

[node name="HealthValueLabel" type="Label" parent="InterfaceRoot/VBoxContainer/HealthRow"]
custom_minimum_size = Vector2(46, 0)
layout_mode = 2
text = "24 / 24"
horizontal_alignment = 2

[node name="StaminaRow" type="HBoxContainer" parent="InterfaceRoot/VBoxContainer"]
layout_mode = 2
theme_override_constants/separation = 4

[node name="StaminaCaption" type="Label" parent="InterfaceRoot/VBoxContainer/StaminaRow"]
layout_mode = 2
text = "ST"

[node name="StaminaBar" type="ProgressBar" parent="InterfaceRoot/VBoxContainer/StaminaRow"]
custom_minimum_size = Vector2(82, 14)
layout_mode = 2
size_flags_horizontal = 3
mouse_filter = 2
max_value = 10.0
value = 10.0
show_percentage = false

[node name="StaminaValueLabel" type="Label" parent="InterfaceRoot/VBoxContainer/StaminaRow"]
custom_minimum_size = Vector2(46, 0)
layout_mode = 2
text = "10 / 10"
horizontal_alignment = 2
```

---

## FILE: `presentation/battle/combatants/placeholder_combatant_visual.tscn`
```text
[gd_scene load_steps=2 format=3 uid="uid://frc3c1tiqsau"]

[ext_resource type="Script" uid="uid://dd83mhrnk6jbc" path="res://presentation/battle/combatants/combatant_visual.gd" id="1_visual"]

[node name="PlaceholderCombatantVisual" type="Node2D"]
script = ExtResource("1_visual")

[node name="VisualRoot" type="Node2D" parent="."]

[node name="Shadow" type="Polygon2D" parent="VisualRoot"]
color = Color(0.08, 0.08, 0.1, 0.45)
polygon = PackedVector2Array(-28, 3, -18, -4, 18, -4, 28, 3, 18, 10, -18, 10)

[node name="Body" type="Polygon2D" parent="VisualRoot"]
polygon = PackedVector2Array(-23, 0, -20, -35, -12, -53, 12, -53, 20, -35, 23, 0)

[node name="Head" type="Polygon2D" parent="VisualRoot"]
color = Color(0.92, 0.92, 0.92, 1)
polygon = PackedVector2Array(-12, -53, -9, -66, 0, -72, 9, -66, 12, -53, 8, -44, -8, -44)

[node name="Weapon" type="Line2D" parent="VisualRoot"]
points = PackedVector2Array(10, -45, 36, -73)
width = 6.0
default_color = Color(0.9, 0.9, 0.9, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="Symbol" type="Label" parent="VisualRoot"]
offset_left = -8.0
offset_top = -43.0
offset_right = 8.0
offset_bottom = -17.0
text = "С"
horizontal_alignment = 1
vertical_alignment = 1

[node name="HitAnchor" type="Marker2D" parent="."]
position = Vector2(0, -42)

[node name="ProjectileAnchor" type="Marker2D" parent="."]
position = Vector2(32, -70)

[node name="EffectsAnchor" type="Marker2D" parent="."]
position = Vector2(0, -30)

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
```

---

## FILE: `presentation/battle/grid/battle_grid_view.gd`
```gdscript
@tool
class_name BattleGridView
extends Node2D


signal cell_hovered(coordinate: Vector2i)
signal cell_clicked(coordinate: Vector2i, mouse_button: int)


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)


@export_group("Grid Size")

@export_range(1, 20, 1)
var rows: int = 5:
	set(value):
		rows = maxi(1, value)
		queue_redraw()


@export_range(1, 30, 1)
var columns: int = 10:
	set(value):
		columns = maxi(1, value)
		divider_column = clampi(divider_column, 0, columns)
		queue_redraw()


@export
var cell_size: Vector2 = Vector2(96.0, 84.0):
	set(value):
		cell_size = Vector2(
			maxf(1.0, value.x),
			maxf(1.0, value.y)
		)
		queue_redraw()


@export
var cell_gap: Vector2 = Vector2(8.0, 8.0):
	set(value):
		cell_gap = Vector2(
			maxf(0.0, value.x),
			maxf(0.0, value.y)
		)
		queue_redraw()


@export
var center_on_node: bool = true:
	set(value):
		center_on_node = value
		queue_redraw()


@export
var origin_offset: Vector2 = Vector2.ZERO:
	set(value):
		origin_offset = value
		queue_redraw()


@export_group("Sides")

@export_range(0, 30, 1)
var divider_column: int = 5:
	set(value):
		divider_column = clampi(value, 0, columns)
		queue_redraw()


@export
var player_side_color: Color = Color(0.12, 0.24, 0.32, 0.72):
	set(value):
		player_side_color = value
		queue_redraw()


@export
var enemy_side_color: Color = Color(0.34, 0.14, 0.14, 0.72):
	set(value):
		enemy_side_color = value
		queue_redraw()


@export_group("Lines")

@export
var grid_line_color: Color = Color(0.72, 0.76, 0.79, 0.72):
	set(value):
		grid_line_color = value
		queue_redraw()


@export_range(0.5, 10.0, 0.5)
var grid_line_width: float = 2.0:
	set(value):
		grid_line_width = maxf(0.5, value)
		queue_redraw()


@export
var divider_color: Color = Color(0.95, 0.82, 0.38, 0.92):
	set(value):
		divider_color = value
		queue_redraw()


@export_range(1.0, 16.0, 0.5)
var divider_width: float = 4.0:
	set(value):
		divider_width = maxf(1.0, value)
		queue_redraw()


@export_group("Interaction")

@export
var hover_color: Color = Color(1.0, 1.0, 1.0, 0.16):
	set(value):
		hover_color = value
		queue_redraw()


@export
var selected_color: Color = Color(1.0, 0.86, 0.30, 0.90):
	set(value):
		selected_color = value
		queue_redraw()


@export_range(1.0, 12.0, 0.5)
var selected_line_width: float = 4.0:
	set(value):
		selected_line_width = maxf(1.0, value)
		queue_redraw()

@export_group("Targeting Debug")

@export
var targeting_aim_marker_color: Color = Color(
	0.30,
	0.90,
	1.0,
	0.95
):
	set(value):
		targeting_aim_marker_color = value
		queue_redraw()

@export_range(2.0, 20.0, 0.5)
var targeting_aim_marker_radius: float = 5.0:
	set(value):
		targeting_aim_marker_radius = maxf(
			2.0,
			value
		)

		queue_redraw()

@export
var targeting_impact_marker_color: Color = Color(
	1.0,
	0.82,
	0.18,
	1.0
):
	set(value):
		targeting_impact_marker_color = value
		queue_redraw()

@export_range(4.0, 30.0, 0.5)
var targeting_impact_marker_size: float = 12.0:
	set(value):
		targeting_impact_marker_size = maxf(
			4.0,
			value
		)

		queue_redraw()

@export_range(1.0, 8.0, 0.5)
var targeting_impact_line_width: float = 3.0:
	set(value):
		targeting_impact_line_width = maxf(
			1.0,
			value
		)

		queue_redraw()

var hovered_cell: Vector2i = INVALID_COORDINATE
var selected_cell: Vector2i = INVALID_COORDINATE

var _cell_overlays: Dictionary = {}
var _targeting_aim_coordinates: Array[Vector2i] = []
var _targeting_impact_coordinates: Array[Vector2i] = []


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	for row in range(rows):
		for column in range(columns):
			var coordinate := Vector2i(column, row)
			var cell_rect := get_cell_rect(coordinate)

			var base_color := (
				player_side_color
				if column < divider_column
				else enemy_side_color
			)

			draw_rect(cell_rect, base_color, true)
			draw_rect(
				cell_rect,
				grid_line_color,
				false,
				grid_line_width,
				true
			)

			if _cell_overlays.has(coordinate):
				var overlay_color: Color = _cell_overlays[coordinate]
				draw_rect(cell_rect, overlay_color, true)

			if coordinate == hovered_cell:
				draw_rect(cell_rect, hover_color, true)

			if coordinate == selected_cell:
				draw_rect(
					cell_rect,
					selected_color,
					false,
					selected_line_width,
					true
				)

	_draw_side_divider()

	_draw_targeting_debug_markers()


func _draw_side_divider() -> void:
	if divider_column <= 0 or divider_column >= columns:
		return

	var origin := get_grid_origin()
	var divider_x := (
		origin.x
		+ divider_column * (cell_size.x + cell_gap.x)
		- cell_gap.x * 0.5
	)

	var grid_size := get_grid_size()

	draw_line(
		Vector2(divider_x, origin.y),
		Vector2(divider_x, origin.y + grid_size.y),
		divider_color,
		divider_width,
		true
	)

func _draw_targeting_debug_markers() -> void:
	for coordinate in (
		_targeting_aim_coordinates
	):
		if not is_valid_coordinate(
			coordinate
		):
			continue

		var cell_rect := get_cell_rect(
			coordinate
		)

		# Точка в левом верхнем углу клетки,
		# чтобы её не закрывал персонаж.
		var marker_position := (
			cell_rect.position
			+ Vector2(12.0, 12.0)
		)

		draw_circle(
			marker_position,
			targeting_aim_marker_radius,
			targeting_aim_marker_color,
			true
		)

	for coordinate in (
		_targeting_impact_coordinates
	):
		if not is_valid_coordinate(
			coordinate
		):
			continue

		var cell_rect := get_cell_rect(
			coordinate
		)

		# Крестик справа сверху, отдельно
		# от aim-точки.
		var marker_position := (
			cell_rect.position
			+ Vector2(
				cell_rect.size.x - 14.0,
				14.0
			)
		)

		var half_size := (
			targeting_impact_marker_size
			* 0.5
		)

		draw_line(
			marker_position
			+ Vector2(
				- half_size,
				- half_size
			),
			marker_position
			+ Vector2(
				half_size,
				half_size
			),
			targeting_impact_marker_color,
			targeting_impact_line_width,
			true
		)

		draw_line(
			marker_position
			+ Vector2(
				- half_size,
				half_size
			),
			marker_position
			+ Vector2(
				half_size,
				- half_size
			),
			targeting_impact_marker_color,
			targeting_impact_line_width,
			true
		)


func set_targeting_debug_markers(
	aim_coordinates: Array[Vector2i],
	impact_coordinates: Array[Vector2i]
) -> void:
	_targeting_aim_coordinates.clear()
	_targeting_impact_coordinates.clear()

	for coordinate in aim_coordinates:
		if not is_valid_coordinate(
			coordinate
		):
			continue

		if _targeting_aim_coordinates.has(
			coordinate
		):
			continue

		_targeting_aim_coordinates.append(
			coordinate
		)

	for coordinate in impact_coordinates:
		if not is_valid_coordinate(
			coordinate
		):
			continue

		if _targeting_impact_coordinates.has(
			coordinate
		):
			continue

		_targeting_impact_coordinates.append(
			coordinate
		)

	queue_redraw()


func clear_targeting_debug_markers() -> void:
	if (
		_targeting_aim_coordinates.is_empty()
		and _targeting_impact_coordinates.is_empty()
	):
		return

	_targeting_aim_coordinates.clear()
	_targeting_impact_coordinates.clear()

	queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseMotion:
		_update_hovered_cell(coordinate_from_local_position(
			get_local_mouse_position()
		))
		return

	if event is InputEventMouseButton and event.pressed:
		var coordinate := coordinate_from_local_position(
			get_local_mouse_position()
		)

		if coordinate == INVALID_COORDINATE:
			return

		cell_clicked.emit(coordinate, event.button_index)


func _update_hovered_cell(coordinate: Vector2i) -> void:
	if hovered_cell == coordinate:
		return

	hovered_cell = coordinate
	cell_hovered.emit(coordinate)
	queue_redraw()


func get_grid_size() -> Vector2:
	return Vector2(
		columns * cell_size.x + maxi(columns - 1, 0) * cell_gap.x,
		rows * cell_size.y + maxi(rows - 1, 0) * cell_gap.y
	)


func get_grid_origin() -> Vector2:
	if not center_on_node:
		return origin_offset

	return origin_offset - get_grid_size() * 0.5


func get_cell_rect(coordinate: Vector2i) -> Rect2:
	if not is_valid_coordinate(coordinate):
		return Rect2()

	var origin := get_grid_origin()
	var step := cell_size + cell_gap

	var cell_position := origin + Vector2(
		coordinate.x * step.x,
		coordinate.y * step.y
	)

	return Rect2(cell_position, cell_size)


func get_cell_center(coordinate: Vector2i) -> Vector2:
	return get_cell_rect(coordinate).get_center()


func get_cell_global_center(coordinate: Vector2i) -> Vector2:
	return to_global(get_cell_center(coordinate))


func coordinate_from_local_position(
	local_position: Vector2
) -> Vector2i:
	var origin := get_grid_origin()
	var relative_position := local_position - origin

	if relative_position.x < 0.0 or relative_position.y < 0.0:
		return INVALID_COORDINATE

	var step := cell_size + cell_gap

	var column := floori(relative_position.x / step.x)
	var row := floori(relative_position.y / step.y)
	var coordinate := Vector2i(column, row)

	if not is_valid_coordinate(coordinate):
		return INVALID_COORDINATE

	var position_inside_step := Vector2(
		fmod(relative_position.x, step.x),
		fmod(relative_position.y, step.y)
	)

	if (
		position_inside_step.x > cell_size.x
		or position_inside_step.y > cell_size.y
	):
		return INVALID_COORDINATE

	return coordinate


func is_valid_coordinate(coordinate: Vector2i) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)


func set_selected_cell(coordinate: Vector2i) -> void:
	selected_cell = (
		coordinate
			if is_valid_coordinate(coordinate)
			else INVALID_COORDINATE
	)

	queue_redraw()


func clear_selected_cell() -> void:
	selected_cell = INVALID_COORDINATE
	queue_redraw()


func set_cell_overlay(
	coordinate: Vector2i,
	color: Color
) -> void:
	if not is_valid_coordinate(coordinate):
		return

	_cell_overlays[coordinate] = color
	queue_redraw()


func remove_cell_overlay(coordinate: Vector2i) -> void:
	_cell_overlays.erase(coordinate)
	queue_redraw()


func clear_cell_overlays() -> void:
	_cell_overlays.clear()
	queue_redraw()
```

---

## FILE: `presentation/battle/grid/battle_grid_view.tscn`
```text
[gd_scene load_steps=2 format=3 uid="uid://cm5m1q7ed87gu"]

[ext_resource type="Script" uid="uid://cvygmt1trpyfr" path="res://presentation/battle/grid/battle_grid_view.gd" id="1_grid_view"]

[node name="BattleGridView" type="Node2D"]
script = ExtResource("1_grid_view")

[node name="SurfaceLayer" type="Node2D" parent="."]
z_index = 10

[node name="ObstacleLayer" type="Node2D" parent="."]
z_index = 20

[node name="CombatantLayer" type="Node2D" parent="."]
z_index = 30

[node name="EffectsLayer" type="Node2D" parent="."]
z_index = 40
```

---

## FILE: `project.godot`
```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="kleynod-steppe-frontier"
config/features=PackedStringArray("4.5", "Forward Plus")
config/icon="res://icon.svg"

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

---

## FILE: `scenes/debug/battle_grid_sandbox.gd`
```gdscript
extends Node2D


const PLAYER_TEAM_ID: StringName = &"team_player"
const ENEMY_TEAM_ID: StringName = &"team_enemy"

const MAX_BATTLE_LOG_LINES: int = 6


@export_group("Combatants")

@export
var combatant_view_scene: PackedScene

@export
var encounter_definition: BattleEncounterDefinition


@export_group("Presentation")

@export
var animate_movement: bool = true

@export
var animate_actions: bool = true

@export
var show_targeting_debug: bool = true

@export_range(0.0, 2.0, 0.05)
var ai_think_delay: float = 0.35


@export_group("Movement")

@export_range(1, 10, 1)
var stamina_cost_per_cell: int = 1


@export_group("Status Debug")

@export
var debug_status_definition: BattleStatusDefinition


@onready
var grid_view: BattleGridView = $BattleGridView

@onready
var combatant_layer: Node2D = (
	$BattleGridView/CombatantLayer
)

@onready
var status_label: Label = (
	$CanvasLayer/InterfaceMargin/PanelContainer /
	ContentMargin / VBoxContainer / StatusLabel
)

@onready
var ability_panel: BattleAbilityPanel = (
	$CanvasLayer/AbilityPanel
)


var session: BattleSession
var grid: BattleGrid

var combatant_presenter: BattleCombatantPresenter
var grid_overlay_presenter: BattleGridOverlayPresenter

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var turn_controller: BattleTurnController
var reinforcement_controller: BattleReinforcementController

var ai_controller: BasicMeleeAIController
var ai_turn_runner: BasicMeleeAITurnRunner

var debug_log_presenter: BattleDebugLogPresenter
var interaction_controller: BattleSandboxInteractionController

var session_factory := BattleSessionFactory.new()

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService


func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_action_services()
	_create_debug_log_presenter()
	_create_combatant_presenter()
	_create_movement_runner()
	_create_action_runner()
	_create_grid_overlay_presenter()
	_create_ai_system()
	_create_reinforcement_system()
	_create_turn_controller()
	_create_interaction_controller()
	_connect_grid_signals()
	_connect_ability_panel()
	_connect_turn_signals()
	_start_battle()


func _input(
	event: InputEvent
) -> void:
	if interaction_controller == null:
		return

	if interaction_controller.handle_input(
		event
	):
		get_viewport().set_input_as_handled()


func _unhandled_input(
	event: InputEvent
) -> void:
	if interaction_controller == null:
		return

	if interaction_controller.handle_unhandled_input(
		event
	):
		get_viewport().set_input_as_handled()


func _validate_dependencies() -> void:
	assert(
		combatant_view_scene != null,
		"Combatant view scene is not assigned."
	)

	assert(
		encounter_definition != null,
		"Encounter definition is not assigned."
	)

	var encounter_errors := (
		encounter_definition.get_validation_errors()
	)

	assert(
		encounter_errors.is_empty(),
		"Invalid encounter definition: %s"
		% encounter_errors
	)


func _create_battle_state() -> void:
	session = session_factory.create_from_encounter(
		encounter_definition
	)

	assert(
		session != null,
		"Failed to create battle session "
		+"from encounter definition."
	)

	grid = session.grid

	movement_service = BattleMovementService.new(
		session.side_rules
	)

	grid_view.rows = grid.rows
	grid_view.columns = grid.columns
	grid_view.divider_column = (
		session.side_rules.divider_column
	)


func _create_action_services() -> void:
	targeting_service = BattleTargetingService.new()

	action_service = BattleActionService.new(
		targeting_service
	)


func _create_debug_log_presenter() -> void:
	debug_log_presenter = BattleDebugLogPresenter.new(
		status_label,
		session,
		debug_status_definition,
		MAX_BATTLE_LOG_LINES
	)


func _create_combatant_presenter() -> void:
	combatant_presenter = BattleCombatantPresenter.new(
		grid_view,
		combatant_layer,
		combatant_view_scene
	)

	for combatant in session.get_all_combatants():
		var created_view := (
			combatant_presenter.add_combatant(
				combatant,
				false
			)
		)

		assert(
			created_view != null,
			"Failed to create view for combatant '%s'."
			% combatant.instance_id
		)

		debug_log_presenter.connect_combatant(
			combatant
		)


func _create_movement_runner() -> void:
	movement_runner = BattleMovementRunner.new(
		movement_service,
		combatant_presenter
	)


func _create_action_runner() -> void:
	action_runner = BattleActionRunner.new(
		action_service,
		combatant_presenter
	)


func _create_grid_overlay_presenter() -> void:
	grid_overlay_presenter = (
		BattleGridOverlayPresenter.new(
			grid_view,
			movement_service,
			action_service,
			targeting_service,
			show_targeting_debug
		)
	)


func _create_ai_system() -> void:
	ai_controller = BasicMeleeAIController.new(
		movement_service,
		action_service,
		targeting_service
	)

	ai_turn_runner = BasicMeleeAITurnRunner.new(
		movement_runner,
		action_runner
	)


func _create_reinforcement_system() -> void:
	reinforcement_controller = (
		BattleReinforcementController.new(
			session,
			encounter_definition.reinforcement_waves
		)
	)

	reinforcement_controller.combatant_spawned.connect(
		_on_reinforcement_combatant_spawned
	)

	reinforcement_controller.wave_completed.connect(
		_on_reinforcement_wave_completed
	)

	reinforcement_controller.wave_deferred.connect(
		_on_reinforcement_wave_deferred
	)


func _create_turn_controller() -> void:
	turn_controller = BattleTurnController.new()


func _create_interaction_controller() -> void:
	interaction_controller = (
		BattleSandboxInteractionController.new(
			PLAYER_TEAM_ID,
			session,
			turn_controller,
			ability_panel,
			movement_service,
			targeting_service,
			movement_runner,
			action_runner,
			grid_overlay_presenter,
			debug_log_presenter,
			stamina_cost_per_cell,
			animate_movement,
			animate_actions
		)
	)


func _connect_grid_signals() -> void:
	grid_view.cell_clicked.connect(
		interaction_controller.on_grid_cell_clicked
	)

	grid_view.cell_hovered.connect(
		interaction_controller.on_grid_cell_hovered
	)


func _connect_ability_panel() -> void:
	assert(
		ability_panel != null,
		"Battle ability panel is required."
	)

	ability_panel.ability_selected.connect(
		interaction_controller.on_ability_selected
	)


func _connect_turn_signals() -> void:
	turn_controller.turn_started.connect(
		_on_turn_started
	)

	turn_controller.battle_finished.connect(
		_on_battle_finished
	)


func _start_battle() -> void:
	var started := turn_controller.start(
		session,
		reinforcement_controller
	)

	assert(
		started,
		"Failed to start battle turn controller."
	)


func _on_reinforcement_combatant_spawned(
	combatant: CombatantState,
	wave_id: StringName,
	scheduled_round: int,
	actual_round: int,
	coordinate: Vector2i
) -> void:
	var created_view := (
		combatant_presenter.add_combatant(
			combatant,
			false
		)
	)

	assert(
		created_view != null,
		"Failed to create reinforcement view "
		+"for combatant '%s'."
		% combatant.instance_id
	)

	debug_log_presenter.connect_combatant(
		combatant
	)

	print(
		"Reinforcement '%s' from wave '%s' "
		% [
			combatant.instance_id,
			wave_id,
		]
		+"spawned at %s. Scheduled round: %d, "
		% [
			coordinate,
			scheduled_round,
		]
		+"actual round: %d."
		% actual_round
	)


func _on_reinforcement_wave_completed(
	wave_id: StringName,
	actual_round: int
) -> void:
	print(
		"Reinforcement wave '%s' completed "
		% wave_id
		+"on round %d."
		% actual_round
	)


func _on_reinforcement_wave_deferred(
	wave_id: StringName,
	pending_combatant_count: int,
	actual_round: int
) -> void:
	print(
		"Reinforcement wave '%s' deferred "
		% wave_id
		+"on round %d. Pending combatants: %d."
		% [
			actual_round,
			pending_combatant_count,
		]
	)


func _on_turn_started(
	combatant: CombatantState,
	current_round: int,
	_turn_index: int
) -> void:
	_set_active_combatant_selection(
		combatant
	)

	if combatant.team_id == PLAYER_TEAM_ID:
		interaction_controller.begin_player_turn(
			combatant
		)

		var selected_ability := (
			interaction_controller.get_selected_ability()
		)

		var ability_name := (
			selected_ability.display_name
			if selected_ability != null
			else "не выбрана"
		)

		debug_log_presenter.set_headline(
			"Раунд %d. Твой ход: %s. "
			% [
				current_round,
				combatant.definition.display_name,
			]
			+"Выносливость: %d/%d. "
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
			+"Статусы: %s. "
			% debug_log_presenter.get_status_summary(
				combatant
			)
			+"Выбрано: %s. "
			% ability_name
			+"1–9 — способность, Space — завершить ход."
		)

		return

	interaction_controller.begin_enemy_turn()

	debug_log_presenter.set_headline(
		"Раунд %d. Ход врага: %s. "
		% [
			current_round,
			combatant.definition.display_name,
		]
		+"Статусы: %s."
		% debug_log_presenter.get_status_summary(
			combatant
		)
	)

	call_deferred(
		"_run_ai_turn",
		combatant
	)


func _on_battle_finished(
	winning_team_id: StringName
) -> void:
	_set_active_combatant_selection(
		null
	)

	interaction_controller.finish_battle()

	if winning_team_id == PLAYER_TEAM_ID:
		debug_log_presenter.set_headline(
			"Бой завершён. Победа!"
		)

	elif winning_team_id == ENEMY_TEAM_ID:
		debug_log_presenter.set_headline(
			"Бой завершён. Поражение."
		)

	else:
		debug_log_presenter.set_headline(
			"Бой завершён без победителя."
		)


func _set_active_combatant_selection(
	active: CombatantState
) -> void:
	for combatant in session.get_all_combatants():
		var view := combatant_presenter.get_view(
			combatant.instance_id
		)

		if view == null:
			continue

		view.set_selected_state(
			combatant == active
		)


func _run_ai_turn(
	combatant: CombatantState
) -> void:
	if not _is_combatant_still_active(
		combatant
	):
		return

	if ai_think_delay > 0.0:
		await get_tree().create_timer(
			ai_think_delay
		).timeout

	if not _is_combatant_still_active(
		combatant
	):
		return

	var ability := combatant.get_default_ability()

	if ability == null:
		debug_log_presenter.set_headline(
			"%s не имеет доступных способностей."
			% combatant.definition.display_name
		)

		_finish_ai_turn(
			combatant
		)
		return

	var plan := ai_controller.create_turn_plan(
		grid,
		session,
		combatant,
		ability,
		stamina_cost_per_cell
	)

	if not plan.is_valid:
		debug_log_presenter.set_headline(
			"%s завершает ход: %s."
			% [
				combatant.definition.display_name,
				plan.failure_code,
			]
		)

		_finish_ai_turn(
			combatant
		)
		return

	grid_overlay_presenter.clear()

	var outcome := await ai_turn_runner.execute(
		session,
		plan,
		animate_movement,
		animate_actions
	)

	if turn_controller.is_finished:
		interaction_controller.set_interaction_in_progress(
			false
		)
		return

	if not outcome.is_successful:
		debug_log_presenter.set_headline(
			"Ход ИИ выполнен не полностью: %s."
			% outcome.failure_code
		)

	elif outcome.did_attack():
		debug_log_presenter.set_headline(
			"%s использует «%s» против %s. "
			% [
				combatant.definition.display_name,
				ability.display_name,
				plan.target.definition.display_name,
			]
			+"Ударов: %d. Общий урон: %d. "
			% [
				outcome.get_attack_count(),
				outcome.get_damage_dealt(),
			]
			+"Здоровье цели: %d/%d. "
			% [
				plan.target.current_health,
				plan.target.max_health,
			]
			+"Выносливость врага: %d/%d."
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
		)

	elif outcome.did_move():
		debug_log_presenter.set_headline(
			"%s приближается к %s. "
			% [
				combatant.definition.display_name,
				plan.target.definition.display_name,
			]
			+"Пройдено клеток: %d. "
			% outcome.get_movement_step_count()
			+"Осталось выносливости: %d/%d."
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
		)

	else:
		debug_log_presenter.set_headline(
			"%s не может действовать."
			% combatant.definition.display_name
		)

	interaction_controller.refresh_grid_overlays()

	_finish_ai_turn(
		combatant
	)


func _is_combatant_still_active(
	combatant: CombatantState
) -> bool:
	return (
		turn_controller != null
		and turn_controller.is_running
		and turn_controller.is_combatant_active(
			combatant
		)
	)


func _finish_ai_turn(
	combatant: CombatantState
) -> void:
	if not _is_combatant_still_active(
		combatant
	):
		return

	turn_controller.end_current_turn()
```

---

## FILE: `scenes/debug/battle_grid_sandbox.tscn`
```text
[gd_scene load_steps=7 format=3 uid="uid://bvvj4s6x1f4km"]

[ext_resource type="Script" uid="uid://dwtnlj74gi01o" path="res://scenes/debug/battle_grid_sandbox.gd" id="1_sandbox"]
[ext_resource type="PackedScene" uid="uid://cm5m1q7ed87gu" path="res://presentation/battle/grid/battle_grid_view.tscn" id="2_grid"]
[ext_resource type="PackedScene" uid="uid://dogan5u1eqtfl" path="res://presentation/battle/combatants/combatant_view.tscn" id="3_combatant_view"]
[ext_resource type="Resource" uid="uid://bcg0f3qjyahde" path="res://content/encounters/debug/debug_reinforcement_encounter.tres" id="4_encounter_definition"]
[ext_resource type="PackedScene" uid="uid://bgg8ap77su8v1" path="res://presentation/battle/abilities/battle_ability_panel.tscn" id="5_7mp7c"]
[ext_resource type="Resource" uid="uid://biy4yp5jjdsj0" path="res://content/statuses/debug/debug_cracked_defense.tres" id="6_debug_status"]

[node name="BattleGridSandbox" type="Node2D"]
script = ExtResource("1_sandbox")
combatant_view_scene = ExtResource("3_combatant_view")
encounter_definition = ExtResource("4_encounter_definition")
debug_status_definition = ExtResource("6_debug_status")

[node name="BattleGridView" parent="." instance=ExtResource("2_grid")]
position = Vector2(958.43, 540)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="InterfaceMargin" type="MarginContainer" parent="CanvasLayer"]
offset_left = 24.0
offset_top = 24.0
offset_right = 720.0
offset_bottom = 210.0

[node name="PanelContainer" type="PanelContainer" parent="CanvasLayer/InterfaceMargin"]
layout_mode = 2

[node name="ContentMargin" type="MarginContainer" parent="CanvasLayer/InterfaceMargin/PanelContainer"]
layout_mode = 2
theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 12
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 12

[node name="VBoxContainer" type="VBoxContainer" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin"]
layout_mode = 2
theme_override_constants/separation = 8

[node name="TitleLabel" type="Label" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin/VBoxContainer"]
layout_mode = 2
text = "Combat Action Sandbox"

[node name="InstructionsLabel" type="Label" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin/VBoxContainer"]
layout_mode = 2
text = "ЛКМ по пустой клетке: движение
ЛКМ по допустимой цели: применить выбранную способность
1–9: выбрать способность
ПКМ: поставить или удалить препятствие
Space: завершить ход игрока
Ход врага выполняется автоматически"

[node name="StatusLabel" type="Label" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin/VBoxContainer"]
layout_mode = 2
text = "Ожидание..."
autowrap_mode = 2

[node name="AbilityPanel" parent="CanvasLayer" instance=ExtResource("5_7mp7c")]
```

---

## FILE: `scenes/debug/controllers/battle_sandbox_interaction_controller.gd`
```gdscript
class_name BattleSandboxInteractionController
extends RefCounted


var player_team_id: StringName

var session: BattleSession
var grid: BattleGrid
var turn_controller: BattleTurnController

var ability_panel: BattleAbilityPanel

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var grid_overlay_presenter: BattleGridOverlayPresenter
var debug_log_presenter: BattleDebugLogPresenter

var stamina_cost_per_cell: int = 1
var animate_movement: bool = true
var animate_actions: bool = true

var _obstacle_counter: int = 0
var _interaction_in_progress: bool = false

var _selected_ability: AbilityDefinition

var _hovered_coordinate: Vector2i = (
	BattleGridView.INVALID_COORDINATE
)


func _init(
	p_player_team_id: StringName,
	p_session: BattleSession,
	p_turn_controller: BattleTurnController,
	p_ability_panel: BattleAbilityPanel,
	p_movement_service: BattleMovementService,
	p_targeting_service: BattleTargetingService,
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner,
	p_grid_overlay_presenter: BattleGridOverlayPresenter,
	p_debug_log_presenter: BattleDebugLogPresenter,
	p_stamina_cost_per_cell: int = 1,
	p_animate_movement: bool = true,
	p_animate_actions: bool = true
) -> void:
	assert(
		p_player_team_id != &"",
		"Interaction controller requires a player team ID."
	)

	assert(
		p_session != null,
		"Interaction controller requires a battle session."
	)

	assert(
		p_turn_controller != null,
		"Interaction controller requires a turn controller."
	)

	assert(
		p_ability_panel != null,
		"Interaction controller requires an ability panel."
	)

	assert(
		p_movement_service != null,
		"Interaction controller requires a movement service."
	)

	assert(
		p_targeting_service != null,
		"Interaction controller requires a targeting service."
	)

	assert(
		p_movement_runner != null,
		"Interaction controller requires a movement runner."
	)

	assert(
		p_action_runner != null,
		"Interaction controller requires an action runner."
	)

	assert(
		p_grid_overlay_presenter != null,
		"Interaction controller requires an overlay presenter."
	)

	assert(
		p_debug_log_presenter != null,
		"Interaction controller requires a debug log presenter."
	)

	player_team_id = p_player_team_id

	session = p_session
	grid = session.grid
	turn_controller = p_turn_controller

	ability_panel = p_ability_panel

	movement_service = p_movement_service
	targeting_service = p_targeting_service

	movement_runner = p_movement_runner
	action_runner = p_action_runner

	grid_overlay_presenter = p_grid_overlay_presenter
	debug_log_presenter = p_debug_log_presenter

	stamina_cost_per_cell = maxi(
		1,
		p_stamina_cost_per_cell
	)

	animate_movement = p_animate_movement
	animate_actions = p_animate_actions


func begin_player_turn(
	combatant: CombatantState
) -> void:
	_interaction_in_progress = false

	_selected_ability = get_default_ability(
		combatant
	)

	ability_panel.bind_combatant(
		combatant,
		_selected_ability
	)

	ability_panel.set_interactable(
		true
	)

	refresh_grid_overlays()


func begin_enemy_turn() -> void:
	_interaction_in_progress = true
	_selected_ability = null

	ability_panel.clear_combatant()

	refresh_grid_overlays()


func finish_battle() -> void:
	_interaction_in_progress = false
	_selected_ability = null

	ability_panel.clear_combatant()
	grid_overlay_presenter.clear()


func set_interaction_in_progress(
	value: bool
) -> void:
	_interaction_in_progress = value

	if value:
		grid_overlay_presenter.clear()
	else:
		refresh_grid_overlays()


func is_interaction_in_progress() -> bool:
	return _interaction_in_progress


func get_selected_ability() -> AbilityDefinition:
	return _selected_ability


func get_selected_ability_for(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	if (
		combatant.team_id == player_team_id
		and _selected_ability != null
		and combatant.has_ability(
			_selected_ability.ability_id
		)
	):
		return _selected_ability

	return get_default_ability(
		combatant
	)


func get_default_ability(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	return combatant.get_default_ability()


func get_active_combatant() -> CombatantState:
	if turn_controller == null:
		return null

	if not turn_controller.is_running:
		return null

	return turn_controller.active_combatant


func is_player_turn() -> bool:
	var active_combatant := get_active_combatant()

	return (
		active_combatant != null
		and active_combatant.team_id
		== player_team_id
	)


func end_active_turn() -> void:
	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	turn_controller.end_current_turn()


func handle_unhandled_input(
	event: InputEvent
) -> bool:
	if _interaction_in_progress:
		return false

	if turn_controller == null:
		return false

	if not turn_controller.is_running:
		return false

	if not (event is InputEventKey):
		return false

	var key_event := event as InputEventKey

	if (
		not key_event.pressed
		or key_event.echo
	):
		return false

	if key_event.keycode == KEY_T:
		_apply_debug_status_to_hovered_combatant()
		return true

	if (
		key_event.keycode == KEY_SPACE
		and is_player_turn()
	):
		end_active_turn()
		return true

	return false


func handle_input(
	event: InputEvent
) -> bool:
	if not (event is InputEventKey):
		return false

	var key_event := event as InputEventKey

	if (
		not key_event.pressed
		or key_event.echo
	):
		return false

	var ability_index := _get_ability_hotkey_index(
		key_event
	)

	if ability_index < 0:
		return false

	if turn_controller == null:
		return false

	if not turn_controller.is_running:
		return false

	var active := turn_controller.active_combatant

	if (
		active == null
		or active.team_id != player_team_id
		or _interaction_in_progress
	):
		return false

	return ability_panel.select_ability_by_index(
		ability_index,
		true
	)


func on_ability_selected(
	ability: AbilityDefinition
) -> void:
	if ability == null:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	var active := turn_controller.active_combatant

	if (
		active == null
		or active.team_id != player_team_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if _interaction_in_progress:
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if not active.has_ability(
		ability.ability_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if not active.can_spend_stamina(
		ability.stamina_cost
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	_selected_ability = ability

	ability_panel.set_selected_ability(
		_selected_ability
	)

	refresh_grid_overlays()

	debug_log_presenter.set_headline(
		"%s выбирает «%s». "
		% [
			active.definition.display_name,
			ability.display_name,
		]
		+"Стоимость: %d выносливости."
		% ability.stamina_cost
	)


func on_grid_cell_hovered(
	coordinate: Vector2i
) -> void:
	_hovered_coordinate = coordinate

	if not _interaction_in_progress:
		refresh_grid_overlays()


func on_grid_cell_clicked(
	coordinate: Vector2i,
	mouse_button: int
) -> void:
	if _interaction_in_progress:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	if not is_player_turn():
		return

	var active_combatant := get_active_combatant()

	if active_combatant == null:
		return

	match mouse_button:
		MOUSE_BUTTON_LEFT:
			var ability := get_selected_ability_for(
				active_combatant
			)

			var target := _get_combatant_at_coordinate(
				coordinate
			)

			if (
				ability != null
				and targeting_service.can_target(
					session,
					active_combatant,
					ability,
					coordinate
				)
			):
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

			elif target == null:
				_try_move_active_combatant(
					active_combatant,
					coordinate
				)

			elif target == active_combatant:
				debug_log_presenter.set_headline(
					"%s уже находится на клетке %s."
					% [
						active_combatant
						.definition.display_name,
						coordinate,
					]
				)

			elif (
				target.team_id
				== active_combatant.team_id
			):
				debug_log_presenter.set_headline(
					"Клетка %s занята союзником %s."
					% [
						coordinate,
						target.definition.display_name,
					]
				)

			else:
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

		MOUSE_BUTTON_RIGHT:
			_toggle_obstacle(
				coordinate
			)


func refresh_grid_overlays() -> void:
	if grid_overlay_presenter == null:
		return

	if turn_controller == null:
		grid_overlay_presenter.clear()
		return

	if not turn_controller.is_running:
		grid_overlay_presenter.clear()
		return

	var active := turn_controller.active_combatant

	if active == null:
		grid_overlay_presenter.clear()
		return

	var target_candidates: Array[CombatantState] = []

	for combatant in session.get_living_combatants():
		if combatant.team_id == active.team_id:
			continue

		target_candidates.append(
			combatant
		)

	var selected_ability := get_selected_ability_for(
		active
	)

	grid_overlay_presenter.refresh(
		session,
		active,
		target_candidates,
		selected_ability,
		_hovered_coordinate,
		stamina_cost_per_cell
	)


func _apply_debug_status_to_hovered_combatant() -> void:
	var target := _get_combatant_at_coordinate(
		_hovered_coordinate
	)

	debug_log_presenter.apply_debug_status(
		target,
		get_active_combatant()
	)


func _get_combatant_at_coordinate(
	coordinate: Vector2i
) -> CombatantState:
	if grid == null or session == null:
		return null

	var cell := grid.get_cell(
		coordinate
	)

	if cell == null or not cell.is_occupied():
		return null

	return session.get_combatant(
		cell.occupant_id
	)


func _try_move_active_combatant(
	combatant: CombatantState,
	target_coordinate: Vector2i
) -> void:
	if combatant == null:
		return

	if not turn_controller.is_combatant_active(
		combatant
	):
		return

	var plan := movement_service.create_plan(
		grid,
		combatant,
		target_coordinate,
		stamina_cost_per_cell
	)

	if not plan.is_valid:
		debug_log_presenter.set_headline(
			_get_movement_failure_message(
				plan.failure_code,
				plan,
				combatant
			)
		)

		refresh_grid_overlays()
		return

	var previous_coordinate := combatant.grid_position

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	debug_log_presenter.set_headline(
		"%s движется к клетке %s..."
		% [
			combatant.definition.display_name,
			plan.target_coordinate,
		]
	)

	var movement_outcome := await movement_runner.execute(
		grid,
		combatant,
		plan,
		animate_movement
	)

	if not movement_outcome.is_successful:
		_interaction_in_progress = false

		debug_log_presenter.set_headline(
			"Не удалось выполнить перемещение: %s."
			% movement_outcome.failure_code
		)

		refresh_grid_overlays()
		return

	debug_log_presenter.set_headline(
		"%s идёт %s → %s. Шагов: %d. "
		% [
			combatant.definition.display_name,
			previous_coordinate,
			plan.target_coordinate,
			movement_outcome.get_step_count(),
		]
		+"Потрачено выносливости: %d. "
		% plan.stamina_cost
		+"Осталось: %d/%d."
		% [
			combatant.current_stamina,
			combatant.max_stamina,
		]
	)

	_interaction_in_progress = false
	refresh_grid_overlays()


func _try_use_ability_at(
	actor: CombatantState,
	aim_coordinate: Vector2i
) -> void:
	if actor == null:
		return

	if not turn_controller.is_combatant_active(
		actor
	):
		return

	var ability := get_selected_ability_for(
		actor
	)

	if ability == null:
		debug_log_presenter.set_headline(
			"%s не имеет доступных способностей."
			% actor.definition.display_name
		)

		return

	var command := BattleActionCommand.new(
		actor,
		ability,
		aim_coordinate
	)

	var failure_code := action_runner.get_validation_failure(
		session,
		command
	)

	if failure_code != &"":
		debug_log_presenter.set_headline(
			_get_action_failure_message(
				failure_code,
				actor,
				ability
			)
		)

		refresh_grid_overlays()
		return

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	debug_log_presenter.suspend_status_signal_logging()

	var action_outcome := await action_runner.execute_action(
		session,
		command,
		animate_actions
	)

	debug_log_presenter.resume_status_signal_logging()

	if not action_outcome.is_successful:
		_interaction_in_progress = false

		debug_log_presenter.set_headline(
			"Действие не выполнено: %s."
			% action_outcome.failure_code
		)

		refresh_grid_overlays()
		return

	debug_log_presenter.append_action_results(
		action_outcome.action_result
	)

	if turn_controller.is_finished:
		_interaction_in_progress = false
		return

	var damage_dealt := (
		action_outcome.get_total_applied_amount(
			&"damage"
		)
	)

	var affected_count := (
		action_outcome.get_affected_target_count()
	)

	var defeated_count := (
		action_outcome
		.get_defeated_target_ids()
		.size()
	)

	debug_log_presenter.set_headline(
		"%s использует «%s» по клетке %s. "
		% [
			actor.definition.display_name,
			ability.display_name,
			aim_coordinate,
		]
		+"Задето целей: %d. "
		% affected_count
		+"Общий урон: %d. "
		% damage_dealt
		+"Погибло целей: %d. "
		% defeated_count
		+"Выносливость: %d/%d."
		% [
			actor.current_stamina,
			actor.max_stamina,
		]
	)

	_interaction_in_progress = false
	refresh_grid_overlays()


func _toggle_obstacle(
	coordinate: Vector2i
) -> void:
	var cell := grid.get_cell(
		coordinate
	)

	if cell == null:
		return

	if cell.is_occupied():
		debug_log_presenter.set_headline(
			"Нельзя поставить препятствие под бойца."
		)
		return

	if cell.has_obstacle():
		var obstacle_id := cell.obstacle_id

		grid.remove_obstacle(
			obstacle_id
		)

		debug_log_presenter.set_headline(
			"Препятствие удалено с клетки %s."
			% coordinate
		)

		refresh_grid_overlays()
		return

	_obstacle_counter += 1

	var new_obstacle_id := StringName(
		"debug_obstacle_%d"
		% _obstacle_counter
	)

	if not grid.try_place_obstacle(
		new_obstacle_id,
		coordinate
	):
		debug_log_presenter.set_headline(
			"Не удалось поставить препятствие."
		)
		return

	debug_log_presenter.set_headline(
		"Препятствие установлено на клетку %s."
		% coordinate
	)

	refresh_grid_overlays()


func _get_ability_hotkey_index(
	event: InputEventKey
) -> int:
	var keycodes: Array[int] = [
		event.keycode,
		event.physical_keycode,
	]

	for keycode in keycodes:
		match keycode:
			KEY_1:
				return 0

			KEY_2:
				return 1

			KEY_3:
				return 2

			KEY_4:
				return 3

			KEY_5:
				return 4

			KEY_6:
				return 5

			KEY_7:
				return 6

			KEY_8:
				return 7

			KEY_9:
				return 8

	return -1


func _get_action_failure_message(
	failure_code: StringName,
	actor: CombatantState,
	ability: AbilityDefinition
) -> String:
	match failure_code:
		BattleTargetingService.FAILURE_AIM_NOT_IN_PATTERN:
			return (
				"Выбранная клетка не входит в зону "
				+"досягаемости способности."
			)

		BattleTargetingService.FAILURE_AIM_OUTSIDE_GRID:
			return (
				"Выбранная клетка находится "
				+"за пределами поля."
			)

		BattleTargetingService.FAILURE_AIM_CELL_MUST_BE_OCCUPIED:
			return (
				"Для этой способности нужно выбрать "
				+"занятую клетку."
			)

		BattleTargetingService.FAILURE_AIM_CELL_MUST_BE_EMPTY:
			return (
				"Для этой способности нужно выбрать "
				+"пустую клетку."
			)

		BattleTargetingService.FAILURE_INVALID_AIM_RELATION:
			return (
				"Эта способность не может быть "
				+"применена к выбранному бойцу."
			)

		BattleActionService.FAILURE_NOT_ENOUGH_STAMINA:
			var cost := (
				ability.stamina_cost
				if ability != null
				else 0
			)

			return (
				"Недостаточно выносливости. "
				+"Нужно: %d, доступно: %d."
				% [
					cost,
					actor.current_stamina,
				]
			)

		BattleActionService.FAILURE_ABILITY_NOT_IN_LOADOUT:
			return (
				"Выбранная способность отсутствует "
				+"в loadout бойца."
			)

		BattleTargetingService.FAILURE_ACTOR_DEAD:
			return (
				"Погибший боец не может "
				+"использовать способности."
			)

		_:
			return (
				"Действие невозможно: %s."
				% failure_code
			)


func _get_movement_failure_message(
	failure_code: StringName,
	plan: BattleMovementPlan,
	combatant: CombatantState
) -> String:
	match failure_code:
		BattleMovementService.FAILURE_TARGET_IS_START:
			return (
				"%s уже находится на выбранной клетке."
				% combatant.definition.display_name
			)

		BattleMovementService.FAILURE_TARGET_OUTSIDE_TEAM_SIDE:
			return (
				"Обычным движением нельзя переходить "
				+"на сторону противника."
			)

		BattleMovementService.FAILURE_TARGET_BLOCKED:
			return (
				"Клетка %s занята или заблокирована."
				% plan.target_coordinate
			)

		BattleMovementService.FAILURE_NO_PATH:
			return (
				"До клетки %s невозможно построить маршрут."
				% plan.target_coordinate
			)

		BattleMovementService.FAILURE_NOT_ENOUGH_STAMINA:
			return (
				"Недостаточно выносливости. "
				+"Нужно: %d, доступно: %d."
				% [
					plan.stamina_cost,
					combatant.current_stamina,
				]
			)

		BattleMovementService.FAILURE_TARGET_OUTSIDE_GRID:
			return "Цель находится за пределами поля."

		BattleMovementService.FAILURE_DEAD_COMBATANT:
			return "Погибший боец не может двигаться."

		_:
			return (
				"Перемещение невозможно: %s."
				% failure_code
			)
```

---

## FILE: `scenes/debug_sechevik.tres`
```text
[gd_resource type="Resource" script_class="CombatantDefinition" load_steps=4 format=3 uid="uid://b3fmtemw5g732"]

[ext_resource type="Script" uid="uid://djbs8im0vo51" path="res://core/battle/combatants/combatant_definition.gd" id="1_definition"]
[ext_resource type="PackedScene" uid="uid://frc3c1tiqsau" path="res://presentation/battle/combatants/placeholder_combatant_visual.tscn" id="2_visual"]
[ext_resource type="Resource" uid="uid://cl0uv1vtgisk5" path="res://content/loadouts/debug/debug_sechevik_loadout.tres" id="3_loadout"]

[resource]
script = ExtResource("1_definition")
definition_id = &"combatant_debug_sechevik"
display_name = "Сечевик"
description = "Временный боец для проверки боевого прототипа."
default_loadout = ExtResource("3_loadout")
base_strength = 4
base_agility = 2
max_health = 26
base_armor = 1
base_initiative = 5
visual_scene = ExtResource("2_visual")
visual_tint = Color(0.3, 0.78, 1, 1)
```

---


## ✅ STATS
- Total files in tree: 71
- Readable files: 67
- Included files written: 24
- Trimmed files: 0
- Total lines written: 4338
