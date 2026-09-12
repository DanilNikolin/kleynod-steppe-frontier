extends SceneTree

var failures: int = 0
const QUEST := &"carpenter_tools_and_family"
const AREA := &"debug_carpenter_homestead_area"
const RESIDENT := &"debug_carpenter"


func check(value: bool, label: String) -> void:
	if not value:
		failures += 1
		push_error(label)


func _initialize() -> void:
	call_deferred("run")


func build(runtime: CampaignRuntimeService, building_id: StringName) -> void:
	for zone in runtime.get_home_settlement_definition().zones:
		var b := zone.get_building(building_id)
		if b != null:
			check(runtime.construct_home_settlement_building(zone.zone_id, building_id), "Build " + String(building_id))
			check(runtime.advance_time(b.construction_minutes), "Advance construction time for " + String(building_id))
			return
	check(false, "Building definition absent")


func run() -> void:
	var runtime := CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Start campaign")
	var campaign := runtime.campaign_definition
	for error in campaign.get_validation_errors():
		check(false, error)
	# Run from either wandering location. Quest turn-in must follow the live giver.
	for meet_in_city in [false, true]:
		check(runtime.start_new_campaign(), "Fresh quest run")
		if meet_in_city:
			check(runtime.advance_time(4320), "Move carpenter to city")
		var state := runtime.campaign_state
		var carpenter := state.get_resident(RESIDENT)
		var rendezvous := carpenter.current_world_node_id
		var quest := state.get_quest(QUEST)
		var quest_definition := campaign.get_quest(QUEST)
		var area := state.get_adventure_area(AREA)
		check(area.get_site(&"old_workshop").is_hidden(), "Workshop hidden before accepting")
		check(not runtime.adventure_service.get_landmark_exploration_error(state, campaign.get_adventure_area(AREA), area, &"old_workshop").is_empty(), "Cannot explore quest location early")
		state.current_world_node_id = rendezvous
		var session := CampaignDialogueSession.new()
		check(session.begin(runtime, &"debug_wandering_carpenter"), "Meet carpenter")
		check(session.choose(&"ask_work", session.revision).is_empty(), "Discuss work")
		check(session.choose(&"accept", session.revision).is_empty(), "Accept personal quest")
		check(quest.is_active() and not area.get_site(&"old_workshop").is_hidden(), "Quest reveals homestead sites")
		check(not runtime.quest_service.get_abandon_error(state, quest_definition, quest).is_empty(), "Personal quest cannot be abandoned")
		check(session.begin(runtime, &"debug_wandering_carpenter"), "Quest reminder")
		check(session.node.node_id == &"active", "Active entry")
		var before_materials := state.materials
		state.current_world_node_id = &"debug_carpenter_homestead"
		check(runtime.explore_adventure_site(AREA, &"old_workshop"), "Recover tools")
		check(quest.is_objective_completed(&"recover_tools"), "Tools tracked")
		check(not quest.is_ready_to_turn_in(quest_definition), "Tools alone do not complete quest")
		check(state.materials == before_materials, "Story exploration grants no stray materials")
		var path := "user://carpenter_quest_smoke_%s.json" % Time.get_ticks_usec()
		var saves := CampaignSaveService.new(path)
		check(saves.save_campaign(state).is_successful, "Save partial quest")
		var loaded := saves.load_campaign(campaign)
		check(loaded.is_successful, "Load partial quest: " + loaded.message)
		if loaded.is_successful:
			runtime.campaign_state = loaded.campaign_state
			state = runtime.campaign_state
			quest = state.get_quest(QUEST)
			carpenter = state.get_resident(RESIDENT)
			area = state.get_adventure_area(AREA)
		check(quest.is_objective_completed(&"recover_tools") and area.get_site(&"old_workshop").is_cleared(), "Partial progress round trip")
		check(not runtime.adventure_service.get_landmark_exploration_error(state, campaign.get_adventure_area(AREA), area, &"old_workshop").is_empty(), "Tools cannot be taken twice")
		check(runtime.explore_adventure_site(AREA, &"roadside_witness"), "Find family lead")
		var panel := CampaignAdventureAreaPanel.new()
		root.add_child(panel)
		panel.bind(campaign.get_adventure_area(AREA), area)
		panel._on_site_selected(&"roadside_witness")
		check(panel._site_description.text.contains("живыми"), "Explored site shows testimony instead of old prompt")
		check(panel._action_button.disabled, "Completed testimony cannot be repeated")
		panel.free()
		check(quest.is_ready_to_turn_in(quest_definition), "Both objectives ready")
		check(not runtime.quest_service.get_turn_in_error(state, quest_definition, quest, campaign.get_resident(RESIDENT), carpenter, runtime.get_home_settlement_definition()).is_empty(), "Cannot report from homestead")
		state.current_world_node_id = rendezvous
		check(session.begin(runtime, &"debug_wandering_carpenter"), "Return to pinned giver")
		check(session.node.node_id == &"ready", "Ready entry")
		check(session.choose(&"report", session.revision).is_empty(), "Report tools and family")
		check(quest.is_completed() and carpenter.recruitment_unlocked, "Report unlocks invitation")
		check(session.get_node_text().contains("живыми"), "Family is missing, not declared dead")
		var invite := session.node.get_choice(&"invite")
		check(not session.get_choice_error(invite).is_empty(), "Empty HOME blocks invite")
		check(not runtime.resident_service.apply_recruitment(state, campaign.get_resident(RESIDENT), carpenter), "Direct service cannot bypass HOME gate")
		state.current_world_node_id = &"debug_home"
		build(runtime, &"primitive_campfire")
		# Exercise the existing starter materials loop, rather than granting test money.
		state.current_world_node_id = &"debug_home_materials_node"
		check(runtime.explore_adventure_site(&"debug_home_outskirts_materials_area", &"starter_materials_cache"), "Starter materials still work")
		state.current_world_node_id = &"debug_home"
		check(runtime.unload_materials().is_empty(), "Unload starter cargo")
		build(runtime, &"temporary_party_shelter")
		state.current_world_node_id = rendezvous
		check(not runtime.get_resident_recruitment_error(RESIDENT).is_empty(), "A1/B1 without C1 blocks guest")
		state.current_world_node_id = &"debug_home"
		build(runtime, &"primitive_common_shelter")
		state.current_world_node_id = rendezvous
		check(session.begin(runtime, &"debug_wandering_carpenter"), "Return after HOME preparation")
		check(session.node.node_id == &"complete", "Completed quest does not restart")
		check(session.choose(&"invite", session.revision).is_empty(), "Invite guest with all requirements")
		check(session.closed and carpenter.status == CampaignResidentState.Status.HOME_GUEST, "Invitation creates temporary guest, closes conversation")
		check(runtime.get_resident_for_local_interaction(&"debug_wandering_carpenter") == null, "Resident leaves old job")
		state.current_world_node_id = &"debug_home"
		check(runtime.get_resident_for_local_interaction(&"debug_home_carpenter") != null, "Resident physically available in HOME")
		check(session.begin(runtime, &"debug_home_carpenter"), "Talk to HOME guest")
		check(session.node.node_id == &"home", "Guest greeting retains family lead")
		check(saves.save_campaign(state).is_successful, "Save guest")
		loaded = saves.load_campaign(campaign)
		check(loaded.is_successful, "Load guest: " + loaded.message)
		if loaded.is_successful:
			check(loaded.campaign_state.get_resident(RESIDENT).status == CampaignResidentState.Status.HOME_GUEST, "Guest status survives load")
		check(runtime.advance_time(100 * 1440), "Advance guest time")
		check(carpenter.is_at_home(), "Guest never resumes wandering")
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		session.close()
	runtime.free()
	if failures == 0:
		print("SMOKE GREEN: carpenter personal quest from village/city, exploration, partial save/load, missing-family lead, A1/B1/C1 gate, guest arrival and persistence.")
	quit(0 if failures == 0 else 1)
