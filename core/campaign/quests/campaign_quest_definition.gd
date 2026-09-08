@tool
class_name CampaignQuestDefinition
extends Resource


@export_group("Identity")

@export
var quest_id: StringName = &""

@export
var display_name: String = "Unnamed Quest"

@export_multiline
var description: String = ""


@export_group("Giver")

@export
var giver_resident_id: StringName = &""


@export_group("Lifecycle")

## Можно ли отказаться от уже принятого задания.
##
## Будущие сюжетные/ключевые задания
## смогут запрещать отказ.
@export
var abandon_enabled: bool = true


@export_group("Objectives")

@export
var objectives: Array[CampaignQuestObjectiveDefinition] = []


@export_group("Rewards")

@export_range(0, 999999999, 1)
var reputation_reward: int = 0

## Resident recruitment flags,
## которые открываются после сдачи задания.
@export
var recruitment_unlock_resident_ids: Array[StringName] = []


func get_objective(
	objective_id: StringName
) -> CampaignQuestObjectiveDefinition:
	if objective_id == &"":
		return null

	for objective in objectives:
		if (
			objective != null
			and objective.objective_id == objective_id
		):
			return objective

	return null


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if quest_id == &"":
		errors.append(
			"Quest ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Quest display name is empty."
		)

	if giver_resident_id == &"":
		errors.append(
			"Quest giver resident ID is empty."
		)

	if objectives.is_empty():
		errors.append(
			"Quest requires at least one objective."
		)

	var used_objective_ids: Dictionary = {}

	for objective_index in range(
		objectives.size()
	):
		var objective := objectives[
			objective_index
		]

		if objective == null:
			errors.append(
				"Quest objective at index %d is null."
				% objective_index
			)

			continue

		for objective_error in (
			objective.get_validation_errors()
		):
			errors.append(
				"Quest objective %d: %s"
				% [
					objective_index,
					objective_error,
				]
			)

		if objective.objective_id == &"":
			continue

		if used_objective_ids.has(
			objective.objective_id
		):
			errors.append(
				"Duplicate quest objective ID: %s."
				% objective.objective_id
			)

			continue

		used_objective_ids[
			objective.objective_id
		] = true

	var used_unlock_ids: Dictionary = {}

	for resident_id in (
		recruitment_unlock_resident_ids
	):
		if resident_id == &"":
			errors.append(
				"Quest recruitment unlock "
				+"contains an empty resident ID."
			)

			continue

		if used_unlock_ids.has(
			resident_id
		):
			errors.append(
				"Duplicate recruitment unlock resident: %s."
				% resident_id
			)

			continue

		used_unlock_ids[
			resident_id
		] = true

	return errors