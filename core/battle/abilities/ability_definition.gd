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