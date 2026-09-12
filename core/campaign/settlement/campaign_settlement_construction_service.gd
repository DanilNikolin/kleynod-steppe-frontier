class_name CampaignSettlementConstructionService
extends RefCounted


var _effect_service := (
	CampaignSettlementEffectService.new()
)


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

	if zone_state.has_pending_construction():
		return (
			"Settlement zone '%s' already has construction in progress."
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

	for required_effect_id in (
		building.required_effect_ids
	):
		if not _effect_service.has_active_effect(
			settlement_definition,
			settlement_state,
			required_effect_id
		):
			return (
				"Required settlement effect '%s' is missing."
				% required_effect_id
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


func start_construction(
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

	var now := (
		campaign_state.current_day
		* CampaignTimeService.MINUTES_PER_DAY
		+ campaign_state.current_minute_of_day
	)

	var completes_at := now + building.construction_minutes
	var completes_day := floori(float(completes_at) / float(CampaignTimeService.MINUTES_PER_DAY))
	if completes_day > CampaignTimeService.MAX_CAMPAIGN_DAY:
		return false

	var previous_gold := (
		campaign_state.inventory_state.gold
	)

	var previous_materials := (
		campaign_state.materials
	)

	campaign_state.inventory_state.gold -= (
		building.construction_gold_cost
	)

	campaign_state.materials -= (
		building.construction_material_cost
	)

	zone_state.pending_building_id = building.building_id
	zone_state.pending_target_level = 1
	zone_state.pending_started_at = now
	zone_state.pending_completes_at = completes_at
	zone_state.pending_paid_gold = building.construction_gold_cost
	zone_state.pending_paid_materials = building.construction_material_cost

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

		zone_state.clear_pending_construction()
		return false

	return true


func complete_due(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition
) -> bool:
	if campaign_state == null or settlement_definition == null:
		return false

	var settlement_state := (
		campaign_state.home_settlement_state
	)

	if settlement_state == null:
		return false

	var now := (
		campaign_state.current_day
		* CampaignTimeService.MINUTES_PER_DAY
		+ campaign_state.current_minute_of_day
	)

	for zone_def in settlement_definition.zones:
		if zone_def == null:
			continue

		var zone_state := settlement_state.get_zone(zone_def.zone_id)
		if zone_state == null:
			continue

		if not zone_state.has_pending_construction():
			continue

		if now < zone_state.pending_completes_at:
			continue

		var building := zone_def.get_building(zone_state.pending_building_id)
		if building == null:
			return false

		if zone_state.pending_target_level != 1:
			return false

		if (zone_state.pending_completes_at - zone_state.pending_started_at) != building.construction_minutes:
			return false

		if zone_state.pending_paid_gold != building.construction_gold_cost:
			return false

		if zone_state.pending_paid_materials != building.construction_material_cost:
			return false

		zone_state.building_id = zone_state.pending_building_id
		zone_state.building_level = zone_state.pending_target_level
		zone_state.clear_pending_construction()

	if not settlement_state.is_valid_against_definition(settlement_definition):
		return false

	if not campaign_state.is_valid_state():
		return false

	return true


func apply_construction(
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	zone_id: StringName,
	building_id: StringName
) -> bool:
	return start_construction(
		campaign_state,
		settlement_definition,
		zone_id,
		building_id
	)


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

	var building := zone_definition.get_building(
		zone_state.building_id
	)

	if building == null:
		return (
			"Settlement zone contains "
			+"an unknown building '%s'."
			% zone_state.building_id
		)

	if not building.demolition_enabled:
		return (
			"Settlement building '%s' cannot be demolished."
			% building.building_id
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