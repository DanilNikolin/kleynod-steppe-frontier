class_name CampaignStateFactory
extends RefCounted


func create_from_definition(
	definition: CampaignDefinition
) -> CampaignState:
	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return null

	var result := CampaignState.new()

	result.campaign_id = definition.campaign_id

	result.selected_hero_id = (
		definition.starting_selected_hero_id
	)

	for hero_id in (
		definition.starting_party_member_hero_ids
	):
		result.party_member_hero_ids.append(
			hero_id
		)

	result.inventory_state = _create_inventory(
		definition
	)

	if result.inventory_state == null:
		return null

	for hero_template in (
		definition.starting_heroes
	):
		if hero_template == null:
			return null

		var progression_copy := (
			hero_template
				.progression_state
				.duplicate(true)
			as HeroProgressionState
		)

		if progression_copy == null:
			return null

		if progression_copy.equipment_state == null:
			progression_copy.equipment_state = (
				HeroEquipmentState.new()
			)

		elif not _remap_equipment_to_inventory(
			progression_copy.equipment_state,
			result.inventory_state
		):
			return null

		var hero_state := CampaignHeroState.new()

		hero_state.hero_definition = (
			hero_template.hero_definition
		)

		hero_state.progression_state = (
			progression_copy
		)

		hero_state.is_placeholder_content = (
			hero_template.is_placeholder_content
		)

		hero_state.roster_note = (
			hero_template.roster_note
		)

		if not hero_state.is_valid_state():
			return null

		result.heroes.append(
			hero_state
		)

	if not result.is_valid_state():
		return null

	return result


func _create_inventory(
	definition: CampaignDefinition
) -> CampaignInventoryState:
	var result := CampaignInventoryState.new()
	result.gold = definition.starting_gold

	for item_template in (
		definition.starting_inventory_items
	):
		if item_template == null:
			return null

		var item_copy := (
			item_template.duplicate(true)
			as HeroEquipmentItemInstance
		)

		if (
			item_copy == null
			or not item_copy.is_valid_instance()
		):
			return null

		result.items.append(
			item_copy
		)

	if not result.is_valid_state():
		return null

	return result


func _remap_equipment_to_inventory(
	equipment_state: HeroEquipmentState,
	inventory_state: CampaignInventoryState
) -> bool:
	if (
		equipment_state == null
		or inventory_state == null
	):
		return false

	for slot in HeroEquipmentState.get_all_slots():
		var equipped_item := equipment_state.get_item(
			slot
		)

		if equipped_item == null:
			continue

		var inventory_item := inventory_state.get_item(
			equipped_item.instance_id
		)

		if inventory_item == null:
			return false

		equipment_state.set_item(
			slot,
			inventory_item
		)

	return equipment_state.is_valid_state()