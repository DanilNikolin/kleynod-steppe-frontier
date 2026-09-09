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

## Минимальная точка маршрута, в которой
## это событие может произойти.
##
## 0.0 = начало маршрута.
## 1.0 = пункт назначения.
@export_range(0.0, 1.0, 0.01)
var min_route_progress: float = 0.15

## Максимальная точка маршрута, в которой
## это событие может произойти.
@export_range(0.0, 1.0, 0.01)
var max_route_progress: float = 0.85


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

	return errors