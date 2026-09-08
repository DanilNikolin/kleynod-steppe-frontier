class_name CampaignAdventureAreaStateFactory
extends RefCounted


func create_from_definition(
	definition: CampaignAdventureAreaDefinition
) -> CampaignAdventureAreaState:
	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return null

	var result := (
		CampaignAdventureAreaState.new()
	)

	result.area_id = definition.area_id

	for site_definition in definition.sites:
		if site_definition == null:
			return null

		var site_state := (
			CampaignAdventureSiteState.new()
		)

		site_state.site_id = (
			site_definition.site_id
		)

		site_state.status = (
			CampaignAdventureSiteState.Status.AVAILABLE
			if site_definition.starting_available
			else CampaignAdventureSiteState.Status.HIDDEN
		)

		result.sites.append(
			site_state
		)

	if not result.is_valid_against_definition(
		definition
	):
		return null

	return result