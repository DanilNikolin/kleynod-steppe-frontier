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


func get_active_hero_state() -> CampaignHeroState:
	if campaign_state == null:
		return null

	return campaign_state.get_active_hero()


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

	var active_hero := get_active_hero_state()

	if (
		active_hero == null
		or not active_hero.is_valid_state()
	):
		push_warning(
			"Cannot start location without "
			+"a valid active hero."
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

	var player_spawn: CombatantSpawnDefinition

	for spawn in runtime_encounter.combatant_spawns:
		if (
			spawn != null
			and spawn.instance_id
				== location.player_spawn_instance_id
		):
			player_spawn = spawn
			break

	if player_spawn == null:
		push_warning(
			"Campaign encounter has no player spawn '%s'."
			% location.player_spawn_instance_id
		)

		return false

	player_spawn.hero_definition = (
		active_hero.hero_definition
	)

	player_spawn.hero_progression_state = (
		active_hero.progression_state
	)

	player_spawn.combatant_definition = (
		active_hero
			.hero_definition
			.base_combatant_definition
	)

	if not runtime_encounter.is_valid_definition():
		push_warning(
			"Runtime campaign encounter is invalid."
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

	request.active_hero_id = (
		active_hero.get_hero_id()
	)

	request.player_spawn_instance_id = (
		location.player_spawn_instance_id
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