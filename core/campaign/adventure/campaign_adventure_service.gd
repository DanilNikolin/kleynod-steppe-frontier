class_name CampaignAdventureService
extends RefCounted


const MAX_MATERIALS: int = 999999999


func get_landmark_exploration_error(
	campaign_state: CampaignState,
	area_definition: CampaignAdventureAreaDefinition,
	area_state: CampaignAdventureAreaState,
	site_id: StringName
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if area_definition == null:
		return "Adventure area definition is missing."

	if area_state == null:
		return "Adventure area state is missing."

	var site_definition := (
		area_definition.get_site(
			site_id
		)
	)

	var site_state := area_state.get_site(
		site_id
	)

	if site_definition == null:
		return "Adventure site definition is missing."

	if site_state == null:
		return "Adventure site state is missing."

	if not site_state.is_available():
		return "Adventure landmark is not available."

	if (
		site_definition.site_type
		!= CampaignAdventureSiteDefinition
			.SiteType
			.LANDMARK
	):
		return "Adventure site is not a landmark."

	if not site_definition.exploration_enabled:
		return "Adventure landmark has no exploration action."

	if site_definition.material_reward > 0:
		var bundle := site_definition.material_bundle_definition
		if bundle == null or bundle.material_value <= 0 or site_definition.material_reward % bundle.material_value != 0:
			return "Неверная награда материалов."
		var count: int = site_definition.material_reward / bundle.material_value
		if not campaign_state.inventory_state.can_add_items(count):
			return "Не хватает места: нужно %d свободных мест. Разгрузите груз в HOME." % count

	return ""


func apply_landmark_exploration(
	campaign_state: CampaignState,
	area_definition: CampaignAdventureAreaDefinition,
	area_state: CampaignAdventureAreaState,
	site_id: StringName
) -> bool:
	var error := get_landmark_exploration_error(
		campaign_state,
		area_definition,
		area_state,
		site_id
	)

	if not error.is_empty():
		return false

	var site_definition := (
		area_definition.get_site(
			site_id
		)
	)

	var site_state := area_state.get_site(
		site_id
	)

	if (
		site_definition == null
		or site_state == null
	):
		return false

	var previous_items := campaign_state.inventory_state.items.duplicate()
	var previous_serial := campaign_state.inventory_state.next_generated_item_serial

	var previous_status := (
		site_state.status
	)

	if not campaign_state.inventory_state.add_material_bundles(site_definition.material_bundle_definition, site_definition.material_reward):
		return false

	site_state.status = (
		CampaignAdventureSiteState
			.Status
			.CLEARED
	)

	if (
		campaign_state.is_valid_state()
		and area_state.is_valid_against_definition(
			area_definition
		)
	):
		return true

	campaign_state.inventory_state.items.assign(previous_items)
	campaign_state.inventory_state.next_generated_item_serial = previous_serial

	site_state.status = (
		previous_status
	)

	return false


func get_battle_site_error(
	area_definition: CampaignAdventureAreaDefinition,
	area_state: CampaignAdventureAreaState,
	site_id: StringName
) -> String:
	if area_definition == null:
		return "Adventure area definition is missing."

	if area_state == null:
		return "Adventure area state is missing."

	var site_definition := (
		area_definition.get_site(
			site_id
		)
	)

	var site_state := area_state.get_site(
		site_id
	)

	if site_definition == null:
		return "Adventure site definition is missing."

	if site_state == null:
		return "Adventure site state is missing."

	if site_state.is_hidden():
		return "Adventure site is still hidden."

	if site_state.is_cleared():
		return "Adventure site has already been cleared."

	if (
		site_definition.site_type
		!= CampaignAdventureSiteDefinition.SiteType.BATTLE
	):
		return "Adventure site is not a battle site."

	if site_definition.campaign_location_id == &"":
		return "Adventure battle site has no campaign location."

	return ""


func apply_battle_result(
	area_definition: CampaignAdventureAreaDefinition,
	area_state: CampaignAdventureAreaState,
	site_id: StringName,
	result: CampaignBattleResult
) -> bool:
	if (
		area_definition == null
		or area_state == null
		or result == null
	):
		return false

	var site_definition := (
		area_definition.get_site(
			site_id
		)
	)

	var site_state := area_state.get_site(
		site_id
	)

	if (
		site_definition == null
		or site_state == null
	):
		return false

	if (
		result.outcome
		!= CampaignBattleResult.Outcome.VICTORY
		or not site_definition.clear_on_victory
	):
		return true

	var previous_status := (
		site_state.status
	)

	site_state.status = (
		CampaignAdventureSiteState.Status.CLEARED
	)

	if area_state.is_valid_against_definition(
		area_definition
	):
		return true

	site_state.status = previous_status

	return false