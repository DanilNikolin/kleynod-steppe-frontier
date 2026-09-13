class_name ConstructionAmbient
extends Node2D


@export var min_pause: float = 2.5
@export var max_pause: float = 6.5
@export var initial_min_pause: float = 1.0
@export var initial_max_pause: float = 3.0

@export var fine_dust_emitter: CPUParticles2D
@export var wood_specks_emitter: CPUParticles2D

var _timer: Timer
var _rng: RandomNumberGenerator
var _is_active: bool = false


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	if fine_dust_emitter == null:
		fine_dust_emitter = get_node_or_null("FineDust") as CPUParticles2D
	if wood_specks_emitter == null:
		wood_specks_emitter = get_node_or_null("WoodSpecks") as CPUParticles2D

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
		_schedule_next_event(initial_min_pause, initial_max_pause)
	else:
		_stop_effects()


func is_active() -> bool:
	return _is_active


func _schedule_next_event(min_delay: float, max_delay: float) -> void:
	if not _is_active or _timer == null:
		return
	var delay := _rng.randf_range(min_delay, max_delay)
	_timer.start(delay)


func _on_timer_timeout() -> void:
	if not _is_active:
		return

	_trigger_micro_event()
	_schedule_next_event(min_pause, max_pause)


func _trigger_micro_event() -> void:
	var roll := _rng.randf()
	var offset := Vector2(
		_rng.randf_range(-12.0, 12.0),
		_rng.randf_range(-6.0, 6.0)
	)

	# 60%: FineDust, 25%: WoodSpecks, 15%: FineDust + WoodSpecks
	if roll < 0.60:
		_emit_dust(offset)
	elif roll < 0.85:
		_emit_wood(offset)
	else:
		_emit_dust(offset)
		_emit_wood(offset)


func _emit_dust(offset: Vector2) -> void:
	if fine_dust_emitter != null:
		fine_dust_emitter.position = offset
		fine_dust_emitter.restart()
		fine_dust_emitter.emitting = true


func _emit_wood(offset: Vector2) -> void:
	if wood_specks_emitter != null:
		wood_specks_emitter.position = offset
		wood_specks_emitter.restart()
		wood_specks_emitter.emitting = true


func _stop_effects() -> void:
	if _timer != null:
		_timer.stop()
	if fine_dust_emitter != null:
		fine_dust_emitter.emitting = false
	if wood_specks_emitter != null:
		wood_specks_emitter.emitting = false
