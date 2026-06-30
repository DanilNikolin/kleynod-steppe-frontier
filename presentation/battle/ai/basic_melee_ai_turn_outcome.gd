class_name BasicMeleeAITurnOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var target_id: StringName = &""

var movement_outcome: BattleMovementOutcome

# Последний выполненный результат оставляем
# для совместимости с существующим кодом.
var action_outcome: BattleActionOutcome

var action_outcomes: Array[BattleActionOutcome] = []


func did_move() -> bool:
	return (
		movement_outcome != null
		and movement_outcome.did_move()
	)


func get_movement_step_count() -> int:
	if movement_outcome == null:
		return 0

	return movement_outcome.get_step_count()


func add_action_outcome(
	outcome: BattleActionOutcome
) -> void:
	if outcome == null:
		return

	action_outcomes.append(
		outcome
	)

	action_outcome = outcome


func did_attack() -> bool:
	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_execute()
		):
			return true

	return false


func get_attack_count() -> int:
	var result: int = 0

	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_execute()
		):
			result += 1

	return result


func get_damage_dealt() -> int:
	var result: int = 0

	for outcome in action_outcomes:
		if outcome == null:
			continue

		result += outcome.get_total_applied_amount(
			&"damage"
		)

	return result


func did_target_die() -> bool:
	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_target_die()
		):
			return true

	return false