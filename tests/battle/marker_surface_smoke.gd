extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.auto_start_battle = false
	root.add_child(screen)
	var model := BattleSessionFactory.new().create_from_encounter(screen.encounter_definition)
	check(screen.bind_session(model), "Bind fixture session")
	var overlay := screen.get_node("BattleWorld/TacticalOverlay") as BattleTacticalOverlay
	var coordinate := Vector2i(2, 1)
	var marker := overlay.get_marker(coordinate)
	check(marker != null and overlay._markers.size() == 18, "One marker per authored anchor")
	for layer in BattleTacticalMarkerView.LAYERS:
		marker.set_flags(BattleTacticalMarkerView.LAYERS[layer])
		for other in BattleTacticalMarkerView.LAYERS:
			check(marker.get_node(NodePath(other)).visible == (other == layer), "Independent layer " + layer)
		check(marker.get_node("Base").visible, "Base remains visible under layer " + layer)
	screen.tactical_state.add_state(coordinate, BattleTacticalState.Kind.VALID_TARGET)
	screen.tactical_state.add_state(coordinate, BattleTacticalState.Kind.AOE)
	screen.tactical_state.add_state(coordinate, BattleTacticalState.Kind.HOVER)
	check(marker.get_node("Hover").visible and marker.get_node("AoE").visible and marker.get_node("ValidTarget").visible, "Flags coexist")
	screen.tactical_state.clear_tactical()
	screen.tactical_state.set_hover(BattleGrid.INVALID_COORDINATE)
	screen.tactical_state.set_surfaces([coordinate])
	check(marker.get_node("Base").visible and not marker.get_node("ValidTarget").visible, "SURFACE alone leaves only neutral Base visual")
	var anchor := screen.get_arena_layout().get_slot_anchor(coordinate)
	anchor.position += Vector2(19, -27)
	anchor.interaction_radii *= 1.5
	marker.sync_anchor()
	check(marker.global_position.is_equal_approx(anchor.global_position) and marker.scale.is_equal_approx(Vector2(1.5, 1.5)), "Marker follows authored position and radii")
	var surfaces := screen.get_node("BattleWorld/SurfaceLayer") as BattleSurfacePresenter
	var fire := load("res://content/surfaces/debug/debug_fire_surface.tres") as BattleSurfaceEffectDefinition
	var fissure := load("res://content/surfaces/heroes/bayda/bayda_burning_fissure.tres") as BattleSurfaceEffectDefinition
	var controller := model.surface_effect_controller
	var first := controller.place_effect(model, coordinate, fire)
	var second := controller.place_effect(model, coordinate, fissure)
	check(first != null and second != null, "Both existing surfaces placed")
	check(surfaces.get_view(first).scene_file_path == surfaces.resolve_scene(fire.surface_effect_id).resource_path, "Fire scene resolves")
	check(surfaces.get_view(second).scene_file_path == surfaces.resolve_scene(fissure.surface_effect_id).resource_path, "Fissure scene resolves")
	check(surfaces._views.size() == 2, "Multiple surfaces at one coordinate")
	var original := surfaces.get_view(first)
	controller.place_effect(model, coordinate, fire)
	check(surfaces.get_view(first) == original, "Update retains visual instance")
	check(original.global_position.is_equal_approx(anchor.global_position), "Surface shares slot position")
	controller.remove_effect(model, coordinate, fire.surface_effect_id)
	check(surfaces.get_view(first) == null and surfaces._views.size() == 1, "Removal removes only matching view")
	var unknown := fire.duplicate() as BattleSurfaceEffectDefinition
	unknown.surface_effect_id = &"test_unknown_visual"
	var third := controller.place_effect(model, coordinate, unknown)
	check(surfaces.get_view(third).scene_file_path == surfaces.fallback_scene.resource_path, "Unknown ID uses explicit fallback")
	screen.queue_free()
	await process_frame
	model.clear()
	print("MARKER SURFACE SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
