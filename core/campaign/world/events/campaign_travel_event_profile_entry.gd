@tool
class_name CampaignTravelEventProfileEntry
extends Resource


@export
var event: CampaignTravelEventDefinition

## Относительный вес события внутри profile.
##
## Это НЕ абсолютный процент.
## Например веса 70 / 20 / 10 означают
## 70%, 20%, 10% среди уже выпавших событий.
@export_range(1, 999999999, 1)
var weight: int = 1


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if event == null:
		errors.append(
			"Travel event profile entry has no event."
		)

	elif not event.is_valid_definition():
		errors.append(
			"Travel event profile entry "
			+"references an invalid event."
		)

	if weight <= 0:
		errors.append(
			"Travel event profile entry weight "
			+"must be positive."
		)

	return errors