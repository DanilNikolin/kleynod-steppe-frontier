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