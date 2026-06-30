class_name BattleGridCell
extends RefCounted


const EMPTY_ID: StringName = &""


var coordinate: Vector2i
var occupant_id: StringName = EMPTY_ID
var obstacle_id: StringName = EMPTY_ID
var surface_effect_ids: Array[StringName] = []


func _init(p_coordinate: Vector2i) -> void:
	coordinate = p_coordinate


func is_occupied() -> bool:
	return occupant_id != EMPTY_ID


func has_obstacle() -> bool:
	return obstacle_id != EMPTY_ID


func is_walkable() -> bool:
	return not is_occupied() and not has_obstacle()


func has_surface_effect(effect_id: StringName) -> bool:
	return surface_effect_ids.has(effect_id)


func add_surface_effect(effect_id: StringName) -> bool:
	if effect_id == EMPTY_ID:
		return false

	if surface_effect_ids.has(effect_id):
		return false

	surface_effect_ids.append(effect_id)
	return true


func remove_surface_effect(effect_id: StringName) -> bool:
	var effect_index: int = surface_effect_ids.find(effect_id)

	if effect_index == -1:
		return false

	surface_effect_ids.remove_at(effect_index)
	return true


func clear() -> void:
	occupant_id = EMPTY_ID
	obstacle_id = EMPTY_ID
	surface_effect_ids.clear()