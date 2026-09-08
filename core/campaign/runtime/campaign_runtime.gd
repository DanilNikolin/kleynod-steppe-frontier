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
var hero_experience_service := HeroExperienceService.new()
var loot_reward_application_service := (
	CampaignLootRewardApplicationService.new()
)

var save_service := (
	CampaignSaveService.new()
)

var travel_service := (
	CampaignTravelService.new()
)

var world_route_access_service := (
	CampaignWorldRouteAccessService.new()
)

var calendar_rules := (
	CampaignCalendarRules.new()
)

var time_service := (
	CampaignTimeService.new()
)

var settlement_construction_service := (
	CampaignSettlementConstructionService.new()
)

var settlement_effect_service := (
	CampaignSettlementEffectService.new()
)

var resident_service := (
	CampaignResidentService.new()
)

var settlement_economy_service := (
	CampaignSettlementEconomyService.new()
)

var equipment_commission_service := (
	CampaignEquipmentCommissionService.new()
)

var quest_service := (
	CampaignQuestService.new()
)

var adventure_service := (
	CampaignAdventureService.new()
)

var trading_service := (
	CampaignTradingService.new()
)

var _return_adventure_area_id: StringName = &""

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
	_return_adventure_area_id = &""

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


func get_world_map_definition() -> CampaignWorldMapDefinition:
	if campaign_definition == null:
		return null

	return (
		campaign_definition
			.world_map_definition
	)


func get_home_settlement_definition() -> CampaignSettlementDefinition:
	if campaign_definition == null:
		return null

	return (
		campaign_definition
			.home_settlement_definition
	)


func get_home_settlement_state() -> CampaignSettlementState:
	if campaign_state == null:
		return null

	return (
		campaign_state
			.home_settlement_state
	)


func get_adventure_area_definition(
	area_id: StringName
) -> CampaignAdventureAreaDefinition:
	if campaign_definition == null:
		return null

	return campaign_definition.get_adventure_area(
		area_id
	)


func get_adventure_area_state(
	area_id: StringName
) -> CampaignAdventureAreaState:
	if campaign_state == null:
		return null

	return campaign_state.get_adventure_area(
		area_id
	)


func consume_return_adventure_area_id() -> StringName:
	var result := _return_adventure_area_id

	_return_adventure_area_id = &""

	return result


func get_home_settlement_seasonal_gold_income() -> int:
	return (
		settlement_economy_service
			.get_seasonal_gold_income(
				get_home_settlement_definition(),
				get_home_settlement_state()
			)
	)


func get_home_settlement_uncollected_gold() -> int:
	var state := get_home_settlement_state()

	if state == null:
		return 0

	return state.uncollected_gold


func get_active_home_settlement_effects() -> Array[CampaignSettlementEffectDefinition]:
	return (
		settlement_effect_service
			.get_active_effects(
				get_home_settlement_definition(),
				get_home_settlement_state()
			)
	)


func has_active_home_settlement_effect(
	effect_id: StringName
) -> bool:
	return (
		settlement_effect_service
			.has_active_effect(
				get_home_settlement_definition(),
				get_home_settlement_state(),
				effect_id
			)
	)


func get_resident_definitions() -> Array[CampaignResidentDefinition]:
	if campaign_definition == null:
		return []

	return campaign_definition.residents


func get_resident_definition(
	resident_id: StringName
) -> CampaignResidentDefinition:
	if campaign_definition == null:
		return null

	return campaign_definition.get_resident(
		resident_id
	)


func get_resident_state(
	resident_id: StringName
) -> CampaignResidentState:
	if campaign_state == null:
		return null

	return campaign_state.get_resident(
		resident_id
	)


func get_quest_definitions() -> Array[CampaignQuestDefinition]:
	if campaign_definition == null:
		return []

	return campaign_definition.quests


func get_quest_definition(
	quest_id: StringName
) -> CampaignQuestDefinition:
	if campaign_definition == null:
		return null

	return campaign_definition.get_quest(
		quest_id
	)


func get_quest_state(
	quest_id: StringName
) -> CampaignQuestState:
	if campaign_state == null:
		return null

	return campaign_state.get_quest(
		quest_id
	)


func start_quest(
	quest_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		return false

	var quest_definition := (
		get_quest_definition(
			quest_id
		)
	)

	var quest_state := get_quest_state(
		quest_id
	)

	if (
		quest_definition == null
		or quest_state == null
	):
		return false

	var giver_definition := (
		get_resident_definition(
			quest_definition.giver_resident_id
		)
	)

	var giver_state := (
		get_resident_state(
			quest_definition.giver_resident_id
		)
	)

	var error := quest_service.get_start_error(
		campaign_state,
		quest_definition,
		quest_state,
		giver_definition,
		giver_state,
		get_home_settlement_definition()
	)

	if not error.is_empty():
		push_warning(
			"Quest start failed: %s"
			% error
		)

		return false

	return quest_service.apply_start(
		campaign_state,
		quest_definition,
		quest_state,
		giver_definition,
		giver_state,
		get_home_settlement_definition()
	)


func turn_in_quest(
	quest_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		return false

	var quest_definition := (
		get_quest_definition(
			quest_id
		)
	)

	var quest_state := get_quest_state(
		quest_id
	)

	if (
		quest_definition == null
		or quest_state == null
	):
		return false

	var giver_definition := (
		get_resident_definition(
			quest_definition.giver_resident_id
		)
	)

	var giver_state := (
		get_resident_state(
			quest_definition.giver_resident_id
		)
	)

	var error := quest_service.get_turn_in_error(
		campaign_state,
		quest_definition,
		quest_state,
		giver_definition,
		giver_state,
		get_home_settlement_definition()
	)

	if not error.is_empty():
		push_warning(
			"Quest turn-in failed: %s"
			% error
		)

		return false

	return quest_service.apply_turn_in(
		campaign_state,
		quest_definition,
		quest_state,
		giver_definition,
		giver_state,
		get_home_settlement_definition()
	)


func get_quest_abandon_error(
	quest_id: StringName
) -> String:
	if (
		campaign_definition == null
		or campaign_state == null
	):
		return "Campaign runtime is not ready."

	if has_pending_battle():
		return (
			"Cannot abandon a quest "
			+ "while a battle request is active."
		)

	return quest_service.get_abandon_error(
		campaign_state,
		get_quest_definition(
			quest_id
		),
		get_quest_state(
			quest_id
		)
	)


func can_abandon_quest(
	quest_id: StringName
) -> bool:
	return get_quest_abandon_error(
		quest_id
	).is_empty()


func abandon_quest(
	quest_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	var error := get_quest_abandon_error(
		quest_id
	)

	if not error.is_empty():
		push_warning(
			"Quest abandon failed: %s"
			% error
		)

		return false

	return quest_service.apply_abandon(
		campaign_state,
		get_quest_definition(
			quest_id
		),
		get_quest_state(
			quest_id
		)
	)


func set_resident_recruitment_unlocked(
	resident_id: StringName,
	unlocked: bool
) -> bool:
	var state := get_resident_state(
		resident_id
	)

	if state == null:
		return false

	var previous_value := (
		state.recruitment_unlocked
	)

	state.recruitment_unlocked = unlocked

	if not campaign_state.is_valid_state():
		state.recruitment_unlocked = (
			previous_value
		)

		return false

	return true


func get_resident_recruitment_error(
	resident_id: StringName
) -> String:
	if (
		campaign_state == null
		or campaign_definition == null
	):
		return "Campaign runtime is not ready."

	if has_pending_battle():
		return (
			"Cannot recruit while a battle request is active."
		)

	var definition := get_resident_definition(
		resident_id
	)

	var state := get_resident_state(
		resident_id
	)

	return resident_service.get_recruitment_error(
		campaign_state,
		definition,
		state
	)


func invite_resident(
	resident_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	var error := get_resident_recruitment_error(
		resident_id
	)

	if not error.is_empty():
		push_warning(
			"Resident recruitment failed: %s"
			% error
		)

		return false

	return resident_service.apply_recruitment(
		campaign_state,
		get_resident_definition(
			resident_id
		),
		get_resident_state(
			resident_id
		)
	)


func is_home_resident_working(
	resident_id: StringName
) -> bool:
	return resident_service.is_workplace_ready(
		get_resident_definition(
			resident_id
		),
		get_resident_state(
			resident_id
		),
		get_home_settlement_definition(),
		get_home_settlement_state()
	)


func get_home_resident_commission_error(
	resident_id: StringName,
	commission_id: StringName
) -> String:
	if (
		campaign_definition == null
		or campaign_state == null
	):
		return "Campaign runtime is not ready."

	if has_pending_battle():
		return (
			"Cannot use resident services "
			+"while a battle request is active."
		)

	return (
		equipment_commission_service
			.get_commission_error(
				campaign_state,
				get_resident_definition(
					resident_id
				),
				get_resident_state(
					resident_id
				),
				get_home_settlement_definition(),
				get_home_settlement_state(),
				commission_id
			)
	)


func can_use_home_resident_commission(
	resident_id: StringName,
	commission_id: StringName
) -> bool:
	return (
		get_home_resident_commission_error(
			resident_id,
			commission_id
		)
		.is_empty()
	)


func commission_home_resident_item(
	resident_id: StringName,
	commission_id: StringName
) -> HeroEquipmentItemInstance:
	if not ensure_campaign_started():
		return null

	var commission_error := (
		get_home_resident_commission_error(
			resident_id,
			commission_id
		)
	)

	if not commission_error.is_empty():
		push_warning(
			"Resident commission failed: %s"
			% commission_error
		)

		return null

	var resident_definition := (
		get_resident_definition(
			resident_id
		)
	)

	var resident_state := (
		get_resident_state(
			resident_id
		)
	)

	if (
		resident_definition == null
		or resident_state == null
	):
		return null

	var commission := (
		resident_definition
			.get_equipment_commission(
				commission_id
			)
	)

	if commission == null:
		return null

	var inventory := (
		campaign_state.inventory_state
	)

	if inventory == null:
		return null

	var previous_gold := inventory.gold

	var previous_materials := (
		campaign_state.materials
	)

	var previous_serial := (
		inventory.next_generated_item_serial
	)

	var previous_day := (
		campaign_state.current_day
	)

	var previous_minute := (
		campaign_state.current_minute_of_day
	)

	var previous_uncollected_gold := (
		get_home_settlement_state()
			.uncollected_gold
	)

	var created_item := (
		equipment_commission_service
			.apply_commission(
				campaign_state,
				resident_definition,
				resident_state,
				get_home_settlement_definition(),
				get_home_settlement_state(),
				commission_id
			)
	)

	if created_item == null:
		push_warning(
			"Resident commission could not be applied."
		)

		return null

	if not advance_time(
		commission.duration_minutes
	):
		inventory.items.erase(
			created_item
		)

		inventory.gold = previous_gold

		campaign_state.materials = (
			previous_materials
		)

		inventory.next_generated_item_serial = (
			previous_serial
		)

		campaign_state.current_day = (
			previous_day
		)

		campaign_state.current_minute_of_day = (
			previous_minute
		)

		get_home_settlement_state().uncollected_gold = (
			previous_uncollected_gold
		)

		push_warning(
			"Resident commission time could not be applied."
		)

		return null

	if not campaign_state.is_valid_state():
		inventory.items.erase(
			created_item
		)

		inventory.gold = previous_gold

		campaign_state.materials = (
			previous_materials
		)

		inventory.next_generated_item_serial = (
			previous_serial
		)

		campaign_state.current_day = (
			previous_day
		)

		campaign_state.current_minute_of_day = (
			previous_minute
		)

		get_home_settlement_state().uncollected_gold = (
			previous_uncollected_gold
		)

		push_error(
			"Resident commission produced "
			+"an invalid campaign state."
		)

		return null

	return created_item


func get_home_settlement_construction_error(
	zone_id: StringName,
	building_id: StringName
) -> String:
	if (
		campaign_definition == null
		or campaign_state == null
	):
		return "Campaign runtime is not ready."

	if has_pending_battle():
		return (
			"Cannot construct while a battle request is active."
		)

	var settlement_definition := (
		get_home_settlement_definition()
	)

	if settlement_definition == null:
		return "Home settlement definition is missing."

	if (
		campaign_state.current_world_node_id
		!= settlement_definition.world_node_id
	):
		return (
			"Campaign party is not at the home settlement."
		)

	return (
		settlement_construction_service
			.get_construction_error(
				campaign_state,
				settlement_definition,
				zone_id,
				building_id
			)
	)


func can_construct_home_settlement_building(
	zone_id: StringName,
	building_id: StringName
) -> bool:
	return get_home_settlement_construction_error(
		zone_id,
		building_id
	).is_empty()


func construct_home_settlement_building(
	zone_id: StringName,
	building_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	var construction_error := (
		get_home_settlement_construction_error(
			zone_id,
			building_id
		)
	)

	if not construction_error.is_empty():
		push_warning(
			"Settlement construction failed: %s"
			% construction_error
		)

		return false

	var settlement_definition := (
		get_home_settlement_definition()
	)

	var settlement_state := (
		get_home_settlement_state()
	)

	if (
		settlement_definition == null
		or settlement_state == null
	):
		return false

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
		building_id
	)

	if building == null:
		return false

	var previous_gold := (
		campaign_state.inventory_state.gold
	)

	var previous_materials := (
		campaign_state.materials
	)

	var previous_day := (
		campaign_state.current_day
	)

	var previous_minute := (
		campaign_state.current_minute_of_day
	)

	var previous_uncollected_gold := (
		settlement_state.uncollected_gold
	)

	var previous_building_id := (
		zone_state.building_id
	)

	var previous_building_level := (
		zone_state.building_level
	)

	## Пока идёт строительство,
	## участок всё ещё считается в старом состоянии.
	if not advance_time(
		building.construction_minutes
	):
		push_warning(
			"Settlement construction time could not be applied."
		)

		return false

	if not settlement_construction_service.apply_construction(
		campaign_state,
		settlement_definition,
		zone_id,
		building_id
	):
		campaign_state.inventory_state.gold = (
			previous_gold
		)

		campaign_state.materials = (
			previous_materials
		)

		campaign_state.current_day = (
			previous_day
		)

		campaign_state.current_minute_of_day = (
			previous_minute
		)

		settlement_state.uncollected_gold = (
			previous_uncollected_gold
		)

		zone_state.building_id = (
			previous_building_id
		)

		zone_state.building_level = (
			previous_building_level
		)

		push_warning(
			"Settlement construction could not be applied."
		)

		return false

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

		campaign_state.current_day = (
			previous_day
		)

		campaign_state.current_minute_of_day = (
			previous_minute
		)

		settlement_state.uncollected_gold = (
			previous_uncollected_gold
		)

		zone_state.building_id = (
			previous_building_id
		)

		zone_state.building_level = (
			previous_building_level
		)

		push_error(
			"Settlement construction produced "
			+"an invalid campaign state."
		)

		return false

	return true


func get_home_settlement_demolition_error(
	zone_id: StringName
) -> String:
	if (
		campaign_definition == null
		or campaign_state == null
	):
		return "Campaign runtime is not ready."

	if has_pending_battle():
		return (
			"Cannot demolish while a battle request is active."
		)

	var settlement_definition := (
		get_home_settlement_definition()
	)

	if settlement_definition == null:
		return "Home settlement definition is missing."

	if (
		campaign_state.current_world_node_id
		!= settlement_definition.world_node_id
	):
		return (
			"Campaign party is not at the home settlement."
		)

	return (
		settlement_construction_service
			.get_demolition_error(
				campaign_state,
				settlement_definition,
				zone_id
			)
	)


func can_demolish_home_settlement_building(
	zone_id: StringName
) -> bool:
	return get_home_settlement_demolition_error(
		zone_id
	).is_empty()


func demolish_home_settlement_building(
	zone_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	var demolition_error := (
		get_home_settlement_demolition_error(
			zone_id
		)
	)

	if not demolition_error.is_empty():
		push_warning(
			"Settlement demolition failed: %s"
			% demolition_error
		)

		return false

	var settlement_definition := (
		get_home_settlement_definition()
	)

	if settlement_definition == null:
		return false

	if not settlement_construction_service.apply_demolition(
		campaign_state,
		settlement_definition,
		zone_id
	):
		push_warning(
			"Settlement demolition could not be applied."
		)

		return false

	return true


func get_home_settlement_upgrade_error(
	zone_id: StringName
) -> String:
	if (
		campaign_definition == null
		or campaign_state == null
	):
		return "Campaign runtime is not ready."

	if has_pending_battle():
		return (
			"Cannot upgrade while a battle request is active."
		)

	var settlement_definition := (
		get_home_settlement_definition()
	)

	if settlement_definition == null:
		return (
			"Home settlement definition is missing."
		)

	if (
		campaign_state.current_world_node_id
		!= settlement_definition.world_node_id
	):
		return (
			"Campaign party is not at the home settlement."
		)

	return (
		settlement_construction_service
			.get_upgrade_error(
				campaign_state,
				settlement_definition,
				zone_id
			)
	)


func can_upgrade_home_settlement_building(
	zone_id: StringName
) -> bool:
	return (
		get_home_settlement_upgrade_error(
			zone_id
		)
		.is_empty()
	)


func upgrade_home_settlement_building(
	zone_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	var upgrade_error := (
		get_home_settlement_upgrade_error(
			zone_id
		)
	)

	if not upgrade_error.is_empty():
		push_warning(
			"Settlement upgrade failed: %s"
			% upgrade_error
		)

		return false

	var settlement_definition := (
		get_home_settlement_definition()
	)

	var settlement_state := (
		get_home_settlement_state()
	)

	if (
		settlement_definition == null
		or settlement_state == null
	):
		return false

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

	var previous_day := (
		campaign_state.current_day
	)

	var previous_minute := (
		campaign_state.current_minute_of_day
	)

	var previous_uncollected_gold := (
		settlement_state.uncollected_gold
	)

	## Пока идёт улучшение, действует старый уровень.
	if not advance_time(
		upgrade.duration_minutes
	):
		push_warning(
			"Settlement upgrade time could not be applied."
		)

		return false

	if not settlement_construction_service.apply_upgrade(
		campaign_state,
		settlement_definition,
		zone_id
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

		campaign_state.current_day = (
			previous_day
		)

		campaign_state.current_minute_of_day = (
			previous_minute
		)

		settlement_state.uncollected_gold = (
			previous_uncollected_gold
		)

		push_warning(
			"Settlement upgrade could not be applied."
		)

		return false

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

		campaign_state.current_day = (
			previous_day
		)

		campaign_state.current_minute_of_day = (
			previous_minute
		)

		settlement_state.uncollected_gold = (
			previous_uncollected_gold
		)

		push_error(
			"Settlement upgrade produced "
			+"an invalid campaign state."
		)

		return false

	return true
	
func get_current_world_node() -> CampaignWorldNodeDefinition:
	if campaign_state == null:
		return null

	var world_map := get_world_map_definition()

	if world_map == null:
		return null

	return world_map.get_node(
		campaign_state.current_world_node_id
	)


func get_current_local_location_definition() -> CampaignLocalLocationDefinition:
	var current_node := get_current_world_node()

	if current_node == null:
		return null

	return (
		current_node
			.local_location_definition
	)


func get_world_node(
	node_id: StringName
) -> CampaignWorldNodeDefinition:
	var world_map := get_world_map_definition()

	if world_map == null:
		return null

	return world_map.get_node(
		node_id
	)


func get_connected_world_nodes() -> Array[CampaignWorldNodeDefinition]:
	var result: Array[CampaignWorldNodeDefinition] = []

	if campaign_state == null:
		return result

	var world_map := get_world_map_definition()

	if world_map == null:
		return result

	for route in world_map.routes:
		if route == null:
			continue

		var other_node_id := route.get_other_node_id(
			campaign_state.current_world_node_id
		)

		if other_node_id == &"":
			continue

		if not is_world_route_available(
			route
		):
			continue

		var node := world_map.get_node(
			other_node_id
		)

		if node == null:
			continue

		result.append(
			node
		)

	return result


func is_world_route_available(
	route: CampaignWorldRouteDefinition
) -> bool:
	return (
		world_route_access_service
			.is_route_available(
				route,
				get_home_settlement_definition(),
				get_home_settlement_state()
			)
	)


func get_travel_days_to(
	destination_node_id: StringName
) -> int:
	if campaign_state == null:
		return (
			CampaignTravelService
				.INVALID_TRAVEL_DAYS
		)

	var world_map := get_world_map_definition()

	if world_map == null:
		return (
			CampaignTravelService
				.INVALID_TRAVEL_DAYS
		)

	var route := world_map.get_route_between(
		campaign_state.current_world_node_id,
		destination_node_id
	)

	if (
		route == null
		or not is_world_route_available(
			route
		)
	):
		return (
			CampaignTravelService
				.INVALID_TRAVEL_DAYS
		)

	return travel_service.get_travel_days(
		world_map,
		campaign_state.current_world_node_id,
		destination_node_id
	)


func travel_to_world_node(
	destination_node_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		push_warning(
			"Cannot travel while a battle request is active."
		)

		return false

	if (
		campaign_state == null
		or not campaign_state.is_valid_state()
	):
		push_warning(
			"Cannot travel with an invalid campaign state."
		)

		return false

	if destination_node_id == &"":
		push_warning(
			"Cannot travel to an empty world node ID."
		)

		return false

	if (
		destination_node_id
		== campaign_state.current_world_node_id
	):
		push_warning(
			"Campaign party is already at world node '%s'."
			% destination_node_id
		)

		return false

	var world_map := get_world_map_definition()

	if (
		world_map == null
		or not world_map.is_valid_definition()
	):
		push_warning(
			"Campaign world map is missing or invalid."
		)

		return false

	var destination := world_map.get_node(
		destination_node_id
	)

	if destination == null:
		push_warning(
			"Unknown world destination '%s'."
			% destination_node_id
		)

		return false

	var route := world_map.get_route_between(
		campaign_state.current_world_node_id,
		destination_node_id
	)

	if route == null:
		push_warning(
			"No direct route from '%s' to '%s'."
			% [
				campaign_state.current_world_node_id,
				destination_node_id,
			]
		)

		return false

	var route_access_error := (
		world_route_access_service
			.get_route_access_error(
				route,
				get_home_settlement_definition(),
				get_home_settlement_state()
			)
	)

	if not route_access_error.is_empty():
		push_warning(
			"World route is locked: %s"
			% route_access_error
		)

		return false

	var travel_days := (
		travel_service.get_travel_days(
			world_map,
			campaign_state.current_world_node_id,
			destination_node_id
		)
	)

	if travel_days <= 0:
		push_warning(
			"No valid route from '%s' to '%s'."
			% [
				campaign_state.current_world_node_id,
				destination_node_id,
			]
		)

		return false

	var previous_node_id := (
		campaign_state.current_world_node_id
	)

	campaign_state.current_world_node_id = (
		destination.node_id
	)

	var travel_minutes := (
		travel_days
		* CampaignTimeService.MINUTES_PER_DAY
	)

	if not advance_time(
		travel_minutes
	):
		campaign_state.current_world_node_id = (
			previous_node_id
		)

		push_warning(
			"Campaign travel time could not be applied."
		)

		return false

	if not campaign_state.is_valid_state():
		campaign_state.current_world_node_id = (
			previous_node_id
		)

		push_error(
			"World travel produced "
			+"an invalid campaign state."
		)

		return false

	return true

func get_current_season() -> int:
	if (
		campaign_state == null
		or campaign_definition == null
	):
		return (
			CampaignCalendarRules
				.Season
				.SPRING
		)

	return calendar_rules.get_season(
		campaign_state.current_day,
		campaign_definition.days_per_season
	)


func get_current_year_number() -> int:
	if (
		campaign_state == null
		or campaign_definition == null
	):
		return 1

	return calendar_rules.get_year_number(
		campaign_state.current_day,
		campaign_definition.days_per_season
	)


func get_current_day_in_season() -> int:
	if (
		campaign_state == null
		or campaign_definition == null
	):
		return 1

	return calendar_rules.get_day_in_season(
		campaign_state.current_day,
		campaign_definition.days_per_season
	)


func get_current_day_in_year() -> int:
	if (
		campaign_state == null
		or campaign_definition == null
	):
		return 1

	return calendar_rules.get_day_in_year(
		campaign_state.current_day,
		campaign_definition.days_per_season
	)


func get_current_absolute_day_number() -> int:
	if campaign_state == null:
		return 1

	return calendar_rules.get_absolute_day_number(
		campaign_state.current_day
	)


func get_days_per_season() -> int:
	if campaign_definition == null:
		return 1

	return maxi(
		campaign_definition.days_per_season,
		1
	)


func advance_time(
	minutes: int
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		push_warning(
			"Cannot advance campaign time "
			+ "while a battle request is active."
		)

		return false

	if (
		campaign_state == null
		or not campaign_state.is_valid_state()
	):
		push_warning(
			"Cannot advance time with "
			+ "an invalid campaign state."
		)

		return false

	if minutes < 0:
		push_warning(
			"Campaign time cannot move backwards."
		)

		return false

	var settlement_definition := (
		get_home_settlement_definition()
	)

	var settlement_state := (
		get_home_settlement_state()
	)

	var inventory := (
		campaign_state.inventory_state
	)

	if (
		settlement_definition == null
		or settlement_state == null
		or inventory == null
	):
		return false

	var previous_day := (
		campaign_state.current_day
	)

	var previous_minute := (
		campaign_state.current_minute_of_day
	)

	var previous_uncollected_gold := (
		settlement_state.uncollected_gold
	)

	var previous_inventory_gold := (
		inventory.gold
	)

	if not time_service.advance_minutes(
		campaign_state,
		minutes
	):
		push_warning(
			"Campaign time could not be advanced."
		)

		return false

	if not settlement_economy_service.accrue_crossed_seasons(
		settlement_definition,
		settlement_state,
		previous_day,
		campaign_state.current_day,
		get_days_per_season()
	):
		_restore_time_economy_snapshot(
			previous_day,
			previous_minute,
			previous_uncollected_gold,
			previous_inventory_gold
		)

		push_warning(
			"Settlement passive income could not be accrued."
		)

		return false

	## Если партия сейчас HOME,
	## произведённый ранее доход автоматически
	## переходит в общий inventory.
	if (
		campaign_state.current_world_node_id
		== settlement_definition.world_node_id
	):
		if not (
			settlement_economy_service
				.collect_uncollected_gold(
					settlement_state,
					inventory
				)
		):
			_restore_time_economy_snapshot(
				previous_day,
				previous_minute,
				previous_uncollected_gold,
				previous_inventory_gold
			)

			push_warning(
				"Settlement passive income could not be collected."
			)

			return false

	if not campaign_state.is_valid_state():
		_restore_time_economy_snapshot(
			previous_day,
			previous_minute,
			previous_uncollected_gold,
			previous_inventory_gold
		)

		return false

	return true


func _restore_time_economy_snapshot(
	previous_day: int,
	previous_minute: int,
	previous_uncollected_gold: int,
	previous_inventory_gold: int
) -> void:
	if campaign_state == null:
		return

	campaign_state.current_day = (
		previous_day
	)

	campaign_state.current_minute_of_day = (
		previous_minute
	)

	var settlement_state := (
		get_home_settlement_state()
	)

	if settlement_state != null:
		settlement_state.uncollected_gold = (
			previous_uncollected_gold
		)

	if campaign_state.inventory_state != null:
		campaign_state.inventory_state.gold = (
			previous_inventory_gold
		)


func get_current_hour() -> int:
	return time_service.get_hour(
		campaign_state
	)


func get_current_minute() -> int:
	return time_service.get_minute(
		campaign_state
	)


func get_current_time_text() -> String:
	return time_service.get_time_text(
		campaign_state
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


func get_pending_battle_party_size() -> int:
	if pending_battle_request == null:
		return 0

	return (
		pending_battle_request
			.party_member_hero_ids
			.size()
	)


func get_loot_catalog() -> Array[HeroEquipmentItemDefinition]:
	var result: Array[HeroEquipmentItemDefinition] = []

	if campaign_definition == null:
		return result

	for definition in (
		campaign_definition.loot_catalog
	):
		if definition == null:
			continue

		result.append(
			definition
		)

	return result


func save_campaign() -> CampaignSaveResult:
	if (
		campaign_definition == null
		or not campaign_definition.is_valid_definition()
		or campaign_state == null
		or campaign_state.campaign_id
			!= campaign_definition.campaign_id
	):
		return _create_save_failure(
			CampaignSaveService.STATUS_SAVE_ERROR,
			"Campaign runtime is not ready for saving."
		)

	if has_pending_battle():
		return _create_save_failure(
			CampaignSaveService.STATUS_SAVE_ERROR,
			"Mid-battle save is not supported."
		)

	return save_service.save_campaign(
		campaign_state
	)


func load_campaign() -> CampaignSaveResult:
	if (
		campaign_definition == null
		or not campaign_definition.is_valid_definition()
	):
		return _create_save_failure(
			CampaignSaveService.STATUS_LOAD_ERROR,
			"Campaign definition is not ready for loading."
		)

	if has_pending_battle():
		return _create_save_failure(
			CampaignSaveService.STATUS_LOAD_ERROR,
			"Mid-battle load is not supported."
		)

	var result := (
		save_service.load_campaign(
			campaign_definition
		)
	)

	if not result.is_successful:
		return result

	## Транзакционный swap:
	## CampaignSaveService уже полностью построил
	## и провалидировал отдельный CampaignState.
	campaign_state = result.campaign_state

	pending_battle_request = null
	_return_adventure_area_id = &""

	## Battle request ID — transient data,
	## но после reload лучше продолжать счётчик,
	## а не снова начинать с campaign_battle_1.
	_battle_request_counter = maxi(
		campaign_state.completed_battle_count,
		0
	)

	return result


func start_adventure_site(
	area_id: StringName,
	site_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		return false

	var current_node := (
		get_current_world_node()
	)

	if (
		current_node == null
		or current_node.adventure_area_id
			!= area_id
	):
		push_warning(
			"Campaign party is not inside adventure area '%s'."
				% area_id
		)

		return false

	var area_definition := (
		get_adventure_area_definition(
			area_id
		)
	)

	var area_state := (
		get_adventure_area_state(
			area_id
		)
	)

	var error := (
		adventure_service
			.get_battle_site_error(
				area_definition,
				area_state,
				site_id
			)
	)

	if not error.is_empty():
		push_warning(
			"Adventure site could not start: %s"
				% error
		)

		return false

	var site_definition := (
		area_definition.get_site(
			site_id
		)
	)

	if site_definition == null:
		return false

	if not start_location(
		site_definition.campaign_location_id
	):
		return false

	if pending_battle_request == null:
		return false

	pending_battle_request.adventure_area_id = (
		area_id
	)

	pending_battle_request.adventure_site_id = (
		site_id
	)

	return true


func start_current_world_adventure() -> bool:
	if not ensure_campaign_started():
		return false

	if campaign_state == null:
		return false

	var current_node := (
		get_current_world_node()
	)

	if current_node == null:
		push_warning(
			"Current world node does not exist."
		)

		return false

	if current_node.adventure_area_id != &"":
		push_warning(
			"Current world node uses an Adventure Area."
		)

		return false

	if (
		current_node.node_type
		!= CampaignWorldNodeDefinition
			.NodeType
			.ADVENTURE
	):
		push_warning(
			"Current world node is not an adventure node."
		)

		return false

	if current_node.campaign_location_id == &"":
		push_warning(
			"Current adventure node has no campaign location."
		)

		return false

	return start_location(
		current_node.campaign_location_id
	)


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
	winning_team_id: StringName,
	defeated_enemy_experience_pool: int = 0,
	loot_reward_roll: BattleLootRewardRoll = null
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

	var loot_applied := (
		loot_reward_application_service
			.apply_reward(
				result,
				loot_reward_roll,
				campaign_state.inventory_state,
				result.outcome
					== CampaignBattleResult
						.Outcome
						.VICTORY
			)
	)

	if not loot_applied:
		push_error(
			"Campaign loot reward could not be applied."
		)

		return false

	_apply_experience_reward(
		result,
		maxi(
			defeated_enemy_experience_pool,
			0
		)
	)

	campaign_state.last_battle_result = (
		result
	)

	campaign_state.current_location_id = (
		pending_battle_request.location_id
	)

	campaign_state.completed_battle_count += 1

	if (
		pending_battle_request.adventure_area_id
			!= &""
		and pending_battle_request.adventure_site_id
			!= &""
	):
		var area_id := (
			pending_battle_request
				.adventure_area_id
		)

		var site_id := (
			pending_battle_request
				.adventure_site_id
		)

		var adventure_progress_applied := (
			adventure_service
				.apply_battle_result(
					get_adventure_area_definition(
						area_id
					),
					get_adventure_area_state(
						area_id
					),
					site_id,
					result
				)
		)

		if not adventure_progress_applied:
			push_error(
				"Battle completed, but adventure "
				+"site progress could not be applied."
			)

		_return_adventure_area_id = (
			area_id
		)

	var quest_progress_applied := (
		quest_service.apply_battle_result(
			campaign_definition.quests,
			campaign_state,
			result
		)
	)

	if not quest_progress_applied:
		push_error(
			"Battle completed, but quest progress "
			+ "could not be applied."
		)

	pending_battle_request = null

	call_deferred(
		"_change_to_campaign_scene"
	)

	return true


func get_trader_definitions() -> Array[CampaignTraderDefinition]:
	if campaign_definition == null:
		return []

	return campaign_definition.traders


func get_trader_definition(
	trader_id: StringName
) -> CampaignTraderDefinition:
	if campaign_definition == null:
		return null

	return campaign_definition.get_trader(
		trader_id
	)


func get_trader_state(
	trader_id: StringName
) -> CampaignTraderState:
	if campaign_state == null:
		return null

	return campaign_state.get_trader(
		trader_id
	)


func get_trader_for_interaction(
	interaction_id: StringName
) -> CampaignTraderDefinition:
	if (
		campaign_definition == null
		or campaign_state == null
	):
		return null

	return (
		campaign_definition
			.get_trader_for_interaction(
				campaign_state.current_world_node_id,
				interaction_id
			)
	)


func get_trader_buy_price(
	trader_id: StringName,
	item_instance_id: StringName
) -> int:
	var definition := get_trader_definition(
		trader_id
	)

	var state := get_trader_state(
		trader_id
	)

	if (
		definition == null
		or state == null
	):
		return 0

	var item := state.get_item(
		item_instance_id
	)

	if item == null:
		return 0

	return trading_service.get_buy_price(
		definition,
		item.definition
	)


func get_trader_sell_price(
	trader_id: StringName,
	item_instance_id: StringName
) -> int:
	var definition := get_trader_definition(
		trader_id
	)

	if (
		definition == null
		or campaign_state == null
		or campaign_state.inventory_state == null
	):
		return 0

	var item := (
		campaign_state
			.inventory_state
			.get_item(
				item_instance_id
			)
	)

	if item == null:
		return 0

	return trading_service.get_sell_price(
		definition,
		item.definition
	)


func buy_from_trader(
	trader_id: StringName,
	item_instance_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		return false

	var definition := get_trader_definition(
		trader_id
	)

	var state := get_trader_state(
		trader_id
	)

	var error := trading_service.get_buy_error(
		campaign_state,
		definition,
		state,
		item_instance_id
	)

	if not error.is_empty():
		push_warning(
			"Trader purchase failed: %s"
			% error
		)

		return false

	return trading_service.apply_buy(
		campaign_state,
		definition,
		state,
		item_instance_id
	)


func sell_to_trader(
	trader_id: StringName,
	item_instance_id: StringName
) -> bool:
	if not ensure_campaign_started():
		return false

	if has_pending_battle():
		return false

	var definition := get_trader_definition(
		trader_id
	)

	var state := get_trader_state(
		trader_id
	)

	var error := trading_service.get_sell_error(
		campaign_state,
		definition,
		state,
		item_instance_id
	)

	if not error.is_empty():
		push_warning(
			"Trader sale failed: %s"
			% error
		)

		return false

	return trading_service.apply_sell(
		campaign_state,
		definition,
		state,
		item_instance_id
	)


func _apply_experience_reward(
	result: CampaignBattleResult,
	total_experience: int
) -> void:
	if result == null:
		return

	result.defeated_enemy_experience_pool = maxi(
		total_experience,
		0
	)

	var party_size := (
		result.party_member_hero_ids.size()
	)

	if (
		party_size <= 0
		or result.defeated_enemy_experience_pool <= 0
	):
		return

	result.experience_per_party_member = floori(
		float(result.defeated_enemy_experience_pool)
		/ float(party_size)
	)

	result.undistributed_experience = (
		result.defeated_enemy_experience_pool
		% party_size
	)

	if result.experience_per_party_member <= 0:
		return

	for hero_id in result.party_member_hero_ids:
		var hero_state := campaign_state.get_hero(
			hero_id
		)

		if (
			hero_state == null
			or hero_state.progression_state == null
		):
			continue

		var gained_levels := (
			hero_experience_service.grant_experience(
				hero_state.progression_state,
				result.experience_per_party_member
			)
		)

		if gained_levels <= 0:
			continue

		result.level_ups_by_hero_id[
			hero_id
		] = gained_levels


func _create_save_failure(
	status_code: StringName,
	message: String
) -> CampaignSaveResult:
	var result := CampaignSaveResult.new()

	result.is_successful = false
	result.status_code = status_code
	result.message = message

	return result
	
func _change_to_campaign_scene() -> void:
	var scene_error := get_tree().change_scene_to_file(
		CAMPAIGN_SCENE_PATH
	)

	if scene_error != OK:
		push_error(
			"Failed to return to campaign scene."
		)
