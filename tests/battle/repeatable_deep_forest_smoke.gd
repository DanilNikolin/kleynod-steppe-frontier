extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func run() -> void:
	seed(42)
	# 1. Check definition & world map
	var location := load("res://content/locations/debug/debug_deep_forest_location.tres") as CampaignLocationDefinition
	check(location != null and location.is_valid_definition(), "debug_deep_forest_location is valid")

	var campaign_def := load("res://content/campaign/debug/debug_campaign_definition.tres") as CampaignDefinition
	check(campaign_def != null, "Campaign definition loaded")
	var has_loc := false
	for loc in campaign_def.locations:
		if loc != null and loc.location_id == &"debug_deep_forest":
			has_loc = true
			break
	check(has_loc, "CampaignDefinition includes debug_deep_forest location")

	var world_map := campaign_def.world_map_definition
	check(world_map != null, "World map definition exists")

	var deep_forest_node: CampaignWorldNodeDefinition = null
	for node in world_map.nodes:
		if node != null and node.node_id == &"debug_deep_forest_node":
			deep_forest_node = node
			break
	check(deep_forest_node != null, "debug_deep_forest_node exists in world map")
	if deep_forest_node != null:
		check(deep_forest_node.node_type == CampaignWorldNodeDefinition.NodeType.ADVENTURE, "Node type is ADVENTURE")
		check(deep_forest_node.campaign_location_id == &"debug_deep_forest", "campaign_location_id is debug_deep_forest")
		check(deep_forest_node.adventure_area_id == &"", "adventure_area_id is empty")

	var route_found := false
	for route in world_map.routes:
		if route != null and ((route.node_a_id == &"debug_home" and route.node_b_id == &"debug_deep_forest_node") or (route.node_b_id == &"debug_home" and route.node_a_id == &"debug_deep_forest_node")):
			route_found = true
			check(route.required_home_settlement_effect_id == &"", "Route has no settlement effect requirement")
			check(route.access_requirement_text == "", "Route has no access requirement text")
			break
	check(route_found, "Route Home -> Deep Forest exists without requirements")

	# 2. Runtime campaign flow and repeatability
	var runtime := root.get_node_or_null("CampaignRuntime") as CampaignRuntimeService
	if runtime == null:
		runtime = CampaignRuntimeService.new()
		runtime.name = "CampaignRuntime"
		root.add_child(runtime)

	check(runtime.start_new_campaign(), "Start new campaign")

	# Move player to deep forest node
	runtime.get_campaign_state().current_world_node_id = &"debug_deep_forest_node"

	# First launch via start_current_world_adventure
	check(runtime.start_current_world_adventure(), "Launch first adventure at deep forest node")
	var req1 := runtime.pending_battle_request
	check(req1 != null, "First pending battle request created")
	check(req1.location_id == &"debug_deep_forest", "Request location_id is debug_deep_forest")
	check(req1.battle_environment_scene != null and req1.battle_environment_scene.resource_path.ends_with("deep_forest_environment.tscn"),
		"Request uses deep_forest_environment.tscn")
	var enc1 := req1.encounter_definition
	check(enc1 != null, "First encounter exists")

	# Fast-forward / complete first battle
	await scene_changed
	var screen1 := current_scene as BattleScreen
	check(screen1 != null, "First battle screen loaded")
	check(screen1.environment != null and screen1.environment.scene_file_path.ends_with("deep_forest_environment.tscn"),
		"First screen uses deep_forest_environment")

	# Win first battle via flow completion / bridge
	screen1.flow.completed.emit(&"team_player")
	for frame in range(200):
		if current_scene != null and current_scene.scene_file_path == runtime.CAMPAIGN_SCENE_PATH:
			break
		await process_frame

	check(not runtime.has_pending_battle(), "Pending battle cleared after first battle")
	check(runtime.get_campaign_state().current_world_node_id == &"debug_deep_forest_node",
		"Current world node remains debug_deep_forest_node after first battle")

	# Verify no AdventureArea progression marked completed
	for area in runtime.get_campaign_state().adventure_areas:
		for site in area.sites:
			check(site.site_id != &"debug_deep_forest", "No adventure area site named debug_deep_forest")

	# 3. Second launch on the same node
	check(runtime.start_current_world_adventure(), "Launch SECOND adventure at deep forest node")
	var req2 := runtime.pending_battle_request
	check(req2 != null, "Second pending battle request created")
	check(req2 != req1, "Second request has new request instance")
	check(req2.request_id != req1.request_id, "Second request has unique request_id")
	var enc2 := req2.encounter_definition
	check(enc2 != enc1, "Second encounter is fresh duplicated object instance")

	await scene_changed
	var screen2 := current_scene as BattleScreen
	check(screen2 != null and screen2 != screen1, "Second battle screen loaded")

	# Verify fresh combatants with initial HP / state
	var enemy_spawns := 0
	for spawn in enc2.combatant_spawns:
		if spawn.team_id == &"team_enemy":
			enemy_spawns += 1
			check(spawn.combatant_definition != null, "Enemy combatant definition exists in second encounter")
	check(enemy_spawns > 0, "Second encounter has living enemy spawns")

	screen2.flow.completed.emit(&"team_player")
	for frame in range(200):
		if current_scene != null and current_scene.scene_file_path == runtime.CAMPAIGN_SCENE_PATH:
			break
		await process_frame

	check(not runtime.has_pending_battle(), "Second pending battle cleared")
	check(runtime.get_campaign_state().current_world_node_id == &"debug_deep_forest_node",
		"Current world node still debug_deep_forest_node")
	check(runtime.campaign_state.completed_battle_count == 2, "Completed battle count is 2")

	print("REPEATABLE DEEP FOREST SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
