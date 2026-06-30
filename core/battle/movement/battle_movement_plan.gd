class_name BattleMovementPlan
extends RefCounted


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)


var is_valid: bool = false
var failure_code: StringName = &""

var combatant_id: StringName = &""

var start_coordinate: Vector2i = INVALID_COORDINATE
var target_coordinate: Vector2i = INVALID_COORDINATE

var path: Array[Vector2i] = []

var stamina_cost_per_step: int = 1
var stamina_cost: int = 0


func get_step_count() -> int:
	return path.size()


func has_path() -> bool:
	return not path.is_empty()


func clear() -> void:
	is_valid = false
	failure_code = &""

	combatant_id = &""

	start_coordinate = INVALID_COORDINATE
	target_coordinate = INVALID_COORDINATE

	path.clear()

	stamina_cost_per_step = 1
	stamina_cost = 0