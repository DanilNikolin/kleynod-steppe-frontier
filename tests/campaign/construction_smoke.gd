extends SceneTree

var failures: int = 0
var runtime: CampaignRuntimeService


func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func build(id: StringName) -> void:
	for zone in runtime.get_home_settlement_definition().zones:
		var b := zone.get_building(id)
		if b != null:
			check(runtime.construct_home_settlement_building(zone.zone_id, id), "Build " + String(id))
			check(runtime.advance_time(b.construction_minutes), "Advance construction time for " + String(id))
			return
	check(false, "Missing primitive building")


func run() -> void:
	runtime = CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Construction campaign validates")
	if runtime.campaign_state == null:
		runtime.free()
		quit(1)
		return
	var campaign := runtime.campaign_definition
	var state := runtime.campaign_state
	var service := runtime.construction_service
	var project := campaign.get_construction_project(&"forge_shell")
	var source := campaign.get_crew_source(&"village_crew")
	check(not service.worksite_available(campaign, state), "No worksite before resident arrival")
	var local := CampaignLocalLocationPanel.new()
	root.add_child(local)
	local.construction_projects = campaign.construction_projects
	local.bind(runtime.get_current_local_location_definition(), state, runtime.get_home_settlement_definition(), runtime.get_home_settlement_state(), campaign.residents, campaign.quests)
	check(local._canvas._visibility_overrides.get(&"debug_home_carpenter_worksite") == false, "Worksite hidden before arrival")
	local.free()
	build(&"primitive_campfire")
	state.current_world_node_id = &"debug_home_materials_node"
	check(runtime.explore_adventure_site(&"debug_home_outskirts_materials_area", &"starter_materials_cache"), "Starter eight materials")
	check(runtime.explore_adventure_site(&"debug_home_outskirts_materials_area", &"construction_timber"), "Reachable additional timber")
	check(state.materials == 0 and state.inventory_state.get_carried_materials() == 20, "Both supplies are carried cargo")
	state.current_world_node_id = &"debug_home"
	check(runtime.unload_materials().is_empty() and state.materials == 20, "Unload construction supplies")
	build(&"temporary_party_shelter")
	build(&"primitive_common_shelter")
	check(state.materials == 12, "Enough timber remains for forge without debug grants")
	# Earlier quest smoke covers unlocking; this slice starts with that prerequisite.
	var carpenter := state.get_resident(&"debug_carpenter")
	carpenter.recruitment_unlocked = true
	state.current_world_node_id = carpenter.current_world_node_id
	check(runtime.invite_resident(&"debug_carpenter"), "Arrival grants knowledge and only promised agreement")
	state.current_world_node_id = &"debug_home"
	check(service.worksite_available(campaign, state), "Temporary worksite available")
	check(state.construction_knowledge_ids.size() == 3 and state.construction_agreement_ids.size() == 1, "Knowledge differs from agreement")
	check(service.get_project_gate(campaign, state, project).is_empty(), "Forge known and agreed")
	check(service.get_project_gate(campaign, state, campaign.get_construction_project(&"party_kurin")).contains("не согласен"), "B2 locked by agreement")
	check(service.get_project_gate(campaign, state, campaign.get_construction_project(&"common_store")).contains("не согласен"), "C2 locked by agreement")
	check(service.get_project_gate(campaign, state, campaign.get_construction_project(&"river_pier")).contains("знания"), "Pier locked by knowledge")
	check(not runtime.get_home_settlement_upgrade_error(&"residential_yard").is_empty(), "Old B2 shortcut remains locked")
	check(not runtime.get_home_settlement_upgrade_error(&"household_yard").is_empty(), "Old C2 shortcut remains locked")
	check(not runtime.get_home_settlement_construction_error(&"workshop_west", &"blacksmith_workshop").is_empty(), "Old operational forge shortcut closed")
	var gold := state.inventory_state.gold
	check(not runtime.start_construction_project(&"forge_shell").is_empty(), "No workers means no start")
	check(state.inventory_state.gold == gold and state.materials == 12, "Rejected start costs nothing")
	check(not runtime.reserve_construction_crew(&"forge_shell", &"village_crew", 2).is_empty(), "Must visit source settlement")
	var small := service.quote(project, source, 2)
	var large := service.quote(project, source, 4)
	check(int(small.minutes) == 6 * 1440 and int(large.minutes) == 3 * 1440, "Labor determines elapsed time")
	check(int(large.gold) > int(small.gold), "Larger crew is faster and more expensive")
	check(source.get_capacity(0) >= project.minimum_crew, "First crew needs no reputation grind")
	state.current_world_node_id = &"debug_village"
	check(not runtime.reserve_construction_crew(&"forge_shell", &"village_crew", 0).is_empty(), "Zero crew rejected")
	check(not runtime.reserve_construction_crew(&"forge_shell", &"village_crew", 100).is_empty(), "Oversized crew rejected")
	check(runtime.reserve_construction_crew(&"forge_shell", &"village_crew", 2).is_empty(), "Reserve two workers")
	check(runtime.reserve_construction_crew(&"forge_shell", &"village_crew", 3).is_empty(), "Revise reservation without duplicating it")
	check(state.construction_contracts.size() == 1 and state.inventory_state.gold == gold, "Reservation has no payment or duplicate contract")
	var path := "user://construction_smoke_%s.json" % Time.get_ticks_usec()
	var saves := CampaignSaveService.new(path)
	check(saves.save_campaign(state).is_successful, "Save reservation")
	var loaded := saves.load_campaign(campaign)
	check(loaded.is_successful, "Load reservation: " + loaded.message)
	if loaded.is_successful:
		runtime.campaign_state = loaded.campaign_state
		state = runtime.campaign_state
	check(service.get_contract(state, &"forge_shell").crew_size == 3, "Reservation survives load")
	state.current_world_node_id = &"debug_home"
	var materials := state.materials
	state.materials = 0
	check(not runtime.start_construction_project(&"forge_shell").is_empty(), "Materials enforced")
	check(service.get_contract(state, &"forge_shell").status == CampaignConstructionContract.Status.RESERVED and state.inventory_state.gold == gold, "Failed signing preserves reservation and money")
	state.materials = materials
	state.inventory_state.gold = 0
	check(not runtime.start_construction_project(&"forge_shell").is_empty(), "Money enforced")
	state.inventory_state.gold = gold
	var before_time := state.current_day * 1440 + state.current_minute_of_day
	check(runtime.start_construction_project(&"forge_shell").is_empty(), "Sign and pay once")
	var contract := service.get_contract(state, &"forge_shell")
	check(contract.status == CampaignConstructionContract.Status.ACTIVE, "Contract running")
	check(state.current_day * 1440 + state.current_minute_of_day == before_time, "Signing does not skip time")
	check(state.materials == 0 and state.inventory_state.gold == gold - contract.paid_gold, "Single upfront payment")
	var paid_gold := state.inventory_state.gold
	check(not runtime.start_construction_project(&"forge_shell").is_empty(), "Double signing rejected")
	check(state.inventory_state.gold == paid_gold, "Double signing does not charge")
	check(state.home_settlement_state.get_zone(&"workshop_west").is_empty(), "No finished shell on signing")
	check(saves.save_campaign(state).is_successful, "Save active construction")
	loaded = saves.load_campaign(campaign)
	check(loaded.is_successful, "Load active construction: " + loaded.message)
	if loaded.is_successful:
		runtime.campaign_state = loaded.campaign_state
		state = runtime.campaign_state
		contract = service.get_contract(state, &"forge_shell")
	state.current_world_node_id = &"debug_city"
	check(runtime.advance_time(contract.completes_at - before_time - 1), "Construction advances away from HOME")
	check(state.home_settlement_state.get_zone(&"workshop_west").is_empty(), "Not finished a minute early")
	check(runtime.advance_time(1), "Exact deadline completes construction")
	check(contract.status == CampaignConstructionContract.Status.COMPLETED, "Contract completed")
	check(state.home_settlement_state.get_zone(&"workshop_west").building_id == &"forge_shell", "Physical building in existing settlement state")
	check(runtime.settlement_effect_service.has_active_effect(runtime.get_home_settlement_definition(), runtime.get_home_settlement_state(), &"forge_shell_completed"), "Shell effect active")
	check(not runtime.settlement_effect_service.has_active_effect(runtime.get_home_settlement_definition(), runtime.get_home_settlement_state(), &"blacksmith_infrastructure"), "Shell is not an operational forge")
	check(not runtime.is_home_resident_working(&"resident_blacksmith_ostap"), "No blacksmith services from empty shell")
	check(service.available_workers(campaign, state, source) == source.get_capacity(state.reputation), "Crew returns after completion")
	check(saves.save_campaign(state).is_successful, "Save completed shell")
	loaded = saves.load_campaign(campaign)
	check(loaded.is_successful, "Load completed shell: " + loaded.message)
	if loaded.is_successful:
		check(loaded.campaign_state.home_settlement_state.get_zone(&"workshop_west").building_id == &"forge_shell", "Built result survives load")
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	raw["construction_contracts"][0]["paid_gold"] += 1
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(raw))
	file.close()
	check(not saves.load_campaign(campaign).is_successful, "Reject altered paid contract")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	state.current_world_node_id = &"debug_home"
	check(not runtime.start_construction_project(&"forge_shell").is_empty(), "Cannot build completed project twice")
	check(runtime.advance_time(1440), "Later time remains valid")
	check(state.inventory_state.gold == paid_gold, "No repeated billing or shell income")
	# Exercise actual game modal routing, not only a standalone panel.
	var live := root.get_node("CampaignRuntime") as CampaignRuntimeService
	live.campaign_definition = campaign
	live.campaign_state = state
	var sandbox = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(sandbox)
	sandbox._show_view(sandbox.View.LOCAL_LOCATION)
	var local_panel := sandbox._shell._immersive_content_host.get_child(0) as CampaignLocalLocationPanel
	check(local_panel != null, "HOME local panel instantiated")
	if local_panel != null:
		check(local_panel._canvas._visibility_overrides.get(&"debug_home_carpenter_worksite") == true, "Worksite visible after arrival")
		sandbox._on_local_interaction_action_requested(&"debug_home_carpenter_worksite", "ОТКРЫТЬ СТРОИТЕЛЬСТВО", local_panel)
		check(sandbox._shell.has_modal(), "Worksite opens modal")
		check(sandbox._shell._modal_layer.get_child(0) is CampaignConstructionPanel, "Construction uses separate panel, not dialogue")
		sandbox._shell.clear_modal()
	sandbox.free()
	runtime.free()
	if failures == 0:
		print("SMOKE GREEN: knowledge/agreement, source crew, full quote, one-time payment, timed construction, save/load, shell-only result and separate worksite UI.")
	quit(0 if failures == 0 else 1)
