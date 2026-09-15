class_name AmbientFlickerLight
extends Node2D

@export var light_path: NodePath

@export_range(0.0, 4.0, 0.01)
var base_energy: float = 0.40

@export_range(0.0, 1.0, 0.01)
var flicker_strength: float = 0.07

@export_range(0.1, 30.0, 0.1)
var flicker_speed: float = 6.5

@export_range(0.0, 1.0, 0.01)
var secondary_flicker_strength: float = 0.35

var _light: PointLight2D
var _time: float = 0.0


func _ready() -> void:
	if not light_path.is_empty():
		_light = get_node_or_null(light_path) as PointLight2D

	if _light != null:
		# If user adjusted energy directly on the PointLight2D node and not on controller, use node energy
		if _light.energy != 1.0 and base_energy == 0.40:
			base_energy = _light.energy


func _process(delta: float) -> void:
	if _light == null:
		return

	if not is_visible_in_tree():
		_light.enabled = false
		return

	_light.enabled = true
	_time += delta

	var flicker := (
		sin(_time * flicker_speed) * flicker_strength
		+ sin(_time * flicker_speed * 1.73) * (flicker_strength * secondary_flicker_strength)
	)

	_light.energy = maxf(0.0, base_energy + flicker)

