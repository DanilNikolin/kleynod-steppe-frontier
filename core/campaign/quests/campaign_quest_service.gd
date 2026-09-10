class_name CampaignQuestService
extends RefCounted


const MAX_REPUTATION: int = 999999999


func get_start_error(
	campaign_state: CampaignState,
	quest_definition: CampaignQuestDefinition,
	quest_state: CampaignQuestState,
	giver_definition: CampaignResidentDefinition,
	giver_state: CampaignResidentState,
	home_settlement_definition: CampaignSettlementDefinition
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if quest_definition == null:
		return "Quest definition is missing."

	if quest_state == null:
		return "Quest state is missing."

	if quest_definition.uses_resident_giver():
		if giver_definition == null:
			return "Quest giver definition is missing."

		if giver_state == null:
			return "Quest giver state is missing."

	if not quest_state.is_not_started():
		return "Quest has already been started."

	var giver_world_node_id := (
		_get_quest_giver_world_node_id(
			quest_definition,
			giver_definition,
			giver_state,
			home_settlement_definition
		)
	)

	if giver_world_node_id == &"":
		return "Quest giver location is unavailable."

	if (
		campaign_state.current_world_node_id
		!= giver_world_node_id
	):
		return "Campaign party is not at the quest giver."

	for unlock in (
		quest_definition
			.start_adventure_site_unlocks
	):
		if unlock == null:
			return (
				"Quest adventure unlock is missing."
			)

		var area_state := (
			campaign_state.get_adventure_area(
				unlock.area_id
			)
		)

		if area_state == null:
			return (
				"Quest adventure area state is missing: %s."
				% unlock.area_id
			)

		if area_state.get_site(
			unlock.site_id
		) == null:
			return (
				"Quest adventure site state is missing: %s/%s."
				% [
					unlock.area_id,
					unlock.site_id,
				]
			)

	return ""


func apply_start(
	campaign_state: CampaignState,
	quest_definition: CampaignQuestDefinition,
	quest_state: CampaignQuestState,
	giver_definition: CampaignResidentDefinition,
	giver_state: CampaignResidentState,
	home_settlement_definition: CampaignSettlementDefinition
) -> bool:
	if not get_start_error(
		campaign_state,
		quest_definition,
		quest_state,
		giver_definition,
		giver_state,
		home_settlement_definition
	).is_empty():
		return false

	var previous_status := (
		quest_state.status
	)

	var previous_site_statuses: Dictionary = {}

	for unlock in (
		quest_definition
			.start_adventure_site_unlocks
	):
		var area_state := (
			campaign_state.get_adventure_area(
				unlock.area_id
			)
		)

		var site_state := area_state.get_site(
			unlock.site_id
		)

		var key := (
			"%s::%s"
			% [
				unlock.area_id,
				unlock.site_id,
			]
		)

		previous_site_statuses[
			key
		] = int(
			site_state.status
		)

		if site_state.is_hidden():
			site_state.status = (
				CampaignAdventureSiteState
					.Status
					.AVAILABLE
			)

	quest_state.status = (
		CampaignQuestState.Status.ACTIVE
	)

	if campaign_state.is_valid_state():
		return true

	quest_state.status = previous_status

	_restore_adventure_unlock_statuses(
		campaign_state,
		quest_definition,
		previous_site_statuses
	)

	return false


func apply_battle_result(
	quest_definitions: Array[
		CampaignQuestDefinition
	],
	campaign_state: CampaignState,
	battle_result: CampaignBattleResult
) -> bool:
	if (
		campaign_state == null
		or battle_result == null
	):
		return false

	if (
		battle_result.outcome
		!= CampaignBattleResult.Outcome.VICTORY
	):
		return true

	var previous_progress: Dictionary = {}

	for quest_definition in quest_definitions:
		if quest_definition == null:
			continue

		var quest_state := campaign_state.get_quest(
			quest_definition.quest_id
		)

		if (
			quest_state == null
			or not quest_state.is_active()
		):
			continue

		previous_progress[
			quest_state.quest_id
		] = quest_state.completed_objective_ids.duplicate()

		for objective in quest_definition.objectives:
			if (
				objective == null
				or objective.objective_type
					!= CampaignQuestObjectiveDefinition
						.ObjectiveType
						.WIN_LOCATION_BATTLE
				or objective.target_location_id
					!= battle_result.location_id
				or quest_state.is_objective_completed(
					objective.objective_id
				)
			):
				continue

			quest_state.completed_objective_ids.append(
				objective.objective_id
			)

	if campaign_state.is_valid_state():
		return true

	for quest_id_value in previous_progress:
		var quest_state := campaign_state.get_quest(
			StringName(quest_id_value)
		)

		if quest_state == null:
			continue

		quest_state.completed_objective_ids = (
			previous_progress[
				quest_id_value
			].duplicate()
		)

	return false


func get_turn_in_error(
	campaign_state: CampaignState,
	quest_definition: CampaignQuestDefinition,
	quest_state: CampaignQuestState,
	giver_definition: CampaignResidentDefinition,
	giver_state: CampaignResidentState,
	home_settlement_definition: CampaignSettlementDefinition
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if (
		quest_definition == null
		or quest_state == null
	):
		return "Quest is missing."

	if quest_definition.uses_resident_giver():
		if (
			giver_definition == null
			or giver_state == null
		):
			return "Quest giver is missing."

	if not quest_state.is_active():
		return "Quest is not active."

	if not quest_state.is_ready_to_turn_in(
		quest_definition
	):
		return "Quest objectives are not complete."

	var giver_world_node_id := (
		_get_quest_giver_world_node_id(
			quest_definition,
			giver_definition,
			giver_state,
			home_settlement_definition
		)
	)

	if (
		giver_world_node_id == &""
		or campaign_state.current_world_node_id
			!= giver_world_node_id
	):
		return "Campaign party is not at the quest giver."

	if (
		quest_definition.reputation_reward > 0
		and campaign_state.reputation
			> MAX_REPUTATION
				- quest_definition.reputation_reward
	):
		return "Reputation reward would overflow."

	for resident_id in (
		quest_definition
			.recruitment_unlock_resident_ids
	):
		if campaign_state.get_resident(
			resident_id
		) == null:
			return (
				"Quest reward references "
				+"missing resident '%s'."
				% resident_id
			)

	return ""


func apply_turn_in(
	campaign_state: CampaignState,
	quest_definition: CampaignQuestDefinition,
	quest_state: CampaignQuestState,
	giver_definition: CampaignResidentDefinition,
	giver_state: CampaignResidentState,
	home_settlement_definition: CampaignSettlementDefinition
) -> bool:
	if not get_turn_in_error(
		campaign_state,
		quest_definition,
		quest_state,
		giver_definition,
		giver_state,
		home_settlement_definition
	).is_empty():
		return false

	var previous_status := quest_state.status

	var previous_reputation := (
		campaign_state.reputation
	)

	var previous_unlocks: Dictionary = {}

	for resident_id in (
		quest_definition
			.recruitment_unlock_resident_ids
	):
		var resident := campaign_state.get_resident(
			resident_id
		)

		if resident == null:
			continue

		previous_unlocks[
			resident_id
		] = resident.recruitment_unlocked

		resident.recruitment_unlocked = true

	campaign_state.reputation += (
		quest_definition.reputation_reward
	)

	quest_state.status = (
		CampaignQuestState.Status.COMPLETED
	)

	if campaign_state.is_valid_state():
		return true

	quest_state.status = previous_status

	campaign_state.reputation = (
		previous_reputation
	)

	for resident_id_value in previous_unlocks:
		var resident := campaign_state.get_resident(
			StringName(resident_id_value)
		)

		if resident != null:
			resident.recruitment_unlocked = bool(
				previous_unlocks[
					resident_id_value
				]
			)

	return false


func get_abandon_error(
	campaign_state: CampaignState,
	quest_definition: CampaignQuestDefinition,
	quest_state: CampaignQuestState
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if quest_definition == null:
		return "Quest definition is missing."

	if quest_state == null:
		return "Quest state is missing."

	if not quest_state.is_active():
		return "Only an active quest can be abandoned."

	if not quest_definition.abandon_enabled:
		return "This quest cannot be abandoned."

	return ""


func apply_abandon(
	campaign_state: CampaignState,
	quest_definition: CampaignQuestDefinition,
	quest_state: CampaignQuestState
) -> bool:
	if not get_abandon_error(
		campaign_state,
		quest_definition,
		quest_state
	).is_empty():
		return false

	var previous_status := (
		quest_state.status
	)

	var previous_objective_ids := (
		quest_state
			.completed_objective_ids
			.duplicate()
	)

	var previous_site_statuses: Dictionary = {}

	for unlock in (
		quest_definition
			.start_adventure_site_unlocks
	):
		if unlock == null:
			continue

		var area_state := (
			campaign_state.get_adventure_area(
				unlock.area_id
			)
		)

		if area_state == null:
			continue

		var site_state := area_state.get_site(
			unlock.site_id
		)

		if site_state == null:
			continue

		var key := (
			"%s::%s"
			% [
				unlock.area_id,
				unlock.site_id,
			]
		)

		previous_site_statuses[
			key
		] = int(
			site_state.status
		)

		## Если quest-owned encounter уже был
		## зачищен, отказ делает его снова доступным.
		##
		## HIDDEN не возвращаем:
		## место уже было обнаружено.
		if site_state.is_cleared():
			site_state.status = (
				CampaignAdventureSiteState
					.Status
					.AVAILABLE
			)

	quest_state.status = (
		CampaignQuestState
			.Status
			.NOT_STARTED
	)

	quest_state.completed_objective_ids.clear()

	if (
		quest_state.is_valid_against_definition(
			quest_definition
		)
		and campaign_state.is_valid_state()
	):
		return true

	quest_state.status = previous_status

	quest_state.completed_objective_ids = (
		previous_objective_ids
	)

	_restore_adventure_unlock_statuses(
		campaign_state,
		quest_definition,
		previous_site_statuses
	)

	return false


func _restore_adventure_unlock_statuses(
	campaign_state: CampaignState,
	quest_definition: CampaignQuestDefinition,
	previous_statuses: Dictionary
) -> void:
	for unlock in (
		quest_definition
			.start_adventure_site_unlocks
	):
		if unlock == null:
			continue

		var area_state := (
			campaign_state.get_adventure_area(
				unlock.area_id
			)
		)

		if area_state == null:
			continue

		var site_state := area_state.get_site(
			unlock.site_id
		)

		if site_state == null:
			continue

		var key := (
			"%s::%s"
			% [
				unlock.area_id,
				unlock.site_id,
			]
		)

		if not previous_statuses.has(
			key
		):
			continue

		site_state.status = (
			int(
				previous_statuses[
					key
				]
			)
			as CampaignAdventureSiteState.Status
		)


func _get_quest_giver_world_node_id(
	quest_definition: CampaignQuestDefinition,
	giver_definition: CampaignResidentDefinition,
	giver_state: CampaignResidentState,
	home_settlement_definition: CampaignSettlementDefinition
) -> StringName:
	if quest_definition == null:
		return &""

	if quest_definition.uses_local_interaction_giver():
		return quest_definition.giver_world_node_id

	return _get_resident_world_node_id(
		giver_definition,
		giver_state,
		home_settlement_definition
	)


func _get_resident_world_node_id(
	definition: CampaignResidentDefinition,
	state: CampaignResidentState,
	home_settlement_definition: CampaignSettlementDefinition
) -> StringName:
	if (
		definition == null
		or state == null
	):
		return &""

	if state.is_at_origin():
		return state.current_world_node_id if state.current_world_node_id != &"" else definition.origin_world_node_id

	if (
		state.is_at_home()
		and home_settlement_definition != null
	):
		return home_settlement_definition.world_node_id

	return &""


func apply_exploration_result(definitions: Array[CampaignQuestDefinition], state: CampaignState, area_id: StringName, site_id: StringName) -> bool:
	var area := state.get_adventure_area(area_id)
	if area == null or area.get_site(site_id) == null or not area.get_site(site_id).is_cleared():
		return false
	var previous: Dictionary = {}
	for definition in definitions:
		var quest := state.get_quest(definition.quest_id)
		if quest == null or not quest.is_active():
			continue
		previous[quest.quest_id] = quest.completed_objective_ids.duplicate()
		for objective in definition.objectives:
			if objective.objective_type == CampaignQuestObjectiveDefinition.ObjectiveType.EXPLORE_ADVENTURE_SITE and objective.target_area_id == area_id and objective.target_site_id == site_id and not quest.is_objective_completed(objective.objective_id):
				quest.completed_objective_ids.append(objective.objective_id)
	if state.is_valid_state():
		return true
	for id in previous:
		state.get_quest(id).completed_objective_ids = previous[id]
	return false
