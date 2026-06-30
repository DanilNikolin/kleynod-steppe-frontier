@tool
class_name AbilityDefinition
extends Resource


enum TargetRelation {
	ENEMY,
	ALLY,
	SELF,
	ANY,
}


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
var target_relation: TargetRelation = TargetRelation.ENEMY

@export_range(0, 30, 1)
var minimum_range: int = 1

@export_range(0, 30, 1)
var maximum_range: int = 1


@export_group("Effects")

@export
var effects: Array[BattleEffect] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if ability_id == &"":
		errors.append("Ability ID is empty.")

	if display_name.strip_edges().is_empty():
		errors.append("Display name is empty.")

	if stamina_cost < 0:
		errors.append("Stamina cost cannot be negative.")

	if minimum_range < 0:
		errors.append("Minimum range cannot be negative.")

	if maximum_range < minimum_range:
		errors.append(
			"Maximum range cannot be lower than minimum range."
		)

	if effects.is_empty():
		errors.append("Ability must contain at least one effect.")

	for effect_index in range(effects.size()):
		var effect := effects[effect_index]

		if effect == null:
			errors.append(
				"Effect at index %d is null."
				% effect_index
			)
			continue

		var effect_errors := effect.get_validation_errors()

		for effect_error in effect_errors:
			errors.append(
				"Effect %d: %s"
				% [
					effect_index,
					effect_error,
				]
			)

	return errors