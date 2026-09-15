extends SceneTree

var failures: int = 0
var sounds_played: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	root.add_child(screen)
	var effects := screen.get_node("BattleWorld/BattleEffectsLayer") as BattleEffectsLayer
	var actor := screen.combatant_presenter.get_view(&"debug_hero")
	var target := screen.combatant_presenter.get_view(&"debug_enemy")
	var locations := [
		Vector2(73, -12), actor.global_position, target.global_position,
		actor.visual.get_effects_anchor_global_position(), target.visual.get_effects_anchor_global_position()]
	var instances: Array[Node2D] = []
	for placement in range(5):
		var effect := effects.spawn_vfx(&"impact", locations[0], &"debug_hero", &"debug_enemy", placement)
		check(effect != null and effect.global_position.distance_to(locations[placement]) < 0.01,
			"Reusable VFX supports placement %d." % placement)
		instances.append(effect)
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_8_BITS
	sound.mix_rate = 8000
	var samples := PackedByteArray()
	samples.resize(800)
	samples.fill(128)
	sound.data = samples
	effects.sounds[&"test"] = sound
	effects.sound_played.connect(func(_id: StringName): sounds_played += 1)
	screen.combatant_presenter.sound_requested.emit(&"test", actor.global_position, &"debug_hero")
	check(sounds_played == 1, "Existing sound hook reaches the shared audio layer.")
	var director := screen.get_node("CameraDirector") as BattleCameraDirector
	var camera := screen.get_node("BattleCamera") as Camera2D
	var rest_zoom := camera.zoom
	var rest_position := camera.position
	director.shake()
	director.push_zoom(1.08, 0.12)
	await create_timer(0.7).timeout
	check(camera.zoom.is_equal_approx(rest_zoom) and camera.offset.is_equal_approx(Vector2.ZERO),
		"Camera effects restore naturally without an explicit reset.")
	for effect in instances:
		check(not is_instance_valid(effect), "Finished VFX frees itself.")
	check(effects.get_child_count() == 0, "VFX/audio cleanup leaves the universal layer empty.")
	camera.position += Vector2(40, 50)
	director.reset()
	check(camera.position.is_equal_approx(rest_position), "Explicit reset restores full camera transform.")
	var session := screen.session
	screen.queue_free()
	await process_frame
	session.clear()
	print("UNIVERSAL FEEDBACK SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
