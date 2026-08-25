class_name SkillGridPurchaseService
extends RefCounted


const FAILURE_INVALID_GRID: StringName = (
	&"invalid_skill_grid"
)

const FAILURE_INVALID_PROGRESSION: StringName = (
	&"invalid_progression_state"
)

const FAILURE_EMPTY_NODE_ID: StringName = (
	&"empty_node_id"
)

const FAILURE_UNKNOWN_NODE: StringName = (
	&"unknown_node"
)

const FAILURE_ALREADY_PURCHASED: StringName = (
	&"node_already_purchased"
)

const FAILURE_BLOCK_NOT_ATTACHED: StringName = (
	&"block_not_attached"
)

const FAILURE_MISSING_PREREQUISITES: StringName = (
	&"missing_prerequisites"
)

const FAILURE_PATH_NOT_REACHED: StringName = (
	&"path_not_reached"
)

const FAILURE_NOT_ENOUGH_SKILL_POINTS: StringName = (
	&"not_enough_skill_points"
)


func can_purchase(
	grid: SkillGridDefinition,
	progression: HeroProgressionState,
	node_id: StringName
) -> bool:
	return get_purchase_result(
		grid,
		progression,
		node_id
	).is_successful


func get_purchase_result(
	grid: SkillGridDefinition,
	progression: HeroProgressionState,
	node_id: StringName
) -> SkillGridPurchaseResult:
	var result := SkillGridPurchaseResult.new()

	result.node_id = node_id

	if progression != null:
		result.previous_unspent_skill_points = (
			progression.unspent_skill_points
		)

		result.current_unspent_skill_points = (
			progression.unspent_skill_points
		)

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
		result.failure_code = (
			FAILURE_INVALID_PROGRESSION
		)

		return result

	if node_id == &"":
		result.failure_code = FAILURE_EMPTY_NODE_ID
		return result

	var node := grid.get_node_definition(
		node_id
	)

	if node == null:
		result.failure_code = FAILURE_UNKNOWN_NODE
		return result

	if progression.purchased_node_ids.has(
		node_id
	):
		result.failure_code = (
			FAILURE_ALREADY_PURCHASED
		)

		return result

	# A. Block access
	if node.block_id != &"":
		if not progression.attached_skill_block_ids.has(
			node.block_id
		):
			result.failure_code = (
				FAILURE_BLOCK_NOT_ATTACHED
			)

			return result

	# B. Hard prerequisites (AND logic)
	for prerequisite_id in (
		node.prerequisite_node_ids
	):
		if progression.purchased_node_ids.has(
			prerequisite_id
		):
			continue

		result.missing_prerequisite_node_ids.append(
			prerequisite_id
		)

	if not (
		result
			.missing_prerequisite_node_ids
			.is_empty()
	):
		result.failure_code = (
			FAILURE_MISSING_PREREQUISITES
		)

		return result

	# C. Graph path (OR logic / entry node check)
	if not node.path_parent_node_ids.is_empty():
		var has_any_path_parent_purchased := false

		for path_parent_id in (
			node.path_parent_node_ids
		):
			if progression.purchased_node_ids.has(
				path_parent_id
			):
				has_any_path_parent_purchased = true
			else:
				result.missing_path_parent_node_ids.append(
					path_parent_id
				)

		if not has_any_path_parent_purchased:
			result.failure_code = (
				FAILURE_PATH_NOT_REACHED
			)

			return result
		else:
			result.missing_path_parent_node_ids.clear()
	elif node.block_id != &"":
		var block := grid.get_block_definition(
			node.block_id
		)

		if (
			block == null
			or not block.entry_node_ids.has(
				node.node_id
			)
		):
			result.failure_code = (
				FAILURE_PATH_NOT_REACHED
			)

			return result

	# D. Skill point cost
	if (
		progression.unspent_skill_points
		< node.skill_point_cost
	):
		result.failure_code = (
			FAILURE_NOT_ENOUGH_SKILL_POINTS
		)

		return result

	result.spent_skill_points = (
		node.skill_point_cost
	)

	result.current_unspent_skill_points = (
		progression.unspent_skill_points
		- node.skill_point_cost
	)

	result.is_successful = true
	return result


func purchase(
	grid: SkillGridDefinition,
	progression: HeroProgressionState,
	node_id: StringName
) -> SkillGridPurchaseResult:
	var result := get_purchase_result(
		grid,
		progression,
		node_id
	)

	if not result.is_successful:
		return result

	progression.unspent_skill_points = (
		result.current_unspent_skill_points
	)

	progression.purchased_node_ids.append(
		node_id
	)

	return result