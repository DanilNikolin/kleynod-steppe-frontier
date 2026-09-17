extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func snapshot(camera: Camera2D, background: Node2D, ground: Node2D) -> Array:
	return [camera.offset, camera.zoom, background.position, background.scale, ground.position, ground.scale]

func run() -> void:
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.environment_scene = load("res://scenes/battle/environments/deep_forest_environment.tscn")
	root.add_child(screen)
	var director := screen.get_node("CameraDirector") as BattleCameraDirector
	director.set_process(false)
	var camera := screen.get_node("BattleCamera") as Camera2D
	var background := screen.environment.get_node("BackgroundLayer") as Node2D
	var ground := screen.environment.get_node("GroundLayer") as Node2D
	check(director != null and background != null and ground != null, "Deep Forest and director loaded.")
	var rest := snapshot(camera, background, ground)
	var fixed_nodes: Array[Node2D] = [screen.get_arena_layout()]
	for path in ["SurfaceLayer", "CombatantLayer", "BattleEffectsLayer", "TacticalOverlay"]:
		fixed_nodes.append(screen.get_node("BattleWorld/" + path))
	var fixed_transforms: Array[Transform2D] = []
	for node in fixed_nodes:
		fixed_transforms.append(node.global_transform)
	for level in ["Weak", "Medium", "Strong"]:
		var button := screen.get_node("BattleUI/Root/ShakeTestPanel/" + level) as Button
		button.pressed.emit()
		director._process(0.03)
		check(camera.offset != rest[0] and camera.zoom.x > rest[1].x, level + " moves and zooms camera.")
		check(background.position != rest[2], level + " moves background.")
		check(ground.position.distance_to(rest[4]) > background.position.distance_to(rest[2]), level + " ground moves more.")
		check(background.scale.x < rest[3].x and ground.scale.x > rest[5].x, level + " differential depth scale.")
		for i in range(fixed_nodes.size()):
			check(fixed_nodes[i].global_transform == fixed_transforms[i], "World layers stay fixed during impact.")
		director.reset()
		check(snapshot(camera, background, ground) == rest, level + " resets exactly.")
	# Repeated interrupted pulses never capture an already displaced rest state.
	for i in range(12):
		director.impact_shake_weak()
		director._process(0.025)
		director.impact_shake_strong()
		director._process(0.03)
		director.impact_shake_medium()
		director._process(0.02)
	director._process(1.0)
	check(snapshot(camera, background, ground) == rest, "Retrigger and natural completion restore exactly.")
	for i in range(fixed_nodes.size()):
		check(fixed_nodes[i].global_transform == fixed_transforms[i], "Gameplay presentation layer stays fixed.")
	# Missing visual layers are optional; the current environment is resolved afresh.
	screen.environment.remove_child(background)
	background.free()
	director.impact_shake(BattleCameraDirector.ImpactStrength.STRONG, Vector2.ZERO)
	director._process(0.03)
	check(camera.offset != rest[0] and ground.position != rest[4], "Missing background still animates camera and ground.")
	director.reset()
	check(ground.position == rest[4] and ground.scale == rest[5], "Missing-layer reset is exact.")
	check(screen.load_environment(load("res://scenes/battle/environments/steppe_environment.tscn")), "Environment replacement succeeds.")
	director.impact_shake_strong()
	director._process(0.03)
	var next_background := screen.environment.get_node("BackgroundLayer") as Node2D
	check(next_background.position != Vector2.ZERO, "New environment receives next impact.")
	director.reset()
	var next_ground := screen.environment.get_node("GroundLayer") as Node2D
	# Authored nonzero positions and nonuniform scales must survive interruption and exit.
	next_background.position = Vector2(41, -23)
	next_background.scale = Vector2(0.8, 1.3)
	next_ground.position = Vector2(-17, 9)
	next_ground.scale = Vector2(1.2, 0.9)
	var next_rest := snapshot(camera, next_background, next_ground)
	director.impact_shake_strong()
	director._process(0.03)
	screen.remove_child(director)
	check(snapshot(camera, next_background, next_ground) == next_rest, "Exiting director restores authored transforms.")
	director.free()
	screen.queue_free()
	await process_frame
	print("LAYERED IMPACT SHAKE SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
