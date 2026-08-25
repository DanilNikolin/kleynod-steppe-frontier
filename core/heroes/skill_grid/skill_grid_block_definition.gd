@tool
class_name SkillGridBlockDefinition
extends Resource


@export_group("Identity")

@export
var block_id: StringName = &""

@export
var display_name: String = "Unnamed Block"

@export
var branch: SkillGridNodeDefinition.Branch = (
	SkillGridNodeDefinition.Branch.NONE
)

@export_range(1, 99, 1)
var branch_order: int = 1


@export_group("Progression")

@export_range(1, 99, 1)
var minimum_purchased_nodes: int = 5


@export_group("Nodes")

@export
var node_ids: Array[StringName] = []

@export
var entry_node_ids: Array[StringName] = []

@export
var exit_anchor_node_ids: Array[StringName] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if block_id == &"":
		errors.append(
			"Skill Grid block ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Skill Grid block display name is empty."
		)

	if branch_order < 1:
		errors.append(
			"Skill Grid block branch order must be at least 1."
		)

	if node_ids.is_empty():
		errors.append(
			"Skill Grid block must contain at least one node ID."
		)

	var registered_node_ids: Dictionary = {}

	for id in node_ids:
		if id == &"":
			errors.append(
				"Skill Grid block contains an empty node ID."
			)
			continue

		if registered_node_ids.has(id):
			errors.append(
				"Duplicate node ID in block: %s."
				% id
			)
			continue

		registered_node_ids[id] = true

	var registered_entry_ids: Dictionary = {}

	for entry_id in entry_node_ids:
		if entry_id == &"":
			errors.append(
				"Skill Grid block contains an empty entry node ID."
			)
			continue

		if registered_entry_ids.has(entry_id):
			errors.append(
				"Duplicate entry node ID in block: %s."
				% entry_id
			)
			continue

		registered_entry_ids[entry_id] = true

		if not registered_node_ids.has(entry_id):
			errors.append(
				"Entry node ID '%s' is not part of block node_ids."
				% entry_id
			)

	var registered_exit_ids: Dictionary = {}

	for exit_id in exit_anchor_node_ids:
		if exit_id == &"":
			errors.append(
				"Skill Grid block contains an empty exit anchor node ID."
			)
			continue

		if registered_exit_ids.has(exit_id):
			errors.append(
				"Duplicate exit anchor node ID in block: %s."
				% exit_id
			)
			continue

		registered_exit_ids[exit_id] = true

		if not registered_node_ids.has(exit_id):
			errors.append(
				"Exit anchor node ID '%s' is not part of block node_ids."
				% exit_id
			)

	if minimum_purchased_nodes <= 0:
		errors.append(
			"Minimum purchased nodes must be greater than zero."
		)
	elif (
		not node_ids.is_empty()
		and minimum_purchased_nodes > node_ids.size()
	):
		errors.append(
			"Minimum purchased nodes (%d) cannot exceed node count (%d)."
			% [
				minimum_purchased_nodes,
				node_ids.size(),
			]
		)

	return errors
