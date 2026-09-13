class_name IntermittentDetailAnimation
extends Node

@export var animated_sprite_path: NodePath
@export var animation_name: StringName = &"idle"
@export var animation_names: Array[StringName] = []
@export var animation_weights: PackedFloat32Array = PackedFloat32Array()

@export var initial_min_pause: float = 0.2
@export var initial_max_pause: float = 1.2

@export var min_pause: float = 1.6
@export var max_pause: float = 4.8

@export var playback_speed_min: float = 0.9
@export var playback_speed_max: float = 1.15

@export var reset_to_first_frame_on_stop: bool = true
@export var enabled: bool = true

var _timer: Timer
var _rng: RandomNumberGenerator
var _is_active: bool = false
var _cached_sprite: AnimatedSprite2D
var _current_animation: StringName = &""
var _warned_loops: Dictionary = {}


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	_timer = get_node_or_null("Timer") as Timer
	if _timer == null:
		_timer = Timer.new()
		_timer.name = "Timer"
		_timer.one_shot = true
		add_child(_timer)

	if not _timer.timeout.is_connected(_on_timer_timeout):
		_timer.timeout.connect(_on_timer_timeout)

	_resolve_sprite()


func set_active(active: bool) -> void:
	if _is_active == active:
		return
	_is_active = active

	if not is_inside_tree():
		return

	if _timer == null:
		_timer = get_node_or_null("Timer") as Timer

	if _is_active:
		if not enabled:
			return
		_schedule_next_event(initial_min_pause, initial_max_pause)
	else:
		_stop_effects()


func is_active() -> bool:
	return _is_active


func _resolve_sprite() -> AnimatedSprite2D:
	if _cached_sprite != null and is_instance_valid(_cached_sprite):
		return _cached_sprite

	if not animated_sprite_path.is_empty():
		_cached_sprite = get_node_or_null(animated_sprite_path) as AnimatedSprite2D

	if _cached_sprite == null:
		_cached_sprite = get_node_or_null("../Visual") as AnimatedSprite2D

	if _cached_sprite != null:
		if not _cached_sprite.animation_finished.is_connected(_on_animation_finished):
			_cached_sprite.animation_finished.connect(_on_animation_finished)

	return _cached_sprite


func _schedule_next_event(min_delay: float, max_delay: float) -> void:
	if not _is_active or _timer == null or not enabled:
		return
	var delay := _rng.randf_range(min_delay, max_delay)
	_timer.start(delay)


func _choose_animation(sprite: AnimatedSprite2D) -> StringName:
	if sprite == null or sprite.sprite_frames == null:
		return &""

	var frames := sprite.sprite_frames

	# If animation_names is empty, use the legacy animation_name
	if animation_names.is_empty():
		if frames.has_animation(animation_name) and frames.get_frame_count(animation_name) > 0:
			return animation_name
		return &""

	# Filter valid candidates from animation_names
	var valid_candidates: Array[StringName] = []
	var valid_weights: Array[float] = []
	var total_weight: float = 0.0

	for i in range(animation_names.size()):
		var anim: StringName = animation_names[i]
		if frames.has_animation(anim) and frames.get_frame_count(anim) > 0:
			var weight: float = 1.0
			if i < animation_weights.size() and animation_weights[i] > 0.0:
				weight = animation_weights[i]
			valid_candidates.append(anim)
			valid_weights.append(weight)
			total_weight += weight

	if valid_candidates.is_empty():
		return &""

	if valid_candidates.size() == 1:
		return valid_candidates[0]

	if total_weight <= 0.0:
		return valid_candidates[0]

	var roll := _rng.randf_range(0.0, total_weight)
	var cumulative: float = 0.0
	for i in range(valid_candidates.size()):
		cumulative += valid_weights[i]
		if roll <= cumulative:
			return valid_candidates[i]

	return valid_candidates[valid_candidates.size() - 1]


func _on_timer_timeout() -> void:
	if not _is_active or not enabled:
		return

	var sprite := _resolve_sprite()
	if sprite == null or sprite.sprite_frames == null:
		return

	var chosen_animation := _choose_animation(sprite)
	if chosen_animation.is_empty():
		return

	_current_animation = chosen_animation

	if not _warned_loops.has(_current_animation) and sprite.sprite_frames.get_animation_loop(_current_animation):
		_warned_loops[_current_animation] = true
		push_warning("IntermittentDetailAnimation: animation '%s' has loop=true in SpriteFrames. Should be loop=false!" % _current_animation)

	var speed := _rng.randf_range(playback_speed_min, playback_speed_max)
	sprite.speed_scale = speed
	sprite.animation = _current_animation
	sprite.frame = 0
	sprite.frame_progress = 0.0
	sprite.play(_current_animation)


func _on_animation_finished() -> void:
	var sprite := _resolve_sprite()
	if sprite != null:
		sprite.stop()
		if reset_to_first_frame_on_stop and not _current_animation.is_empty():
			if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(_current_animation):
				sprite.animation = _current_animation
			sprite.frame = 0
			sprite.frame_progress = 0.0

	if not _is_active or not enabled:
		return

	_schedule_next_event(min_pause, max_pause)


func _stop_effects() -> void:
	if _timer != null:
		_timer.stop()

	var sprite := _resolve_sprite()
	if sprite != null:
		if sprite.is_playing():
			sprite.stop()
		if reset_to_first_frame_on_stop:
			var target_anim := _current_animation
			if target_anim.is_empty():
				target_anim = animation_name
			if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(target_anim):
				sprite.animation = target_anim
			sprite.frame = 0
			sprite.frame_progress = 0.0
			sprite.speed_scale = 1.0

	_current_animation = &""
