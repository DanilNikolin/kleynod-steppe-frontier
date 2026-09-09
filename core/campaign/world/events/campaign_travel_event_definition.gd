@tool
class_name CampaignTravelEventDefinition
extends Resource


@export_group("Identity")

@export
var event_id: StringName = &""

@export
var display_name: String = "Unnamed Travel Event"

@export_multiline
var description: String = ""


@export_group("Route Position")

## Минимальная точка маршрута,
## в которой событие может произойти.
##
## 0.0 = начало.
## 1.0 = пункт назначения.
@export_range(0.0, 1.0, 0.01)
var min_route_progress: float = 0.15

@export_range(0.0, 1.0, 0.01)
var max_route_progress: float = 0.85


@export_group("Event Graph")

@export
var entry_node_id: StringName = &""

@export
var nodes: Array[CampaignTravelEventNode] = []


func get_node(
	node_id: StringName
) -> CampaignTravelEventNode:
	if node_id == &"":
		return null

	for node in nodes:
		if (
			node != null
			and node.node_id == node_id
		):
			return node

	return null


func get_entry() -> CampaignTravelEventNode:
	return get_node(
		entry_node_id
	)


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if event_id == &"":
		errors.append(
			"Travel event ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Travel event display name is empty."
		)

	if (
		min_route_progress < 0.0
		or min_route_progress > 1.0
	):
		errors.append(
			"Travel event minimum route progress "
			+"must be between 0 and 1."
		)

	if (
		max_route_progress < 0.0
		or max_route_progress > 1.0
	):
		errors.append(
			"Travel event maximum route progress "
			+"must be between 0 and 1."
		)

	if (
		min_route_progress
		>= max_route_progress
	):
		errors.append(
			"Travel event route progress range "
			+"must have positive length."
		)

	if entry_node_id == &"":
		errors.append(
			"Travel event entry node ID is empty."
		)

	if nodes.is_empty():
		errors.append(
			"Travel event has no nodes."
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
				"Travel event node at index %d is null."
				% node_index
			)

			continue

		for node_error in (
			node.get_validation_errors()
		):
			errors.append(
				"Travel event node %d: %s"
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
				"Duplicate travel event node ID: %s."
				% node.node_id
			)

			continue

		used_node_ids[
			node.node_id
		] = true

	if (
		entry_node_id != &""
		and not used_node_ids.has(
			entry_node_id
		)
	):
		errors.append(
			"Travel event references unknown "
			+"entry node '%s'."
			% entry_node_id
		)

	for node in nodes:
		if node == null:
			continue

		for choice in node.choices:
			if choice == null:
				continue

			match choice.action:
				CampaignTravelEventChoice.Action.NONE:
					_append_unknown_node_error(
						errors,
						choice.next_node_id,
						choice.choice_id,
						used_node_ids
					)

				CampaignTravelEventChoice.Action.PAY_GOLD:
					_append_unknown_node_error(
						errors,
						choice.next_node_id,
						choice.choice_id,
						used_node_ids
					)

				CampaignTravelEventChoice.Action.CHANCE:
					_append_unknown_node_error(
						errors,
						choice.success_node_id,
						choice.choice_id,
						used_node_ids
					)

					_append_unknown_node_error(
						errors,
						choice.failure_node_id,
						choice.choice_id,
						used_node_ids
					)

				CampaignTravelEventChoice.Action.RESOLVE_EVENT:
					pass

				CampaignTravelEventChoice.Action.START_BATTLE:
					pass

	return errors


func _append_unknown_node_error(
	errors: PackedStringArray,
	target_node_id: StringName,
	choice_id: StringName,
	used_node_ids: Dictionary
) -> void:
	if (
		target_node_id == &""
		or used_node_ids.has(
			target_node_id
		)
	):
		return

	errors.append(
		"Travel event choice '%s' references "
		% choice_id
		+"unknown node '%s'."
		% target_node_id
	)