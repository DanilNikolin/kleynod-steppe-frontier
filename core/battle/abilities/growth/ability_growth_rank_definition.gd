@tool
class_name AbilityGrowthRankDefinition
extends Resource


@export_group("Ability")

## Значение -1 означает:
## оставить исходную стартовую задержку.
@export_range(-1, 999, 1)
var initial_lock_turns_override: int = -1

## Значение -1 означает:
## оставить исходный кулдаун.
@export_range(-1, 999, 1)
var cooldown_turns_override: int = -1


@export_group("Targeting")

## Если не задано, сохраняется targeting
## предыдущего ранга.
@export
var targeting_override: AbilityTargetingDefinition


@export_group("Effects")

## Эффекты заменяются по effect_id.
##
## Если effect_id совпадает с эффектом
## базовой способности, старая версия эффекта
## заменяется этой.
@export
var effect_overrides: Array[BattleEffect] = []


func has_changes() -> bool:
	return (
		initial_lock_turns_override >= 0
		or cooldown_turns_override >= 0
		or targeting_override != null
		or not effect_overrides.is_empty()
	)


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if not has_changes():
		errors.append(
			"Growth rank must contain at least one change."
		)

	if initial_lock_turns_override < -1:
		errors.append(
			"Initial lock override cannot be lower than -1."
		)

	if cooldown_turns_override < -1:
		errors.append(
			"Cooldown override cannot be lower than -1."
		)

	if targeting_override != null:
		for targeting_error in (
			targeting_override.get_validation_errors()
		):
			errors.append(
				"Targeting override: %s"
				% targeting_error
			)

	var used_effect_ids: Dictionary = {}

	for effect_index in range(
		effect_overrides.size()
	):
		var effect := effect_overrides[
			effect_index
		]

		if effect == null:
			errors.append(
				"Effect override at index %d is null."
				% effect_index
			)

			continue

		for effect_error in (
			effect.get_validation_errors()
		):
			errors.append(
				"Effect override %d: %s"
				% [
					effect_index,
					effect_error,
				]
			)

		if effect.effect_id == &"":
			continue

		if used_effect_ids.has(
			effect.effect_id
		):
			errors.append(
				"Duplicate effect override ID: %s."
				% effect.effect_id
			)

			continue

		used_effect_ids[
			effect.effect_id
		] = true

	return errors