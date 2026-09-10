class_name CampaignResidentService
extends RefCounted


func get_recruitment_error(
	campaign_state: CampaignState,
	definition: CampaignResidentDefinition,
	state: CampaignResidentState,
	settlement_definition: CampaignSettlementDefinition = null
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
		!= get_origin_world_node_id(definition, state)
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

	if not definition.required_home_effect_ids.is_empty():
		var effects := CampaignSettlementEffectService.new()
		for id in definition.required_home_effect_ids:
			if not effects.has_active_effect(settlement_definition, campaign_state.home_settlement_state, id):
				return "Подготовьте HOME: костровище, временное укрытие отряда и общий походный навес."
	return ""


func can_recruit(
	campaign_state: CampaignState,
	definition: CampaignResidentDefinition,
	state: CampaignResidentState,
	settlement_definition: CampaignSettlementDefinition = null
) -> bool:
	return get_recruitment_error(
		campaign_state,
		definition,
		state,
		settlement_definition
	).is_empty()


func apply_recruitment(
	campaign_state: CampaignState,
	definition: CampaignResidentDefinition,
	state: CampaignResidentState,
	settlement_definition: CampaignSettlementDefinition = null
) -> bool:
	if not can_recruit(
		campaign_state,
		definition,
		state,
		settlement_definition
	):
		return false

	var previous_status := state.status

	state.status = CampaignResidentState.Status.HOME_GUEST if definition.arrives_as_guest else CampaignResidentState.Status.HOME_SETTLEMENT

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
	interaction_id: StringName,
	world_node_id: StringName = &""
) -> bool:
	if (
		definition == null
		or state == null
		or interaction_id == &""
	):
		return false

	if state.is_at_origin():
		if world_node_id != &"" and world_node_id != get_origin_world_node_id(definition, state):
			return false
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

func get_origin_world_node_id(definition: CampaignResidentDefinition, state: CampaignResidentState) -> StringName:
	return state.current_world_node_id if state.current_world_node_id != &"" else definition.origin_world_node_id


func update_wandering(campaign: CampaignDefinition, state: CampaignState) -> void:
	var now := state.current_day * 1440 + state.current_minute_of_day
	for definition in campaign.residents:
		var resident := state.get_resident(definition.resident_id)
		if resident == null or definition.wandering_world_node_ids.is_empty():
			continue
		if not resident.is_at_origin() or resident.has_met or resident.location_clue_known:
			continue
		if now < resident.next_move_at_minute:
			continue
		var interval := definition.wandering_interval_minutes
		var steps: int = (now - resident.next_move_at_minute) / interval + 1
		var index := definition.wandering_world_node_ids.find(resident.current_world_node_id)
		resident.current_world_node_id = definition.wandering_world_node_ids[(index + steps) % definition.wandering_world_node_ids.size()]
		resident.next_move_at_minute += steps * interval
