class_name CampaignResidentService
extends RefCounted


func get_recruitment_error(
	campaign_state: CampaignState,
	definition: CampaignResidentDefinition,
	state: CampaignResidentState
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if definition == null:
		return "Resident definition is missing."

	if state == null:
		return "Resident state is missing."

	if (
		state.resident_id
		!= definition.resident_id
	):
		return (
			"Resident state does not match definition."
		)

	if not state.is_at_origin():
		return (
			"Resident has already left the origin location."
		)

	if (
		campaign_state.current_world_node_id
		!= definition.origin_world_node_id
	):
		return (
			"Campaign party is not at the resident origin."
		)

	if not state.recruitment_unlocked:
		return (
			"Resident recruitment condition is not completed."
		)

	if (
		campaign_state.reputation
		< definition.required_reputation
	):
		return (
			"Not enough reputation. Required: %d."
			% definition.required_reputation
		)

	return ""


func can_recruit(
	campaign_state: CampaignState,
	definition: CampaignResidentDefinition,
	state: CampaignResidentState
) -> bool:
	return get_recruitment_error(
		campaign_state,
		definition,
		state
	).is_empty()


func apply_recruitment(
	campaign_state: CampaignState,
	definition: CampaignResidentDefinition,
	state: CampaignResidentState
) -> bool:
	if not can_recruit(
		campaign_state,
		definition,
		state
	):
		return false

	var previous_status := state.status

	state.status = (
		CampaignResidentState
			.Status
			.HOME_SETTLEMENT
	)

	if (
		not state.is_valid_state()
		or not campaign_state.is_valid_state()
	):
		state.status = previous_status
		return false

	return true


func is_interaction_present(
	definition: CampaignResidentDefinition,
	state: CampaignResidentState,
	interaction_id: StringName
) -> bool:
	if (
		definition == null
		or state == null
		or interaction_id == &""
	):
		return false

	if state.is_at_origin():
		return (
			interaction_id
			== definition.origin_interaction_id
		)

	if state.is_at_home():
		return (
			interaction_id
			== definition.home_interaction_id
		)

	return false


func is_workplace_ready(
	definition: CampaignResidentDefinition,
	state: CampaignResidentState,
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState
) -> bool:
	if (
		definition == null
		or state == null
		or not state.is_at_home()
	):
		return false

	if not definition.has_required_workplace():
		return true

	if (
		settlement_definition == null
		or settlement_state == null
	):
		return false

	var zone_definition := (
		settlement_definition.get_zone(
			definition.required_workplace_zone_id
		)
	)

	var zone_state := settlement_state.get_zone(
		definition.required_workplace_zone_id
	)

	if (
		zone_definition == null
		or zone_state == null
		or zone_state.is_empty()
	):
		return false

	if (
		zone_state.building_id
		!= definition.required_workplace_building_id
	):
		return false

	return (
		zone_definition.get_building(
			zone_state.building_id
		)
		!= null
	)