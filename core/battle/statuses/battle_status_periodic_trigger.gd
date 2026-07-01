@tool
class_name BattleStatusPeriodicTrigger
extends Resource


enum Timing {
	OWNER_TURN_START,
	OWNER_TURN_END,
}


@export
var timing: Timing = Timing.OWNER_TURN_END

@export
var effects: Array[BattleEffect] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if effects.is_empty():
		errors.append(
			"Periodic trigger has no effects."
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