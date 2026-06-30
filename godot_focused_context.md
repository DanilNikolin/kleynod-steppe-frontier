# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/targeting/ability_targeting_definition.gd', 'core/battle/targeting/battle_targeting_result.gd', 'core/battle/targeting/battle_targeting_service.gd', 'core/battle/actions/battle_action_command.gd', 'core/battle/actions/battle_action_result.gd', 'core/battle/actions/battle_effect_result.gd', 'core/battle/actions/battle_action_service.gd', 'presentation/battle/actions/battle_action_runner.gd', 'presentation/battle/actions/battle_action_outcome.gd', 'presentation/battle/combatants/battle_combatant_presenter.gd', 'scenes/debug/battle_grid_sandbox.gd', 'content/encounters/debug/debug_reinforcement_encounter.tres', 'content/loadouts/debug/debug_sechevik_loadout.tres']`
- Allow addons: `False`
- Included files planned: `30`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_raider_chop.tres
│   │       └── debug_sabre_slash.tres
│   ├── combatants
│   │   └── debug
│   │       ├── debug_sechevik.tres
│   │       └── debug_steppe_raider.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   └── loadouts
│       └── debug
│           ├── debug_sechevik_loadout.tres
│           └── debug_steppe_raider_loadout.tres
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
    └── debug
        ├── battle_grid_sandbox.gd
        └── battle_grid_sandbox.tscn
```

---

## 📌 INCLUDED FILES

## FILE: `content/abilities/debug/debug_raider_chop.tres`
```text
[gd_resource type="Resource" script_class="AbilityDefinition" load_steps=7 format=3 uid="uid://bfgvpavod3dxb"]

[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="1_ability"]
[ext_resource type="Script" uid="uid://36m0bduhwx85" path="res://core/battle/targeting/ability_targeting_definition.gd" id="2_targeting"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="3_effect"]
[ext_resource type="Script" uid="uid://djty1vj4ucxrn" path="res://core/battle/effects/damage_effect.gd" id="4_damage"]

[sub_resource type="Resource" id="Resource_raider_damage"]
script = ExtResource("4_damage")
base_damage = 2
effect_id = &"effect_raider_chop_damage"

[sub_resource type="Resource" id="Resource_raider_targeting"]
script = ExtResource("2_targeting")
aim_offsets = Array[Vector2i]([Vector2i(1, -1), Vector2i(2, -1), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)])

[resource]
script = ExtResource("1_ability")
ability_id = &"ability_raider_chop"
display_name = "Рубящий удар"
description = "Грубая атака одного врага на дистанции до двух клеток."
stamina_cost = 2
targeting = SubResource("Resource_raider_targeting")
effects = Array[ExtResource("3_effect")]([SubResource("Resource_raider_damage")])
```

---

## FILE: `content/abilities/debug/debug_sabre_slash.tres`
```text
[gd_resource type="Resource" script_class="AbilityDefinition" load_steps=7 format=3 uid="uid://bh0xtv0ndcte4"]

[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="1_ability"]
[ext_resource type="Script" uid="uid://36m0bduhwx85" path="res://core/battle/targeting/ability_targeting_definition.gd" id="2_targeting"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="3_effect"]
[ext_resource type="Script" uid="uid://djty1vj4ucxrn" path="res://core/battle/effects/damage_effect.gd" id="4_damage"]

[sub_resource type="Resource" id="Resource_sabre_damage"]
script = ExtResource("4_damage")
base_damage = 4
effect_id = &"effect_sabre_slash_damage"

[sub_resource type="Resource" id="Resource_sabre_targeting"]
script = ExtResource("2_targeting")
aim_offsets = Array[Vector2i]([Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)])

[resource]
script = ExtResource("1_ability")
ability_id = &"ability_sabre_slash"
display_name = "Удар саблей"
description = "Атака одного врага в своём или соседнем ряду на дистанции до трёх клеток."
stamina_cost = 3
targeting = SubResource("Resource_sabre_targeting")
effects = Array[ExtResource("3_effect")]([SubResource("Resource_sabre_damage")])
```

---

## FILE: `content/combatants/debug/debug_sechevik.tres`
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
[ext_resource type="Resource" uid="uid://b3fmtemw5g732" path="res://content/combatants/debug/debug_sechevik.tres" id="4_player"]
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
[gd_resource type="Resource" script_class="CombatantLoadoutDefinition" load_steps=4 format=3 uid="uid://cl0uv1vtgisk5"]

[ext_resource type="Script" uid="uid://bis4duqvyinf4" path="res://core/battle/loadouts/combatant_loadout_definition.gd" id="1_loadout"]
[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" uid="uid://bh0xtv0ndcte4" path="res://content/abilities/debug/debug_sabre_slash.tres" id="3_sabre"]

[resource]
script = ExtResource("1_loadout")
loadout_id = &"loadout_debug_sechevik"
display_name = "Сечевик с саблей"
default_ability_id = &"ability_sabre_slash"
abilities = Array[ExtResource("2_ability")]([ExtResource("3_sabre")])
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

## FILE: `core/battle/abilities/ability_definition.gd`
```gdscript
@tool
class_name AbilityDefinition
extends Resource


@export_group("Identity")

@export
var ability_id: StringName = &""

@export
var display_name: String = "Unnamed Ability"

@export_multiline
var description: String = ""


@export_group("Cost")

@export_range(0, 999, 1)
var stamina_cost: int = 1


@export_group("Targeting")

@export
var targeting: AbilityTargetingDefinition


@export_group("Effects")

@export
var effects: Array[BattleEffect] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if ability_id == &"":
		errors.append(
			"Ability ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Display name is empty."
		)

	if stamina_cost < 0:
		errors.append(
			"Stamina cost cannot be negative."
		)

	if targeting == null:
		errors.append(
			"Ability targeting definition is not assigned."
		)

	else:
		for targeting_error in (
			targeting.get_validation_errors()
		):
			errors.append(
				"Targeting: %s"
				% targeting_error
			)

	if effects.is_empty():
		errors.append(
			"Ability must contain at least one effect."
		)

	for effect_index in range(
		effects.size()
	):
		var effect := effects[
			effect_index
		]

		if effect == null:
			errors.append(
				"Effect at index %d is null."
				% effect_index
			)

			continue

		for effect_error in (
			effect.get_validation_errors()
		):
			errors.append(
				"Effect %d: %s"
				% [
					effect_index,
					effect_error,
				]
			)

	return errors
```

---

## FILE: `core/battle/actions/battle_action_command.gd`
```gdscript
class_name BattleActionCommand
extends RefCounted


var actor: CombatantState
var ability: AbilityDefinition

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)


func _init(
	p_actor: CombatantState = null,
	p_ability: AbilityDefinition = null,
	p_aim_coordinate: Vector2i = (
		BattleGrid.INVALID_COORDINATE
	)
) -> void:
	actor = p_actor
	ability = p_ability
	aim_coordinate = p_aim_coordinate
```

---

## FILE: `core/battle/actions/battle_action_result.gd`
```gdscript
class_name BattleActionResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var ability_id: StringName = &""

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var affected_coordinates: Array[Vector2i] = []
var affected_target_ids: Array[StringName] = []

var stamina_cost: int = 0
var stamina_spent: int = 0

var effect_results: Array[BattleEffectResult] = []


func get_primary_target_id() -> StringName:
	if affected_target_ids.is_empty():
		return &""

	return affected_target_ids[0]


func get_total_applied_amount(
	effect_kind: StringName = &""
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if effect_result == null:
			continue

		if (
			effect_kind != &""
			and effect_result.effect_kind
			!= effect_kind
		):
			continue

		total += effect_result.applied_amount

	return total


func did_target_die(
	target_id: StringName = &""
) -> bool:
	for effect_result in effect_results:
		if effect_result == null:
			continue

		if (
			target_id != &""
			and effect_result.target_id
			!= target_id
		):
			continue

		if effect_result.target_died:
			return true

	return false
```

---

## FILE: `core/battle/actions/battle_action_service.gd`
```gdscript
class_name BattleActionService
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_COMMAND: StringName = (
	&"invalid_command"
)

const FAILURE_INVALID_ACTOR: StringName = (
	&"invalid_actor"
)

const FAILURE_INVALID_ABILITY: StringName = (
	&"invalid_ability"
)

const FAILURE_INVALID_ABILITY_DEFINITION: StringName = (
	&"invalid_ability_definition"
)

const FAILURE_ABILITY_NOT_IN_LOADOUT: StringName = (
	&"ability_not_in_loadout"
)

const FAILURE_NOT_ENOUGH_STAMINA: StringName = (
	&"not_enough_stamina"
)

const FAILURE_UNSUPPORTED_EFFECT: StringName = (
	&"unsupported_effect"
)

const FAILURE_STAMINA_SPEND_FAILED: StringName = (
	&"stamina_spend_failed"
)

const FAILURE_EFFECT_RESOLUTION_FAILED: StringName = (
	&"effect_resolution_failed"
)


var targeting_service: BattleTargetingService
var effect_resolver := EffectResolver.new()


func _init(
	p_targeting_service: BattleTargetingService
) -> void:
	assert(
		p_targeting_service != null,
		"BattleActionService requires "
		+"BattleTargetingService."
	)

	targeting_service = p_targeting_service


func execute(
	session: BattleSession,
	command: BattleActionCommand
) -> BattleActionResult:
	var result := _create_result(
		command
	)

	var failure_code := (
		_get_validation_failure(
			session,
			command
		)
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	var targeting_result := (
		targeting_service.create_result(
			session,
			command.actor,
			command.ability,
			command.aim_coordinate
		)
	)

	if not targeting_result.is_valid:
		result.failure_code = (
			targeting_result.failure_code
		)

		return result

	for coordinate in (
		targeting_result.affected_coordinates
	):
		result.affected_coordinates.append(
			coordinate
		)

	for target in (
		targeting_result.affected_combatants
	):
		result.affected_target_ids.append(
			target.instance_id
		)

	if not command.actor.spend_stamina(
		command.ability.stamina_cost
	):
		result.failure_code = (
			FAILURE_STAMINA_SPEND_FAILED
		)

		return result

	result.stamina_spent = (
		command.ability.stamina_cost
	)

	# Стоимость списана один раз.
	# Эффекты применяются ко всем найденным целям.
	for target in (
		targeting_result.affected_combatants
	):
		if target == null or not target.is_alive:
			continue

		for effect in command.ability.effects:
			if not target.is_alive:
				break

			var effect_result := (
				effect_resolver.resolve(
					effect,
					command.actor,
					target
				)
			)

			result.effect_results.append(
				effect_result
			)

			if not effect_result.is_successful:
				result.failure_code = (
					FAILURE_EFFECT_RESOLUTION_FAILED
				)

				return result

	result.is_successful = true
	return result


func can_execute(
	session: BattleSession,
	command: BattleActionCommand
) -> bool:
	return _get_validation_failure(
		session,
		command
	) == &""


func get_validation_failure(
	session: BattleSession,
	command: BattleActionCommand
) -> StringName:
	return _get_validation_failure(
		session,
		command
	)


func get_targeting_result(
	session: BattleSession,
	command: BattleActionCommand
) -> BattleTargetingResult:
	if command == null:
		return BattleTargetingResult.new()

	return targeting_service.create_result(
		session,
		command.actor,
		command.ability,
		command.aim_coordinate
	)


func _get_validation_failure(
	session: BattleSession,
	command: BattleActionCommand
) -> StringName:
	if session == null:
		return FAILURE_INVALID_SESSION

	if command == null:
		return FAILURE_INVALID_COMMAND

	var actor := command.actor
	var ability := command.ability

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if ability == null:
		return FAILURE_INVALID_ABILITY

	if not ability.is_valid_definition():
		return FAILURE_INVALID_ABILITY_DEFINITION

	if not actor.has_ability(
		ability.ability_id
	):
		return FAILURE_ABILITY_NOT_IN_LOADOUT

	var targeting_failure := (
		targeting_service.get_validation_failure(
			session,
			actor,
			ability,
			command.aim_coordinate
		)
	)

	if targeting_failure != &"":
		return targeting_failure

	if not actor.can_spend_stamina(
		ability.stamina_cost
	):
		return FAILURE_NOT_ENOUGH_STAMINA

	for effect in ability.effects:
		if not effect_resolver.can_resolve(
			effect
		):
			return FAILURE_UNSUPPORTED_EFFECT

	return &""


func _create_result(
	command: BattleActionCommand
) -> BattleActionResult:
	var result := BattleActionResult.new()

	if command == null:
		return result

	result.aim_coordinate = (
		command.aim_coordinate
	)

	if command.actor != null:
		result.actor_id = (
			command.actor.instance_id
		)

	if command.ability != null:
		result.ability_id = (
			command.ability.ability_id
		)

		result.stamina_cost = (
			command.ability.stamina_cost
		)

	return result
```

---

## FILE: `core/battle/actions/battle_effect_result.gd`
```gdscript
class_name BattleEffectResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var effect_id: StringName = &""
var effect_kind: StringName = &""

var source_id: StringName = &""
var target_id: StringName = &""

var raw_amount: int = 0
var mitigated_amount: int = 0
var resolved_amount: int = 0
var applied_amount: int = 0

var previous_value: int = 0
var current_value: int = 0

var target_died: bool = false
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

## FILE: `core/battle/effects/battle_effect.gd`
```gdscript
@tool
class_name BattleEffect
extends Resource


@export_group("Identity")

@export
var effect_id: StringName = &""


func is_valid_effect() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if effect_id == &"":
		errors.append("Effect ID is empty.")

	return errors
```

---

## FILE: `core/battle/effects/damage_effect.gd`
```gdscript
@tool
class_name DamageEffect
extends BattleEffect


@export_group("Damage")

@export_range(0, 9999, 1)
var base_damage: int = 1

@export_range(0.0, 20.0, 0.05)
var strength_scaling: float = 1.0

@export_range(0, 999, 1)
var armor_piercing: int = 0

@export_range(0, 999, 1)
var minimum_damage: int = 1


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

## FILE: `core/battle/loadouts/combatant_loadout_definition.gd`
```gdscript
@tool
class_name CombatantLoadoutDefinition
extends Resource


@export_group("Identity")

@export
var loadout_id: StringName = &""

@export
var display_name: String = "Unnamed Loadout"


@export_group("Abilities")

@export
var default_ability_id: StringName = &""

@export
var abilities: Array[AbilityDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if loadout_id == &"":
		errors.append(
			"Loadout ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Loadout display name is empty."
		)

	if abilities.is_empty():
		errors.append(
			"Loadout must contain at least one ability."
		)

	var used_ability_ids: Dictionary = {}

	for ability_index in range(
		abilities.size()
	):
		var ability := abilities[ability_index]

		if ability == null:
			errors.append(
				"Ability at index %d is null."
				% ability_index
			)

			continue

		for ability_error in ability.get_validation_errors():
			errors.append(
				"Ability %d: %s"
				% [
					ability_index,
					ability_error,
				]
			)

		if ability.ability_id == &"":
			continue

		if used_ability_ids.has(
			ability.ability_id
		):
			errors.append(
				"Duplicate ability ID in loadout: %s."
				% ability.ability_id
			)
		else:
			used_ability_ids[
				ability.ability_id
			] = true

	if default_ability_id == &"":
		errors.append(
			"Default ability ID is empty."
		)

	elif not used_ability_ids.has(
		default_ability_id
	):
		errors.append(
			"Default ability '%s' is not included "
			% default_ability_id
			+"in the loadout."
		)

	return errors


func has_ability(
	ability_id: StringName
) -> bool:
	return get_ability(
		ability_id
	) != null


func get_ability(
	ability_id: StringName
) -> AbilityDefinition:
	if ability_id == &"":
		return null

	for ability in abilities:
		if (
			ability != null
			and ability.ability_id == ability_id
		):
			return ability

	return null


func get_default_ability() -> AbilityDefinition:
	return get_ability(
		default_ability_id
	)


func get_abilities() -> Array[AbilityDefinition]:
	var result: Array[AbilityDefinition] = []

	for ability in abilities:
		if ability != null:
			result.append(
				ability
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

## FILE: `core/battle/targeting/battle_targeting_result.gd`
```gdscript
class_name BattleTargetingResult
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var ability_id: StringName = &""

var origin_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var affected_coordinates: Array[Vector2i] = []
var affected_combatants: Array[CombatantState] = []


func get_primary_target() -> CombatantState:
	if affected_combatants.is_empty():
		return null

	return affected_combatants[0]


func get_primary_target_id() -> StringName:
	var target := get_primary_target()

	if target == null:
		return &""

	return target.instance_id
```

---

## FILE: `core/battle/targeting/battle_targeting_service.gd`
```gdscript
class_name BattleTargetingService
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_GRID: StringName = (
	&"invalid_grid"
)

const FAILURE_INVALID_ACTOR: StringName = (
	&"invalid_actor"
)

const FAILURE_INVALID_ABILITY: StringName = (
	&"invalid_ability"
)

const FAILURE_INVALID_ABILITY_DEFINITION: StringName = (
	&"invalid_ability_definition"
)

const FAILURE_ACTOR_DEAD: StringName = (
	&"actor_dead"
)

const FAILURE_ACTOR_NOT_IN_SESSION: StringName = (
	&"actor_not_in_session"
)

const FAILURE_ACTOR_NOT_ON_GRID: StringName = (
	&"actor_not_on_grid"
)

const FAILURE_INVALID_ORIGIN: StringName = (
	&"invalid_origin"
)

const FAILURE_INVALID_FORWARD_DIRECTION: StringName = (
	&"invalid_forward_direction"
)

const FAILURE_AIM_OUTSIDE_GRID: StringName = (
	&"aim_outside_grid"
)

const FAILURE_AIM_NOT_IN_PATTERN: StringName = (
	&"aim_not_in_pattern"
)

const FAILURE_AIM_CELL_MUST_BE_OCCUPIED: StringName = (
	&"aim_cell_must_be_occupied"
)

const FAILURE_AIM_CELL_MUST_BE_EMPTY: StringName = (
	&"aim_cell_must_be_empty"
)

const FAILURE_INVALID_AIM_RELATION: StringName = (
	&"invalid_aim_relation"
)


func create_result(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> BattleTargetingResult:
	var result := BattleTargetingResult.new()

	if actor != null:
		result.actor_id = actor.instance_id
		result.origin_coordinate = actor.grid_position

	if ability != null:
		result.ability_id = ability.ability_id

	result.aim_coordinate = aim_coordinate

	var failure_code := _get_validation_failure(
		session,
		actor,
		ability,
		actor.grid_position if actor != null else (
			BattleGrid.INVALID_COORDINATE
		),
		aim_coordinate,
		true
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	var targeting := ability.targeting
	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	var used_coordinates: Dictionary = {}
	var used_combatants: Dictionary = {}

	for impact_offset in targeting.impact_offsets:
		var oriented_offset := Vector2i(
			impact_offset.x * forward_direction,
			impact_offset.y
		)

		var affected_coordinate := (
			aim_coordinate + oriented_offset
		)

		# Область у края поля просто обрезается.
		if not session.grid.is_inside(
			affected_coordinate
		):
			continue

		if not used_coordinates.has(
			affected_coordinate
		):
			used_coordinates[
				affected_coordinate
			] = true

			result.affected_coordinates.append(
				affected_coordinate
			)

		var target := _get_combatant_at_coordinate(
			session,
			affected_coordinate
		)

		if target == null or not target.is_alive:
			continue

		if not _is_relation_allowed(
			actor,
			target,
			targeting.affected_relation_mask
		):
			continue

		if used_combatants.has(
			target.instance_id
		):
			continue

		used_combatants[
			target.instance_id
		] = true

		result.affected_combatants.append(
			target
		)

	result.is_valid = true
	return result

func get_aim_coordinates(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if (
		session == null
		or session.grid == null
		or actor == null
		or ability == null
		or ability.targeting == null
	):
		return result

	if not actor.is_alive:
		return result

	if not session.has_combatant(
		actor.instance_id
	):
		return result

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	if forward_direction == 0:
		return result

	var used_coordinates: Dictionary = {}

	for aim_offset in (
		ability.targeting.aim_offsets
	):
		var oriented_offset := Vector2i(
			aim_offset.x * forward_direction,
			aim_offset.y
		)

		var coordinate := (
			actor.grid_position
			+ oriented_offset
		)

		if not session.grid.is_inside(
			coordinate
		):
			continue

		if used_coordinates.has(
			coordinate
		):
			continue

		used_coordinates[coordinate] = true
		result.append(coordinate)

	return result


func get_impact_coordinates(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if (
		session == null
		or session.grid == null
		or actor == null
		or ability == null
		or ability.targeting == null
	):
		return result

	var aim_coordinates := get_aim_coordinates(
		session,
		actor,
		ability
	)

	if not aim_coordinates.has(
		aim_coordinate
	):
		return result

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	if forward_direction == 0:
		return result

	var used_coordinates: Dictionary = {}

	for impact_offset in (
		ability.targeting.impact_offsets
	):
		var oriented_offset := Vector2i(
			impact_offset.x * forward_direction,
			impact_offset.y
		)

		var coordinate := (
			aim_coordinate
			+ oriented_offset
		)

		# Область за краем поля обрезается.
		if not session.grid.is_inside(
			coordinate
		):
			continue

		if used_coordinates.has(
			coordinate
		):
			continue

		used_coordinates[coordinate] = true
		result.append(coordinate)

	return result

func can_target(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> bool:
	if actor == null:
		return false

	return _get_validation_failure(
		session,
		actor,
		ability,
		actor.grid_position,
		aim_coordinate,
		true
	) == &""


## Используется ИИ для проверки гипотетической
## позиции, на которую актёр ещё только планирует прийти.
func can_target_from(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	origin_coordinate: Vector2i,
	aim_coordinate: Vector2i
) -> bool:
	return _get_validation_failure(
		session,
		actor,
		ability,
		origin_coordinate,
		aim_coordinate,
		false
	) == &""


func get_validation_failure(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> StringName:
	if actor == null:
		return FAILURE_INVALID_ACTOR

	return _get_validation_failure(
		session,
		actor,
		ability,
		actor.grid_position,
		aim_coordinate,
		true
	)


func _get_validation_failure(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	origin_coordinate: Vector2i,
	aim_coordinate: Vector2i,
	require_actor_at_origin: bool
) -> StringName:
	if session == null:
		return FAILURE_INVALID_SESSION

	var grid := session.grid

	if grid == null:
		return FAILURE_INVALID_GRID

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if ability == null:
		return FAILURE_INVALID_ABILITY

	if not ability.is_valid_definition():
		return FAILURE_INVALID_ABILITY_DEFINITION

	if not actor.is_alive:
		return FAILURE_ACTOR_DEAD

	if not session.has_combatant(
		actor.instance_id
	):
		return FAILURE_ACTOR_NOT_IN_SESSION

	if not grid.is_inside(origin_coordinate):
		return FAILURE_INVALID_ORIGIN

	if not session.is_coordinate_allowed_for_team(
		actor.team_id,
		origin_coordinate
	):
		return FAILURE_INVALID_ORIGIN

	if require_actor_at_origin:
		if (
			actor.grid_position
			!= origin_coordinate
		):
			return FAILURE_ACTOR_NOT_ON_GRID

		if not grid.has_occupant(
			actor.instance_id
		):
			return FAILURE_ACTOR_NOT_ON_GRID

		if (
			grid.get_occupant_position(
				actor.instance_id
			)
			!= origin_coordinate
		):
			return FAILURE_ACTOR_NOT_ON_GRID

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	if forward_direction == 0:
		return FAILURE_INVALID_FORWARD_DIRECTION

	if not grid.is_inside(aim_coordinate):
		return FAILURE_AIM_OUTSIDE_GRID

	if not _is_aim_coordinate_in_pattern(
		ability.targeting,
		origin_coordinate,
		aim_coordinate,
		forward_direction
	):
		return FAILURE_AIM_NOT_IN_PATTERN

	var aimed_combatant := (
		_get_combatant_at_coordinate(
			session,
			aim_coordinate
		)
	)

	match ability.targeting.aim_requirement:
		AbilityTargetingDefinition.AimRequirement.OCCUPIED_CELL:
			if (
				aimed_combatant == null
				or not aimed_combatant.is_alive
			):
				return (
					FAILURE_AIM_CELL_MUST_BE_OCCUPIED
				)

		AbilityTargetingDefinition.AimRequirement.EMPTY_CELL:
			if aimed_combatant != null:
				return (
					FAILURE_AIM_CELL_MUST_BE_EMPTY
				)

		AbilityTargetingDefinition.AimRequirement.ANY_CELL:
			pass

		_:
			return FAILURE_INVALID_ABILITY_DEFINITION

	if (
		aimed_combatant != null
		and not _is_relation_allowed(
			actor,
			aimed_combatant,
			ability.targeting.aim_relation_mask
		)
	):
		return FAILURE_INVALID_AIM_RELATION

	return &""


func _is_aim_coordinate_in_pattern(
	targeting: AbilityTargetingDefinition,
	origin_coordinate: Vector2i,
	aim_coordinate: Vector2i,
	forward_direction: int
) -> bool:
	for aim_offset in targeting.aim_offsets:
		var oriented_offset := Vector2i(
			aim_offset.x * forward_direction,
			aim_offset.y
		)

		if (
			origin_coordinate + oriented_offset
			== aim_coordinate
		):
			return true

	return false


func _get_combatant_at_coordinate(
	session: BattleSession,
	coordinate: Vector2i
) -> CombatantState:
	if session == null or session.grid == null:
		return null

	var cell := session.grid.get_cell(
		coordinate
	)

	if cell == null or not cell.is_occupied():
		return null

	return session.get_combatant(
		cell.occupant_id
	)


func _is_relation_allowed(
	actor: CombatantState,
	target: CombatantState,
	relation_mask: int
) -> bool:
	var relation_bit := _get_relation_bit(
		actor,
		target
	)

	return (
		relation_bit != 0
		and (
			relation_mask
			& relation_bit
		) != 0
	)


func _get_relation_bit(
	actor: CombatantState,
	target: CombatantState
) -> int:
	if actor == null or target == null:
		return 0

	if actor == target:
		return (
			AbilityTargetingDefinition
			.RelationMask.SELF
		)

	if actor.team_id == target.team_id:
		return (
			AbilityTargetingDefinition
			.RelationMask.ALLY
		)

	return (
		AbilityTargetingDefinition
		.RelationMask.ENEMY
	)
```

---

## FILE: `presentation/battle/actions/battle_action_outcome.gd`
```gdscript
class_name BattleActionOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var command: BattleActionCommand
var action_result: BattleActionResult

var action_presented: bool = false
var defeated_view_removed: bool = false


func did_execute() -> bool:
	return (
		action_result != null
		and action_result.is_successful
	)


func get_total_applied_amount(
	effect_kind: StringName = &""
) -> int:
	if action_result == null:
		return 0

	return action_result.get_total_applied_amount(
		effect_kind
	)


func did_target_die() -> bool:
	return (
		action_result != null
		and action_result.did_target_die()
	)
```

---

## FILE: `presentation/battle/actions/battle_action_runner.gd`
```gdscript
class_name BattleActionRunner
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_COMMAND: StringName = (
	&"invalid_command"
)

const FAILURE_REQUIRES_SINGLE_TARGET: StringName = (
	&"requires_single_target"
)

const FAILURE_EXECUTION_FAILED: StringName = (
	&"execution_failed"
)

const FAILURE_PRESENTATION_FAILED: StringName = (
	&"presentation_failed"
)

const FAILURE_DEFEATED_VIEW_REMOVAL_FAILED: StringName = (
	&"defeated_view_removal_failed"
)


var action_service: BattleActionService
var combatant_presenter: BattleCombatantPresenter


func _init(
	p_action_service: BattleActionService,
	p_combatant_presenter: BattleCombatantPresenter
) -> void:
	assert(
		p_action_service != null,
		"BattleActionRunner requires an action service."
	)

	assert(
		p_combatant_presenter != null,
		"BattleActionRunner requires "
		+"a combatant presenter."
	)

	action_service = p_action_service
	combatant_presenter = p_combatant_presenter


func can_execute(
	session: BattleSession,
	command: BattleActionCommand
) -> bool:
	return get_validation_failure(
		session,
		command
	) == &""


func get_validation_failure(
	session: BattleSession,
	command: BattleActionCommand
) -> StringName:
	if session == null:
		return FAILURE_INVALID_SESSION

	if command == null:
		return FAILURE_INVALID_COMMAND

	var action_failure := (
		action_service.get_validation_failure(
			session,
			command
		)
	)

	if action_failure != &"":
		return action_failure

	var targeting_result := (
		action_service.get_targeting_result(
			session,
			command
		)
	)

	if (
		not targeting_result.is_valid
		or targeting_result
		.affected_combatants.size() != 1
	):
		return FAILURE_REQUIRES_SINGLE_TARGET

	return &""


func execute_melee(
	session: BattleSession,
	command: BattleActionCommand,
	animated: bool = true,
	remove_defeated_view: bool = true
) -> BattleActionOutcome:
	var outcome := BattleActionOutcome.new()

	outcome.command = command

	var validation_failure := (
		get_validation_failure(
			session,
			command
		)
	)

	if validation_failure != &"":
		outcome.failure_code = (
			validation_failure
		)

		return outcome

	outcome.action_result = (
		action_service.execute(
			session,
			command
		)
	)

	if not outcome.action_result.is_successful:
		outcome.failure_code = (
			outcome.action_result.failure_code
			if outcome.action_result.failure_code
			!= &""
			else FAILURE_EXECUTION_FAILED
		)

		return outcome

	var target_id := (
		outcome.action_result
		.get_primary_target_id()
	)

	var target_died := (
		outcome.action_result.did_target_die(
			target_id
		)
	)

	outcome.action_presented = await (
		combatant_presenter.play_melee_feedback(
			command.actor.instance_id,
			target_id,
			target_died,
			animated
		)
	)

	if not outcome.action_presented:
		outcome.failure_code = (
			FAILURE_PRESENTATION_FAILED
		)

		return outcome

	if (
		remove_defeated_view
		and target_died
	):
		outcome.defeated_view_removed = (
			combatant_presenter.remove_view(
				target_id
			)
		)

		if not outcome.defeated_view_removed:
			outcome.failure_code = (
				FAILURE_DEFEATED_VIEW_REMOVAL_FAILED
			)

			return outcome

	outcome.is_successful = true
	return outcome
```

---

## FILE: `presentation/battle/combatants/battle_combatant_presenter.gd`
```gdscript
class_name BattleCombatantPresenter
extends RefCounted


var grid_view: BattleGridView
var combatant_layer: Node2D
var combatant_view_scene: PackedScene

var _views: Dictionary = {}


func _init(
	p_grid_view: BattleGridView,
	p_combatant_layer: Node2D,
	p_combatant_view_scene: PackedScene
) -> void:
	assert(p_grid_view != null, "Grid view is required.")
	assert(p_combatant_layer != null, "Combatant layer is required.")
	assert(p_combatant_view_scene != null, "Combatant view scene is required.")

	grid_view = p_grid_view
	combatant_layer = p_combatant_layer
	combatant_view_scene = p_combatant_view_scene


func add_combatant(
	state: CombatantState,
	selected: bool = false
) -> CombatantView:
	if state == null or state.instance_id == &"":
		return null

	if has_view(state.instance_id):
		return null

	var instance := combatant_view_scene.instantiate()

	if not (instance is CombatantView):
		push_error(
			"Combatant view scene must inherit CombatantView."
		)
		instance.queue_free()
		return null

	var view := instance as CombatantView

	combatant_layer.add_child(view)
	view.bind_state(state)
	view.set_selected_state(selected)
	view.snap_to_local_position(
		grid_view.get_cell_center(state.grid_position)
	)

	_views[state.instance_id] = view
	return view


func has_view(instance_id: StringName) -> bool:
	return get_view(instance_id) != null


func get_view(instance_id: StringName) -> CombatantView:
	if not _views.has(instance_id):
		return null

	var value: Variant = _views[instance_id]

	if not is_instance_valid(value):
		_views.erase(instance_id)
		return null

	return value as CombatantView


func move_along_grid_path(
	instance_id: StringName,
	grid_path: Array[Vector2i],
	animated: bool = true
) -> bool:
	var view := get_view(instance_id)

	if view == null or grid_path.is_empty():
		return false

	var local_path: Array[Vector2] = []

	for coordinate in grid_path:
		if not grid_view.is_valid_coordinate(coordinate):
			return false

		local_path.append(
			grid_view.get_cell_center(coordinate)
		)

	view.move_along_local_path(local_path, animated)

	if animated:
		await view.movement_finished

	return true


func face_toward(
	actor_id: StringName,
	target_id: StringName
) -> bool:
	var actor_view := get_view(actor_id)
	var target_view := get_view(target_id)

	if actor_view == null or target_view == null:
		return false

	var horizontal_distance := (
		target_view.position.x - actor_view.position.x
	)

	if not is_zero_approx(horizontal_distance):
		actor_view.set_facing_direction(
			1 if horizontal_distance > 0.0 else -1
		)

	return true


func play_melee_feedback(
	actor_id: StringName,
	target_id: StringName,
	target_died: bool = false,
	animated: bool = true
) -> bool:
	var actor_view := get_view(actor_id)
	var target_view := get_view(target_id)

	if actor_view == null or target_view == null:
		return false

	face_toward(actor_id, target_id)

	actor_view.play_visual_animation(&"attack", &"idle")
	target_view.play_visual_animation(&"hit", &"idle")

	if not animated:
		_finish_melee_feedback(
			actor_view,
			target_view,
			target_died
		)
		return true

	var actor_start := actor_view.position
	var target_original_modulate := target_view.modulate
	var direction := (
		target_view.position - actor_view.position
	).normalized()

	var tween := combatant_layer.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		actor_view,
		"position",
		actor_start + direction * 22.0,
		0.08
	)

	tween.parallel().tween_property(
		target_view,
		"modulate",
		Color(1.0, 0.28, 0.22, 1.0),
		0.06
	)

	tween.tween_property(
		actor_view,
		"position",
		actor_start,
		0.11
	)

	tween.parallel().tween_property(
		target_view,
		"modulate",
		target_original_modulate,
		0.11
	)

	await tween.finished

	_finish_melee_feedback(
		actor_view,
		target_view,
		target_died
	)

	return true


func remove_view(instance_id: StringName) -> bool:
	var view := get_view(instance_id)

	if view == null:
		return false

	_views.erase(instance_id)
	view.queue_free()
	return true


func clear() -> void:
	for value in _views.keys():
		var instance_id: StringName = value
		remove_view(instance_id)


func _finish_melee_feedback(
	actor_view: CombatantView,
	target_view: CombatantView,
	target_died: bool
) -> void:
	if is_instance_valid(actor_view):
		actor_view.play_visual_animation(&"idle", &"")

	if not is_instance_valid(target_view):
		return

	if target_died:
		target_view.play_visual_animation(&"death", &"")
	else:
		target_view.play_visual_animation(&"idle", &"")
```

---

## FILE: `presentation/battle/combatants/combatant_visual.gd`
```gdscript
@tool
class_name CombatantVisual
extends Node2D


const EMPTY_ANIMATION: StringName = &""


@export_group("Structure")

@export
var visual_root_path: NodePath = ^"VisualRoot"

@export
var animation_player_path: NodePath = ^"AnimationPlayer"

@export
var hit_anchor_path: NodePath = ^"HitAnchor"

@export
var projectile_anchor_path: NodePath = ^"ProjectileAnchor"

@export
var effects_anchor_path: NodePath = ^"EffectsAnchor"


@export_group("Facing")

@export
var faces_right_by_default: bool = true


var _visual_root: Node2D
var _animation_player: AnimationPlayer
var _hit_anchor: Node2D
var _projectile_anchor: Node2D
var _effects_anchor: Node2D


func _ready() -> void:
	_cache_nodes()


func _cache_nodes() -> void:
	_visual_root = (
		get_node_or_null(visual_root_path)
		as Node2D
	)

	_animation_player = (
		get_node_or_null(animation_player_path)
		as AnimationPlayer
	)

	_hit_anchor = (
		get_node_or_null(hit_anchor_path)
		as Node2D
	)

	_projectile_anchor = (
		get_node_or_null(projectile_anchor_path)
		as Node2D
	)

	_effects_anchor = (
		get_node_or_null(effects_anchor_path)
		as Node2D
	)


func set_facing_direction(direction: int) -> void:
	if direction == 0:
		return

	if _visual_root == null:
		_cache_nodes()

	if _visual_root == null:
		return

	var should_face_right := direction > 0
	var use_positive_scale := (
		should_face_right == faces_right_by_default
	)

	var current_scale := _visual_root.scale
	var absolute_x := absf(current_scale.x)

	if is_zero_approx(absolute_x):
		absolute_x = 1.0

	current_scale.x = (
		absolute_x
		if use_positive_scale
		else -absolute_x
	)

	_visual_root.scale = current_scale


func play_animation(
	animation_key: StringName,
	fallback_key: StringName = &"idle"
) -> bool:
	if _animation_player == null:
		_cache_nodes()

	if _animation_player == null:
		return false

	if (
		animation_key != EMPTY_ANIMATION
		and _animation_player.has_animation(animation_key)
	):
		_animation_player.play(animation_key)
		return true

	if (
		fallback_key != EMPTY_ANIMATION
		and _animation_player.has_animation(fallback_key)
	):
		_animation_player.play(fallback_key)
		return true

	return false


func play_idle() -> bool:
	return play_animation(&"idle", EMPTY_ANIMATION)


func play_move() -> bool:
	return play_animation(&"move", &"idle")


func play_hit() -> bool:
	return play_animation(&"hit", &"idle")


func play_block() -> bool:
	return play_animation(&"block", &"idle")


func play_death() -> bool:
	return play_animation(&"death", EMPTY_ANIMATION)


func get_hit_anchor_global_position() -> Vector2:
	if _hit_anchor == null:
		_cache_nodes()

	if _hit_anchor != null:
		return _hit_anchor.global_position

	return global_position


func get_projectile_anchor_global_position() -> Vector2:
	if _projectile_anchor == null:
		_cache_nodes()

	if _projectile_anchor != null:
		return _projectile_anchor.global_position

	return global_position


func get_effects_anchor_global_position() -> Vector2:
	if _effects_anchor == null:
		_cache_nodes()

	if _effects_anchor != null:
		return _effects_anchor.global_position

	return global_position
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

var session_factory := BattleSessionFactory.new()

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService

var _obstacle_counter: int = 0
var _interaction_in_progress: bool = false

var _hovered_coordinate: Vector2i = (
	BattleGridView.INVALID_COORDINATE
)


func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_action_services()
	_create_combatant_presenter()
	_create_movement_runner()
	_create_action_runner()
	_create_grid_overlay_presenter()
	_create_ai_system()
	_create_reinforcement_system()
	_connect_grid_signals()
	_create_turn_controller()


func _create_action_services() -> void:
	targeting_service = (
		BattleTargetingService.new()
	)

	action_service = BattleActionService.new(
		targeting_service
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

	turn_controller.turn_started.connect(
		_on_turn_started
	)

	turn_controller.battle_finished.connect(
		_on_battle_finished
	)

	var started := turn_controller.start(
		session,
		reinforcement_controller
	)

	assert(
		started,
		"Failed to start battle turn controller."
	)


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

func _connect_grid_signals() -> void:
	grid_view.cell_clicked.connect(
		_on_grid_cell_clicked
	)

	grid_view.cell_hovered.connect(
		_on_grid_cell_hovered
	)


func _unhandled_input(
	event: InputEvent
) -> void:
	if _interaction_in_progress:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_SPACE
		and _is_player_turn()
	):
		_end_active_turn()


func _on_grid_cell_hovered(
	coordinate: Vector2i
) -> void:
	_hovered_coordinate = coordinate

	if not _interaction_in_progress:
		_refresh_grid_overlays()


func _on_grid_cell_clicked(
	coordinate: Vector2i,
	mouse_button: int
) -> void:
	if _interaction_in_progress:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	if not _is_player_turn():
		return

	var active_combatant := (
		_get_active_combatant()
	)

	if active_combatant == null:
		return

	match mouse_button:
		MOUSE_BUTTON_LEFT:
			var ability := (
				_get_default_ability(
					active_combatant
				)
			)

			var target := (
				_get_combatant_at_coordinate(
					coordinate
				)
			)

			# Это уже позволит следующим способностям
			# применяться по пустым клеткам.
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
				_set_status(
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
				_set_status(
					"Клетка %s занята союзником %s."
					% [
						coordinate,
						target.definition.display_name,
					]
				)

			else:
				# Враг есть, но клетка может быть
				# вне маски. Показываем ошибку атаки,
				# а не ошибку движения.
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

		MOUSE_BUTTON_RIGHT:
			_toggle_obstacle(
				coordinate
			)


func _get_active_combatant() -> CombatantState:
	if turn_controller == null:
		return null

	if not turn_controller.is_running:
		return null

	return turn_controller.active_combatant
func _get_default_ability(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	return combatant.get_default_ability()


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

func _is_player_turn() -> bool:
	var active_combatant := (
		_get_active_combatant()
	)

	return (
		active_combatant != null
		and active_combatant.team_id
		== PLAYER_TEAM_ID
	)


func _end_active_turn() -> void:
	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	turn_controller.end_current_turn()


func _on_turn_started(
	combatant: CombatantState,
	current_round: int,
	_turn_index: int
) -> void:
	_set_active_combatant_selection(
		combatant
	)

	_refresh_grid_overlays()

	if combatant.team_id == PLAYER_TEAM_ID:
		_interaction_in_progress = false

		_set_status(
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
			+"Space — завершить ход."
		)

		return

	_interaction_in_progress = true

	_set_status(
		"Раунд %d. Ход врага: %s."
		% [
			current_round,
			combatant.definition.display_name,
		]
	)

	call_deferred(
		"_run_ai_turn",
		combatant
	)


func _on_battle_finished(
	winning_team_id: StringName
) -> void:
	_interaction_in_progress = false

	_set_active_combatant_selection(
		null
	)

	grid_overlay_presenter.clear()

	if winning_team_id == PLAYER_TEAM_ID:
		_set_status(
			"Бой завершён. Победа!"
		)

	elif winning_team_id == ENEMY_TEAM_ID:
		_set_status(
			"Бой завершён. Поражение."
		)

	else:
		_set_status(
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

	var ability := _get_default_ability(
		combatant
	)

	if ability == null:
		_set_status(
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
		_set_status(
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
		_interaction_in_progress = false
		return

	if not outcome.is_successful:
		_set_status(
			"Ход ИИ выполнен не полностью: %s."
			% outcome.failure_code
		)

	elif outcome.did_attack():
		_set_status(
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
		_set_status(
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
		_set_status(
			"%s не может действовать."
			% combatant.definition.display_name
		)

	_refresh_grid_overlays()

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
		_set_status(
			_get_movement_failure_message(
				plan.failure_code,
				plan,
				combatant
			)
		)

		_refresh_grid_overlays()
		return

	var previous_coordinate := (
		combatant.grid_position
	)

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	_set_status(
		"%s движется к клетке %s..."
		% [
			combatant.definition.display_name,
			plan.target_coordinate,
		]
	)

	var movement_outcome := await (
		movement_runner.execute(
			grid,
			combatant,
			plan,
			animate_movement
		)
	)

	if not movement_outcome.is_successful:
		_interaction_in_progress = false

		_set_status(
			"Не удалось выполнить перемещение: %s."
			% movement_outcome.failure_code
		)

		_refresh_grid_overlays()
		return

	_set_status(
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
	_refresh_grid_overlays()


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

	var ability := _get_default_ability(
		actor
	)

	if ability == null:
		_set_status(
			"%s не имеет доступных способностей."
			% actor.definition.display_name
		)

		return

	var target := _get_combatant_at_coordinate(
		aim_coordinate
	)

	var command := BattleActionCommand.new(
		actor,
		ability,
		aim_coordinate
	)

	var failure_code := (
		action_runner.get_validation_failure(
			session,
			command
		)
	)

	if failure_code != &"":
		_set_status(
			_get_action_failure_message(
				failure_code,
				actor,
				ability
			)
		)

		_refresh_grid_overlays()
		return

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	var action_outcome := await (
		action_runner.execute_melee(
			session,
			command,
			animate_actions
		)
	)

	if not action_outcome.is_successful:
		_interaction_in_progress = false

		_set_status(
			"Действие не выполнено: %s."
			% action_outcome.failure_code
		)

		_refresh_grid_overlays()
		return

	if turn_controller.is_finished:
		_interaction_in_progress = false
		return

	var damage_dealt := (
		action_outcome.get_total_applied_amount(
			&"damage"
		)
	)

	if (
		target != null
		and action_outcome.did_target_die()
	):
		_set_status(
			"%s использует «%s». Урон: %d. "
			% [
				actor.definition.display_name,
				ability.display_name,
				damage_dealt,
			]
			+"%s погиб. Его клетка освобождена. "
			% target.definition.display_name
			+"Выносливость бойца: %d/%d."
			% [
				actor.current_stamina,
				actor.max_stamina,
			]
		)

	elif target != null:
		_set_status(
			"%s использует «%s». Урон: %d. "
			% [
				actor.definition.display_name,
				ability.display_name,
				damage_dealt,
			]
			+"Здоровье цели: %d/%d. "
			% [
				target.current_health,
				target.max_health,
			]
			+"Выносливость бойца: %d/%d."
			% [
				actor.current_stamina,
				actor.max_stamina,
			]
		)

	else:
		_set_status(
			"%s использует «%s» по клетке %s."
			% [
				actor.definition.display_name,
				ability.display_name,
				aim_coordinate,
			]
		)

	_interaction_in_progress = false
	_refresh_grid_overlays()


func _toggle_obstacle(
	coordinate: Vector2i
) -> void:
	var cell := grid.get_cell(coordinate)

	if cell == null:
		return

	if cell.is_occupied():
		_set_status(
			"Нельзя поставить препятствие под бойца."
		)
		return

	if cell.has_obstacle():
		var obstacle_id := cell.obstacle_id

		grid.remove_obstacle(
			obstacle_id
		)

		_set_status(
			"Препятствие удалено с клетки %s."
			% coordinate
		)

		_refresh_grid_overlays()
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
		_set_status(
			"Не удалось поставить препятствие."
		)
		return

	_set_status(
		"Препятствие установлено на клетку %s."
		% coordinate
	)

	_refresh_grid_overlays()


func _refresh_grid_overlays() -> void:
	if grid_overlay_presenter == null:
		return

	if turn_controller == null:
		grid_overlay_presenter.clear()
		return

	if not turn_controller.is_running:
		grid_overlay_presenter.clear()
		return

	var active := (
		turn_controller.active_combatant
	)

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

	var selected_ability := (
		_get_default_ability(
			active
		)
	)

	grid_overlay_presenter.refresh(
		session,
		active,
		target_candidates,
		selected_ability,
		_hovered_coordinate,
		stamina_cost_per_cell
	)


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


func _set_status(message: String) -> void:
	status_label.text = message
```

---


## ✅ STATS
- Total files in tree: 59
- Readable files: 55
- Included files written: 30
- Trimmed files: 0
- Total lines written: 4263
