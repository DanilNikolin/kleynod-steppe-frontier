extends SceneTree

var failures := 0
var expected_experience := -1
var expected_winner: StringName

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	seed(247)
	var runtime := root.get_node("CampaignRuntime") as CampaignRuntimeService
	check(runtime.start_new_campaign(), "Start campaign")
	# Exercise real victory/rewards with the existing debug weapon; no battle-state edits.
	if "--default-party" not in OS.get_cmdline_user_args():
		var hero := runtime.campaign_state.heroes[1]
		runtime.campaign_state.party_member_hero_ids.assign([hero.get_hero_id()])
		var equipped := CampaignEquipmentService.new().equip_item(runtime.campaign_state,
			hero.get_hero_id(), &"debug_testing_sabre_start", HeroEquipmentState.Slot.WEAPON_1)
		check(equipped.is_successful, "Equip existing debug sabre")
	for name in ["forest_edge", "abandoned_cart", "overturned_cart_ambush"]:
		var location := load("res://content/locations/debug/debug_%s_location.tres" % name) as CampaignLocationDefinition
		check(location.is_valid_definition(), "Valid campaign location " + name)
		var environment := location.battle_environment_scene.instantiate() as BattleEnvironment
		check(environment.get_validation_errors(Vector2i(6, 3)).is_empty(), "Valid authored environment " + name)
		environment.free()
	check(runtime.start_location(&"debug_forest_edge"), "Launch campaign location")
	var request := runtime.pending_battle_request
	check(request != null, "Pending request exists")
	await scene_changed
	var screen := current_scene as BattleScreen
	check(screen != null, "Campaign loads production BattleScreen")
	if screen == null:
		quit(1)
		return
	check(screen.encounter_definition == request.encounter_definition, "Runtime party encounter used")
	check(screen.environment_scene == request.battle_environment_scene and screen.environment.scene_file_path.ends_with("forest_edge_environment.tscn"), "Location environment used")
	screen.animate_actions = "--animated" in OS.get_cmdline_user_args()
	screen.animate_movement = screen.animate_actions
	screen.ai_think_delay = 0
	var flow := screen.flow
	flow.completed.connect(func(winner: StringName):
		expected_winner = winner
		expected_experience = BattleExperienceRewardService.new().get_defeated_team_experience(screen.session, &"team_enemy"))
	for step in range(5000):
		if not is_instance_valid(screen) or flow.turn_controller.is_finished:
			break
		var actor := flow.turn_controller.active_combatant
		if actor == null or actor.team_id != screen.player_team_id or flow.interaction.is_interaction_in_progress():
			await process_frame
			continue
		var report := flow.ai_runner.plan_generator.create_report(screen.session, actor, 1)
		var plan := report.selected_plan
		if plan == null or plan.is_wait() or plan.get_score() <= 0:
			flow._end_turn()
		elif plan.has_movement():
			await flow.interaction._try_move_active_combatant(actor, plan.get_destination_coordinate())
		elif plan.has_ally_swap():
			await flow.interaction._try_swap_with_ally(actor, screen.session.get_combatant(plan.ally_swap_target_id))
		elif plan.has_action():
			flow.interaction.on_ability_selected(plan.ability)
			screen.slot_clicked.emit(plan.aim_coordinate, MOUSE_BUTTON_LEFT)
		await process_frame
	for frame in range(10000):
		if current_scene != null and current_scene.scene_file_path == runtime.CAMPAIGN_SCENE_PATH:
			break
		await process_frame
	check(expected_experience >= 0, "Battle completed through existing services")
	check(not runtime.has_pending_battle(), "Pending battle cleared")
	check(current_scene != null and current_scene.scene_file_path == runtime.CAMPAIGN_SCENE_PATH, "Campaign scene restored")
	var result := runtime.campaign_state.last_battle_result
	check(result != null and result.location_id == request.location_id, "Campaign receives result")
	if result != null:
		check(result.defeated_enemy_experience_pool == expected_experience, "Existing XP calculation preserved")
		check(result.winning_team_id == expected_winner, "Winner preserved")
		if "--default-party" not in OS.get_cmdline_user_args():
			check(result.outcome == CampaignBattleResult.Outcome.VICTORY and expected_experience > 0, "Victory grants XP")
			check(result.loot_budget > 0, "Victory uses existing loot budget")
	check(runtime.campaign_state.completed_battle_count == 1, "Completion applied once")
	print("CAMPAIGN PRODUCTION SMOKE: ", "GREEN" if failures == 0 else "FAILED", " winner=", expected_winner, " XP=", expected_experience)
	quit(0 if failures == 0 else 1)
