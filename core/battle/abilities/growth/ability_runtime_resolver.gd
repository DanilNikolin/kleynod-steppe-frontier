class_name AbilityRuntimeResolver
extends RefCounted


func resolve(
	source: AbilityDefinition,
	requested_rank: int
) -> AbilityDefinition:
	if source == null:
		return null

	if not source.is_valid_definition():
		return null

	var result := (
		source.duplicate(true)
		as AbilityDefinition
	)

	if result == null:
		return null

	var growth_table := source.growth_table

	var resolved_rank := clampi(
		requested_rank,
		0,
		AbilityGrowthTableDefinition.MAX_RANK
	)

	## Runtime-способность уже разрешена.
	## Повторно применять к ней таблицу нельзя.
	result.growth_table = null

	if (
		growth_table == null
		or resolved_rank <= 0
	):
		return result

	for rank in range(
		1,
		resolved_rank + 1
	):
		var rank_step := (
			growth_table.get_rank_step(
				rank
			)
		)

		if rank_step == null:
			return null

		if not _apply_rank_step(
			result,
			rank_step
		):
			return null

	if not result.is_valid_definition():
		return null

	return result


func _apply_rank_step(
	ability: AbilityDefinition,
	rank_step: AbilityGrowthRankDefinition
) -> bool:
	if ability == null or rank_step == null:
		return false

	if rank_step.initial_lock_turns_override >= 0:
		ability.initial_lock_turns = (
			rank_step.initial_lock_turns_override
		)

	if rank_step.cooldown_turns_override >= 0:
		ability.cooldown_turns = (
			rank_step.cooldown_turns_override
		)

	if rank_step.targeting_override != null:
		ability.targeting = (
			rank_step
				.targeting_override
				.duplicate(true)
			as AbilityTargetingDefinition
		)

		if ability.targeting == null:
			return false

	for effect_override in (
		rank_step.effect_overrides
	):
		if effect_override == null:
			return false

		if not _replace_effect(
			ability,
			effect_override
		):
			return false

	return true


func _replace_effect(
	ability: AbilityDefinition,
	effect_override: BattleEffect
) -> bool:
	for effect_index in range(
		ability.effects.size()
	):
		var current_effect := ability.effects[
			effect_index
		]

		if current_effect == null:
			continue

		if (
			current_effect.effect_id
			!= effect_override.effect_id
		):
			continue

		var effect_copy := (
			effect_override.duplicate(true)
			as BattleEffect
		)

		if effect_copy == null:
			return false

		ability.effects[
			effect_index
		] = effect_copy

		return true

	return false