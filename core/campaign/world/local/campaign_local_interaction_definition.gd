@tool
class_name CampaignLocalInteractionDefinition
extends Resource


@export_group("Identity")

@export
var interaction_id: StringName = &""

@export
var display_name: String = "Unnamed Interaction"

@export_multiline
var description: String = ""


@export_group("Presentation")

## Позиция на authored 2D-плоскости локальной локации.
## Сейчас здесь появится placeholder-кнопка.
## Позже эта же позиция сможет использоваться
## настоящим NPC / интерактивным объектом.
@export
var local_position: Vector2 = Vector2.ZERO


@export_group("Actions")

## Пока это presentation-заглушки действий.
## Реальные action definitions появятся только
## когда конкретная механика их потребует.
@export
var action_labels: PackedStringArray = PackedStringArray()


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if interaction_id == &"":
		errors.append(
			"Local interaction ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Local interaction display name is empty."
		)

	if action_labels.is_empty():
		errors.append(
			"Local interaction has no actions."
		)

	var used_labels: Dictionary = {}

	for action_index in range(
		action_labels.size()
	):
		var action_label := (
			action_labels[action_index]
		)

		if action_label.strip_edges().is_empty():
			errors.append(
				"Local interaction action %d is empty."
				% action_index
			)

			continue

		if used_labels.has(
			action_label
		):
			errors.append(
				"Duplicate local interaction action: %s."
				% action_label
			)

			continue

		used_labels[
			action_label
		] = true

	return errors