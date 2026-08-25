@tool
class_name CampaignInventoryState
extends Resource


@export_group("Currency")

@export_range(0, 999999999, 1)
var gold: int = 0


@export_group("Items")

@export
var items: Array[HeroEquipmentItemInstance] = []


@export_group("Generated Items")

## Следующий serial для runtime-generated loot instance.
## Храним прямо в Campaign State, чтобы будущий
## Save/Load не создавал повторяющиеся instance IDs.
@export_range(1, 999999999, 1)
var next_generated_item_serial: int = 1


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

	if gold < 0:
		errors.append(
			"Campaign gold cannot be negative."
		)

	if next_generated_item_serial <= 0:
		errors.append(
			"Generated item serial must be greater than zero."
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
				"Inventory item at index %d is null."
				% item_index
			)

			continue

		for item_error in (
			item.get_validation_errors()
		):
			errors.append(
				"Inventory item %d: %s"
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
				"Duplicate inventory instance ID: %s."
				% item.instance_id
			)

			continue

		used_instance_ids[
			item.instance_id
		] = true

	return errors