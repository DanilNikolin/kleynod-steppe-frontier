class_name CampaignPendingTravel
extends RefCounted


var from_node_id: StringName = &""
var destination_node_id: StringName = &""

var route_id: StringName = &""

## Полное базовое время пути.
## Event может отдельно потратить дополнительное время.
var total_travel_minutes: int = 0

## 0.0 = только вышли.
## 1.0 = прибыли.
var progress: float = 0.0

## Выпавшее authored event.
## null означает, что этот travel проходит без события.
var event_definition: CampaignTravelEventDefinition

## -1.0 используется, если event не выпал.
var event_progress: float = -1.0


func has_event() -> bool:
	return event_definition != null


func has_reached_event() -> bool:
	return (
		has_event()
		and is_equal_approx(
			progress,
			event_progress
		)
	)


func get_elapsed_travel_minutes() -> int:
	if total_travel_minutes <= 0:
		return 0

	return clampi(
		int(
			round(
				float(total_travel_minutes)
				* progress
			)
		),
		0,
		total_travel_minutes
	)


func get_remaining_travel_minutes() -> int:
	return maxi(
		total_travel_minutes
			- get_elapsed_travel_minutes(),
		0
	)


func is_valid_against_world_map(
	world_map: CampaignWorldMapDefinition
) -> bool:
	return (
		get_validation_errors(
			world_map
		).is_empty()
	)


func get_validation_errors(
	world_map: CampaignWorldMapDefinition
) -> PackedStringArray:
	var errors := PackedStringArray()

	if from_node_id == &"":
		errors.append(
			"Pending travel origin node ID is empty."
		)

	if destination_node_id == &"":
		errors.append(
			"Pending travel destination node ID is empty."
		)

	if (
		from_node_id != &""
		and from_node_id == destination_node_id
	):
		errors.append(
			"Pending travel cannot begin and end "
			+"at the same world node."
		)

	if route_id == &"":
		errors.append(
			"Pending travel route ID is empty."
		)

	if total_travel_minutes <= 0:
		errors.append(
			"Pending travel total duration "
			+"must be positive."
		)

	if (
		progress < 0.0
		or progress > 1.0
	):
		errors.append(
			"Pending travel progress must be "
			+"between 0 and 1."
		)

	if world_map == null:
		errors.append(
			"Pending travel world map is missing."
		)

	else:
		var route := world_map.get_route(
			route_id
		)

		if route == null:
			errors.append(
				"Pending travel references "
				+"unknown route '%s'."
				% route_id
			)

		elif not route.connects(
			from_node_id,
			destination_node_id
		):
			errors.append(
				"Pending travel route '%s' "
				% route_id
				+"does not connect '%s' and '%s'."
				% [
					from_node_id,
					destination_node_id,
				]
			)

	if event_definition == null:
		if not is_equal_approx(
			event_progress,
			-1.0
		):
			errors.append(
				"Pending travel without an event "
				+"must use event progress -1."
			)

	else:
		for event_error in (
			event_definition
				.get_validation_errors()
		):
			errors.append(
				"Pending travel event: %s"
				% event_error
			)

		if (
			event_progress < 0.0
			or event_progress > 1.0
		):
			errors.append(
				"Pending travel event progress "
				+"must be between 0 and 1."
			)

		elif (
			event_progress
				< event_definition
					.min_route_progress
			or event_progress
				> event_definition
					.max_route_progress
		):
			errors.append(
				"Pending travel event progress "
				+"is outside the event's "
				+"allowed route range."
			)

		if progress > event_progress:
			errors.append(
				"Pending travel cannot progress "
				+"past an unresolved event."
			)

	return errors