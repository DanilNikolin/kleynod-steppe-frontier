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
	result.active_hero_id = (
		definition.starting_active_hero_id
	)

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

		var hero_state := CampaignHeroState.new()

		hero_state.hero_definition = (
			hero_template.hero_definition
		)

		hero_state.progression_state = (
			progression_copy
		)

		if not hero_state.is_valid_state():
			return null

		result.heroes.append(
			hero_state
		)

	if result.get_active_hero() == null:
		return null

	return result