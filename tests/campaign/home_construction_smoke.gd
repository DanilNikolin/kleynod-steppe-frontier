extends SceneTree


var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
	else:
		print("OK: ", message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var runtime := CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Start campaign")
	var campaign := runtime.campaign_definition
	var state := runtime.campaign_state
	var settlement := campaign.home_settlement_definition
	var zone_def := settlement.get_zone(&"residential_yard")
	var building_def := zone_def.get_building(&"temporary_party_shelter")
	check(building_def != null, "Found temporary_party_shelter definition")

	# Required prerequisite: primitive_campfire unlocks primitive_camp_established
	check(runtime.construct_home_settlement_building(&"trade_yard", &"primitive_campfire"), "Build campfire prerequisite")
	check(runtime.advance_time(120), "Campfire finishes")

	state.materials = 10
	var initial_gold := state.inventory_state.gold
	var initial_materials := state.materials
	var before_day := state.current_day
	var before_minute := state.current_minute_of_day
	var before_time := before_day * 1440 + before_minute

	# Step 1: Start construction
	check(runtime.construct_home_settlement_building(&"residential_yard", &"temporary_party_shelter"), "Start party shelter construction")

	# Check A: current campaign time == before_time
	var current_time := state.current_day * 1440 + state.current_minute_of_day
	check(current_time == before_time, "Campaign time did not advance on build start")

	# Check B: Gold / Materials deducted immediately
	check(state.inventory_state.gold == initial_gold - building_def.construction_gold_cost, "Gold deducted immediately")
	check(state.materials == initial_materials - building_def.construction_material_cost, "Materials deducted immediately")

	# Check C & D: zone.building_id still empty, has_pending_construction is true
	var zone_state := state.home_settlement_state.get_zone(&"residential_yard")
	check(zone_state.building_id == &"", "Building id is still empty while constructing")
	check(zone_state.building_level == 0, "Building level is still 0 while constructing")
	check(zone_state.has_pending_construction(), "Zone has pending construction")

	# Check E & F: pending_started_at and pending_completes_at
	check(zone_state.pending_started_at == before_time, "pending_started_at matches before_time")
	check(zone_state.pending_completes_at == before_time + building_def.construction_minutes, "pending_completes_at matches deadline")

	# Check: Cannot start second construction on same zone
	check(not runtime.can_construct_home_settlement_building(&"residential_yard", &"temporary_party_shelter"), "Cannot start second construction while pending")

	# Step 2: Visual check in LOCAL_LOCATION panel before completion (CONSTRUCTING state)
	var live := root.get_node("CampaignRuntime") as CampaignRuntimeService
	live.campaign_definition = campaign
	live.campaign_state = state
	var sandbox = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(sandbox)
	sandbox._show_view(sandbox.View.LOCAL_LOCATION)
	var panel := sandbox._shell._immersive_content_host.get_child(0) as CampaignLocalLocationPanel
	check(panel != null, "Local location panel created")

	var party_shelter_anchor := panel._canvas._anchors_by_interaction_id.get(&"home_zone_party_shelter") as LocalBuildSiteView
	check(party_shelter_anchor != null, "Found party shelter anchor")
	var construction_visual := party_shelter_anchor.get_node_or_null("ConstructionVisual") as CanvasItem
	var built_visual := party_shelter_anchor.get_node_or_null("BuiltVisual") as CanvasItem
	check(construction_visual != null and construction_visual.visible == true, "ConstructionVisual is visible during construction")
	check(built_visual != null and built_visual.visible == false, "BuiltVisual is hidden during construction")

	# Step 3: Advance time partially (construction_minutes - 1)
	var partial_minutes := building_def.construction_minutes - 1
	check(runtime.advance_time(partial_minutes), "Advance time partially")
	check(zone_state.building_id == &"", "Zone still empty before deadline")
	check(zone_state.has_pending_construction(), "Pending construction still active before deadline")

	# Step 4: Save and load in the middle of construction
	var path := "user://home_construction_async_smoke_%d.json" % Time.get_ticks_usec()
	var saves := CampaignSaveService.new(path)
	check(saves.save_campaign(state).is_successful, "Save campaign mid-construction")

	var loaded := saves.load_campaign(campaign)
	check(loaded.is_successful, "Load campaign mid-construction: " + loaded.message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var loaded_state := loaded.campaign_state
	var loaded_zone := loaded_state.home_settlement_state.get_zone(&"residential_yard")
	check(loaded_zone.has_pending_construction(), "Loaded zone has pending construction")
	check(loaded_zone.pending_started_at == before_time, "Loaded pending_started_at preserved")
	check(loaded_zone.pending_completes_at == before_time + building_def.construction_minutes, "Loaded pending_completes_at preserved")
	check(loaded_zone.building_id == &"", "Loaded building_id still empty")

	# Step 5: Advance the remaining 1 minute to trigger completion
	runtime.campaign_state = loaded_state
	state = loaded_state
	zone_state = loaded_zone
	check(runtime.advance_time(1), "Advance final 1 minute to complete deadline")

	check(zone_state.building_id == &"temporary_party_shelter", "Building completed: building_id set")
	check(zone_state.building_level == 1, "Building completed: building_level is 1")
	check(not zone_state.has_pending_construction(), "Pending construction cleared after completion")

	# Step 6: Visual check after completion (BUILT state)
	# Update panel state reference and refresh
	panel._state = state
	panel._settlement_state = state.home_settlement_state
	panel.refresh_state()
	check(construction_visual.visible == false, "ConstructionVisual is hidden after completion")
	check(built_visual.visible == true, "BuiltVisual is visible after completion")

	sandbox.free()
	runtime.free()

	if failures == 0:
		print("SMOKE GREEN: async home settlement construction, time preservation, save/load, deadline completion and 3-state visuals.")
		quit(0)
	else:
		print("SMOKE FAILED: %d errors" % failures)
		quit(1)
