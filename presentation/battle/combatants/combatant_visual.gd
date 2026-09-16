@tool
class_name CombatantVisual
extends Node2D


signal animation_finished(animation_key: StringName)


const EMPTY_ANIMATION: StringName = &""


@export_group("Structure")

@export
var visual_root_path: NodePath = ^"VisualRoot"

@export
var animation_player_path: NodePath = ^"AnimationPlayer"

@export
var hit_anchor_path: NodePath = ^"HitAnchor"

@export
var projectile_anchor_path: NodePath = ^"ProjectileAnchor"

@export
var effects_anchor_path: NodePath = ^"EffectsAnchor"


@export var animated_sprite: AnimatedSprite2D


@export_group("Facing")

@export
var faces_right_by_default: bool = true


var _is_dead: bool = false
var _animation_revision: int = 0
var _current_key: StringName = &""
var _completion_source: Object
var _completion_callback: Callable

var _visual_root: Node2D
var _animation_player: AnimationPlayer
var _hit_anchor: Node2D
var _projectile_anchor: Node2D
var _effects_anchor: Node2D


func _ready() -> void:
	_cache_nodes()


func _cache_nodes() -> void:
	if animated_sprite == null:
		animated_sprite = get_node_or_null("Forward/BodyPivot/Character") as AnimatedSprite2D
	_visual_root = (
		get_node_or_null(visual_root_path)
		as Node2D
	)

	_animation_player = (
		get_node_or_null(animation_player_path)
		as AnimationPlayer
	)

	_hit_anchor = (
		get_node_or_null(hit_anchor_path)
		as Node2D
	)

	_projectile_anchor = (
		get_node_or_null(projectile_anchor_path)
		as Node2D
	)

	_effects_anchor = (
		get_node_or_null(effects_anchor_path)
		as Node2D
	)


func set_facing_direction(direction: int) -> void:
	if direction == 0:
		return

	if _visual_root == null:
		_cache_nodes()

	if _visual_root == null:
		return

	var should_face_right := direction > 0
	var use_positive_scale := (
		should_face_right == faces_right_by_default
	)

	var current_scale := _visual_root.scale
	var absolute_x := absf(current_scale.x)

	if is_zero_approx(absolute_x):
		absolute_x = 1.0

	current_scale.x = (
		absolute_x
		if use_positive_scale
		else -absolute_x
	)

	_visual_root.scale = current_scale


func has_animation(key: StringName) -> bool:
	_cache_nodes()
	return _uses_sprite(key) or (_animation_player != null and _animation_player.has_animation(key))


func _uses_sprite(key: StringName) -> bool:
	return animated_sprite != null and animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(key)


func get_animation_duration(key: StringName) -> float:
	if not has_animation(key):
		return 0.0
	if _uses_sprite(key):
		var frames := animated_sprite.sprite_frames
		var rate := frames.get_animation_speed(key) * absf(animated_sprite.speed_scale)
		if is_zero_approx(rate):
			return INF
		var duration := 0.0
		for index in range(frames.get_frame_count(key)):
			duration += frames.get_frame_duration(key, index)
		return duration / rate
	var rate := absf(_animation_player.speed_scale)
	return _animation_player.get_animation(key).length / rate if rate > 0.0 else INF


func is_animation_looping(key: StringName) -> bool:
	if not has_animation(key):
		return false
	if _uses_sprite(key):
		return animated_sprite.sprite_frames.get_animation_loop(key)
	return _animation_player.get_animation(key).loop_mode != Animation.LOOP_NONE


func get_animation_mixer() -> AnimationMixer:
	_cache_nodes()
	return _animation_player


func set_facing(direction: int) -> void:
	set_facing_direction(direction)


func play_animation(key: StringName, fallback_key: StringName = &"idle", restart_if_same: bool = false) -> bool:
	if _is_dead:
		return false
	if key == &"death":
		_is_dead = true
	var resolved := key if has_animation(key) else fallback_key
	if not has_animation(resolved):
		return false
	# Cosmetic feedback completion must not truncate a newer hit/action.
	if not _is_dead and _current_key != &"" and not is_animation_looping(_current_key):
		if resolved in [&"idle", &"move"] or (_current_key == &"hit" and resolved != &"hit"):
			return false
	if resolved == _current_key and not restart_if_same and resolved != &"hit":
		return true
	_animation_revision += 1
	_disconnect_completion()
	_current_key = resolved
	if _uses_sprite(resolved):
		if _animation_player != null:
			_animation_player.stop()
		_completion_source = animated_sprite
		_completion_callback = _on_sprite_finished.bind(resolved, _animation_revision)
		animated_sprite.animation_finished.connect(_completion_callback)
		animated_sprite.stop()
		animated_sprite.play(resolved)
	else:
		if animated_sprite != null:
			animated_sprite.stop()
		_completion_source = _animation_player
		_completion_callback = _on_player_finished.bind(_animation_revision)
		_animation_player.animation_finished.connect(_completion_callback)
		_animation_player.stop()
		_animation_player.play(resolved)
	return true


func _disconnect_completion() -> void:
	if is_instance_valid(_completion_source) and _completion_source.is_connected(&"animation_finished", _completion_callback):
		_completion_source.disconnect(&"animation_finished", _completion_callback)
	_completion_source = null


func _on_sprite_finished(key: StringName, revision: int) -> void:
	_finish_animation(key, revision)


func _on_player_finished(key: StringName, revision: int) -> void:
	_finish_animation(key, revision)


func _finish_animation(key: StringName, revision: int) -> void:
	if revision != _animation_revision or key != _current_key:
		return
	_disconnect_completion()
	if not _is_dead:
		_current_key = &""
		play_idle()
	# Death remains stopped at its native last frame; never reset it with stop().
	animation_finished.emit(key)


func play_idle() -> bool:
	return play_animation(&"idle", EMPTY_ANIMATION)


func play_move() -> bool:
	return play_animation(&"move", &"idle")


func play_hit() -> bool:
	return play_animation(&"hit", &"idle", true)


func play_block() -> bool:
	return play_animation(&"block", &"idle")


func play_death() -> bool:
	return play_animation(&"death", EMPTY_ANIMATION)


func get_hit_anchor_global_position() -> Vector2:
	if _hit_anchor == null:
		_cache_nodes()

	if _hit_anchor != null:
		return _hit_anchor.global_position

	return global_position


func get_projectile_anchor_global_position() -> Vector2:
	if _projectile_anchor == null:
		_cache_nodes()

	if _projectile_anchor != null:
		return _projectile_anchor.global_position

	return global_position


func get_effects_anchor_global_position() -> Vector2:
	if _effects_anchor == null:
		_cache_nodes()

	if _effects_anchor != null:
		return _effects_anchor.global_position

	return global_position
