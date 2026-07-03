class_name BattleMovementOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var combatant_id: StringName = &""
var movement_plan: BattleMovementPlan
var relocation_result: BattleRelocationResult

var movement_committed: bool = false
var movement_presented: bool = false


func did_move() -> bool:
	if (
		is_successful
		and relocation_result != null
		and relocation_result.is_successful
	):
		return true

	return (
		is_successful
		and movement_plan != null
		and movement_committed
		and movement_plan.has_path()
	)


func get_step_count() -> int:
	if (
		relocation_result != null
		and relocation_result.is_swap()
		and relocation_result.is_successful
	):
		return 1

	if movement_plan == null:
		return 0

	return movement_plan.get_step_count()


func did_swap() -> bool:
	return (
		is_successful
		and relocation_result != null
		and relocation_result.is_successful
		and relocation_result.is_swap()
	)