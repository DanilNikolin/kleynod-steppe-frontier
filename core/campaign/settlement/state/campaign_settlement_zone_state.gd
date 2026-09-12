class_name CampaignSettlementZoneState
extends RefCounted


var zone_id: StringName = &""

## Пусто = участок незастроен.
var building_id: StringName = &""

## 0 допустим только для пустого участка.
var building_level: int = 0

## Persistent состояние асинхронного строительства
var pending_building_id: StringName = &""
var pending_target_level: int = 0

var pending_started_at: int = 0
var pending_completes_at: int = 0

var pending_paid_gold: int = 0
var pending_paid_materials: int = 0


func has_pending_construction() -> bool:
	return pending_building_id != &""


func clear_pending_construction() -> void:
	pending_building_id = &""
	pending_target_level = 0
	pending_started_at = 0
	pending_completes_at = 0
	pending_paid_gold = 0
	pending_paid_materials = 0


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

	if pending_building_id == &"":
		if (
			pending_target_level != 0
			or pending_started_at != 0
			or pending_completes_at != 0
			or pending_paid_gold != 0
			or pending_paid_materials != 0
		):
			errors.append(
				"Pending construction fields must be zero when pending_building_id is empty."
			)
	else:
		if is_empty() and pending_target_level != 1:
			errors.append(
				"Pending target level for initial construction must be 1."
			)
		elif pending_target_level < 1:
			errors.append(
				"Pending target level must be at least 1."
			)

		if pending_started_at < 0:
			errors.append(
				"Pending started_at cannot be negative."
			)

		if pending_completes_at <= pending_started_at:
			errors.append(
				"Pending completes_at must be strictly greater than started_at."
			)

		if pending_paid_gold < 0:
			errors.append(
				"Pending paid gold cannot be negative."
			)

		if pending_paid_materials < 0:
			errors.append(
				"Pending paid materials cannot be negative."
			)

	return errors