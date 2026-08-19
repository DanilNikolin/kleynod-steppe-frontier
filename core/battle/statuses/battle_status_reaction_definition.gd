@tool
class_name BattleStatusReactionDefinition
extends Resource


enum TriggerTiming {
	AFTER_ENEMY_ACTION,
}


enum DamageRequirement {
	NONE,
	HEALTH_OR_GUARD,
	HEALTH_ONLY,
	GUARD_ONLY,
}


@export_group("Trigger")

@export
var trigger_timing: TriggerTiming = (
	TriggerTiming.AFTER_ENEMY_ACTION
)

@export
var damage_requirement: DamageRequirement = (
	DamageRequirement.HEALTH_OR_GUARD
)


@export_group("Effects")

@export
var effects: Array[BattleEffect] = []


@export_group("Consumption")

## Подходит для реакций вида:
## «первый враг, который ударит...».
@export
var consume_status_on_trigger: bool = false


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if effects.is_empty():
		errors.append(
			"Reaction must contain at least one effect."
		)

	for effect_index in range(
		effects.size()
	):
		var effect := effects[
			effect_index
		]

		if effect == null:
			errors.append(
				"Reaction effect at index %d is null."
				% effect_index
			)

			continue

		for effect_error in (
			effect.get_validation_errors()
		):
			errors.append(
				"Reaction effect %d: %s"
				% [
					effect_index,
					effect_error,
				]
			)

	return errors