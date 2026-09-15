extends SceneTree

var failures: int = 0


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
	await process_frame
	var host := screen.get_node("BattleWorld/EnvironmentHost")
	check(host.get_child_count() == 1, "Default environment is loaded exactly once.")
	check(screen.environment.get_node_or_null("BackAtmosphereLayer") == null,
		"Concrete environments can omit optional layers.")
	screen.position = Vector2(123, 45)
	var layout := screen.get_arena_layout()
	layout.rotation = 0.2
	layout.scale = Vector2(1.2, 0.8)
	var combatants := screen.get_node("BattleWorld/CombatantLayer") as Node2D
	var grid := BattleGrid.new(3, 6)
	for coordinate in grid.get_all_coordinates():
		var world_position := layout.get_slot_position(coordinate)
		check(combatants.to_global(combatants.to_local(world_position)).is_equal_approx(world_position),
			"Coordinates transfer between layout and combatant parents.")
		check(layout.to_local(world_position).distance_to(layout.get_slot_anchor(coordinate).position) < 0.001,
			"Arena transform is respected.")
	var previous := screen.environment
	check(screen.load_environment(load("res://presentation/battle/environment/battle_environment.tscn")),
		"Base environment can replace a concrete environment.")
	check(host.get_child_count() == 1 and previous.get_parent() == null,
		"Replacement immediately detaches the previous environment.")
	var ordered_layers: Array[Node2D] = []
	for layer_name in ["BackgroundLayer", "GroundLayer", "BackAtmosphereLayer"]:
		ordered_layers.append(screen.environment.get_node(layer_name))
	for layer_name in ["SurfaceLayer", "CombatantLayer", "BattleEffectsLayer", "TacticalOverlay"]:
		ordered_layers.append(screen.get_node("BattleWorld/" + layer_name))
	for layer_name in ["ForegroundLayer", "FrontAtmosphereLayer", "LightingLayer"]:
		ordered_layers.append(screen.environment.get_node(layer_name))
	for index in range(ordered_layers.size()):
		check(not ordered_layers[index].z_as_relative, "World layer Z is independent of parent Z.")
		if index > 0:
			check(ordered_layers[index - 1].z_index < ordered_layers[index].z_index,
				"World layers interleave in the required order.")
	check((screen.get_node("BattleUI") as CanvasLayer).layer == 1, "UI is above the world canvas.")
	check((screen.get_node("BattleCamera") as Camera2D).is_current(), "Battle camera is active.")
	await process_frame
	check(not is_instance_valid(previous), "Replaced environment is freed.")
	screen.queue_free()
	await process_frame
	# Loading before ready must not instantiate the selected environment twice.
	var preloaded := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	check(preloaded.load_environment(load("res://presentation/battle/environment/battle_environment.tscn")),
		"Environment can be selected before entering the tree.")
	preloaded.auto_start_battle = false
	root.add_child(preloaded)
	check(preloaded.get_node("BattleWorld/EnvironmentHost").get_child_count() == 1,
		"Ready preserves an explicitly loaded environment.")
	preloaded.queue_free()
	await process_frame
	print("BATTLE PRESENTATION SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
