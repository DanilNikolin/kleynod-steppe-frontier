extends SceneTree

var failures: int = 0
var clicks: Array[Vector2i] = []
var hovers: Array[Vector2i] = []


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func at_slot(view: CombatantView, layout: BattleArenaLayout, coordinate: Vector2i) -> bool:
	return view.global_position.distance_to(layout.get_slot_position(coordinate)) < 0.01


func run() -> void:
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.auto_start_battle = false
	root.add_child(screen)
	await process_frame
	var layout := screen.get_arena_layout()
	check(layout.get_anchors().size() == 18, "18 authored slots exist.")
	check(layout.get_validation_errors(Vector2i(6, 3)).is_empty(), "Standard encounter validates.")
	var anchor := layout.get_slot_anchor(Vector2i(0, 0))
	anchor.coordinate = Vector2i(1, 0)
	var errors := "; ".join(layout.get_validation_errors(Vector2i(6, 3)))
	check("duplicate" in errors and "missing" in errors and "Slot_0_0" in errors,
		"Duplicate/missing errors identify offending node and coordinate.")
	anchor.coordinate = Vector2i(6, 0)
	errors = "; ".join(layout.get_validation_errors(Vector2i(6, 3)))
	check("outside encounter bounds" in errors, "Out-of-bounds anchor is rejected.")
	anchor.coordinate = Vector2i(0, 0)
	check(not layout.get_validation_errors(Vector2i(8, 3)).is_empty(),
		"Actual encounter dimensions determine required coordinates.")
	check(not layout.has_slot(Vector2i(99, 99)), "Invalid slot cannot resolve.")

	screen.position = Vector2(81, -29)
	layout.position = Vector2(21, 54)
	layout.rotation = 0.15
	layout.scale = Vector2(1.1, 0.9)
	anchor.position += Vector2(-91, 27)
	check(layout.get_slot_position(anchor.coordinate).is_equal_approx(anchor.global_position),
		"Dragged anchor is resolved immediately.")
	anchor.rotation = 0.3
	check(layout.pick_slot(anchor.to_global(Vector2(10, 5))) == anchor,
		"Hit area follows the same anchor transform.")
	check(not anchor.contains_world_position(anchor.to_global(Vector2(300, 0))),
		"Outside ellipse does not hit.")

	var session := BattleSessionFactory.new().create_from_encounter(
		load("res://content/encounters/debug/debug_duel_encounter.tres"))
	check(session != null and screen.bind_session(session), "Existing model binds to production screen.")
	var presenter := screen.combatant_presenter
	var actor := session.get_combatant(&"debug_hero")
	var enemy := session.get_combatant(&"debug_enemy")
	var actor_view := presenter.get_view(actor.instance_id)
	var enemy_view := presenter.get_view(enemy.instance_id)
	check(at_slot(actor_view, layout, actor.grid_position), "Initial spawn uses authored ground contact.")
	check(presenter.combatant_layer.y_sort_enabled and actor_view.visual_container.position == Vector2.ZERO,
		"Actors sort at foot origins.")
	var original_actor_coordinate := actor.grid_position
	var original_enemy_coordinate := enemy.grid_position
	# Presentation methods do not write back to the model.
	check(await presenter.move_along_grid_path(actor.instance_id,
		[Vector2i(0, 0), Vector2i(2, 2)], true), "Animated multi-slot path completes.")
	check(at_slot(actor_view, layout, Vector2i(2, 2)), "Path ends at authored slot.")
	for animated in [false, true]:
		check(await presenter.present_swap(actor.instance_id, enemy.instance_id,
			Vector2i(2, 0), Vector2i(3, 2), animated), "Swap presentation completes.")
		check(at_slot(actor_view, layout, Vector2i(2, 0)) and at_slot(enemy_view, layout, Vector2i(3, 2)),
			"Both swap destinations use anchors.")
		check(await presenter.present_teleport(actor.instance_id, Vector2i(0, 2), animated),
			"Teleport presentation completes.")
		check(at_slot(actor_view, layout, Vector2i(0, 2)), "Teleport lands at authored slot.")
	check(await presenter.move_along_grid_path(actor.instance_id, [Vector2i(1, 2)], false),
		"Non-animated displacement uses the same resolver as forced movement.")
	check(at_slot(actor_view, layout, Vector2i(1, 2)), "Displacement ends at authored slot.")
	check(not await presenter.move_along_grid_path(actor.instance_id, [Vector2i(99, 2)], false),
		"Invalid movement path fails before changing the view.")
	check(actor.grid_position == original_actor_coordinate and enemy.grid_position == original_enemy_coordinate,
		"Presentation leaves gameplay coordinates unchanged.")

	# Exercise the unchanged normal movement service and runner against anchors.
	await presenter.present_teleport(actor.instance_id, actor.grid_position, false)
	var service := BattleMovementService.new(session.side_rules)
	var plan := service.create_plan(session.grid, actor, Vector2i(0, 1))
	var outcome := await BattleMovementRunner.new(session, service, presenter).execute(
		session.grid, actor, plan, true)
	check(outcome.is_successful and actor.grid_position == Vector2i(0, 1)
		and at_slot(actor_view, layout, actor.grid_position), "Gameplay movement runner works with authored layout.")

	var spawn := CombatantSpawnDefinition.new()
	spawn.instance_id = &"anchor_reinforcement"
	spawn.combatant_definition = enemy.definition
	spawn.team_id = enemy.team_id
	spawn.coordinate = Vector2i(5, 2)
	var wave := BattleReinforcementWaveDefinition.new()
	wave.wave_id = &"anchor_wave"
	wave.round_number = 1
	wave.combatant_spawns = [spawn]
	var reinforcement := BattleReinforcementController.new(session, [wave])
	var spawned := reinforcement.process_round(1)
	check(spawned.size() == 1, "Existing reinforcement controller spawns normally.")
	check(presenter.has_view(spawn.instance_id)
		and at_slot(presenter.get_view(spawn.instance_id), layout, spawn.coordinate),
		"Reinforcement signal spawns its view at authored anchor.")

	var camera := screen.get_node("BattleCamera") as Camera2D
	camera.position = Vector2(45, 80)
	camera.zoom = Vector2(0.75, 0.75)
	camera.force_update_scroll()
	var interaction := screen.get_node("BattleWorld/TacticalOverlay/SlotInteraction") as BattleSlotInteraction
	screen.slot_clicked.connect(func(coordinate: Vector2i, _button: int): clicks.append(coordinate))
	screen.slot_hovered.connect(func(coordinate: Vector2i): hovers.append(coordinate))
	var event := InputEventMouseButton.new()
	event.position = interaction.get_canvas_transform() * anchor.global_position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event, true)
	check(clicks == [anchor.coordinate], "Viewport input resolves slot with camera pan and zoom.")
	check(interaction.hovered_coordinate == anchor.coordinate, "Hover resolves same slot as click.")
	# GUI consumes clicks before the world input stage.
	var blocker := Control.new()
	blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	screen.get_node("BattleUI").add_child(blocker)
	root.push_input(event, true)
	check(clicks.size() == 1, "UI blocks world slot clicks.")
	var motion := InputEventMouseMotion.new()
	motion.position = event.position
	root.push_input(motion, true)
	await process_frame
	check(interaction.hovered_coordinate == BattleSlotInteraction.NO_SLOT,
		"Moving over blocking UI clears world hover.")
	blocker.queue_free()
	await process_frame

	check(screen.load_environment(load("res://presentation/battle/environment/battle_environment.tscn")),
		"Environment can change with a bound presenter.")
	check(presenter.slot_resolver == screen.get_arena_layout()
		and interaction.layout == screen.get_arena_layout(), "Movement and input both switch to new layout.")
	check(at_slot(actor_view, screen.get_arena_layout(), actor.grid_position),
		"Existing actors realign to replacement anchors.")
	screen.queue_free()
	await process_frame
	session.clear()
	print("AUTHORED SLOTS SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
