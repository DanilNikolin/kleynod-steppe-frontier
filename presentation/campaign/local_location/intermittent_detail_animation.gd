class_name IntermittentDetailAnimation
extends Node


@export var animation_player: AnimationPlayer
@export var animation_name: StringName = &"idle"

@export var initial_min_pause: float = 0.5
@export var initial_max_pause: float = 2.5

@export var min_pause: float = 1.5
@export var max_pause: float = 5.0

@export var playback_speed_min: float = 0.9
@export var playback_speed_max: float = 1.1

@export var enabled: bool = true

var _timer: Timer
var _rng: RandomNumberGenerator
var _is_active: bool = false


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	if animation_player == null:
		animation_player = get_node_or_null("../AnimationPlayer") as AnimationPlayer

	_timer = get_node_or_null("Timer") as Timer
	if _timer == null:
		_timer = Timer.new()
		_timer.name = "Timer"
		_timer.one_shot = true
		add_child(_timer)

	if not _timer.timeout.is_connected(_on_timer_timeout):
		_timer.timeout.connect(_on_timer_timeout)


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


func _schedule_next_event(min_delay: float, max_delay: float) -> void:
	if not _is_active or _timer == null or not enabled:
		return
	var delay := _rng.randf_range(min_delay, max_delay)
	_timer.start(delay)


func _on_timer_timeout() -> void:
	if not _is_active or not enabled:
		return

	if animation_player != null and animation_player.has_animation(animation_name):
		var speed := _rng.randf_range(playback_speed_min, playback_speed_max)
		animation_player.speed_scale = speed

		if animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.disconnect(_on_animation_finished)
		animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

		animation_player.play(animation_name)
	else:
		# If animation_player is missing or doesn't have animation, just schedule next
		_schedule_next_event(min_pause, max_pause)


func _on_animation_finished(_anim: StringName) -> void:
	if not _is_active or not enabled:
		return
	_reset_to_rest_state()
	_schedule_next_event(min_pause, max_pause)


func _stop_effects() -> void:
	if _timer != null:
		_timer.stop()

	if animation_player != null:
		if animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.disconnect(_on_animation_finished)
		if animation_player.is_playing():
			animation_player.stop()
		_reset_to_rest_state()


func _reset_to_rest_state() -> void:
	if animation_player == null:
		return

	if animation_player.has_animation(&"RESET"):
		animation_player.play(&"RESET")
		animation_player.advance(0.0)
		animation_player.stop()
	elif animation_player.has_animation(animation_name):
		animation_player.seek(0.0, true)
