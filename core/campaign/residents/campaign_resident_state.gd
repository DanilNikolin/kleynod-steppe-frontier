class_name CampaignResidentState
extends RefCounted


enum Status {
	ORIGIN,
	HOME_SETTLEMENT,
	HOME_GUEST,
}


var resident_id: StringName = &""

var status: Status = Status.ORIGIN

## Это НЕ сам quest-state.
##
## Quest system позже просто выставит этот флаг,
## когда выполнено нужное условие приглашения.
var recruitment_unlocked: bool = false


## Saved independently of authored resources. Static residents keep empty location.
var current_world_node_id: StringName = &""
var next_move_at_minute: int = 0
## A fresh clue reserves the current job until the first conversation.
## This is an encounter pin, not a deadline that can expire during a travel event.
var location_clue_known: bool = false
var has_met: bool = false


func is_at_origin() -> bool:
	return status == Status.ORIGIN


func is_at_home() -> bool:
	return status in [Status.HOME_SETTLEMENT, Status.HOME_GUEST]


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if resident_id == &"":
		errors.append(
			"Resident state ID is empty."
		)

	if (
		status < Status.ORIGIN
		or status > Status.HOME_GUEST
	):
		errors.append(
			"Resident state has invalid status."
		)

	if next_move_at_minute < 0:
		errors.append("Resident movement time cannot be negative.")
	if (location_clue_known or has_met) and current_world_node_id == &"":
		errors.append("Known wandering resident needs a location.")
	return errors