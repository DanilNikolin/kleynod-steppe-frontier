class_name BattleActionOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var command: BattleActionCommand
var action_result: BattleActionResult

var action_presented: bool = false
var defeated_view_removed: bool = false


func did_execute() -> bool:
	return (
		action_result != null
		and action_result.is_successful
	)


func get_total_applied_amount(
	effect_kind: StringName = &""
) -> int:
	if action_result == null:
		return 0

	return action_result.get_total_applied_amount(
		effect_kind
	)


func did_target_die() -> bool:
	return (
		action_result != null
		and action_result.did_target_die()
	)