class_name BattleCameraDirector
extends Node


enum ImpactStrength {
	WEAK,
	MEDIUM,
	STRONG,
}


@export var camera_path: NodePath = ^"../BattleCamera"

@export var environment_host_path: NodePath = (
	^"../BattleWorld/EnvironmentHost"
)

@export_group("Impact Motion")

@export_range(0.0, 1.0, 0.05)
var vertical_motion_ratio: float = 0.45

@export_range(1.0, 4.0, 0.1)
var decay_power: float = 2.2


var camera: Camera2D


var _rest_offset: Vector2
var _rest_zoom: Vector2
var _rest_transform: Transform2D

var _zoom_tween: Tween


var _impact_active: bool = false
var _impact_elapsed: float = 0.0

var _impact_duration: float = 0.0
var _impact_oscillations: float = 0.0

var _camera_amplitude: float = 0.0
var _background_amplitude: float = 0.0
var _ground_amplitude: float = 0.0

var _camera_zoom_amount: float = 0.0

var _background_scale_amount: float = 0.0
var _ground_scale_amount: float = 0.0

var _impact_direction: Vector2 = Vector2.RIGHT


var _background_layer: Node2D
var _ground_layer: Node2D

var _background_rest_position: Vector2
var _background_rest_scale: Vector2

var _ground_rest_position: Vector2
var _ground_rest_scale: Vector2


func _ready() -> void:
	camera = get_node(camera_path) as Camera2D

	_rest_offset = camera.offset
	_rest_zoom = camera.zoom
	_rest_transform = camera.transform


func impact_shake(
	strength: int = ImpactStrength.WEAK,
	direction: Vector2 = Vector2.RIGHT
) -> void:
	var profile := _get_impact_profile(
		strength
	)

	_start_impact(
		float(profile["duration"]),
		float(profile["oscillations"]),
		float(profile["camera_amplitude"]),
		float(profile["background_amplitude"]),
		float(profile["ground_amplitude"]),
		float(profile["camera_zoom"]),
		float(profile["background_scale"]),
		float(profile["ground_scale"]),
		direction
	)


func impact_shake_weak() -> void:
	impact_shake(
		ImpactStrength.WEAK
	)


func impact_shake_medium() -> void:
	impact_shake(
		ImpactStrength.MEDIUM
	)


func impact_shake_strong() -> void:
	impact_shake(
		ImpactStrength.STRONG
	)


func _get_impact_profile(
	strength: int
) -> Dictionary:
	match strength:
		ImpactStrength.MEDIUM:
			return {
				"duration": 0.18,
				"oscillations": 2.75,
				"camera_amplitude": 3.0,
				"background_amplitude": 6.0,
				"ground_amplitude": 14.0,
				"camera_zoom": 0.009,
				"background_scale": -0.003,
				"ground_scale": 0.008,
			}

		ImpactStrength.STRONG:
			return {
				"duration": 0.28,
				"oscillations": 3.25,
				"camera_amplitude": 5.0,
				"background_amplitude": 10.0,
				"ground_amplitude": 24.0,
				"camera_zoom": 0.016,
				"background_scale": -0.005,
				"ground_scale": 0.014,
			}

		_:
			return {
				"duration": 0.12,
				"oscillations": 2.25,
				"camera_amplitude": 1.5,
				"background_amplitude": 3.0,
				"ground_amplitude": 7.0,
				"camera_zoom": 0.004,
				"background_scale": -0.0015,
				"ground_scale": 0.004,
			}


func _start_impact(
	duration: float,
	oscillations: float,
	camera_amplitude: float,
	background_amplitude: float,
	ground_amplitude: float,
	camera_zoom_amount: float,
	background_scale_amount: float,
	ground_scale_amount: float,
	direction: Vector2
) -> void:
	# Never capture an already-shaken transform as
	# the new rest state.
	_restore_impact_state()

	if _zoom_tween != null:
		_zoom_tween.kill()
		_zoom_tween = null

	if is_instance_valid(camera):
		camera.offset = _rest_offset
		camera.zoom = _rest_zoom

	_resolve_environment_layers()
	_capture_environment_rest_state()

	var resolved_direction := direction

	if resolved_direction.length_squared() < 0.0001:
		resolved_direction = Vector2.RIGHT

	_impact_direction = (
		resolved_direction.normalized()
	)

	_impact_duration = maxf(
		duration,
		0.001
	)

	_impact_oscillations = maxf(
		oscillations,
		0.1
	)

	_camera_amplitude = maxf(
		camera_amplitude,
		0.0
	)

	_background_amplitude = maxf(
		background_amplitude,
		0.0
	)

	_ground_amplitude = maxf(
		ground_amplitude,
		0.0
	)

	_camera_zoom_amount = maxf(
		camera_zoom_amount,
		0.0
	)

	_background_scale_amount = (
		background_scale_amount
	)

	_ground_scale_amount = (
		ground_scale_amount
	)

	_impact_elapsed = 0.0
	_impact_active = true


func _resolve_environment_layers() -> void:
	_background_layer = null
	_ground_layer = null

	var host := get_node_or_null(
		environment_host_path
	)

	if host == null:
		return

	var environment: BattleEnvironment

	for child in host.get_children():
		if child is BattleEnvironment:
			environment = child
			break

	if environment == null:
		return

	_background_layer = (
		environment.get_node_or_null(
			^"BackgroundLayer"
		)
		as Node2D
	)

	_ground_layer = (
		environment.get_node_or_null(
			^"GroundLayer"
		)
		as Node2D
	)


func _capture_environment_rest_state() -> void:
	if is_instance_valid(
		_background_layer
	):
		_background_rest_position = (
			_background_layer.position
		)

		_background_rest_scale = (
			_background_layer.scale
		)

	if is_instance_valid(
		_ground_layer
	):
		_ground_rest_position = (
			_ground_layer.position
		)

		_ground_rest_scale = (
			_ground_layer.scale
		)


func _process(delta: float) -> void:
	if not _impact_active:
		return

	_impact_elapsed = minf(
		_impact_elapsed + delta,
		_impact_duration
	)

	var progress := clampf(
		_impact_elapsed
		/ _impact_duration,
		0.0,
		1.0
	)

	# Fast damping.
	# Big first punch -> rapidly decreasing follow-up oscillation.
	var envelope: float = pow(
		1.0 - progress,
		decay_power
	)

	var phase := (
		progress
		* TAU
		* _impact_oscillations
	)

	# Deterministic oscillation instead of noisy random jitter.
	var primary_wave := cos(
		phase
	)

	var secondary_wave := sin(
		phase * 0.83 + 0.7
	)

	var perpendicular := Vector2(
		-_impact_direction.y,
		_impact_direction.x
	)

	var motion := (
		_impact_direction
		* primary_wave
		+ perpendicular
		* secondary_wave
		* vertical_motion_ratio
	)

	# One soft zoom/depth pulse:
	# 0 -> peak -> 0.
	var depth_pulse := sin(
		progress * PI
	)

	if is_instance_valid(camera):
		camera.offset = (
			_rest_offset
			+ motion
			* _camera_amplitude
			* envelope
		)

		var camera_zoom_factor := (
			1.0
			+ _camera_zoom_amount
			* depth_pulse
		)

		camera.zoom = (
			_rest_zoom
			* camera_zoom_factor
		)

	if is_instance_valid(
		_background_layer
	):
		_background_layer.position = (
			_background_rest_position
			+ motion
			* _background_amplitude
			* envelope
		)

		var background_scale_factor := maxf(
			0.9,
			1.0
			+ _background_scale_amount
			* depth_pulse
		)

		_background_layer.scale = Vector2(
			_background_rest_scale.x
			* background_scale_factor,
			_background_rest_scale.y
			* background_scale_factor
		)

	if is_instance_valid(
		_ground_layer
	):
		_ground_layer.position = (
			_ground_rest_position
			+ motion
			* _ground_amplitude
			* envelope
		)

		var ground_scale_factor := maxf(
			0.9,
			1.0
			+ _ground_scale_amount
			* depth_pulse
		)

		_ground_layer.scale = Vector2(
			_ground_rest_scale.x
			* ground_scale_factor,
			_ground_rest_scale.y
			* ground_scale_factor
		)

	if progress >= 1.0:
		_restore_impact_state()


func _restore_impact_state() -> void:
	_impact_active = false
	_impact_elapsed = 0.0

	if is_instance_valid(camera):
		camera.offset = _rest_offset
		camera.zoom = _rest_zoom

	if is_instance_valid(
		_background_layer
	):
		_background_layer.position = (
			_background_rest_position
		)

		_background_layer.scale = (
			_background_rest_scale
		)

	if is_instance_valid(
		_ground_layer
	):
		_ground_layer.position = (
			_ground_rest_position
		)

		_ground_layer.scale = (
			_ground_rest_scale
		)

	# Release restored layers so the next impact captures their current authored state.
	_background_layer = null
	_ground_layer = null


# Keep old public API for compatibility.
# It now resolves into the new layered impact system.
func shake(
	strength: float = 8.0,
	duration: float = 0.25
) -> void:
	var normalized_strength := clampf(
		strength / 8.0,
		0.0,
		3.0
	)

	_start_impact(
		maxf(duration, 0.001),
		2.5,
		1.5 * normalized_strength,
		3.0 * normalized_strength,
		7.0 * normalized_strength,
		0.004 * normalized_strength,
		-0.0015 * normalized_strength,
		0.004 * normalized_strength,
		Vector2.RIGHT
	)


# Keep for compatibility.
# Do not combine it automatically with impact_shake.
func push_zoom(
	factor: float = 1.04,
	duration: float = 0.3
) -> void:
	_restore_impact_state()

	if _zoom_tween != null:
		_zoom_tween.kill()

	camera.zoom = _rest_zoom

	_zoom_tween = create_tween()

	_zoom_tween.tween_property(
		camera,
		"zoom",
		_rest_zoom
		* clampf(
			factor,
			0.5,
			2.0
		),
		duration * 0.3
	)

	_zoom_tween.tween_property(
		camera,
		"zoom",
		_rest_zoom,
		duration * 0.7
	)


func reset() -> void:
	if _zoom_tween != null:
		_zoom_tween.kill()
		_zoom_tween = null

	_restore_impact_state()
	if is_instance_valid(camera):
		camera.transform = _rest_transform


func _exit_tree() -> void:
	reset()
