class_name SkillGridBlockAttachmentService
extends RefCounted


const FAILURE_INVALID_GRID: StringName = (
	&"invalid_skill_grid"
)

const FAILURE_INVALID_PROGRESSION: StringName = (
	&"invalid_progression_state"
)

const FAILURE_INVALID_ATTACHMENT_HISTORY: StringName = (
	&"invalid_attachment_history"
)

const FAILURE_EMPTY_BLOCK_ID: StringName = (
	&"empty_block_id"
)

const FAILURE_UNKNOWN_BLOCK: StringName = (
	&"unknown_block"
)

const FAILURE_ALREADY_ATTACHED: StringName = (
	&"block_already_attached"
)

const FAILURE_PREVIOUS_BLOCK_NOT_READY: StringName = (
	&"previous_block_not_ready"
)

const FAILURE_BLOCK_NOT_CANDIDATE: StringName = (
	&"block_not_attachment_candidate"
)


var block_progress_service := (
	SkillGridBlockProgressService.new()
)


func get_attachment_candidates(
	grid: SkillGridDefinition,
	progression: HeroProgressionState
) -> Array[SkillGridBlockDefinition]:
	var result: Array[SkillGridBlockDefinition] = []

	if (
		grid == null
		or not grid.is_valid_definition()
	):
		return result

	if (
		progression == null
		or not progression.is_valid_state()
	):
		return result

	if not _has_valid_attachment_history(
		grid,
		progression
	):
		return result

	if not progression.attached_skill_block_ids.is_empty():
		var latest_block := get_latest_attached_block(
			grid,
			progression
		)

		if latest_block == null:
			return result

		if not block_progress_service.is_ready_for_expansion(
			latest_block,
			progression
		):
			return result

	for branch in _get_standard_branches():
		var expected_order := _get_next_branch_order(
			grid,
			progression,
			branch
		)

		var candidate := _get_block_by_branch_order(
			grid,
			branch,
			expected_order
		)

		if candidate == null:
			continue

		if progression.attached_skill_block_ids.has(
			candidate.block_id
		):
			continue

		result.append(
			candidate
		)

	return result


func can_attach(
	grid: SkillGridDefinition,
	progression: HeroProgressionState,
	block_id: StringName
) -> bool:
	return get_attachment_result(
		grid,
		progression,
		block_id
	).is_successful


func get_attachment_result(
	grid: SkillGridDefinition,
	progression: HeroProgressionState,
	block_id: StringName
) -> SkillGridBlockAttachmentResult:
	var result := SkillGridBlockAttachmentResult.new()

	result.block_id = block_id

	if (
		grid == null
		or not grid.is_valid_definition()
	):
		result.failure_code = FAILURE_INVALID_GRID
		return result

	if (
		progression == null
		or not progression.is_valid_state()
	):
		result.failure_code = FAILURE_INVALID_PROGRESSION
		return result

	if not _has_valid_attachment_history(
		grid,
		progression
	):
		result.failure_code = (
			FAILURE_INVALID_ATTACHMENT_HISTORY
		)

		return result

	if block_id == &"":
		result.failure_code = FAILURE_EMPTY_BLOCK_ID
		return result

	var block := grid.get_block_definition(
		block_id
	)

	if block == null:
		result.failure_code = FAILURE_UNKNOWN_BLOCK
		return result

	if progression.attached_skill_block_ids.has(
		block_id
	):
		result.failure_code = FAILURE_ALREADY_ATTACHED
		return result

	if not progression.attached_skill_block_ids.is_empty():
		var latest_block := get_latest_attached_block(
			grid,
			progression
		)

		if (
			latest_block == null
			or not block_progress_service
				.is_ready_for_expansion(
					latest_block,
					progression
				)
		):
			result.failure_code = (
				FAILURE_PREVIOUS_BLOCK_NOT_READY
			)

			return result

	for candidate in get_attachment_candidates(
		grid,
		progression
	):
		if candidate.block_id != block_id:
			continue

		result.is_successful = true
		return result

	result.failure_code = FAILURE_BLOCK_NOT_CANDIDATE
	return result


func attach(
	grid: SkillGridDefinition,
	progression: HeroProgressionState,
	block_id: StringName
) -> SkillGridBlockAttachmentResult:
	var result := get_attachment_result(
		grid,
		progression,
		block_id
	)

	if not result.is_successful:
		return result

	progression.attached_skill_block_ids.append(
		block_id
	)

	return result


func get_latest_attached_block(
	grid: SkillGridDefinition,
	progression: HeroProgressionState
) -> SkillGridBlockDefinition:
	if (
		grid == null
		or progression == null
		or progression
			.attached_skill_block_ids
			.is_empty()
	):
		return null

	var latest_block_id := (
		progression.attached_skill_block_ids[
			progression.attached_skill_block_ids.size() - 1
		]
	)

	return grid.get_block_definition(
		latest_block_id
	)


func _get_standard_branches() -> Array[int]:
	var result: Array[int] = [
		SkillGridNodeDefinition.Branch.STRENGTH,
		SkillGridNodeDefinition.Branch.AGILITY,
		SkillGridNodeDefinition.Branch.SPIRIT,
	]

	return result


func _get_next_branch_order(
	grid: SkillGridDefinition,
	progression: HeroProgressionState,
	branch: int
) -> int:
	var highest_attached_order := 0

	for block_id in (
		progression.attached_skill_block_ids
	):
		var block := grid.get_block_definition(
			block_id
		)

		if (
			block == null
			or block.branch != branch
		):
			continue

		highest_attached_order = maxi(
			highest_attached_order,
			block.branch_order
		)

	return highest_attached_order + 1


func _get_block_by_branch_order(
	grid: SkillGridDefinition,
	branch: int,
	branch_order: int
) -> SkillGridBlockDefinition:
	for block in grid.blocks:
		if block == null:
			continue

		if (
			block.branch == branch
			and block.branch_order == branch_order
		):
			return block

	return null


func _has_valid_attachment_history(
	grid: SkillGridDefinition,
	progression: HeroProgressionState
) -> bool:
	var last_order_by_branch: Dictionary = {}

	for block_id in (
		progression.attached_skill_block_ids
	):
		var block := grid.get_block_definition(
			block_id
		)

		if block == null:
			return false

		if (
			block.branch
			== SkillGridNodeDefinition.Branch.NONE
		):
			return false

		var previous_order := int(
			last_order_by_branch.get(
				block.branch,
				0
			)
		)

		if (
			block.branch_order
			!= previous_order + 1
		):
			return false

		last_order_by_branch[
			block.branch
		] = block.branch_order

	return true