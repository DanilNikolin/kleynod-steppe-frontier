class_name CampaignAdventureSiteState
extends RefCounted


enum Status {
	HIDDEN,
	AVAILABLE,
	CLEARED,
}


var site_id: StringName = &""

var status: Status = Status.HIDDEN


func is_hidden() -> bool:
	return status == Status.HIDDEN


func is_available() -> bool:
	return status == Status.AVAILABLE


func is_cleared() -> bool:
	return status == Status.CLEARED


func is_valid_state() -> bool:
	return (
		site_id != &""
		and status >= Status.HIDDEN
		and status <= Status.CLEARED
	)