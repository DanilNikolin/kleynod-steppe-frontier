@tool
class_name BattleEnvironment
extends Node2D

## All world layers share one canvas. Absolute Z lets environment children
## interleave with BattleScreen layers despite having different parents.
const LAYER_Z: Dictionary = {
	&"BackgroundLayer": -400,
	&"GroundLayer": -300,
	&"BackAtmosphereLayer": -200,
	&"ForegroundLayer": 400,
	&"FrontAtmosphereLayer": 500,
	&"LightingLayer": 600,
}


func _enter_tree() -> void:
	for layer_name in LAYER_Z:
		var layer := get_node_or_null(NodePath(layer_name)) as Node2D
		if layer != null:
			layer.z_as_relative = false
			layer.z_index = LAYER_Z[layer_name]


func get_arena_layout() -> BattleArenaLayout:
	return get_node_or_null("ArenaLayout") as BattleArenaLayout


func get_validation_errors(grid_size: Vector2i = Vector2i(6, 3)) -> PackedStringArray:
	var errors := PackedStringArray()
	if get_arena_layout() == null:
		errors.append("BattleEnvironment requires a BattleArenaLayout named ArenaLayout.")
	else:
		errors.append_array(get_arena_layout().get_validation_errors(grid_size))
	for layer_name in LAYER_Z:
		var layer := get_node_or_null(NodePath(layer_name))
		if layer != null and not layer is Node2D:
			errors.append("%s must be a Node2D world layer." % layer_name)
	return errors
