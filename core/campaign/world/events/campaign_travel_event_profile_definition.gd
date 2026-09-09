@tool
class_name CampaignTravelEventProfileDefinition
extends Resource


@export_group("Identity")

@export
var profile_id: StringName = &""


@export_group("Occurrence")

## Абсолютный шанс, что на маршруте
## вообще произойдёт событие.
##
## Какое именно событие выпадет —
## решается weights внутри entries.
@export_range(0.0, 1.0, 0.01)
var event_chance: float = 0.0


@export_group("Events")

@export
var entries: Array[CampaignTravelEventProfileEntry] = []


func get_total_weight() -> int:
	var result := 0

	for entry in entries:
		if entry == null:
			continue

		result += maxi(
			entry.weight,
			0
		)

	return result


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if profile_id == &"":
		errors.append(
			"Travel event profile ID is empty."
		)

	if (
		event_chance < 0.0
		or event_chance > 1.0
	):
		errors.append(
			"Travel event chance must be "
			+"between 0 and 1."
		)

	if entries.is_empty():
		errors.append(
			"Travel event profile has no events."
		)

	var used_event_ids: Dictionary = {}

	for entry_index in range(
		entries.size()
	):
		var entry := entries[
			entry_index
		]

		if entry == null:
			errors.append(
				"Travel event profile entry "
				+"at index %d is null."
				% entry_index
			)

			continue

		for entry_error in (
			entry.get_validation_errors()
		):
			errors.append(
				"Travel event profile entry %d: %s"
				% [
					entry_index,
					entry_error,
				]
			)

		if (
			entry.event == null
			or entry.event.event_id == &""
		):
			continue

		if used_event_ids.has(
			entry.event.event_id
		):
			errors.append(
				"Duplicate travel event in profile: %s."
				% entry.event.event_id
			)

			continue

		used_event_ids[
			entry.event.event_id
		] = true

	if get_total_weight() <= 0:
		errors.append(
			"Travel event profile total weight "
			+"must be positive."
		)

	return errors