class_name CampaignSettlementStateFactory
extends RefCounted


func create_from_definition(
	definition: CampaignSettlementDefinition
) -> CampaignSettlementState:
	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return null

	var result := CampaignSettlementState.new()

	result.settlement_id = (
		definition.settlement_id
	)

	for zone_definition in definition.zones:
		if zone_definition == null:
			return null

		var zone_state := (
			CampaignSettlementZoneState.new()
		)

		zone_state.zone_id = (
			zone_definition.zone_id
		)

		zone_state.building_id = (
			zone_definition.starting_building_id
		)

		zone_state.building_level = (
			1
			if zone_state.building_id != &""
			else 0
		)

		result.zones.append(
			zone_state
		)

	if not result.is_valid_against_definition(
		definition
	):
		return null

	return result