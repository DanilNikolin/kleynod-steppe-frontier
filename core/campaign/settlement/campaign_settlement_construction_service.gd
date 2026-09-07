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


func can_demolish(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName
) -> bool:
	return get_demolition_error(
		campaign_state,
		settlement_definition,
		zone_id
	).is_empty()


func get_demolition_error(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if settlement_definition == null:
		return "Settlement definition is missing."

	var settlement_state := (
		campaign_state.home_settlement_state
	)

	if settlement_state == null:
		return "Settlement state is missing."

	if not settlement_state.is_valid_against_definition(
		settlement_definition
	):
		return (
			"Settlement state does not match its definition."
		)

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

	if zone_state.is_empty():
		return (
			"Settlement zone '%s' is already empty."
			% zone_id
		)

	if (
		zone_definition.get_building(
			zone_state.building_id
		)
		== null
	):
		return (
			"Settlement zone contains "
			+"an unknown building '%s'."
			% zone_state.building_id
		)

	return ""


func apply_demolition(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName
) -> bool:
	if not can_demolish(
		campaign_state,
		settlement_definition,
		zone_id
	):
		return false

	var settlement_state := (
		campaign_state.home_settlement_state
	)

	var zone_state := settlement_state.get_zone(
		zone_id
	)

	if zone_state == null:
		return false

	var previous_building_id := (
		zone_state.building_id
	)

	var previous_building_level := (
		zone_state.building_level
	)

	## Demolition intentionally returns
	## no Gold and no Materials.
	zone_state.building_id = &""
	zone_state.building_level = 0

	if (
		not settlement_state.is_valid_against_definition(
			settlement_definition
		)
		or not campaign_state.is_valid_state()
	):
		zone_state.building_id = (
			previous_building_id
		)

		zone_state.building_level = (
			previous_building_level
		)

		return false

	return true

func can_upgrade(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName
) -> bool:
	return get_upgrade_error(
		campaign_state,
		settlement_definition,
		zone_id
	).is_empty()


func get_upgrade_error(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName
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
		return (
			"Settlement state does not match its definition."
		)

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

	if zone_state.is_empty():
		return (
			"Settlement zone '%s' is empty."
			% zone_id
		)

	var building := zone_definition.get_building(
		zone_state.building_id
	)

	if building == null:
		return (
			"Settlement building definition is missing."
		)

	if (
		zone_state.building_level
		>= building.max_level
	):
		return (
			"Building is already at maximum level."
		)

	var target_level := (
		zone_state.building_level + 1
	)

	var upgrade := building.get_upgrade_to_level(
		target_level
	)

	if upgrade == null:
		return (
			"Upgrade to level %d is not defined."
			% target_level
		)

	if not upgrade.upgrade_enabled:
		return (
			"Upgrade to level %d is not available yet."
			% target_level
		)

	if (
		campaign_state.inventory_state.gold
		< upgrade.gold_cost
	):
		return (
			"Not enough gold. Required: %d."
			% upgrade.gold_cost
		)

	if (
		campaign_state.materials
		< upgrade.material_cost
	):
		return (
			"Not enough materials. Required: %d."
			% upgrade.material_cost
		)

	return ""


func apply_upgrade(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName
) -> bool:
	if not can_upgrade(
		campaign_state,
		settlement_definition,
		zone_id
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

	if (
		zone_definition == null
		or zone_state == null
	):
		return false

	var building := zone_definition.get_building(
		zone_state.building_id
	)

	if building == null:
		return false

	var upgrade := building.get_upgrade_to_level(
		zone_state.building_level + 1
	)

	if upgrade == null:
		return false

	var previous_gold := (
		campaign_state.inventory_state.gold
	)

	var previous_materials := (
		campaign_state.materials
	)

	var previous_level := (
		zone_state.building_level
	)

	campaign_state.inventory_state.gold -= (
		upgrade.gold_cost
	)

	campaign_state.materials -= (
		upgrade.material_cost
	)

	zone_state.building_level = (
		upgrade.target_level
	)

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

		zone_state.building_level = (
			previous_level
		)

		return false

	return true