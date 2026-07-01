# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/abilities/ability_definition.gd', 'core/battle/targeting/ability_targeting_definition.gd', 'content/abilities/debug/debug_sabre_slash.tres', 'content/abilities/debug/debug_sweeping_slash.tres', 'content/loadouts/debug/debug_sechevik_loadout.tres', 'content/loadouts/debug/debug_sweeping_sechevik_loadout.tres']`
- Allow addons: `False`
- Included files planned: `6`

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
│           ├── debug_bleeding.tres
│           ├── debug_cracked_defense.tres
│           └── debug_regeneration.tres
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
│       │   ├── effect_resolver.gd
│       │   └── heal_effect.gd
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
│       │   ├── battle_status_instance.gd
│       │   ├── battle_status_periodic_processor.gd
│       │   ├── battle_status_periodic_trigger.gd
│       │   └── battle_status_periodic_trigger_result.gd
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
│   ├── battle
│   │   ├── abilities
│   │   │   ├── battle_ability_panel.gd
│   │   │   ├── battle_ability_panel.tscn
│   │   │   └── battle_ability_presentation_builder.gd
│   │   ├── actions
│   │   │   ├── battle_action_outcome.gd
│   │   │   └── battle_action_runner.gd
│   │   ├── ai
│   │   │   ├── basic_melee_ai_turn_outcome.gd
│   │   │   └── basic_melee_ai_turn_runner.gd
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
│   │   └── movement
│   │       ├── battle_movement_outcome.gd
│   │       └── battle_movement_runner.gd
│   └── common
│       └── controls
│           └── collapsible_panel_controller.gd
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

## FILE: `content/abilities/debug/debug_sabre_slash.tres`
```text
[gd_resource type="Resource" script_class="AbilityDefinition" load_steps=10 format=3 uid="uid://bh0xtv0ndcte4"]

[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="1_ability"]
[ext_resource type="Script" uid="uid://36m0bduhwx85" path="res://core/battle/targeting/ability_targeting_definition.gd" id="2_targeting"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="3_effect"]
[ext_resource type="Script" uid="uid://djty1vj4ucxrn" path="res://core/battle/effects/damage_effect.gd" id="4_damage"]
[ext_resource type="Script" uid="uid://bnwv71blsmx3l" path="res://core/battle/effects/apply_status_effect.gd" id="5_apply_status"]
[ext_resource type="Resource" uid="uid://biy4yp5jjdsj0" path="res://content/statuses/debug/debug_cracked_defense.tres" id="6_status"]

[sub_resource type="Resource" id="Resource_sabre_damage"]
script = ExtResource("4_damage")
base_damage = 4
effect_id = &"effect_sabre_slash_damage"

[sub_resource type="Resource" id="Resource_sabre_status"]
script = ExtResource("5_apply_status")
status_definition = ExtResource("6_status")
effect_id = &"effect_sabre_slash_cracked_defense"

[sub_resource type="Resource" id="Resource_sabre_targeting"]
script = ExtResource("2_targeting")
aim_offsets = Array[Vector2i]([Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)])

[resource]
script = ExtResource("1_ability")
ability_id = &"ability_sabre_slash"
display_name = "Удар саблей"
description = "Наносит урон одному врагу и раскалывает его защиту на два хода."
stamina_cost = 3
targeting = SubResource("Resource_sabre_targeting")
effects = Array[ExtResource("3_effect")]([SubResource("Resource_sabre_damage"), SubResource("Resource_sabre_status")])
```

---

## FILE: `content/abilities/debug/debug_sweeping_slash.tres`
```text
[gd_resource type="Resource" script_class="AbilityDefinition" load_steps=7 format=3 uid="uid://bl21cyxngsid0"]

[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="1_ability"]
[ext_resource type="Script" uid="uid://36m0bduhwx85" path="res://core/battle/targeting/ability_targeting_definition.gd" id="2_targeting"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="3_effect"]
[ext_resource type="Script" uid="uid://djty1vj4ucxrn" path="res://core/battle/effects/damage_effect.gd" id="4_damage"]

[sub_resource type="Resource" id="Resource_sweeping_damage"]
script = ExtResource("4_damage")
base_damage = 4
effect_id = &"effect_sweeping_slash_damage"

[sub_resource type="Resource" id="Resource_sweeping_targeting"]
script = ExtResource("2_targeting")
aim_offsets = Array[Vector2i]([Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)])
impact_offsets = Array[Vector2i]([Vector2i(0, 0), Vector2i(0, -1), Vector2i(0, 1)])

[resource]
script = ExtResource("1_ability")
ability_id = &"ability_sweeping_slash"
display_name = "Размашистый удар"
description = "Удар по выбранному врагу и противникам в рядах сверху и снизу."
stamina_cost = 5
targeting = SubResource("Resource_sweeping_targeting")
effects = Array[ExtResource("3_effect")]([SubResource("Resource_sweeping_damage")])
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

## FILE: `content/loadouts/debug/debug_sweeping_sechevik_loadout.tres`
```text
[gd_resource type="Resource" script_class="CombatantLoadoutDefinition" load_steps=4 format=3 uid="uid://c7bo4jut344ao"]

[ext_resource type="Script" uid="uid://bis4duqvyinf4" path="res://core/battle/loadouts/combatant_loadout_definition.gd" id="1_loadout"]
[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" uid="uid://bl21cyxngsid0" path="res://content/abilities/debug/debug_sweeping_slash.tres" id="3_sweeping"]

[resource]
script = ExtResource("1_loadout")
loadout_id = &"loadout_debug_sweeping_sechevik"
display_name = "Сечевик с размашистым ударом"
default_ability_id = &"ability_sweeping_slash"
abilities = Array[ExtResource("2_ability")]([ExtResource("3_sweeping")])
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


## ✅ STATS
- Total files in tree: 85
- Readable files: 81
- Included files written: 6
- Trimmed files: 0
- Total lines written: 339
