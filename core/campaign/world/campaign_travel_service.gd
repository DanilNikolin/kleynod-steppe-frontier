class_name CampaignTravelService
extends RefCounted


const INVALID_TRAVEL_DAYS: int = -1


func get_travel_minutes(
	world_map: CampaignWorldMapDefinition,
	from_node_id: StringName,
	to_node_id: StringName
) -> int:
	if (
		world_map == null
		or not world_map.is_valid_definition()
	):
		return INVALID_TRAVEL_DAYS

	if (
		from_node_id == &""
		or to_node_id == &""
	):
		return INVALID_TRAVEL_DAYS

	if from_node_id == to_node_id:
		return 0

	var from_node := world_map.get_node(
		from_node_id
	)

	var to_node := world_map.get_node(
		to_node_id
	)

	if (
		from_node == null
		or to_node == null
	):
		return INVALID_TRAVEL_DAYS

	var route := world_map.get_route_between(
		from_node_id,
		to_node_id
	)

	if route == null:
		return INVALID_TRAVEL_DAYS

	if route.travel_days_override > 0:
		return route.travel_days_override * CampaignTimeService.MINUTES_PER_DAY

	if world_map.map_units_per_day <= 0.0:
		return INVALID_TRAVEL_DAYS

	var distance := (
		from_node
			.map_position
			.distance_to(
				to_node.map_position
			)
	)

	var raw_days := (
		distance
		/ world_map.map_units_per_day
		* route.travel_multiplier
	)

	return maxi(
		int(ceil(raw_days * CampaignTimeService.MINUTES_PER_DAY)),
		1
	)


func can_travel(
	world_map: CampaignWorldMapDefinition,
	from_node_id: StringName,
	to_node_id: StringName
) -> bool:
	return (
		get_travel_days(
			world_map,
			from_node_id,
			to_node_id
		)
		> 0
	)

## Compatibility for callers that explicitly need whole days.
func get_travel_days(world_map: CampaignWorldMapDefinition, origin: StringName, destination: StringName) -> int:
	var minutes := get_travel_minutes(world_map, origin, destination)
	return -1 if minutes < 0 else int(ceil(float(minutes) / CampaignTimeService.MINUTES_PER_DAY))


## Dijkstra over available roads; cost is actual travel time including terrain.
func get_shortest_path(world_map: CampaignWorldMapDefinition, origin: StringName, destination: StringName,
	settlement: CampaignSettlementDefinition, state: CampaignSettlementState) -> Array[StringName]:
	var empty: Array[StringName] = []
	if world_map == null or world_map.get_node(origin) == null or world_map.get_node(destination) == null:
		return empty
	var costs: Dictionary = {origin: 0}
	var previous: Dictionary = {}
	var open: Array[StringName] = [origin]
	var access := CampaignWorldRouteAccessService.new()
	while not open.is_empty():
		var current: StringName = open[0]
		for candidate in open:
			if costs[candidate] < costs[current]:
				current = candidate
		open.erase(current)
		if current == destination:
			var path: Array[StringName] = [current]
			while current != origin:
				current = previous[current]
				path.push_front(current)
			return path
		for route in world_map.routes:
			var neighbor := route.get_other_node_id(current)
			if neighbor == &"" or not access.is_route_available(route, settlement, state):
				continue
			var minutes := get_travel_minutes(world_map, current, neighbor)
			if minutes <= 0:
				continue
			var cost: int = costs[current] + minutes
			if not costs.has(neighbor) or cost < costs[neighbor]:
				costs[neighbor] = cost
				previous[neighbor] = current
				if not open.has(neighbor):
					open.append(neighbor)
	return empty
