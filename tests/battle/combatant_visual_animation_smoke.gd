extends SceneTree

var failures := 0
const BAYDA = preload("res://presentation/battle/combatants/visuals/bayda_battle_visual.tscn")
const RAIDER = preload("res://presentation/battle/combatants/visuals/steppe_raider_battle_visual.tscn")

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func wait_finish(visual: CombatantVisual) -> void:
	# Bounded test wait; production completion uses native animation_finished.
	for frame in range(500):
		await process_frame
		if visual._current_key == &"idle" or (visual._is_dead and not visual.animated_sprite.is_playing()):
			return
	check(false, "Animation did not finish")

func test_visual(scene: PackedScene) -> void:
	var visual := scene.instantiate() as CombatantVisual
	root.add_child(visual)
	visual.play_idle()
	var sprite := visual.animated_sprite
	check(sprite != null and sprite.is_playing() and sprite.animation == &"idle", "Idle starts")
	check(visual.is_animation_looping(&"idle") and not visual.is_animation_looping(&"attack"), "Loop flags")
	check(not visual.has_animation(&"move"), "No walk/move frames")
	visual.play_move()
	check(sprite.animation == &"idle", "Movement falls back to idle")
	visual.set_facing(1)
	check(visual.get_node("Forward").scale.x > 0, "Facing right")
	visual.set_facing(-1)
	check(visual.get_node("Forward").scale.x < 0, "Facing left")
	check(is_equal_approx(visual.get_animation_duration(&"attack"), 0.25), "Actual frame duration")
	sprite.sprite_frames.set_frame(&"attack", 0, sprite.sprite_frames.get_frame_texture(&"attack", 0), 2.0)
	sprite.speed_scale = 2
	check(is_equal_approx(visual.get_animation_duration(&"attack"), 3.0 / 16.0), "FPS, per-frame weight and speed scale")
	visual.play_animation(&"attack")
	visual.play_idle()
	check(sprite.animation == &"attack", "Feedback finish cannot truncate attack")
	await wait_finish(visual)
	check(sprite.animation == &"idle", "Attack returns to idle")
	visual.play_animation(&"attack")
	visual.play_hit()
	visual.play_animation(&"attack")
	check(sprite.animation == &"hit", "Hit interrupts and takes priority over action")
	visual.play_hit()
	check(sprite.frame == 0, "Repeated hit restarts")
	await wait_finish(visual)
	check(sprite.animation == &"idle", "Hit returns to idle")
	visual.play_animation(&"celebrate", &"")
	check(sprite.animation == &"idle", "Unknown keys are not attacks")
	visual.play_animation(&"attack")
	var old_revision := visual._animation_revision
	visual.play_death()
	visual._on_sprite_finished(&"attack", old_revision)
	visual.play_idle()
	visual.play_move()
	visual.play_animation(&"attack")
	visual.play_animation(&"hit")
	check(sprite.animation == &"death", "Death lock and stale completion guard")
	await wait_finish(visual)
	check(sprite.animation == &"death" and sprite.frame == sprite.sprite_frames.get_frame_count(&"death") - 1,
		"Death holds final frame")
	visual.queue_free()
	await process_frame

func integration(speed: float) -> Array:
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.auto_start_battle = false
	root.add_child(screen)
	var encounter := load("res://content/encounters/debug/debug_duel_encounter.tres").duplicate(true) as BattleEncounterDefinition
	encounter.combatant_spawns[0].hero_definition = null
	encounter.combatant_spawns[0].combatant_definition.visual_scene = BAYDA
	encounter.combatant_spawns[1].combatant_definition.visual_scene = RAIDER
	var model := BattleSessionFactory.new().create_from_encounter(encounter)
	check(screen.bind_session(model), "Bind custom visual session")
	var actor := model.get_combatant(&"debug_hero")
	var target := model.get_combatant(&"debug_enemy")
	var actor_view := screen.combatant_presenter.get_view(actor.instance_id)
	var target_view := screen.combatant_presenter.get_view(target.instance_id)
	check(actor_view.visual.scene_file_path == BAYDA.resource_path and actor_view.visual_container.get_child_count() == 1,
		"Canonical scene mapping; no duplicate basic body")
	check(actor_view.visual.global_position.is_equal_approx(screen.get_arena_layout().get_slot_position(actor.grid_position)), "Feet at authored anchor")
	actor_view.visual.animated_sprite.sprite_frames.set_animation_speed(&"attack", speed)
	var ability := actor.loadout.get_abilities()[0]
	for effect in ability.effects:
		if effect is DamageEffect:
			effect.crit_mode = DamageEffect.CritMode.DISABLED
	var service := BattleActionService.new(BattleTargetingService.new())
	var runner := BattleActionRunner.new(service, screen.combatant_presenter)
	var command := BattleActionCommand.new(actor, ability, target.grid_position)
	var profile := BattleAbilityPresentationProfile.new()
	profile.actor_animation_key = &"heavy_test_attack"
	ability.presentation_profile = profile
	var seen: Array[StringName] = []
	actor_view.visual.animated_sprite.animation_changed.connect(func(): seen.append(actor_view.visual.animated_sprite.animation))
	var hits: Array[StringName] = []
	target_view.visual.animated_sprite.animation_changed.connect(func(): hits.append(target_view.visual.animated_sprite.animation))
	var outcome := await runner.execute_action(model, command, true, false)
	check(outcome.is_successful, "Real action succeeds")
	check(seen.has(&"attack"), "Missing specific damage animation falls back to attack")
	check(hits.has(&"hit") and target.is_alive, "Real nonlethal damage launches hit")
	var result := [target.current_health, actor.current_stamina, actor.get_ability_lock_remaining_turns(ability.ability_id)]
	await wait_finish(actor_view.visual)
	var frames := actor_view.visual.animated_sprite.sprite_frames
	frames.add_animation(&"heavy_test_attack")
	frames.set_animation_loop(&"heavy_test_attack", false)
	frames.add_frame(&"heavy_test_attack", frames.get_frame_texture(&"attack", 0))
	seen.clear()
	await screen.combatant_presenter.play_ability_feedback(actor.instance_id, [target.instance_id], [], outcome.action_result, profile, false)
	check(seen.has(&"heavy_test_attack"), "Specific authored action takes precedence")
	await wait_finish(actor_view.visual)
	# Commit another real attack with normal presentation, retaining the defeated view.
	actor.current_stamina = actor.max_stamina
	await runner.execute_action(model, command, true, false)
	check(not target.is_alive and target_view.visual._is_dead, "Lethal damage reaches death")
	await wait_finish(target_view.visual)
	check(target_view.visual.animated_sprite.animation == &"death", "Finish feedback cannot resurrect target")
	# Missing visual remains a valid content definition and uses the old scene.
	var fallback_definition := target.definition.duplicate() as CombatantDefinition
	fallback_definition.visual_scene = null
	check(fallback_definition.is_valid_definition(), "Custom art is optional")
	var fallback_actor := CombatantState.new(&"fallback", fallback_definition, &"team_enemy", target.loadout)
	var fallback_view := load("res://presentation/battle/combatants/combatant_view.tscn").instantiate() as CombatantView
	root.add_child(fallback_view)
	fallback_view.bind_state(fallback_actor)
	check(fallback_view.visual.scene_file_path.ends_with("placeholder_combatant_visual.tscn"), "Missing scene uses placeholder")
	# Existing AnimationPlayer backend still resolves/play/completes clips.
	var player := fallback_view.visual.get_animation_mixer() as AnimationPlayer
	var library := AnimationLibrary.new()
	var clip := Animation.new()
	clip.length = 0.03
	library.add_animation(&"attack", clip)
	var idle := Animation.new()
	idle.loop_mode = Animation.LOOP_LINEAR
	library.add_animation(&"idle", idle)
	player.add_animation_library(&"", library)
	check(fallback_view.visual.play_animation(&"attack") and fallback_view.visual.has_animation(&"attack"), "AnimationPlayer remains supported")
	await create_timer(0.1).timeout
	check(player.current_animation == &"idle", "AnimationPlayer completion returns idle")
	fallback_view.queue_free()
	screen.queue_free()
	await process_frame
	model.clear()
	return result

func run() -> void:
	await test_visual(BAYDA)
	await test_visual(RAIDER)
	var fast := await integration(120.0)
	var slow := await integration(2.0)
	check(fast == slow, "HP, stamina and cooldown do not depend on art duration")
	print("COMBATANT VISUAL ANIMATION SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
