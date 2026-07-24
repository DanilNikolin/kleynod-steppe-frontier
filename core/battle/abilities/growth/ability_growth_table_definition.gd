@tool
class_name AbilityGrowthTableDefinition
extends Resource


const MAX_RANK: int = 10


@export_group("Ranks")

## Исходная AbilityDefinition является Rank 0.
##
## Элементы массива:
## index 0 = изменения Rank 1;
## index 1 = изменения Rank 2;
## ...
## index 9 = изменения Rank 10.
##
## Изменения применяются последовательно.
@export
var rank_steps: Array[AbilityGrowthRankDefinition] = []


func get_rank_step(
	rank: int
) -> AbilityGrowthRankDefinition:
	if rank <= 0 or rank > MAX_RANK:
		return null

	var step_index := rank - 1

	if step_index >= rank_steps.size():
		return null

	return rank_steps[step_index]


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if rank_steps.size() != MAX_RANK:
		errors.append(
			"Growth table must contain exactly "
			+"%d rank steps, but contains %d."
			% [
				MAX_RANK,
				rank_steps.size(),
			]
		)

	for step_index in range(
		rank_steps.size()
	):
		var rank_step := rank_steps[
			step_index
		]

		var rank := step_index + 1

		if rank_step == null:
			errors.append(
				"Growth rank %d is null."
				% rank
			)

			continue

		for rank_error in (
			rank_step.get_validation_errors()
		):
			errors.append(
				"Growth rank %d: %s"
				% [
					rank,
					rank_error,
				]
			)

	return errors