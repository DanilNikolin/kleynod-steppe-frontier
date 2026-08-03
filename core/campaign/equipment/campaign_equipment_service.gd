class_name CampaignEquipmentService
extends RefCounted


const FAILURE_INVALID_CAMPAIGN_STATE: StringName = (
	&"invalid_campaign_state"
)

const FAILURE_UNKNOWN_HERO: StringName = (
	&"unknown_campaign_hero"
)

const FAILURE_UNKNOWN_ITEM: StringName = (
	&"unknown_inventory_item"
)

const FAILURE_EQUIPMENT_CHANGE_FAILED: StringName = (
	&"equipment_change_failed"
)


var equipment_service := (
	HeroEquipmentService.new()
)


func get_item_owner(
	state: CampaignState,
	item_instance_id: StringName
) -> CampaignHeroState:
	if (
		state == null
		or item_instance_id == &""
	):
		return null

	for hero_state in state.heroes:
		if (
			hero_state == null
			or hero_state.progression_state == null
			or hero_state
				.progression_state
				.equipment_state == null
		):
			continue

		for slot in HeroEquipmentState.get_all_slots():
			var equipped_item := (
				hero_state
					.progression_state
					.equipment_state
					.get_item(
						slot
					)
			)

			if (
				equipped_item != null
				and equipped_item.instance_id
					== item_instance_id
			):
				return hero_state

	return null


func equip_item(
	state: CampaignState,
	target_hero_id: StringName,
	item_instance_id: StringName,
	target_slot: int
) -> CampaignEquipmentChangeResult:
	var result := CampaignEquipmentChangeResult.new()

	result.target_hero_id = target_hero_id
	result.item_instance_id = item_instance_id
	result.target_slot = target_slot

	if (
		state == null
		or not state.is_valid_state()
	):
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

		return result

	var target_hero := state.get_hero(
		target_hero_id
	)

	if target_hero == null:
		result.failure_code = FAILURE_UNKNOWN_HERO
		return result

	var item := state.inventory_state.get_item(
		item_instance_id
	)

	if item == null:
		result.failure_code = FAILURE_UNKNOWN_ITEM
		return result

	var target_equipment := (
		target_hero
			.progression_state
			.equipment_state
	)

	if target_equipment == null:
		target_equipment = HeroEquipmentState.new()

		target_hero.progression_state.equipment_state = (
			target_equipment
		)

	var previous_owner := get_item_owner(
		state,
		item_instance_id
	)

	if previous_owner != null:
		result.previous_owner_hero_id = (
			previous_owner.get_hero_id()
		)

	var target_snapshot := (
		target_equipment.create_copy()
	)

	var previous_owner_equipment: HeroEquipmentState
	var previous_owner_snapshot: HeroEquipmentState

	if (
		previous_owner != null
		and previous_owner != target_hero
	):
		previous_owner_equipment = (
			previous_owner
				.progression_state
				.equipment_state
		)

		previous_owner_snapshot = (
			previous_owner_equipment.create_copy()
		)

		_remove_item_from_equipment(
			previous_owner_equipment,
			item_instance_id
		)

	var equipment_result := equipment_service.equip(
		target_equipment,
		item,
		target_slot
	)

	if not equipment_result.is_successful:
		_restore_equipment(
			target_snapshot,
			target_equipment
		)

		if (
			previous_owner_snapshot != null
			and previous_owner_equipment != null
		):
			_restore_equipment(
				previous_owner_snapshot,
				previous_owner_equipment
			)

		result.failure_code = (
			equipment_result.failure_code
		)

		return result

	if not state.is_valid_state():
		_restore_equipment(
			target_snapshot,
			target_equipment
		)

		if (
			previous_owner_snapshot != null
			and previous_owner_equipment != null
		):
			_restore_equipment(
				previous_owner_snapshot,
				previous_owner_equipment
			)

		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

		return result

	result.is_successful = true
	return result


func unequip_slot(
	state: CampaignState,
	hero_id: StringName,
	slot: int
) -> CampaignEquipmentChangeResult:
	var result := CampaignEquipmentChangeResult.new()

	result.target_hero_id = hero_id
	result.target_slot = slot

	if (
		state == null
		or not state.is_valid_state()
	):
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

		return result

	var hero_state := state.get_hero(
		hero_id
	)

	if hero_state == null:
		result.failure_code = FAILURE_UNKNOWN_HERO
		return result

	var equipment_state := (
		hero_state
			.progression_state
			.equipment_state
	)

	if equipment_state == null:
		result.failure_code = (
			FAILURE_EQUIPMENT_CHANGE_FAILED
		)

		return result

	var item := equipment_state.get_item(
		slot
	)

	if item != null:
		result.item_instance_id = (
			item.instance_id
		)

	var snapshot := equipment_state.create_copy()

	var equipment_result := equipment_service.unequip(
		equipment_state,
		slot
	)

	if not equipment_result.is_successful:
		result.failure_code = (
			equipment_result.failure_code
		)

		return result

	if not state.is_valid_state():
		_restore_equipment(
			snapshot,
			equipment_state
		)

		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

		return result

	result.is_successful = true
	return result


func _remove_item_from_equipment(
	equipment_state: HeroEquipmentState,
	item_instance_id: StringName
) -> void:
	if equipment_state == null:
		return

	for slot in HeroEquipmentState.get_all_slots():
		var item := equipment_state.get_item(
			slot
		)

		if (
			item == null
			or item.instance_id
				!= item_instance_id
		):
			continue

		equipment_state.set_item(
			slot,
			null
		)


func _restore_equipment(
	source: HeroEquipmentState,
	target: HeroEquipmentState
) -> void:
	if (
		source == null
		or target == null
	):
		return

	for slot in HeroEquipmentState.get_all_slots():
		target.set_item(
			slot,
			source.get_item(
				slot
			)
		)