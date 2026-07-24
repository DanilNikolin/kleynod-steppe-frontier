@tool
class_name SkillGridDefinition
extends Resource


@export_group("Identity")

@export
var grid_id: StringName = &""

@export
var display_name: String = "Unnamed Skill Grid"


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

	for node in nodes:
		if node == null:
			continue

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

	for prerequisite_id in (
		node.prerequisite_node_ids
	):
		var prerequisite_state := int(
			visit_states.get(
				prerequisite_id,
				0
			)
		)

		if prerequisite_state == 1:
			return true

		if (
			prerequisite_state == 0
			and _visit_for_cycle(
				prerequisite_id,
				visit_states
			)
		):
			return true

	visit_states[
		node_id
	] = 2

	return false