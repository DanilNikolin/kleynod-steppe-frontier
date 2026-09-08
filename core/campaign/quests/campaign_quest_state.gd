class_name CampaignQuestState
extends RefCounted


enum Status {
	NOT_STARTED,
	ACTIVE,
	COMPLETED,
}


var quest_id: StringName = &""

var status: Status = Status.NOT_STARTED

var completed_objective_ids: Array[StringName] = []


func is_not_started() -> bool:
	return status == Status.NOT_STARTED


func is_active() -> bool:
	return status == Status.ACTIVE


func is_completed() -> bool:
	return status == Status.COMPLETED


func is_objective_completed(
	objective_id: StringName
) -> bool:
	return completed_objective_ids.has(
		objective_id
	)


func is_ready_to_turn_in(
	definition: CampaignQuestDefinition
) -> bool:
	if (
		definition == null
		or not is_active()
	):
		return false

	for objective in definition.objectives:
		if (
			objective == null
			or not is_objective_completed(
				objective.objective_id
			)
		):
			return false

	return true


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if quest_id == &"":
		errors.append(
			"Quest state ID is empty."
		)

	if (
		status < Status.NOT_STARTED
		or status > Status.COMPLETED
	):
		errors.append(
			"Quest state has invalid status."
		)

	var used_objective_ids: Dictionary = {}

	for objective_id in (
		completed_objective_ids
	):
		if objective_id == &"":
			errors.append(
				"Completed objective ID is empty."
			)

			continue

		if used_objective_ids.has(
			objective_id
		):
			errors.append(
				"Duplicate completed objective ID: %s."
				% objective_id
			)

			continue

		used_objective_ids[
			objective_id
		] = true

	if (
		status == Status.NOT_STARTED
		and not completed_objective_ids.is_empty()
	):
		errors.append(
			"Not-started quest cannot "
			+"contain completed objectives."
		)

	return errors


func is_valid_against_definition(
	definition: CampaignQuestDefinition
) -> bool:
	if (
		definition == null
		or quest_id != definition.quest_id
		or not is_valid_state()
	):
		return false

	for objective_id in (
		completed_objective_ids
	):
		if definition.get_objective(
			objective_id
		) == null:
			return false

	if status == Status.COMPLETED:
		for objective in definition.objectives:
			if (
				objective == null
				or not completed_objective_ids.has(
					objective.objective_id
				)
			):
				return false

	return true