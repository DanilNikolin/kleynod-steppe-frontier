extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func run() -> void:
	var marker_scene := load("res://presentation/battle/overlay/battle_tactical_marker_view.tscn") as PackedScene
	check(marker_scene != null, "battle_tactical_marker_view.tscn loaded")
	var marker := marker_scene.instantiate() as BattleTacticalMarkerView
	check(marker != null, "BattleTacticalMarkerView instantiated")
	root.add_child(marker)
	await process_frame

	# 1. Base layer exists and has Sprite2D
	var base_layer := marker.get_node_or_null("Base")
	check(base_layer != null, "Base layer node exists")
	if base_layer != null:
		var base_sprite := base_layer.get_node_or_null("Sprite") as Sprite2D
		check(base_sprite != null, "Base/Sprite exists and is Sprite2D")
		if base_sprite != null:
			check(base_sprite.texture != null, "Base/Sprite has texture")
			check(base_sprite.centered == true, "Base/Sprite is centered")

	# 2. Structure check: 8 canonical dynamic layers exist, each has child "Sprite" of type Sprite2D with non-null texture
	for layer_name in BattleTacticalMarkerView.LAYERS:
		var layer := marker.get_node_or_null(NodePath(layer_name))
		check(layer != null, "Layer node exists: " + layer_name)
		if layer != null:
			var sprite := layer.get_node_or_null("Sprite") as Sprite2D
			check(sprite != null, layer_name + "/Sprite exists and is Sprite2D")
			if sprite != null:
				check(sprite.texture != null, layer_name + "/Sprite has texture")
				check(sprite.centered == true, layer_name + "/Sprite is centered")

	# 3. Primitive removal check: exactly 0 Polygon2D and 0 Line2D in the scene
	var primitive_count := 0
	var nodes_to_check: Array[Node] = [marker]
	while not nodes_to_check.is_empty():
		var current: Node = nodes_to_check.pop_back()
		if current is Polygon2D or current is Line2D:
			primitive_count += 1
		for child in current.get_children():
			nodes_to_check.append(child)
	check(primitive_count == 0, "No Polygon2D or Line2D primitives exist in marker scene (found: %d)" % primitive_count)

	# 4. Scale check: Selected and Hover scale is (1, 1)
	var selected_node := marker.get_node_or_null("Selected") as Node2D
	check(selected_node != null and selected_node.scale.is_equal_approx(Vector2.ONE),
		"Selected scale is Vector2.ONE (1, 1)")
	var hover_node := marker.get_node_or_null("Hover") as Node2D
	check(hover_node != null and hover_node.scale.is_equal_approx(Vector2.ONE),
		"Hover scale is Vector2.ONE (1, 1)")

	# 5. Single flag visibility check
	for layer_name in BattleTacticalMarkerView.LAYERS:
		var flag: int = BattleTacticalMarkerView.LAYERS[layer_name]
		marker.set_flags(flag)
		check(marker.visible == true, "Marker is visible when flag is active: " + layer_name)
		check(marker.get_node("Base").visible == true, "Base remains visible under layer: " + layer_name)
		for other_name in BattleTacticalMarkerView.LAYERS:
			var target_vis: bool = (other_name == layer_name)
			var node := marker.get_node(NodePath(other_name)) as CanvasItem
			check(node.visible == target_vis, "Visibility of %s when flag is %s (expected: %s, got: %s)" % [other_name, layer_name, str(target_vis), str(node.visible)])

	# 6. Zero flags test: Base is visible, all 8 dynamic layers invisible, marker.visible is true
	marker.set_flags(0)
	check(marker.visible == true, "Marker is visible with 0 flags (shows neutral Base)")
	check(marker.get_node("Base").visible == true, "Base is visible with 0 flags")
	for layer_name in BattleTacticalMarkerView.LAYERS:
		check(marker.get_node(NodePath(layer_name)).visible == false, layer_name + " is invisible with 0 flags")

	# 7. Combined flags test
	marker.set_flags(BattleTacticalState.Kind.VALID_TARGET | BattleTacticalState.Kind.AOE)
	check(marker.visible == true, "Combined VALID_TARGET | AOE is visible")
	check(marker.get_node("Base").visible == true, "Base is visible in combination")
	check(marker.get_node("ValidTarget").visible == true, "ValidTarget is visible in combination")
	check(marker.get_node("AoE").visible == true, "AoE is visible in combination")
	check(marker.get_node("Hover").visible == false, "Hover remains invisible")

	marker.set_flags(BattleTacticalState.Kind.SELECTED | BattleTacticalState.Kind.HOVER)
	check(marker.get_node("Selected").visible == true, "Selected is visible in combination")
	check(marker.get_node("Hover").visible == true, "Hover is visible in combination")

	# 8. Anchor scaling test
	var anchor := BattleSlotAnchor.new()
	anchor.interaction_radii = Vector2(60, 32)
	marker.bind_anchor(anchor)
	check(marker.scale.is_equal_approx(Vector2(1.0, 1.0)), "Marker scale is 1.0 at design radii (60, 32)")

	anchor.interaction_radii = Vector2(90, 48)
	marker.sync_anchor()
	check(marker.scale.is_equal_approx(Vector2(1.5, 1.5)), "Marker scale scales up to 1.5 with interaction_radii")

	marker.queue_free()
	anchor.free()
	await process_frame

	# 9. Runtime overlay test on 6x3 arena (18 anchors)
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.auto_start_battle = false
	root.add_child(screen)
	await process_frame

	var overlay := screen.get_node("BattleWorld/TacticalOverlay") as BattleTacticalOverlay
	check(overlay != null, "BattleTacticalOverlay exists")
	check(overlay.z_index == -50, "TacticalOverlay z_index is -50 (beneath CombatantLayer)")
	check(overlay._markers.size() == 18, "18 tactical marker instances bound to authored anchors")

	for coord in overlay._markers:
		var m := overlay.get_marker(coord)
		check(m is BattleTacticalMarkerView, "Marker is BattleTacticalMarkerView at " + str(coord))
		var base_sprite := m.get_node_or_null("Base/Sprite") as Sprite2D
		check(base_sprite != null, "Base/Sprite exists in runtime overlay instance at " + str(coord))
		check(m.get_node("Base").visible == true, "Base is visible at " + str(coord))

	# 10. Deep forest environment integration check
	var deep_forest_env := load("res://scenes/battle/environments/deep_forest_environment.tscn") as PackedScene
	check(screen.load_environment(deep_forest_env), "Deep forest environment loaded into BattleScreen")
	check(overlay._markers.size() == 18, "Overlay still has 18 markers with Deep Forest environment")
	for coord in overlay._markers:
		var m := overlay.get_marker(coord)
		var h_sprite := m.get_node_or_null("Hover/Sprite") as Sprite2D
		check(h_sprite != null, "Deep Forest marker has Hover/Sprite")

	screen.queue_free()
	await process_frame

	print("TACTICAL MARKER SPRITE SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
