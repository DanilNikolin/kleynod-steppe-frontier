class_name BattleTargetingResult
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var ability_id: StringName = &""

var origin_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var affected_coordinates: Array[Vector2i] = []
var affected_combatants: Array[CombatantState] = []


func get_primary_target() -> CombatantState:
	if affected_combatants.is_empty():
		return null

	return affected_combatants[0]


func get_primary_target_id() -> StringName:
	var target := get_primary_target()

	if target == null:
		return &""

	return target.instance_id