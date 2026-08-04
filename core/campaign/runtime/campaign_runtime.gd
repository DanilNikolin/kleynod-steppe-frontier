class_name CampaignRuntimeService
extends Node


const PLAYER_TEAM_ID: StringName = &"team_player"

const CAMPAIGN_SCENE_PATH: String = (
	"res://scenes/campaign/campaign_sandbox.tscn"
)

const BATTLE_SCENE_PATH: String = (
	"res://scenes/debug/battle_grid_sandbox.tscn"
)

const DEBUG_CAMPAIGN_DEFINITION_PATH: String = (
	"res://content/campaign/debug/"
	+"debug_campaign_definition.tres"
)


var campaign_definition: CampaignDefinition
var campaign_state: CampaignState

var pending_battle_request: CampaignBattleRequest

var state_factory := CampaignStateFactory.new()

var _battle_request_counter: int = 0


func _ready() -> void:
	ensure_campaign_started()


func ensure_campaign_started() -> bool:
	if campaign_state != null:
		return true

	return start_new_campaign()


func start_new_campaign() -> bool:
	var loaded_definition := load(
		DEBUG_CAMPAIGN_DEFINITION_PATH
	)

	campaign_definition = (
		loaded_definition as CampaignDefinition
	)

	if (
		campaign_definition == null
		or not campaign_definition.is_valid_definition()
	):
		push_error(
			"CampaignRuntime failed to load "
			+"a valid CampaignDefinition."
		)

		return false

	campaign_state = (
		state_factory.create_from_definition(
			campaign_definition
		)
	)

	if campaign_state == null:
		push_error(
			"CampaignRuntime failed to create "
			+"CampaignState."
		)

		return false

	pending_battle_request = null
	_battle_request_counter = 0

	return true


func get_campaign_state() -> CampaignState:
	return campaign_state


func get_inventory_state() -> CampaignInventoryState:
	if campaign_state == null:
		return null

	return campaign_state.inventory_state


func get_selected_hero_state() -> CampaignHeroState:
	if campaign_state == null:
		return null

	return campaign_state.get_selected_hero()


## Compatibility alias для старых debug-вызовов.
func get_active_hero_state() -> CampaignHeroState:
	return get_selected_hero_state()


func get_party_members() -> Array[CampaignHeroState]:
	if campaign_state == null:
		return []

	return campaign_state.get_party_members()


func get_location(
	location_id: StringName
) -> CampaignLocationDefinition:
	if campaign_definition == null:
		return null

	return campaign_definition.get_location(
		location_id
	)


func get_available_locations() -> Array[CampaignLocationDefinition]:
	var result: Array[CampaignLocationDefinition] = []

	if campaign_definition == null:
		return result

	for location in campaign_definition.locations:
		if location == null:
			continue

		result.append(
			location
		)

	return result


func has_pending_battle() -> bool:
	return (
		pending_battle_request != null
		and pending_battle_request
			.encounter_definition != null
	)


func get_pending_battle_encounter() -> BattleEncounterDefinition:
	if pending_battle_request == null:
		return null

	return pending_battle_request.encounter_definition


func start_location(
	location_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		push_warning(
			"Campaign battle request is already active."
		)

		return false

	if (
		campaign_state == null
		or not campaign_state.is_valid_state()
	):
		push_warning(
			"Campaign state is invalid."
		)

		return false

	var location := get_location(
		location_id
	)

	if (
		location == null
		or not location.is_valid_definition()
	):
		push_warning(
			"Cannot start unknown or invalid location: %s."
			% location_id
		)

		return false

	var party_members := (
		campaign_state.get_party_members()
	)

	if party_members.is_empty():
		push_warning(
			"Cannot start location with an empty party."
		)

		return false

	if (
		party_members.size()
		> location.party_spawn_instance_ids.size()
	):
		push_warning(
			"Location does not provide enough "
			+"party spawn slots."
		)

		return false

	var runtime_encounter := (
		location
			.encounter_definition
			.duplicate(true)
		as BattleEncounterDefinition
	)

	if runtime_encounter == null:
		push_warning(
			"Campaign encounter could not be duplicated."
		)

		return false

	var slot_index_by_instance_id: Dictionary = {}

	for slot_index in range(
		location.party_spawn_instance_ids.size()
	):
		slot_index_by_instance_id[
			location.party_spawn_instance_ids[
				slot_index
			]
		] = slot_index

	var rebuilt_spawns: Array[CombatantSpawnDefinition] = []
	var used_party_slots: Dictionary = {}

	for spawn in runtime_encounter.combatant_spawns:
		if spawn == null:
			continue

		if not slot_index_by_instance_id.has(
			spawn.instance_id
		):
			rebuilt_spawns.append(
				spawn
			)

			continue

		var party_index: int = int(
			slot_index_by_instance_id[
				spawn.instance_id
			]
		)

		## Незанятый party placeholder полностью
		## удаляется из runtime encounter.
		if party_index >= party_members.size():
			continue

		var hero_state := party_members[
			party_index
		]

		if (
			hero_state == null
			or not hero_state.is_valid_state()
		):
			push_warning(
				"Campaign party contains "
				+"an invalid hero state."
			)

			return false

		spawn.hero_definition = (
			hero_state.hero_definition
		)

		spawn.hero_progression_state = (
			hero_state.progression_state
		)

		spawn.combatant_definition = (
			hero_state
				.hero_definition
				.base_combatant_definition
		)

		spawn.loadout_override = null
		spawn.team_id = PLAYER_TEAM_ID

		used_party_slots[
			spawn.instance_id
		] = true

		rebuilt_spawns.append(
			spawn
		)

	for party_index in range(
		party_members.size()
	):
		var required_spawn_id := (
			location.party_spawn_instance_ids[
				party_index
			]
		)

		if not used_party_slots.has(
			required_spawn_id
		):
			push_warning(
				"Runtime encounter is missing "
				+"party spawn '%s'."
				% required_spawn_id
			)

			return false

	runtime_encounter.combatant_spawns = (
		rebuilt_spawns
	)

	if not runtime_encounter.is_valid_definition():
		push_warning(
			"Runtime campaign encounter is invalid."
		)

		for validation_error in (
			runtime_encounter.get_validation_errors()
		):
			push_warning(
				validation_error
			)

		return false

	_battle_request_counter += 1

	var request := CampaignBattleRequest.new()

	request.request_id = StringName(
		"campaign_battle_%d"
		% _battle_request_counter
	)

	request.location_id = (
		location.location_id
	)

	for hero_state in party_members:
		request.party_member_hero_ids.append(
			hero_state.get_hero_id()
		)

	for party_index in range(
		party_members.size()
	):
		request.player_spawn_instance_ids.append(
			location.party_spawn_instance_ids[
				party_index
			]
		)

	request.encounter_definition = (
		runtime_encounter
	)

	pending_battle_request = request

	var scene_error := get_tree().change_scene_to_file(
		BATTLE_SCENE_PATH
	)

	if scene_error != OK:
		pending_battle_request = null

		push_error(
			"Failed to change to campaign battle scene."
		)

		return false

	return true


func complete_pending_battle_and_return(
	winning_team_id: StringName
) -> bool:
	if (
		campaign_state == null
		or pending_battle_request == null
	):
		return false

	var result := CampaignBattleResult.new()

	result.request_id = (
		pending_battle_request.request_id
	)

	result.location_id = (
		pending_battle_request.location_id
	)

	result.winning_team_id = (
		winning_team_id
	)

	for hero_id in (
		pending_battle_request
			.party_member_hero_ids
	):
		result.party_member_hero_ids.append(
			hero_id
		)

	if (
		pending_battle_request
			.encounter_definition != null
	):
		result.encounter_id = (
			pending_battle_request
				.encounter_definition
				.encounter_id
		)

	if winning_team_id == PLAYER_TEAM_ID:
		result.outcome = (
			CampaignBattleResult.Outcome.VICTORY
		)

	elif winning_team_id == &"":
		result.outcome = (
			CampaignBattleResult.Outcome.DRAW
		)

	else:
		result.outcome = (
			CampaignBattleResult.Outcome.DEFEAT
		)

	campaign_state.last_battle_result = (
		result
	)

	campaign_state.current_location_id = (
		pending_battle_request.location_id
	)

	campaign_state.completed_battle_count += 1

	pending_battle_request = null

	call_deferred(
		"_change_to_campaign_scene"
	)

	return true


func _change_to_campaign_scene() -> void:
	var scene_error := get_tree().change_scene_to_file(
		CAMPAIGN_SCENE_PATH
	)

	if scene_error != OK:
		push_error(
			"Failed to return to campaign scene."
		)
