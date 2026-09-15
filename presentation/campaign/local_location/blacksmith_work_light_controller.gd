class_name BlacksmithWorkLightController
extends Node2D

@export var animated_sprite_path: NodePath
@export var light_path: NodePath

@export var active_animation_name: StringName = &"work"

@export_range(0.0, 4.0, 0.01)
var base_energy: float = 0.45

@export_range(0.0, 1.0, 0.01)
var flicker_strength: float = 0.06

@export_range(0.1, 30.0, 0.1)
var flicker_speed: float = 8.0

# Future hammer-hit pulse controls.

@export var impact_frames: PackedInt32Array = PackedInt32Array()

@export_range(0.0, 4.0, 0.01)
var impact_energy_boost: float = 0.0

@export_range(0.01, 1.0, 0.01)
var impact_fade_time: float = 0.10

var _sprite: AnimatedSprite2D
var _light: PointLight2D

var _current_impact: float = 0.0
var _last_frame: int = -1
var _time: float = 0.0


func _ready() -> void:
	if not animated_sprite_path.is_empty():
		_sprite = get_node_or_null(animated_sprite_path) as AnimatedSprite2D
	if not light_path.is_empty():
		_light = get_node_or_null(light_path) as PointLight2D

	if _light != null:
		_light.enabled = false


func _process(delta: float) -> void:
	if _sprite == null or _light == null:
		return

	var is_working := (
		_sprite.animation == active_animation_name
		and (_sprite.is_playing() or (_sprite.sprite_frames != null and _sprite.sprite_frames.get_frame_count(active_animation_name) == 0))
	)

	if not is_working:
		_light.enabled = false
		_current_impact = 0.0
		_last_frame = -1
		return

	_light.enabled = true
	_time += delta

	# Impact frame handling
	var current_frame := _sprite.frame
	if current_frame != _last_frame:
		_last_frame = current_frame
		if impact_frames.has(current_frame):
			_current_impact = impact_energy_boost

	if _current_impact > 0.0:
		if impact_fade_time > 0.0:
			_current_impact = maxf(0.0, _current_impact - (impact_energy_boost / impact_fade_time) * delta)
		else:
			_current_impact = 0.0

	var flicker := (
		sin(_time * flicker_speed) * flicker_strength
		+ sin(_time * flicker_speed * 1.7) * (flicker_strength * 0.35)
	)

	_light.energy = maxf(0.0, base_energy + flicker + _current_impact)
