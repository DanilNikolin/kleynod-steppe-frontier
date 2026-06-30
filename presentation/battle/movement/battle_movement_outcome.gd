class_name BattleMovementOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var combatant_id: StringName = &""
var movement_plan: BattleMovementPlan

var movement_committed: bool = false
var movement_presented: bool = false


func did_move() -> bool:
	return (
		is_successful
		and movement_plan != null
		and movement_committed
		and movement_plan.has_path()
	)


func get_step_count() -> int:
	if movement_plan == null:
		return 0

	return movement_plan.get_step_count()