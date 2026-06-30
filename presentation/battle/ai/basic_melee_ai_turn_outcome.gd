class_name BasicMeleeAITurnOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var target_id: StringName = &""

var movement_outcome: BattleMovementOutcome
var action_outcome: BattleActionOutcome


func did_move() -> bool:
	return (
		movement_outcome != null
		and movement_outcome.did_move()
	)


func get_movement_step_count() -> int:
	if movement_outcome == null:
		return 0

	return movement_outcome.get_step_count()


func did_attack() -> bool:
	return (
		action_outcome != null
		and action_outcome.did_execute()
	)


func get_damage_dealt() -> int:
	if action_outcome == null:
		return 0

	return action_outcome.get_total_applied_amount(
		&"damage"
	)


func did_target_die() -> bool:
	return (
		action_outcome != null
		and action_outcome.did_target_die()
	)