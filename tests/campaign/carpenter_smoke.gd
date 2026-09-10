extends SceneTree


var failures: int = 0


func check(value: bool, label: String) -> void:
	if not value:
		failures += 1
		push_error(label)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var runtime := CampaignRuntimeService.new()
	var content := load(CampaignRuntimeService.DEBUG_CAMPAIGN_DEFINITION_PATH) as CampaignDefinition
	if content != null:
		for error in content.get_validation_errors():
			check(false, error)
	check(runtime.start_new_campaign(), "Campaign content validates and starts")
	if runtime.campaign_state == null:
		runtime.free()
		quit(1)
		return
	var campaign := runtime.campaign_definition
	var state := runtime.campaign_state
	var carpenter := state.get_resident(&"debug_carpenter")
	var definition := campaign.get_resident(&"debug_carpenter")
	check(carpenter.current_world_node_id == &"debug_village", "Initial early job")
	check(not carpenter.has_met and not carpenter.location_clue_known, "Starts unknown")
	check(runtime.advance_time(4320), "Time advances")
	check(carpenter.current_world_node_id == &"debug_city", "Moves to other permitted job")
	var wandering_path := "user://carpenter_wandering_%s.json" % Time.get_ticks_usec()
	var wandering_save := CampaignSaveService.new(wandering_path)
	check(wandering_save.save_campaign(state).is_successful, "Save unpinned job")
	var wandering_loaded := wandering_save.load_campaign(campaign)
	check(wandering_loaded.is_successful, "Load unpinned job")
	if wandering_loaded.is_successful:
		var next_job := wandering_loaded.campaign_state
		check(runtime.time_service.advance_minutes(next_job, 4320), "Advance restored schedule")
		runtime.resident_service.update_wandering(campaign, next_job)
		check(next_job.get_resident(&"debug_carpenter").current_world_node_id == &"debug_village", "Unpinned wandering resumes after load")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(wandering_path))
	state.current_world_node_id = &"debug_village"
	check(runtime.get_resident_for_local_interaction(&"debug_wandering_carpenter") == null, "Absent at previous job")
	check(not runtime.resident_service.is_interaction_present(definition, carpenter, &"debug_wandering_carpenter", &"debug_village"), "Map hides previous job")
	var session := CampaignDialogueSession.new()
	check(not session.begin(runtime, &"debug_wandering_carpenter"), "Cannot talk remotely")
	check(session.begin(runtime, &"debug_village_innkeeper"), "Talk to witness")
	var revision := session.revision
	check(session.choose(&"carpenter_clue", revision).is_empty(), "Ask witness for clue")
	check(carpenter.location_clue_known and not carpenter.has_met, "Clue pins without meeting")
	check(session.get_node_text().contains("Большой город"), "Clue names live destination")
	check(not session.choose(&"carpenter_clue", revision).is_empty(), "Reject stale answer")
	check(runtime.advance_time(30 * 1440), "Long detour advances")
	check(carpenter.current_world_node_id == &"debug_city", "Fresh lead survives travel and detours")
	# Unique temporary save; never use the player's campaign_save.json.
	var path := "user://carpenter_smoke_%s.json" % Time.get_ticks_usec()
	var saves := CampaignSaveService.new(path)
	check(saves.save_campaign(state).is_successful, "Save clue before meeting")
	var loaded := saves.load_campaign(campaign)
	check(loaded.is_successful, "Load clue before meeting: " + loaded.message)
	if loaded.is_successful:
		runtime.campaign_state = loaded.campaign_state
		state = runtime.campaign_state
		carpenter = state.get_resident(&"debug_carpenter")
		check(carpenter.location_clue_known and not carpenter.has_met and carpenter.current_world_node_id == &"debug_city", "Pin round trip")
		check(runtime.advance_time(4320), "Advance loaded pin")
		check(carpenter.current_world_node_id == &"debug_city", "Loaded clue still pins")
	state.current_world_node_id = &"debug_city"
	var panel := CampaignLocalLocationPanel.new()
	root.add_child(panel)
	panel.bind(runtime.get_current_local_location_definition(), state, runtime.get_home_settlement_definition(), runtime.get_home_settlement_state(), campaign.residents, campaign.quests)
	panel._on_interaction_selected(&"debug_wandering_carpenter")
	check(panel._interaction_description.text.contains("Большой город"), "Resident card names current city")
	check(not panel._interaction_description.text.contains("Малом селе"), "Resident card does not claim origin village")
	check(panel._actions_row.get_child_count() == 1, "Resident card offers conversation without recruitment")
	panel.free()
	check(session.begin(runtime, &"debug_wandering_carpenter"), "First conversation at real job")
	check(session.node.node_id == &"first" and carpenter.has_met, "First entry records meeting")
	session.close()
	check(runtime.advance_time(100 * 1440), "Advance after meeting")
	check(carpenter.current_world_node_id == &"debug_city", "Meeting permanently ends wandering")
	check(session.begin(runtime, &"debug_wandering_carpenter"), "Talk again")
	check(session.node.node_id == &"again", "Repeat meeting uses different entry")
	check(session.choose(&"ask_work", session.revision).is_empty(), "Discuss work")
	check(not runtime.get_resident_recruitment_error(&"debug_carpenter").is_empty(), "Meeting does not recruit")
	check(saves.save_campaign(state).is_successful, "Save meeting")
	loaded = saves.load_campaign(campaign)
	check(loaded.is_successful, "Load meeting: " + loaded.message)
	if loaded.is_successful:
		check(loaded.campaign_state.get_resident(&"debug_carpenter").has_met, "Meeting round trip")
		var ostap := loaded.campaign_state.get_resident(&"resident_blacksmith_ostap")
		check(ostap != null and not ostap.has_met and ostap.current_world_node_id == &"", "Static resident round trip")
	# Corrupt a permitted-location reference: the loader must reject it.
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var payload: Dictionary = data
	check(payload.has("residents"), "Save resident payload exists")
	if payload.has("residents"):
		for resident in payload["residents"]:
			if resident["resident_id"] == "debug_carpenter":
				resident["current_world_node_id"] = "debug_forest_edge_node"
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
		file.close()
		check(not saves.load_campaign(campaign).is_successful, "Reject saved location outside early pool")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	# Meeting without any clue must stop movement as well.
	check(runtime.start_new_campaign(), "Restart campaign")
	runtime.campaign_state.current_world_node_id = &"debug_village"
	check(session.begin(runtime, &"debug_wandering_carpenter"), "Chance encounter without clue")
	check(runtime.advance_time(4320), "Advance chance encounter")
	check(runtime.get_resident_state(&"debug_carpenter").current_world_node_id == &"debug_village", "Chance meeting stops movement")
	session.close()
	runtime.free()
	if failures == 0:
		print("SMOKE GREEN: wandering, truthful pinned clue, first/repeat encounter, save/load, invalid save rejection, no premature recruitment.")
	quit(0 if failures == 0 else 1)
