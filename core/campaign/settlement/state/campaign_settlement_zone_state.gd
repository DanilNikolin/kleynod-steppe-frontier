class_name CampaignSettlementZoneState
extends RefCounted


var zone_id: StringName = &""

## Пусто = участок незастроен.
var building_id: StringName = &""

## 0 допустим только для пустого участка.
var building_level: int = 0


func is_empty() -> bool:
	return building_id == &""


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if zone_id == &"":
		errors.append(
			"Settlement zone state ID is empty."
		)

	if building_id == &"":
		if building_level != 0:
			errors.append(
				"Empty settlement zone must have building level 0."
			)

	elif building_level <= 0:
		errors.append(
			"Built settlement zone must have positive level."
		)

	return errors