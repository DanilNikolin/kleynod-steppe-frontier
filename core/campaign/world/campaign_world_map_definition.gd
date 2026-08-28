@tool
class_name CampaignWorldMapDefinition
extends Resource


@export_group("Travel Scale")

## Сколько условных единиц координат глобальной карты
## соответствуют одному игровому дню пути.
##
## Сам расчёт будет жить в отдельном travel service,
## а не внутри content definition.
@export
var map_units_per_day: float = 100.0


@export_group("Start")

@export
var starting_node_id: StringName = &""


@export_group("Content")

@export
var nodes: Array[CampaignWorldNodeDefinition] = []

@export
var routes: Array[CampaignWorldRouteDefinition] = []


func get_node(
	node_id: StringName
) -> CampaignWorldNodeDefinition:
	if node_id == &"":
		return null

	for node in nodes:
		if (
			node != null
			and node.node_id == node_id
		):
			return node

	return null


func get_route(
	route_id: StringName
) -> CampaignWorldRouteDefinition:
	if route_id == &"":
		return null

	for route in routes:
		if (
			route != null
			and route.route_id == route_id
		):
			return route

	return null


func get_route_between(
	first_node_id: StringName,
	second_node_id: StringName
) -> CampaignWorldRouteDefinition:
	for route in routes:
		if (
			route != null
			and route.connects(
				first_node_id,
				second_node_id
			)
		):
			return route

	return null


func get_connected_node_ids(
	node_id: StringName
) -> Array[StringName]:
	var result: Array[StringName] = []

	for route in routes:
		if route == null:
			continue

		var other_node_id := route.get_other_node_id(
			node_id
		)

		if other_node_id == &"":
			continue

		result.append(
			other_node_id
		)

	return result


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if map_units_per_day <= 0.0:
		errors.append(
			"World map units per day must be positive."
		)

	if nodes.is_empty():
		errors.append(
			"World map has no nodes."
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
				"World node at index %d is null."
				% node_index
			)

			continue

		for node_error in (
			node.get_validation_errors()
		):
			errors.append(
				"World node %d: %s"
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
				"Duplicate world node ID: %s."
				% node.node_id
			)

			continue

		used_node_ids[
			node.node_id
		] = true

	if starting_node_id == &"":
		errors.append(
			"World map starting node ID is empty."
		)

	elif not used_node_ids.has(
		starting_node_id
	):
		errors.append(
			"World map starting node '%s' does not exist."
			% starting_node_id
		)

	var used_route_ids: Dictionary = {}
	var used_connections: Dictionary = {}

	for route_index in range(
		routes.size()
	):
		var route := routes[
			route_index
		]

		if route == null:
			errors.append(
				"World route at index %d is null."
				% route_index
			)

			continue

		for route_error in (
			route.get_validation_errors()
		):
			errors.append(
				"World route %d: %s"
				% [
					route_index,
					route_error,
				]
			)

		if route.route_id != &"":
			if used_route_ids.has(
				route.route_id
			):
				errors.append(
					"Duplicate world route ID: %s."
					% route.route_id
				)

			else:
				used_route_ids[
					route.route_id
				] = true

		if (
			route.node_a_id != &""
			and not used_node_ids.has(
				route.node_a_id
			)
		):
			errors.append(
				"World route '%s' references "
				% route.route_id
				+"unknown node A '%s'."
				% route.node_a_id
			)

		if (
			route.node_b_id != &""
			and not used_node_ids.has(
				route.node_b_id
			)
		):
			errors.append(
				"World route '%s' references "
				% route.route_id
				+"unknown node B '%s'."
				% route.node_b_id
			)

		if (
			route.node_a_id == &""
			or route.node_b_id == &""
		):
			continue

		var connection_key := (
			"%s->%s"
			% [
				route.node_a_id,
				route.node_b_id,
			]
		)

		var reverse_connection_key := (
			"%s->%s"
			% [
				route.node_b_id,
				route.node_a_id,
			]
		)

		if (
			used_connections.has(
				connection_key
			)
			or used_connections.has(
				reverse_connection_key
			)
		):
			errors.append(
				"Duplicate world connection between "
				+"'%s' and '%s'."
				% [
					route.node_a_id,
					route.node_b_id,
				]
			)

			continue

		used_connections[
			connection_key
		] = true

	return errors