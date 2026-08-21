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


@export_group("Reactor Health")

## 0 означает: нижнего ограничения фактически нет.
@export_range(0, 9999, 1)
var minimum_reactor_health: int = 0

## -1 означает: верхнего ограничения нет.
@export_range(-1, 9999, 1)
var maximum_reactor_health: int = -1


@export_group("Effects")

@export
var effects: Array[BattleEffect] = []


@export_group("Consumption")

## Подходит для реакций вида:
## «первый враг, который ударит...».
@export
var consume_status_on_trigger: bool = false


func matches_reactor_health(
	current_health: int
) -> bool:
	if current_health < minimum_reactor_health:
		return false

	if (
		maximum_reactor_health >= 0
		and current_health > maximum_reactor_health
	):
		return false

	return true


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if minimum_reactor_health < 0:
		errors.append(
			"Minimum reactor health cannot be negative."
		)

	if maximum_reactor_health < -1:
		errors.append(
			"Maximum reactor health cannot be lower than -1."
		)

	if (
		maximum_reactor_health >= 0
		and maximum_reactor_health
			< minimum_reactor_health
	):
		errors.append(
			"Maximum reactor health cannot be lower "
			+ "than minimum reactor health."
		)

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