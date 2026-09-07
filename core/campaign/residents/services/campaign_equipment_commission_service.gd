class_name CampaignEquipmentCommissionService
extends RefCounted


var _resident_service := (
	CampaignResidentService.new()
)


func get_commission_error(
	campaign_state: CampaignState,
	resident_definition: CampaignResidentDefinition,
	resident_state: CampaignResidentState,
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState,
	commission_id: StringName
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if campaign_state.inventory_state == null:
		return "Campaign inventory is missing."

	if resident_definition == null:
		return "Resident definition is missing."

	if resident_state == null:
		return "Resident state is missing."

	if settlement_definition == null:
		return "Settlement definition is missing."

	if settlement_state == null:
		return "Settlement state is missing."

	if not resident_state.is_at_home():
		return (
			"Resident is not at the home settlement."
		)

	if (
		campaign_state.current_world_node_id
		!= settlement_definition.world_node_id
	):
		return (
			"Campaign party is not at the home settlement."
		)

	if not _resident_service.is_workplace_ready(
		resident_definition,
		resident_state,
		settlement_definition,
		settlement_state
	):
		return (
			"Resident workplace is not ready."
		)

	var commission := (
		resident_definition.get_equipment_commission(
			commission_id
		)
	)

	if commission == null:
		return (
			"Unknown equipment commission '%s'."
			% commission_id
		)

	if not commission.is_valid_definition():
		return (
			"Equipment commission definition is invalid."
		)

	if (
		campaign_state.inventory_state.gold
		< commission.gold_cost
	):
		return (
			"Not enough gold. Required: %d."
			% commission.gold_cost
		)

	if (
		campaign_state.materials
		< commission.material_cost
	):
		return (
			"Not enough materials. Required: %d."
			% commission.material_cost
		)

	return ""


func can_commission(
	campaign_state: CampaignState,
	resident_definition: CampaignResidentDefinition,
	resident_state: CampaignResidentState,
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState,
	commission_id: StringName
) -> bool:
	return get_commission_error(
		campaign_state,
		resident_definition,
		resident_state,
		settlement_definition,
		settlement_state,
		commission_id
	).is_empty()


func apply_commission(
	campaign_state: CampaignState,
	resident_definition: CampaignResidentDefinition,
	resident_state: CampaignResidentState,
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState,
	commission_id: StringName
) -> HeroEquipmentItemInstance:
	if not can_commission(
		campaign_state,
		resident_definition,
		resident_state,
		settlement_definition,
		settlement_state,
		commission_id
	):
		return null

	var commission := (
		resident_definition.get_equipment_commission(
			commission_id
		)
	)

	if commission == null:
		return null

	var inventory := (
		campaign_state.inventory_state
	)

	var next_serial := maxi(
		inventory.next_generated_item_serial,
		1
	)

	var instance_id: StringName = &""

	while instance_id == &"":
		var candidate_id := StringName(
			"craft_%06d_%s"
			% [
				next_serial,
				commission
					.output_item_definition
					.item_id,
			]
		)

		next_serial += 1

		if inventory.has_item(
			candidate_id
		):
			continue

		instance_id = candidate_id

	var instance := (
		HeroEquipmentItemInstance.new()
	)

	instance.instance_id = instance_id

	instance.definition = (
		commission.output_item_definition
	)

	if not instance.is_valid_instance():
		return null

	var previous_gold := inventory.gold

	var previous_materials := (
		campaign_state.materials
	)

	var previous_serial := (
		inventory.next_generated_item_serial
	)

	inventory.gold -= (
		commission.gold_cost
	)

	campaign_state.materials -= (
		commission.material_cost
	)

	inventory.next_generated_item_serial = (
		next_serial
	)

	inventory.items.append(
		instance
	)

	if (
		not inventory.is_valid_state()
		or not campaign_state.is_valid_state()
	):
		inventory.items.erase(
			instance
		)

		inventory.gold = previous_gold

		campaign_state.materials = (
			previous_materials
		)

		inventory.next_generated_item_serial = (
			previous_serial
		)

		return null

	return instance