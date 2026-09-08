class_name CampaignAdventureService
extends RefCounted


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