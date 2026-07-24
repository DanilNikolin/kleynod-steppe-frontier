@tool
class_name HeroEquipmentState
extends Resource


enum Slot {
	WEAPON_1,
	WEAPON_2,
	HEAD,
	ARMOR,
	GLOVES,
	BOOTS,
	CHARM,
	RING_1,
	RING_2,
}


@export_group("Weapons")

@export
var weapon_1: HeroEquipmentItemInstance

@export
var weapon_2: HeroEquipmentItemInstance


@export_group("Armor")

@export
var head: HeroEquipmentItemInstance

@export
var armor: HeroEquipmentItemInstance

@export
var gloves: HeroEquipmentItemInstance

@export
var boots: HeroEquipmentItemInstance


@export_group("Accessories")

@export
var charm: HeroEquipmentItemInstance

@export
var ring_1: HeroEquipmentItemInstance

@export
var ring_2: HeroEquipmentItemInstance


static func get_all_slots() -> Array[int]:
	var result: Array[int] = []

	result.append(Slot.WEAPON_1)
	result.append(Slot.WEAPON_2)
	result.append(Slot.HEAD)
	result.append(Slot.ARMOR)
	result.append(Slot.GLOVES)
	result.append(Slot.BOOTS)
	result.append(Slot.CHARM)
	result.append(Slot.RING_1)
	result.append(Slot.RING_2)

	return result


static func get_slot_display_name(
	slot: int
) -> String:
	match slot:
		Slot.WEAPON_1:
			return "Weapon 1"

		Slot.WEAPON_2:
			return "Weapon 2"

		Slot.HEAD:
			return "Head"

		Slot.ARMOR:
			return "Armor"

		Slot.GLOVES:
			return "Gloves"

		Slot.BOOTS:
			return "Boots"

		Slot.CHARM:
			return "Charm"

		Slot.RING_1:
			return "Ring 1"

		Slot.RING_2:
			return "Ring 2"

	return "Unknown Slot"


func get_item(
	slot: int
) -> HeroEquipmentItemInstance:
	match slot:
		Slot.WEAPON_1:
			return weapon_1

		Slot.WEAPON_2:
			return weapon_2

		Slot.HEAD:
			return head

		Slot.ARMOR:
			return armor

		Slot.GLOVES:
			return gloves

		Slot.BOOTS:
			return boots

		Slot.CHARM:
			return charm

		Slot.RING_1:
			return ring_1

		Slot.RING_2:
			return ring_2

	return null


func set_item(
	slot: int,
	item: HeroEquipmentItemInstance
) -> bool:
	match slot:
		Slot.WEAPON_1:
			weapon_1 = item

		Slot.WEAPON_2:
			weapon_2 = item

		Slot.HEAD:
			head = item

		Slot.ARMOR:
			armor = item

		Slot.GLOVES:
			gloves = item

		Slot.BOOTS:
			boots = item

		Slot.CHARM:
			charm = item

		Slot.RING_1:
			ring_1 = item

		Slot.RING_2:
			ring_2 = item

		_:
			return false

	return true


func create_copy() -> HeroEquipmentState:
	var result := HeroEquipmentState.new()

	for slot in get_all_slots():
		result.set_item(
			slot,
			get_item(
				slot
			)
		)

	return result


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	var used_instance_ids: Dictionary = {}
	var placement_counts: Dictionary = {}
	var instances_by_object_id: Dictionary = {}

	for slot in get_all_slots():
		var item := get_item(
			slot
		)

		if item == null:
			continue

		for item_error in item.get_validation_errors():
			errors.append(
				"%s: %s"
				% [
					get_slot_display_name(
						slot
					),
					item_error,
				]
			)

		if item.definition == null:
			continue

		if not _is_category_allowed_in_slot(
			item.definition.category,
			slot
		):
			errors.append(
				"Item '%s' cannot occupy %s."
				% [
					item.definition.display_name,
					get_slot_display_name(
						slot
					),
				]
			)

		if used_instance_ids.has(
			item.instance_id
		):
			var previous_item := (
				used_instance_ids[
					item.instance_id
				]
				as HeroEquipmentItemInstance
			)

			if previous_item != item:
				errors.append(
					"Duplicate equipment instance ID: %s."
					% item.instance_id
				)

		else:
			used_instance_ids[
				item.instance_id
			] = item

		var object_id := item.get_instance_id()

		placement_counts[
			object_id
		] = int(
			placement_counts.get(
				object_id,
				0
			)
		) + 1

		instances_by_object_id[
			object_id
		] = item

	for object_id in placement_counts:
		var placement_count := int(
			placement_counts[
				object_id
			]
		)

		if placement_count <= 1:
			continue

		var item := (
			instances_by_object_id[
				object_id
			]
			as HeroEquipmentItemInstance
		)

		var is_valid_two_handed_placement := (
			placement_count == 2
			and item != null
			and item.definition != null
			and item.definition.is_two_handed
			and weapon_1 == item
			and weapon_2 == item
		)

		if not is_valid_two_handed_placement:
			errors.append(
				"Equipment instance '%s' occupies "
				% item.instance_id
				+"multiple incompatible slots."
			)

	if (
		weapon_1 != null
		and weapon_1.definition != null
		and weapon_1.definition.is_two_handed
		and weapon_2 != weapon_1
	):
		errors.append(
			"Two-handed weapon in Weapon 1 "
			+"must also occupy Weapon 2."
		)

	if (
		weapon_2 != null
		and weapon_2.definition != null
		and weapon_2.definition.is_two_handed
		and weapon_1 != weapon_2
	):
		errors.append(
			"Two-handed weapon in Weapon 2 "
			+"must also occupy Weapon 1."
		)

	return errors


func _is_category_allowed_in_slot(
	category: int,
	slot: int
) -> bool:
	match category:
		HeroEquipmentItemDefinition.Category.WEAPON:
			return (
				slot == Slot.WEAPON_1
				or slot == Slot.WEAPON_2
			)

		HeroEquipmentItemDefinition.Category.HEAD:
			return slot == Slot.HEAD

		HeroEquipmentItemDefinition.Category.ARMOR:
			return slot == Slot.ARMOR

		HeroEquipmentItemDefinition.Category.GLOVES:
			return slot == Slot.GLOVES

		HeroEquipmentItemDefinition.Category.BOOTS:
			return slot == Slot.BOOTS

		HeroEquipmentItemDefinition.Category.CHARM:
			return slot == Slot.CHARM

		HeroEquipmentItemDefinition.Category.RING:
			return (
				slot == Slot.RING_1
				or slot == Slot.RING_2
			)

	return false