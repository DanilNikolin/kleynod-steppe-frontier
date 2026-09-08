class_name CampaignTraderState
extends RefCounted


const MAX_GOLD: int = 999999999


var trader_id: StringName = &""

var gold: int = 0

var items: Array[HeroEquipmentItemInstance] = []


func get_item(
	instance_id: StringName
) -> HeroEquipmentItemInstance:
	if instance_id == &"":
		return null

	for item in items:
		if (
			item != null
			and item.instance_id == instance_id
		):
			return item

	return null


func has_item(
	instance_id: StringName
) -> bool:
	return get_item(
		instance_id
	) != null


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if trader_id == &"":
		errors.append(
			"Trader state ID is empty."
		)

	if (
		gold < 0
		or gold > MAX_GOLD
	):
		errors.append(
			"Trader gold is outside valid range."
		)

	var used_instance_ids: Dictionary = {}

	for item_index in range(
		items.size()
	):
		var item := items[
			item_index
		]

		if item == null:
			errors.append(
				"Trader item at index %d is null."
				% item_index
			)

			continue

		for item_error in (
			item.get_validation_errors()
		):
			errors.append(
				"Trader item %d: %s"
				% [
					item_index,
					item_error,
				]
			)

		if item.instance_id == &"":
			continue

		if used_instance_ids.has(
			item.instance_id
		):
			errors.append(
				"Duplicate trader item instance ID: %s."
				% item.instance_id
			)

			continue

		used_instance_ids[
			item.instance_id
		] = true

	return errors