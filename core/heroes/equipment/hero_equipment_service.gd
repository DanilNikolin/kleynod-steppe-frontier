class_name HeroEquipmentService
extends RefCounted


const FAILURE_INVALID_STATE: StringName = (
	&"invalid_equipment_state"
)

const FAILURE_INVALID_ITEM: StringName = (
	&"invalid_equipment_item"
)

const FAILURE_INVALID_SLOT: StringName = (
	&"invalid_equipment_slot"
)

const FAILURE_INCOMPATIBLE_SLOT: StringName = (
	&"incompatible_equipment_slot"
)

const FAILURE_EMPTY_SLOT: StringName = (
	&"equipment_slot_is_empty"
)


func get_compatible_slots(
	item: HeroEquipmentItemInstance
) -> Array[int]:
	var result: Array[int] = []

	if (
		item == null
		or item.definition == null
	):
		return result

	match item.definition.category:
		HeroEquipmentItemDefinition.Category.WEAPON:
			if item.definition.is_two_handed:
				result.append(
					HeroEquipmentState.Slot.WEAPON_1
				)

			else:
				result.append(
					HeroEquipmentState.Slot.WEAPON_1
				)

				result.append(
					HeroEquipmentState.Slot.WEAPON_2
				)

		HeroEquipmentItemDefinition.Category.HEAD:
			result.append(
				HeroEquipmentState.Slot.HEAD
			)

		HeroEquipmentItemDefinition.Category.ARMOR:
			result.append(
				HeroEquipmentState.Slot.ARMOR
			)

		HeroEquipmentItemDefinition.Category.GLOVES:
			result.append(
				HeroEquipmentState.Slot.GLOVES
			)

		HeroEquipmentItemDefinition.Category.BOOTS:
			result.append(
				HeroEquipmentState.Slot.BOOTS
			)

		HeroEquipmentItemDefinition.Category.CHARM:
			result.append(
				HeroEquipmentState.Slot.CHARM
			)

		HeroEquipmentItemDefinition.Category.RING:
			result.append(
				HeroEquipmentState.Slot.RING_1
			)

			result.append(
				HeroEquipmentState.Slot.RING_2
			)

	return result


func equip(
	state: HeroEquipmentState,
	item: HeroEquipmentItemInstance,
	target_slot: int
) -> HeroEquipmentChangeResult:
	var result := HeroEquipmentChangeResult.new()

	result.target_slot = target_slot

	if item != null:
		result.item_instance_id = (
			item.instance_id
		)

	if (
		state == null
		or not state.is_valid_state()
	):
		result.failure_code = FAILURE_INVALID_STATE
		return result

	if (
		item == null
		or not item.is_valid_instance()
	):
		result.failure_code = FAILURE_INVALID_ITEM
		return result

	if not HeroEquipmentState.get_all_slots().has(
		target_slot
	):
		result.failure_code = FAILURE_INVALID_SLOT
		return result

	var compatible_slots := get_compatible_slots(
		item
	)

	if not compatible_slots.has(
		target_slot
	):
		result.failure_code = (
			FAILURE_INCOMPATIBLE_SLOT
		)

		return result

	var candidate := state.create_copy()

	_remove_instance_from_all_slots(
		candidate,
		item
	)

	if item.definition.is_two_handed:
		candidate.set_item(
			HeroEquipmentState.Slot.WEAPON_1,
			null
		)

		candidate.set_item(
			HeroEquipmentState.Slot.WEAPON_2,
			null
		)

		candidate.set_item(
			HeroEquipmentState.Slot.WEAPON_1,
			item
		)

		candidate.set_item(
			HeroEquipmentState.Slot.WEAPON_2,
			item
		)

	else:
		if (
			target_slot
				== HeroEquipmentState.Slot.WEAPON_1
			or target_slot
				== HeroEquipmentState.Slot.WEAPON_2
		):
			_clear_two_handed_weapon(
				candidate
			)

		candidate.set_item(
			target_slot,
			item
		)

	if not candidate.is_valid_state():
		result.failure_code = FAILURE_INVALID_STATE
		return result

	_copy_state(
		candidate,
		state
	)

	result.is_successful = true
	return result


func unequip(
	state: HeroEquipmentState,
	target_slot: int
) -> HeroEquipmentChangeResult:
	var result := HeroEquipmentChangeResult.new()

	result.target_slot = target_slot

	if (
		state == null
		or not state.is_valid_state()
	):
		result.failure_code = FAILURE_INVALID_STATE
		return result

	if not HeroEquipmentState.get_all_slots().has(
		target_slot
	):
		result.failure_code = FAILURE_INVALID_SLOT
		return result

	var item := state.get_item(
		target_slot
	)

	if item == null:
		result.failure_code = FAILURE_EMPTY_SLOT
		return result

	result.item_instance_id = (
		item.instance_id
	)

	var candidate := state.create_copy()

	_remove_instance_from_all_slots(
		candidate,
		item
	)

	if not candidate.is_valid_state():
		result.failure_code = FAILURE_INVALID_STATE
		return result

	_copy_state(
		candidate,
		state
	)

	result.is_successful = true
	return result


func _clear_two_handed_weapon(
	state: HeroEquipmentState
) -> void:
	var first := state.weapon_1
	var second := state.weapon_2

	if (
		first != null
		and first.definition != null
		and first.definition.is_two_handed
	):
		state.weapon_1 = null
		state.weapon_2 = null
		return

	if (
		second != null
		and second.definition != null
		and second.definition.is_two_handed
	):
		state.weapon_1 = null
		state.weapon_2 = null


func _remove_instance_from_all_slots(
	state: HeroEquipmentState,
	item: HeroEquipmentItemInstance
) -> void:
	for slot in HeroEquipmentState.get_all_slots():
		if state.get_item(
			slot
		) != item:
			continue

		state.set_item(
			slot,
			null
		)


func _copy_state(
	source: HeroEquipmentState,
	target: HeroEquipmentState
) -> void:
	for slot in HeroEquipmentState.get_all_slots():
		target.set_item(
			slot,
			source.get_item(
				slot
			)
		)