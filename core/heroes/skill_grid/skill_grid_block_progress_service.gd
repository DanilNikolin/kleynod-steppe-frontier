class_name SkillGridBlockProgressService
extends RefCounted


func get_purchased_node_count(
	block: SkillGridBlockDefinition,
	progression: HeroProgressionState
) -> int:
	if (
		block == null
		or progression == null
	):
		return 0

	var purchased_count := 0

	for node_id in block.node_ids:
		if progression.purchased_node_ids.has(
			node_id
		):
			purchased_count += 1

	return purchased_count


func get_required_additional_node_count(
	block: SkillGridBlockDefinition,
	progression: HeroProgressionState
) -> int:
	if block == null:
		return 0

	return maxi(
		0,
		block.minimum_purchased_nodes
			- get_purchased_node_count(
				block,
				progression
			)
	)


func has_reached_exit(
	block: SkillGridBlockDefinition,
	progression: HeroProgressionState
) -> bool:
	if (
		block == null
		or progression == null
	):
		return false

	for exit_node_id in (
		block.exit_anchor_node_ids
	):
		if progression.purchased_node_ids.has(
			exit_node_id
		):
			return true

	return false


func is_ready_for_expansion(
	block: SkillGridBlockDefinition,
	progression: HeroProgressionState
) -> bool:
	if (
		block == null
		or progression == null
		or block.block_id == &""
	):
		return false

	if not progression.attached_skill_block_ids.has(
		block.block_id
	):
		return false

	if (
		get_purchased_node_count(
			block,
			progression
		)
		< block.minimum_purchased_nodes
	):
		return false

	return has_reached_exit(
		block,
		progression
	)