class_name CampaignTravelService
extends RefCounted


const INVALID_TRAVEL_DAYS: int = -1


func get_travel_days(
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
		return route.travel_days_override

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
		int(ceil(raw_days)),
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