extends SceneTree

var failures: int = 0
var vfx_count: int = 0
var player_actions: int = 0
var player_moves: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func settle(controller: BattleInteractionController) -> void:
	for frame in range(1000):
		await process_frame
		if not controller.is_interaction_in_progress():
			if controller.turn_controller.is_finished:
				await create_timer(0.6).timeout
			return
	check(false, "Interaction did not settle within 1000 frames.")


func run() -> void:
	seed(247)
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.ai_think_delay = 0
	screen.animate_movement = "--animated" in OS.get_cmdline_user_args()
	screen.animate_actions = screen.animate_movement
	root.add_child(screen)
	await process_frame
	check(screen.flow != null and screen.flow.turn_controller.is_running, "Production encounter starts automatically.")
	var flow := screen.flow
	var fx := screen.get_node("BattleWorld/BattleEffectsLayer") as BattleEffectsLayer
	fx.effect_spawned.connect(func(_id: StringName, _view: Node2D): vfx_count += 1)
	var layout := screen.get_arena_layout()
	var actor := flow.turn_controller.active_combatant
	check(actor != null, "Turn controller selects an active combatant.")
	check(screen.tactical_state.get_flags(actor.grid_position) & BattleTacticalState.Kind.SELECTED,
		"Selected slot is produced by existing overlay computations.")
	var hover := Vector2i(0, 1)
	screen.slot_hovered.emit(hover)
	# SlotInteraction updates hover state before forwarding the same coordinate.
	screen.tactical_state.set_hover(hover)
	check(screen.tactical_state.get_flags(hover) & BattleTacticalState.Kind.HOVER, "Semantic hover exists.")
	check(screen.tactical_state.get_flags(hover) & BattleTacticalState.Kind.PATH, "Movement preview uses logical path.")
	check(not screen.find_children("*", "BattleGridView", true, false).size(), "Production contains no rectangular renderer.")
	screen.slot_clicked.emit(hover, MOUSE_BUTTON_LEFT)
	await settle(flow.interaction)
	check(actor.grid_position == hover, "A slot click commits normal movement.")
	player_moves += 1
	flow._end_turn()
	await settle(flow.interaction)

	# Drive the player side through its existing interaction controller.
	# Use the unchanged planner to choose legal inputs, not to alter combat state.
	for step in range(160):
		if flow.turn_controller.is_finished:
			break
		actor = flow.turn_controller.active_combatant
		if actor == null or actor.team_id != screen.player_team_id:
			await process_frame
			continue
		var report := flow.ai_runner.plan_generator.create_report(screen.session, actor, 1)
		check(report.is_valid, "Planner can inspect production session.")
		var plan := report.selected_plan
		if plan == null or plan.is_wait() or plan.get_score() <= 0:
			flow._end_turn()
			await process_frame
			continue
		if plan.has_movement():
			await flow.interaction._try_move_active_combatant(actor, plan.get_destination_coordinate())
			player_moves += 1
		elif plan.has_ally_swap():
			await flow.interaction._try_swap_with_ally(actor, screen.session.get_combatant(plan.ally_swap_target_id))
		if plan.has_action() and actor.is_alive and not flow.turn_controller.is_finished:
			flow.interaction.on_ability_selected(plan.ability)
			screen.slot_clicked.emit(plan.aim_coordinate, MOUSE_BUTTON_LEFT)
			await settle(flow.interaction)
			player_actions += 1
		var view := screen.combatant_presenter.get_view(actor.instance_id)
		if view != null and actor.is_alive:
			check(view.global_position.distance_to(layout.get_slot_position(actor.grid_position)) < 0.1,
				"Committed state and authored visual position agree.")
		await process_frame
	check(flow.turn_controller.is_finished, "Existing encounter reaches battle_finished through production.")
	check(player_actions > 0 and player_moves > 0, "Player used movement and ability interactions.")
	check(flow.ai_turns_completed > 0, "Enemy AI completed turns.")
	check(vfx_count > 0, "CombatantPresenter VFX hooks spawned reusable effects.")
	check(screen.get_node("BattleUI/Root/EndTurn").disabled, "Finished battle disables turn action.")

	var camera := screen.get_node("BattleCamera") as Camera2D
	var director := screen.get_node("CameraDirector") as BattleCameraDirector
	var original_offset := camera.offset
	var original_zoom := camera.zoom
	director.shake(12, 0.2)
	director._process(0.05)
	check(camera.offset != original_offset, "Test shake changes camera offset.")
	director.push_zoom(1.08, 0.2)
	director.reset()
	check(camera.offset.is_equal_approx(Vector2.ZERO) and camera.zoom.is_equal_approx(original_zoom),
		"Camera reset restores fixed rest state.")
	var feedback := screen.get_node("BattleUI/ScreenFeedback") as BattleScreenFeedback
	feedback.damage_flash()
	check(feedback.modulate.a > 0, "Universal feedback can flash.")
	feedback.reset()
	check(feedback.modulate.a == 0 and feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"Feedback resets and never blocks input.")
	# Let ephemeral effects/death cleanup finish before disposing the test scene.
	await create_timer(0.6).timeout
	var session := screen.session
	print("PRODUCTION BATTLE: winner=", flow.turn_controller.winning_team_id,
		" rounds=", flow.turn_controller.round_number, " actions=", player_actions,
		" moves=", player_moves, " enemy_turns=", flow.ai_turns_completed, " vfx=", vfx_count)
	screen.queue_free()
	await process_frame
	session.clear()
	print("PRODUCTION BATTLE SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
