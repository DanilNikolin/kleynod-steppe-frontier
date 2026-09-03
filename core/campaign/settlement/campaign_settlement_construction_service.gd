class_name CampaignSettlementConstructionService
extends RefCounted


func can_construct(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName,
	building_id: StringName
) -> bool:
	return get_construction_error(
		campaign_state,
		settlement_definition,
		zone_id,
		building_id
	).is_empty()


func get_construction_error(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName,
	building_id: StringName
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if settlement_definition == null:
		return "Settlement definition is missing."

	if campaign_state.inventory_state == null:
		return "Campaign inventory is missing."

	var settlement_state := (
		campaign_state.home_settlement_state
	)

	if settlement_state == null:
		return "Settlement state is missing."

	if not settlement_state.is_valid_against_definition(
		settlement_definition
	):
		return "Settlement state does not match its definition."

	var zone_definition := (
		settlement_definition.get_zone(
			zone_id
		)
	)

	if zone_definition == null:
		return (
			"Unknown settlement zone '%s'."
			% zone_id
		)

	var zone_state := settlement_state.get_zone(
		zone_id
	)

	if zone_state == null:
		return (
			"Settlement zone state '%s' is missing."
			% zone_id
		)

	if not zone_state.is_empty():
		return (
			"Settlement zone '%s' is already occupied."
			% zone_id
		)

	var building := zone_definition.get_building(
		building_id
	)

	if building == null:
		return (
			"Building '%s' is not allowed in zone '%s'."
			% [
				building_id,
				zone_id,
			]
		)

	if not building.construction_enabled:
		return (
			"Building '%s' is not available for construction yet."
			% building_id
		)

	if (
		campaign_state.inventory_state.gold
		< building.construction_gold_cost
	):
		return (
			"Not enough gold. Required: %d."
			% building.construction_gold_cost
		)

	if (
		campaign_state.materials
		< building.construction_material_cost
	):
		return (
			"Not enough materials. Required: %d."
			% building.construction_material_cost
		)

	return ""


func apply_construction(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName,
	building_id: StringName
) -> bool:
	if not can_construct(
		campaign_state,
		settlement_definition,
		zone_id,
		building_id
	):
		return false

	var settlement_state := (
		campaign_state.home_settlement_state
	)

	var zone_definition := (
		settlement_definition.get_zone(
			zone_id
		)
	)

	var zone_state := settlement_state.get_zone(
		zone_id
	)

	var building := zone_definition.get_building(
		building_id
	)

	if (
		zone_state == null
		or building == null
	):
		return false

	var previous_gold := (
		campaign_state.inventory_state.gold
	)

	var previous_materials := (
		campaign_state.materials
	)

	var previous_building_id := (
		zone_state.building_id
	)

	var previous_building_level := (
		zone_state.building_level
	)

	campaign_state.inventory_state.gold -= (
		building.construction_gold_cost
	)

	campaign_state.materials -= (
		building.construction_material_cost
	)

	zone_state.building_id = (
		building.building_id
	)

	zone_state.building_level = 1

	if (
		not settlement_state.is_valid_against_definition(
			settlement_definition
		)
		or not campaign_state.is_valid_state()
	):
		campaign_state.inventory_state.gold = (
			previous_gold
		)

		campaign_state.materials = (
			previous_materials
		)

		zone_state.building_id = (
			previous_building_id
		)

		zone_state.building_level = (
			previous_building_level
		)

		return false

	return true