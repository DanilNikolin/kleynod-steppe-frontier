@tool
class_name CampaignInventoryState
extends Resource


@export_group("Currency")

@export_range(0, 999999999, 1)
var gold: int = 0


## DEV: shared expedition capacity, including carried equipment. One instance = one slot.
@export_range(1, 999, 1) var slot_capacity: int = 12

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

	if slot_capacity < 1 or items.size() > slot_capacity:
		errors.append("Inventory exceeds its shared slot capacity.")
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

func can_add_items(count: int) -> bool:
	return count >= 0 and items.size() + count <= slot_capacity

func get_carried_materials() -> int:
	var total: int = 0
	for item in items:
		if item != null and item.definition != null:
			total += item.definition.material_value
	return total

func add_material_bundles(definition: HeroEquipmentItemDefinition, amount: int) -> bool:
	if amount == 0:
		return true
	if definition == null or not definition.is_valid_definition() or definition.material_value <= 0 or amount < 0 or amount % definition.material_value != 0:
		return false
	var count: int = amount / definition.material_value
	if not can_add_items(count):
		return false
	for index in count:
		var item := HeroEquipmentItemInstance.new()
		item.definition = definition
		item.instance_id = StringName("cargo_%d" % next_generated_item_serial)
		next_generated_item_serial += 1
		while has_item(item.instance_id):
			item.instance_id = StringName("cargo_%d" % next_generated_item_serial)
			next_generated_item_serial += 1
		items.append(item)
	return true
