extends SceneTree
var sandbox
var runtime
func _initialize() -> void:
	call_deferred("run")
func capture(label: String) -> void:
	await process_frame
	await process_frame

func show_panel():
	sandbox._show_view(sandbox.View.LOGISTICS)
	return sandbox._shell._content_host.get_child(0)
func run() -> void:
	runtime = root.get_node("CampaignRuntime")
	runtime.start_new_campaign()
	var state = runtime.campaign_state
	runtime.construct_home_settlement_building(&"trade_yard", &"primitive_campfire")
	runtime.advance_time(120)
	state.current_world_node_id = &"debug_home_materials_node"
	assert(runtime.explore_adventure_site(&"debug_home_outskirts_materials_area", &"starter_materials_cache"))
	sandbox = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(sandbox)
	sandbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel = show_panel()
	await capture("cargo-away")
	assert(panel.find_child("UnloadButton", true, false).disabled)
	state.current_world_node_id = &"debug_home"
	panel = show_panel()
	panel._confirm_unload(panel._revision)
	await capture("unload-confirm")
	panel.get_node("LogisticsConfirmation").confirmed.emit()
	await capture("unloaded")
	assert(state.materials == 8 and state.inventory_state.get_carried_materials() == 0)
	runtime.construct_home_settlement_building(&"residential_yard", &"temporary_party_shelter")
	runtime.construct_home_settlement_building(&"household_yard", &"primitive_common_shelter")
	runtime.advance_time(120)
	state.home_settlement_state.get_zone(&"household_yard").building_level = 2
	panel = show_panel()
	await capture("no-supplier")
	state.current_world_node_id = &"debug_village"
	sandbox._show_view(sandbox.View.LOCAL_LOCATION)
	var local = sandbox._shell._immersive_content_host.get_child(0)
	sandbox._on_dialogue_requested(&"debug_village_innkeeper", local)
	await capture("contact")
	sandbox._on_dialogue_choice(&"supply_contact", sandbox._dialogue_session.revision, local)
	await capture("agreed")
	sandbox._on_dialogue_closed(local)
	state.current_world_node_id = &"debug_home"
	state.reputation = -1
	panel = show_panel()
	await capture("rep-locked")
	state.reputation = 0
	panel = show_panel()
	await capture("base-price")
	state.reputation = 20
	panel = show_panel()
	await capture("discount")
	panel._confirm_order(&"village_materials", &"small", 24, panel._revision)
	await capture("order-confirm")
	panel.get_node("LogisticsConfirmation").confirmed.emit()
	await capture("in-transit")
	assert(state.materials == 0 and state.active_deliveries.size() == 1)
	var path = "user://logistics_visual_%d.json" % Time.get_ticks_usec()
	var saves = CampaignSaveService.new(path)
	assert(saves.save_campaign(state).is_successful)
	var loaded = saves.load_campaign(runtime.campaign_definition)
	assert(loaded.is_successful)
	runtime.campaign_state = loaded.campaign_state
	state = runtime.campaign_state
	state.current_world_node_id = &"debug_village"
	assert(runtime.advance_time(1440))
	state.current_world_node_id = &"debug_home"
	panel = show_panel()
	await capture("arrived")
	assert(state.materials == 5 and state.active_deliveries.is_empty())
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("LOGISTICS UI GREEN: pickup inventory, unload confirmation, C2/no supplier, real contact, reputation and prices, order confirmation, timer, active save/load, arrival.")
	quit()
