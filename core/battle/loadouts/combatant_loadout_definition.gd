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