@tool
class_name CampaignLocalLocationDefinition
extends Resource


@export_group("Identity")

@export
var local_location_id: StringName = &""

@export
var display_name: String = "Unnamed Local Location"

@export_multiline
var description: String = ""


@export_group("Presentation")

## Authoring-пространство локальной side-view сцены.
## Placeholder UI масштабирует эти координаты
## под фактический размер окна.
@export
var reference_size: Vector2 = Vector2(
	1000.0,
	500.0
)

## Базовая ширина кадра в authored world units.
## Presentation использует её для масштаба Camera2D.
##
## Это НЕ страница: вся Local Location остаётся
## одной непрерывной сценой.
@export_range(100.0, 10000.0, 1.0)
var view_width: float = 1000.0


@export_group("Interactions")

@export
var interactions: Array[CampaignLocalInteractionDefinition] = []


func get_interaction(
	interaction_id: StringName
) -> CampaignLocalInteractionDefinition:
	if interaction_id == &"":
		return null

	for interaction in interactions:
		if (
			interaction != null
			and interaction.interaction_id
				== interaction_id
		):
			return interaction

	return null


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if local_location_id == &"":
		errors.append(
			"Local location ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Local location display name is empty."
		)

	if (
		reference_size.x <= 0.0
		or reference_size.y <= 0.0
	):
		errors.append(
			"Local location reference size must be positive."
		)

	if (
		view_width <= 0.0
		or view_width > reference_size.x
	):
		errors.append(
			"Local location view width must be positive "
			+ "and cannot exceed reference width."
		)

	var used_ids: Dictionary = {}

	for interaction_index in range(
		interactions.size()
	):
		var interaction := interactions[
			interaction_index
		]

		if interaction == null:
			errors.append(
				"Local interaction at index %d is null."
				% interaction_index
			)

			continue

		for interaction_error in (
			interaction.get_validation_errors()
		):
			errors.append(
				"Local interaction %d: %s"
				% [
					interaction_index,
					interaction_error,
				]
			)

		if interaction.interaction_id != &"":
			if used_ids.has(
				interaction.interaction_id
			):
				errors.append(
					"Duplicate local interaction ID: %s."
					% interaction.interaction_id
				)

			else:
				used_ids[
					interaction.interaction_id
				] = true

		if (
			interaction.local_position.x < 0.0
			or interaction.local_position.y < 0.0
			or interaction.local_position.x
				> reference_size.x
			or interaction.local_position.y
				> reference_size.y
		):
			errors.append(
				"Local interaction '%s' is outside "
				% interaction.interaction_id
				+"the reference area."
			)

	return errors