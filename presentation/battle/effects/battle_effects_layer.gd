class_name BattleEffectsLayer
extends Node2D

signal effect_spawned(effect_id: StringName, instance: Node2D)
signal sound_played(sound_id: StringName)

enum Placement { WORLD, ACTOR, TARGET, ACTOR_EFFECT_ANCHOR, TARGET_EFFECT_ANCHOR }

@export var effects: Array[BattleVFXDefinition] = []
@export var sounds: Dictionary[StringName, AudioStream] = {}

var presenter: BattleCombatantPresenter


func bind(value: BattleCombatantPresenter) -> void:
	unbind()
	presenter = value
	presenter.vfx_requested.connect(_on_vfx_requested)
	presenter.sound_requested.connect(_on_sound_requested)


func unbind() -> void:
	if presenter != null:
		presenter.vfx_requested.disconnect(_on_vfx_requested)
		presenter.sound_requested.disconnect(_on_sound_requested)
	presenter = null


func _exit_tree() -> void:
	unbind()


func _on_vfx_requested(id: StringName, position_world: Vector2, source: StringName, target: StringName) -> void:
	spawn_vfx(id, position_world, source, target)


func _on_sound_requested(id: StringName, position_world: Vector2, _source: StringName) -> void:
	if not sounds.has(id) or sounds[id] == null:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = sounds[id]
	add_child(player)
	player.global_position = position_world
	player.finished.connect(player.queue_free)
	player.play()
	sound_played.emit(id)


func spawn_vfx(id: StringName, position_world: Vector2 = Vector2.ZERO,
		actor_id: StringName = &"", target_id: StringName = &"",
		placement: Placement = Placement.WORLD) -> Node2D:
	var definition: BattleVFXDefinition
	for item in effects:
		if item != null and item.effect_id == id:
			definition = item
			break
	if definition == null or definition.scene == null:
		push_warning("Unregistered battle VFX: %s" % id)
		return null
	if placement != Placement.WORLD:
		var combatant_id := actor_id if placement in [Placement.ACTOR, Placement.ACTOR_EFFECT_ANCHOR] else target_id
		var view := presenter.get_view(combatant_id) if presenter != null else null
		if view == null:
			return null
		position_world = view.global_position
		if placement in [Placement.ACTOR_EFFECT_ANCHOR, Placement.TARGET_EFFECT_ANCHOR] and view.visual != null:
			position_world = view.visual.get_effects_anchor_global_position()
	var instance := definition.scene.instantiate()
	if not instance is Node2D:
		instance.free()
		push_error("Battle VFX scene root must be Node2D: %s" % id)
		return null
	add_child(instance)
	instance.global_position = position_world
	# Projectile or attached VFX can consume existing view references if needed.
	if instance.has_method("configure_battle_effect"):
		instance.call("configure_battle_effect", presenter, actor_id, target_id)
	var timer := Timer.new()
	timer.wait_time = definition.lifetime
	timer.one_shot = true
	instance.add_child(timer)
	timer.timeout.connect(instance.queue_free)
	timer.start()
	effect_spawned.emit(id, instance)
	return instance
