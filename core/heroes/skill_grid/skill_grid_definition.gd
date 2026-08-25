@tool
class_name SkillGridDefinition
extends Resource


@export_group("Identity")

@export
var grid_id: StringName = &""

@export
var display_name: String = "Unnamed Skill Grid"


@export_group("Blocks")

@export
var blocks: Array[SkillGridBlockDefinition] = []


@export_group("Nodes")

@export
var nodes: Array[SkillGridNodeDefinition] = []


func get_node_definition(
	node_id: StringName
) -> SkillGridNodeDefinition:
	if node_id == &"":
		return null

	for node in nodes:
		if (
			node != null
			and node.node_id == node_id
		):
			return node

	return null


func has_node(
	node_id: StringName
) -> bool:
	return get_node_definition(
		node_id
	) != null


func get_block_definition(
	block_id: StringName
) -> SkillGridBlockDefinition:
	if block_id == &"":
		return null

	for block in blocks:
		if (
			block != null
			and block.block_id == block_id
		):
			return block

	return null


func has_block(
	block_id: StringName
) -> bool:
	return get_block_definition(
		block_id
	) != null


func get_nodes_for_block(
	block_id: StringName
) -> Array[SkillGridNodeDefinition]:
	var block_nodes: Array[SkillGridNodeDefinition] = []

	if block_id == &"":
		return block_nodes

	for node in nodes:
		if (
			node != null
			and node.block_id == block_id
		):
			block_nodes.append(node)

	return block_nodes


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if grid_id == &"":
		errors.append(
			"Skill Grid ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Skill Grid display name is empty."
		)

	if nodes.is_empty():
		errors.append(
			"Skill Grid must contain at least one node."
		)

	var used_block_ids: Dictionary = {}

	for block_index in range(
		blocks.size()
	):
		var block := blocks[
			block_index
		]

		if block == null:
			errors.append(
				"Skill Grid block at index %d is null."
				% block_index
			)

			continue

		for block_error in (
			block.get_validation_errors()
		):
			errors.append(
				"Block %d: %s"
				% [
					block_index,
					block_error,
				]
			)

		if block.block_id == &"":
			continue

		if used_block_ids.has(
			block.block_id
		):
			errors.append(
				"Duplicate Skill Grid block ID: %s."
				% block.block_id
			)

			continue

		used_block_ids[
			block.block_id
		] = true

	var used_node_ids: Dictionary = {}

	for node_index in range(
		nodes.size()
	):
		var node := nodes[
			node_index
		]

		if node == null:
			errors.append(
				"Skill Grid node at index %d is null."
				% node_index
			)

			continue

		for node_error in (
			node.get_validation_errors()
		):
			errors.append(
				"Node %d: %s"
				% [
					node_index,
					node_error,
				]
			)

		if node.node_id == &"":
			continue

		if used_node_ids.has(
			node.node_id
		):
			errors.append(
				"Duplicate Skill Grid node ID: %s."
				% node.node_id
			)

			continue

		used_node_ids[
			node.node_id
		] = true

	for block in blocks:
		if block == null:
			continue

		for block_node_id in block.node_ids:
			var target_node := get_node_definition(
				block_node_id
			)

			if target_node == null:
				errors.append(
					"Block '%s' references unknown node '%s'."
					% [
						block.block_id,
						block_node_id,
					]
				)
			elif (
				target_node.block_id
				!= block.block_id
			):
				errors.append(
					"Node '%s' in block '%s' has mismatched block_id '%s'."
					% [
						block_node_id,
						block.block_id,
						target_node.block_id,
					]
				)

	for node in nodes:
		if node == null:
			continue

		if node.block_id != &"":
			var assigned_block := get_block_definition(
				node.block_id
			)

			if assigned_block == null:
				errors.append(
					"Node '%s' references unknown block '%s'."
					% [
						node.node_id,
						node.block_id,
					]
				)
			elif not assigned_block.node_ids.has(
				node.node_id
			):
				errors.append(
					"Block '%s' does not contain node '%s'."
					% [
						node.block_id,
						node.node_id,
					]
				)

		for prerequisite_id in (
			node.prerequisite_node_ids
		):
			if not used_node_ids.has(
				prerequisite_id
			):
				errors.append(
					"Node '%s' requires unknown node '%s'."
					% [
						node.node_id,
						prerequisite_id,
					]
				)

		for path_parent_id in (
			node.path_parent_node_ids
		):
			if not used_node_ids.has(
				path_parent_id
			):
				errors.append(
					"Node '%s' has unknown path parent node '%s'."
					% [
						node.node_id,
						path_parent_id,
					]
				)
			else:
				var parent_node := get_node_definition(
					path_parent_id
				)

				if (
					parent_node != null
					and (
						parent_node.block_id
						!= node.block_id
					)
				):
					errors.append(
						"Node '%s' and path parent '%s' must belong to the same block."
						% [
							node.node_id,
							path_parent_id,
						]
					)

	if (
		errors.is_empty()
		and _has_dependency_cycle()
	):
		errors.append(
			"Skill Grid contains a dependency cycle."
		)

	return errors


func _has_dependency_cycle() -> bool:
	var visit_states: Dictionary = {}

	for node in nodes:
		if node == null:
			continue

		if int(
			visit_states.get(
				node.node_id,
				0
			)
		) != 0:
			continue

		if _visit_for_cycle(
			node.node_id,
			visit_states
		):
			return true

	return false


func _visit_for_cycle(
	node_id: StringName,
	visit_states: Dictionary
) -> bool:
	visit_states[
		node_id
	] = 1

	var node := get_node_definition(
		node_id
	)

	if node == null:
		return false

	var upstream_ids: Array[StringName] = []

	for prerequisite_id in (
		node.prerequisite_node_ids
	):
		upstream_ids.append(
			prerequisite_id
		)

	for path_parent_id in (
		node.path_parent_node_ids
	):
		upstream_ids.append(
			path_parent_id
		)

	for upstream_id in upstream_ids:
		var upstream_state := int(
			visit_states.get(
				upstream_id,
				0
			)
		)

		if upstream_state == 1:
			return true

		if (
			upstream_state == 0
			and _visit_for_cycle(
				upstream_id,
				visit_states
			)
		):
			return true

	visit_states[
		node_id
	] = 2

	return false