@tool
class_name CampaignTravelEventChoice
extends Resource


enum Action {
	NONE,
	CHANCE,
	PAY_GOLD,
	RESOLVE_EVENT,
}


@export_group("Identity")

@export
var choice_id: StringName = &""

@export_multiline
var text: String = ""


@export_group("Action")

@export
var action: Action = Action.NONE


## NONE / PAY_GOLD.
@export
var next_node_id: StringName = &""


@export_group("Chance")

## Используется только CHANCE.
##
## 0.85 = 85% успеха.
@export_range(0.0, 1.0, 0.01)
var success_chance: float = 0.5

@export
var success_node_id: StringName = &""

@export
var failure_node_id: StringName = &""


@export_group("Gold")

## Используется только PAY_GOLD.
@export_range(1, 999999999, 1)
var gold_cost: int = 1


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if choice_id == &"":
		errors.append(
			"Travel event choice ID is empty."
		)

	if text.strip_edges().is_empty():
		errors.append(
			"Travel event choice text is empty."
		)

	match action:
		Action.NONE:
			if next_node_id == &"":
				errors.append(
					"NONE travel event choice "
					+"requires next node ID."
				)

		Action.CHANCE:
			if success_node_id == &"":
				errors.append(
					"CHANCE travel event choice "
					+"requires success node ID."
				)

			if failure_node_id == &"":
				errors.append(
					"CHANCE travel event choice "
					+"requires failure node ID."
				)

			if (
				success_chance < 0.0
				or success_chance > 1.0
			):
				errors.append(
					"Travel event success chance "
					+"must be between 0 and 1."
				)

		Action.PAY_GOLD:
			if gold_cost <= 0:
				errors.append(
					"PAY_GOLD travel event choice "
					+"requires positive gold cost."
				)

			if next_node_id == &"":
				errors.append(
					"PAY_GOLD travel event choice "
					+"requires next node ID."
				)

		Action.RESOLVE_EVENT:
			pass

	return errors