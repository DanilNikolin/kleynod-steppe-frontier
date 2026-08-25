@tool
class_name HeroProgressionState
extends Resource


@export_group("Progression")

@export_range(1, 999, 1)
var level: int = 1

## Опыт внутри текущего уровня.
## При level-up порог вычитается из этого значения.
@export_range(0, 999999999, 1)
var experience: int = 0

@export_range(0, 999, 1)
var unspent_skill_points: int = 0


@export_group("Skill Grid")

@export
var purchased_node_ids: Array[StringName] = []

@export
var attached_skill_block_ids: Array[StringName] = []


@export_group("Personal Loadout")

@export
var selected_personal_ability_ids: Array[StringName] = []

@export_group("Equipment")

@export
var equipment_state: HeroEquipmentState


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if level <= 0:
		errors.append(
			"Hero level must be greater than zero."
		)

	if experience < 0:
		errors.append(
			"Hero experience cannot be negative."
		)

	if unspent_skill_points < 0:
		errors.append(
			"Unspent Skill Points cannot be negative."
		)

	_append_duplicate_id_errors(
		purchased_node_ids,
		"Purchased node",
		errors
	)

	_append_duplicate_id_errors(
		attached_skill_block_ids,
		"Attached skill block",
		errors
	)

	_append_duplicate_id_errors(
		selected_personal_ability_ids,
		"Selected personal ability",
		errors
	)

	if equipment_state != null:
		for equipment_error in (
			equipment_state.get_validation_errors()
		):
			errors.append(
				"Equipment: %s"
				% equipment_error
			)

	return errors


func _append_duplicate_id_errors(
	ids: Array[StringName],
	label: String,
	errors: PackedStringArray
) -> void:
	var used_ids: Dictionary = {}

	for value in ids:
		if value == &"":
			errors.append(
				"%s ID is empty."
				% label
			)

			continue

		if used_ids.has(
			value
		):
			errors.append(
				"Duplicate %s ID: %s."
				% [
					label.to_lower(),
					value,
				]
			)

			continue

		used_ids[
			value
		] = true