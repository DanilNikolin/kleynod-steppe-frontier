@tool
class_name CampaignTravelEventNode
extends Resource


@export_group("Identity")

@export
var node_id: StringName = &""


@export_group("Content")

@export_multiline
var text: String = ""


@export_group("Choices")

@export
var choices: Array[CampaignTravelEventChoice] = []


func get_choice(
	choice_id: StringName
) -> CampaignTravelEventChoice:
	if choice_id == &"":
		return null

	for choice in choices:
		if (
			choice != null
			and choice.choice_id == choice_id
		):
			return choice

	return null


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if node_id == &"":
		errors.append(
			"Travel event node ID is empty."
		)

	if text.strip_edges().is_empty():
		errors.append(
			"Travel event node text is empty."
		)

	if choices.is_empty():
		errors.append(
			"Travel event node has no choices."
		)

	var used_choice_ids: Dictionary = {}

	for choice_index in range(
		choices.size()
	):
		var choice := choices[
			choice_index
		]

		if choice == null:
			errors.append(
				"Travel event choice at index %d is null."
				% choice_index
			)

			continue

		for choice_error in (
			choice.get_validation_errors()
		):
			errors.append(
				"Travel event choice %d: %s"
				% [
					choice_index,
					choice_error,
				]
			)

		if choice.choice_id == &"":
			continue

		if used_choice_ids.has(
			choice.choice_id
		):
			errors.append(
				"Duplicate travel event choice ID: %s."
				% choice.choice_id
			)

			continue

		used_choice_ids[
			choice.choice_id
		] = true

	return errors