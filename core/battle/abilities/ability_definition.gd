@tool
class_name AbilityDefinition
extends Resource


enum Branch {
	NONE,
	STRENGTH,
	AGILITY,
	SPIRIT,
}


@export_group("Identity")

@export
var ability_id: StringName = &""

@export
var display_name: String = "Unnamed Ability"

@export_multiline
var description: String = ""


@export_group("Progression")

## Ветка определяет, какое значение героя
## выбирает Rank этой способности.
##
## NONE используется для старых debug-способностей
## и способностей без таблицы роста.
@export
var branch: Branch = Branch.NONE

## Исходная способность является Rank 0.
## Таблица содержит изменения Rank 1–10.
@export
var growth_table: AbilityGrowthTableDefinition


@export_group("Cost")

@export_range(0, 999, 1)
var stamina_cost: int = 1


@export_group("Cooldown")

@export_range(0, 999, 1)
var initial_lock_turns: int = 0

@export_range(0, 999, 1)
var cooldown_turns: int = 0


@export_group("Targeting")

@export
var targeting: AbilityTargetingDefinition


@export_group("Effects")

@export
var effects: Array[BattleEffect] = []


@export_group("Presentation")

## Необязательный presentation-layer Resource.
## Combat Core его не читает и не интерпретирует.
@export
var presentation_profile: Resource


func get_growth_rank(
	strength_rank: int,
	agility_rank: int,
	spirit_rank: int
) -> int:
	var result := 0

	match branch:
		Branch.STRENGTH:
			result = strength_rank

		Branch.AGILITY:
			result = agility_rank

		Branch.SPIRIT:
			result = spirit_rank

		Branch.NONE:
			result = 0

	return clampi(
		result,
		0,
		AbilityGrowthTableDefinition.MAX_RANK
	)


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

	if initial_lock_turns < 0:
		errors.append(
			"Initial lock turns cannot be negative."
		)

	if cooldown_turns < 0:
		errors.append(
			"Cooldown turns cannot be negative."
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

	var base_effect_ids: Dictionary = {}

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

		if effect.effect_id == &"":
			continue

		if base_effect_ids.has(
			effect.effect_id
		):
			errors.append(
				"Duplicate base effect ID: %s."
				% effect.effect_id
			)

			continue

		base_effect_ids[
			effect.effect_id
		] = true

	if growth_table != null:
		if branch == Branch.NONE:
			errors.append(
				"Ability with a growth table "
				+"must belong to a branch."
			)

		for growth_error in (
			growth_table.get_validation_errors()
		):
			errors.append(
				"Growth table: %s"
				% growth_error
			)

		var known_effect_ids: Dictionary = (
			base_effect_ids.duplicate()
		)

		for step_index in range(
			growth_table.rank_steps.size()
		):
			var rank_step := (
				growth_table.rank_steps[
					step_index
				]
			)

			if rank_step == null:
				continue

			for effect_addition in (
				rank_step.effect_additions
			):
				if (
					effect_addition == null
					or effect_addition.effect_id == &""
				):
					continue

				if known_effect_ids.has(
					effect_addition.effect_id
				):
					errors.append(
						"Growth rank %d adds "
						% (step_index + 1)
						+"already known effect '%s'."
						% effect_addition.effect_id
					)

					continue

				known_effect_ids[
					effect_addition.effect_id
				] = true

			for effect_override in (
				rank_step.effect_overrides
			):
				if (
					effect_override == null
					or effect_override.effect_id == &""
				):
					continue

				if not known_effect_ids.has(
					effect_override.effect_id
				):
					errors.append(
						"Growth rank %d replaces "
						% (step_index + 1)
						+"unknown effect '%s'."
						% effect_override.effect_id
					)

	return errors