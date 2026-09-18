extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func spawn(id: StringName, definition: CombatantDefinition, team: StringName, coordinate: Vector2i) -> CombatantSpawnDefinition:
	var value := CombatantSpawnDefinition.new()
	value.instance_id = id
	value.combatant_definition = definition
	value.team_id = team
	value.coordinate = coordinate
	if team == &"team_player":
		# Production fixtures equip only the abilities exercised here; the sandbox
		# retains its full 17-ability debug loadout and separate visual panel.
		var loadout := CombatantLoadoutDefinition.new()
		loadout.loadout_id = &"production_feature_test"
		for key in ["sabre_slash", "swap_positions", "teleport", "shield_bash", "place_fire_surface"]:
			loadout.abilities.append(load("res://content/abilities/debug/debug_%s.tres" % key))
		loadout.default_ability_id = loadout.abilities[0].ability_id
		value.loadout_override = loadout
	return value


func fixture() -> BattleEncounterDefinition:
	var encounter := BattleEncounterDefinition.new()
	encounter.encounter_id = &"presentation_feature_test"
	var hero := load("res://scenes/debug_sechevik.tres") as CombatantDefinition
	var enemy := load("res://content/combatants/debug/debug_steppe_raider.tres") as CombatantDefinition
	encounter.combatant_spawns = [
		spawn(&"a_actor", hero, &"team_player", Vector2i(1, 1)),
		spawn(&"b_ally", hero, &"team_player", Vector2i(0, 1)),
		spawn(&"enemy", enemy, &"team_enemy", Vector2i(3, 1))]
	var wave := BattleReinforcementWaveDefinition.new()
	wave.wave_id = &"wave"
	wave.round_number = 2
	wave.combatant_spawns = [spawn(&"reinforcement", enemy, &"team_enemy", Vector2i(5, 2))]
	encounter.reinforcement_waves = [wave]
	return encounter


func at_slot(screen: BattleScreen, id: StringName) -> bool:
	var state := screen.session.get_combatant(id)
	var view := screen.combatant_presenter.get_view(id)
	return state != null and view != null and view.global_position.distance_to(
		screen.get_arena_layout().get_slot_position(state.grid_position)) < 0.1


func run() -> void:
	seed(13)
	for case_name in ["swap_positions", "teleport", "shield_bash", "place_fire_surface"]:
		var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
		screen.encounter_definition = fixture()
		screen.ai_think_delay = 0
		root.add_child(screen)
		await process_frame
		var flow := screen.flow
		var actor := screen.session.get_combatant(&"a_actor")
		var ability := load("res://content/abilities/debug/debug_%s.tres" % case_name) as AbilityDefinition
		var aim := Vector2i(0, 1)
		if case_name == "teleport":
			aim = Vector2i(2, 2)
		elif case_name == "shield_bash":
			aim = Vector2i(3, 1)
		elif case_name == "place_fire_surface":
			aim = Vector2i(2, 1)
		var command := BattleActionCommand.new(actor, ability, aim)
		check(flow.action_service.can_execute(screen.session, command), "%s is legal on logical grid." % case_name)
		# Change visual distances radically without touching the model or ability.
		screen.get_arena_layout().get_slot_anchor(aim).position += Vector2(201, -71)
		check(flow.action_service.can_execute(screen.session, command), "Dragging slots does not change range/cost.")
		flow.interaction.on_ability_selected(ability)
		screen.slot_hovered.emit(aim)
		check(screen.tactical_state.get_flags(aim) & BattleTacticalState.Kind.VALID_TARGET,
			"%s produces a valid target marker." % case_name)
		if case_name == "place_fire_surface":
			check(not screen.tactical_state.surface_previews.is_empty(), "Surface preview stays semantic.")
		# Exercise the actual interaction -> action runner -> authored presentation path.
		await flow.interaction._try_use_ability_at(actor, aim)
		match case_name:
			"swap_positions":
				check(actor.grid_position == aim and at_slot(screen, &"a_actor") and at_slot(screen, &"b_ally"),
					"Ability swap animates both authored positions.")
				await flow.interaction._try_swap_with_ally(actor, screen.session.get_combatant(&"b_ally"))
				check(actor.grid_position == Vector2i(1, 1) and at_slot(screen, &"a_actor") and at_slot(screen, &"b_ally"),
					"Normal allied swap uses unchanged movement runner.")
			"teleport":
				check(actor.grid_position == aim and at_slot(screen, &"a_actor"), "Teleport lands on moved anchor.")
			"shield_bash":
				check(screen.session.get_combatant(&"enemy").grid_position == Vector2i(5, 1)
					and at_slot(screen, &"enemy"), "Forced movement pushes to authored destination.")
			"place_fire_surface":
				var controller := screen.session.surface_effect_controller
				check(not controller.get_effects_at(aim).is_empty(), "Ability creates logical surface.")
				flow.interaction.refresh_grid_overlays()
				check(screen.tactical_state.get_flags(aim) & BattleTacticalState.Kind.SURFACE,
					"Surface semantic state survives tactical refresh.")
				var hp := actor.current_health
				await flow.interaction._try_move_active_combatant(actor, aim)
				check(actor.current_health < hp and at_slot(screen, &"a_actor"),
					"Entering the authored surface triggers existing damage logic.")

		# Real turn flow reaches round two and schedules the existing reinforcement controller.
		for index in range(8):
			if flow.turn_controller.round_number >= 2:
				break
			if flow.interaction.is_player_turn():
				flow._end_turn()
			for frame in range(1000):
				await process_frame
				if not flow.interaction.is_interaction_in_progress():
					break
		check(screen.session.has_combatant(&"reinforcement") and at_slot(screen, &"reinforcement"),
			"Round-two reinforcement is presented at its authored slot.")
		await create_timer(0.6).timeout
		var model := screen.session
		screen.queue_free()
		await process_frame
		model.clear()
		print("FEATURE CHECK: ", case_name)
	print("PRODUCTION FEATURES SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
