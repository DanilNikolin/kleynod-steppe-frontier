class_name CampaignResidentState
extends RefCounted


enum Status {
	ORIGIN,
	HOME_SETTLEMENT,
}


var resident_id: StringName = &""

var status: Status = Status.ORIGIN

## Это НЕ сам quest-state.
##
## Quest system позже просто выставит этот флаг,
## когда выполнено нужное условие приглашения.
var recruitment_unlocked: bool = false


func is_at_origin() -> bool:
	return status == Status.ORIGIN


func is_at_home() -> bool:
	return status == Status.HOME_SETTLEMENT


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
		or status > Status.HOME_SETTLEMENT
	):
		errors.append(
			"Resident state has invalid status."
		)

	return errors