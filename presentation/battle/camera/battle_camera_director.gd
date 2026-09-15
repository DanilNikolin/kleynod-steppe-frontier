class_name BattleCameraDirector
extends Node

@export var camera_path: NodePath = ^"../BattleCamera"

var camera: Camera2D
var _rest_offset: Vector2
var _rest_zoom: Vector2
var _rest_transform: Transform2D
var _shake_remaining: float = 0.0
var _shake_duration: float = 0.0
var _shake_strength: float = 0.0
var _zoom_tween: Tween
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	camera = get_node(camera_path) as Camera2D
	_rest_offset = camera.offset
	_rest_zoom = camera.zoom
	_rest_transform = camera.transform


func shake(strength: float = 8.0, duration: float = 0.25) -> void:
	_shake_strength = maxf(strength, 0)
	_shake_duration = maxf(duration, 0.001)
	_shake_remaining = _shake_duration


func impact_shake() -> void:
	shake(5.0, 0.16)


func push_zoom(factor: float = 1.04, duration: float = 0.3) -> void:
	if _zoom_tween != null:
		_zoom_tween.kill()
	camera.zoom = _rest_zoom
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(camera, "zoom", _rest_zoom * clampf(factor, 0.5, 2.0), duration * 0.3)
	_zoom_tween.tween_property(camera, "zoom", _rest_zoom, duration * 0.7)


func reset() -> void:
	_shake_remaining = 0
	if _zoom_tween != null:
		_zoom_tween.kill()
	if is_instance_valid(camera):
		camera.offset = _rest_offset
		camera.zoom = _rest_zoom
		camera.transform = _rest_transform


func _process(delta: float) -> void:
	if _shake_remaining <= 0:
		return
	_shake_remaining = maxf(0, _shake_remaining - delta)
	var strength := _shake_strength * _shake_remaining / _shake_duration
	camera.offset = _rest_offset + Vector2(_rng.randf_range(-strength, strength), _rng.randf_range(-strength, strength))


func _exit_tree() -> void:
	reset()
