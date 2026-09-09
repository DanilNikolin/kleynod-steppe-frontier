@tool
class_name CampaignQuestDefinition
extends Resource


enum GiverKind {
	RESIDENT,
	LOCAL_INTERACTION,
}


@export_group("Identity")

@export
var quest_id: StringName = &""

@export
var display_name: String = "Unnamed Quest"

@export_multiline
var description: String = ""


@export_group("Giver")

@export
var giver_kind: GiverKind = GiverKind.RESIDENT

## Используется, когда giver_kind == RESIDENT.
@export
var giver_resident_id: StringName = &""

## Используется, когда giver_kind == LOCAL_INTERACTION.
## Это world node, где физически находится источник задания
## (например, доска объявлений в Малом селе).
@export
var giver_world_node_id: StringName = &""

## Используется, когда giver_kind == LOCAL_INTERACTION.
## Например: debug_village_notice_board
@export
var giver_local_interaction_id: StringName = &""


func uses_resident_giver() -> bool:
	return giver_kind == GiverKind.RESIDENT


func uses_local_interaction_giver() -> bool:
	return giver_kind == GiverKind.LOCAL_INTERACTION


@export_group("Lifecycle")

## Можно ли отказаться от уже принятого задания.
##
## Будущие сюжетные/ключевые задания
## смогут запрещать отказ.
@export
var abandon_enabled: bool = true


@export_group("Adventure")

## Adventure sites, которые становятся AVAILABLE
## в момент принятия задания.
@export
var start_adventure_site_unlocks: Array[CampaignAdventureSiteReferenceDefinition] = []


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

	match giver_kind:
		GiverKind.RESIDENT:
			if giver_resident_id == &"":
				errors.append(
					"Quest giver resident ID is empty."
				)

		GiverKind.LOCAL_INTERACTION:
			if giver_world_node_id == &"":
				errors.append(
					"Quest giver world node ID is empty."
				)

			if giver_local_interaction_id == &"":
				errors.append(
					"Quest giver local interaction ID is empty."
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

	var used_adventure_unlocks: Dictionary = {}

	for unlock_index in range(
		start_adventure_site_unlocks.size()
	):
		var unlock := (
			start_adventure_site_unlocks[
				unlock_index
			]
		)

		if (
			unlock == null
			or not unlock.is_valid_definition()
		):
			errors.append(
				"Quest adventure unlock at index %d is invalid."
					% unlock_index
			)

			continue

		var key := (
			"%s::%s"
			% [
				unlock.area_id,
				unlock.site_id,
			]
		)

		if used_adventure_unlocks.has(
			key
		):
			errors.append(
				"Duplicate quest adventure unlock: %s."
					% key
			)

			continue

		used_adventure_unlocks[
			key
		] = true

	return errors