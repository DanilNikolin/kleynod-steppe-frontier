@tool
class_name CombatantVisual
extends Node2D


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


@export_group("Facing")

@export
var faces_right_by_default: bool = true


var _visual_root: Node2D
var _animation_player: AnimationPlayer
var _hit_anchor: Node2D
var _projectile_anchor: Node2D
var _effects_anchor: Node2D


func _ready() -> void:
	_cache_nodes()


func _cache_nodes() -> void:
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


func play_animation(
	animation_key: StringName,
	fallback_key: StringName = &"idle"
) -> bool:
	if _animation_player == null:
		_cache_nodes()

	if _animation_player == null:
		return false

	if (
		animation_key != EMPTY_ANIMATION
		and _animation_player.has_animation(animation_key)
	):
		_animation_player.play(animation_key)
		return true

	if (
		fallback_key != EMPTY_ANIMATION
		and _animation_player.has_animation(fallback_key)
	):
		_animation_player.play(fallback_key)
		return true

	return false


func play_idle() -> bool:
	return play_animation(&"idle", EMPTY_ANIMATION)


func play_move() -> bool:
	return play_animation(&"move", &"idle")


func play_hit() -> bool:
	return play_animation(&"hit", &"idle")


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