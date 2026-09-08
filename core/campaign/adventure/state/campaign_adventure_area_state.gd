class_name CampaignAdventureAreaState
extends RefCounted


var area_id: StringName = &""

var sites: Array[CampaignAdventureSiteState] = []


func get_site(
	site_id: StringName
) -> CampaignAdventureSiteState:
	if site_id == &"":
		return null

	for site_state in sites:
		if (
			site_state != null
			and site_state.site_id == site_id
		):
			return site_state

	return null


func is_valid_state() -> bool:
	if area_id == &"":
		return false

	var used_site_ids: Dictionary = {}

	for site_state in sites:
		if (
			site_state == null
			or not site_state.is_valid_state()
		):
			return false

		if used_site_ids.has(
			site_state.site_id
		):
			return false

		used_site_ids[
			site_state.site_id
		] = true

	return true


func is_valid_against_definition(
	definition: CampaignAdventureAreaDefinition
) -> bool:
	if (
		definition == null
		or area_id != definition.area_id
		or not is_valid_state()
		or sites.size() != definition.sites.size()
	):
		return false

	for site_definition in definition.sites:
		if site_definition == null:
			return false

		if get_site(
			site_definition.site_id
		) == null:
			return false

	return true