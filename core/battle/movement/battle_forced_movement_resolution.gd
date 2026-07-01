class_name BattleForcedMovementResolution
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var origin: Vector2i = BattleGrid.INVALID_COORDINATE
var destination: Vector2i = BattleGrid.INVALID_COORDINATE
var direction: Vector2i = Vector2i.ZERO

var requested_distance: int = 0
var path: Array[Vector2i] = []

var was_blocked: bool = false
var block_reason: StringName = &""


func get_applied_distance() -> int:
	return path.size()