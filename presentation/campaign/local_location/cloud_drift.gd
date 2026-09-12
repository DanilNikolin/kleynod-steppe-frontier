class_name CloudDrift
extends Sprite2D


@export var speed_x: float = 6.0

@export var vertical_amplitude: float = 8.0
@export var vertical_period: float = 30.0
@export var phase_offset: float = 0.0

@export var spawn_marker: Marker2D
@export var despawn_marker: Marker2D

@export var despawn_margin: float = 250.0
@export var respawn_x_variation: float = 600.0

@export var respawn_y_min: float = 80.0
@export var respawn_y_max: float = 460.0

@export_range(0.0, 0.3, 0.01)
var speed_variation: float = 0.08

@export var scale_variation_min: float = 0.95
@export var scale_variation_max: float = 1.05


var _base_y: float
var _base_scale: Vector2
var _elapsed: float = 0.0
var _current_speed: float

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_base_y = position.y
	_base_scale = scale

	_elapsed = phase_offset
	_current_speed = speed_x

	_rng.randomize()


func _process(delta: float) -> void:
	_elapsed += delta

	position.x += _current_speed * delta

	var safe_period := maxf(
		vertical_period,
		0.1
	)

	position.y = (
		_base_y
		+ sin(
			(_elapsed / safe_period) * TAU
		) * vertical_amplitude
	)

	if despawn_marker != null:
		var half_width := 0.0
		if texture != null:
			half_width = texture.get_width() * absf(scale.x) * 0.5

		if (position.x - half_width) > (despawn_marker.position.x + despawn_margin):
			_respawn_cloud()


func _respawn_cloud() -> void:
	var half_width := 0.0
	if texture != null:
		half_width = texture.get_width() * absf(scale.x) * 0.5

	var spawn_x := -800.0
	if spawn_marker != null:
		spawn_x = spawn_marker.position.x

	position.x = spawn_x - half_width - _rng.randf_range(0.0, respawn_x_variation)

	_base_y = _rng.randf_range(
		respawn_y_min,
		respawn_y_max
	)

	_current_speed = (
		speed_x
		* _rng.randf_range(
			1.0 - speed_variation,
			1.0 + speed_variation
		)
	)

	var scale_factor := _rng.randf_range(
		scale_variation_min,
		scale_variation_max
	)

	scale = _base_scale * scale_factor
