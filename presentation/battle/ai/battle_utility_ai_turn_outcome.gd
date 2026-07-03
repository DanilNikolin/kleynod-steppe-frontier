class_name BattleUtilityAITurnOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""

var stop_reason: StringName = &""

var planning_reports: Array[BattleAIPlanningReport] = []
var executed_plans: Array[BattleAIPlan] = []

var movement_outcomes: Array[BattleMovementOutcome] = []
var action_outcomes: Array[BattleActionOutcome] = []


func add_planning_report(
	report: BattleAIPlanningReport
) -> void:
	if report == null:
		return

	planning_reports.append(
		report
	)


func add_executed_plan(
	plan: BattleAIPlan
) -> void:
	if plan == null:
		return

	executed_plans.append(
		plan
	)


func add_movement_outcome(
	outcome: BattleMovementOutcome
) -> void:
	if outcome == null:
		return

	movement_outcomes.append(
		outcome
	)


func add_action_outcome(
	outcome: BattleActionOutcome
) -> void:
	if outcome == null:
		return

	action_outcomes.append(
		outcome
	)


func did_move() -> bool:
	for outcome in movement_outcomes:
		if (
			outcome != null
			and outcome.did_move()
		):
			return true

	return false


func did_act() -> bool:
	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_execute()
		):
			return true

	return false


func did_anything() -> bool:
	return did_move() or did_act()


func get_movement_step_count() -> int:
	var result := 0

	for outcome in movement_outcomes:
		if outcome == null:
			continue

		result += outcome.get_step_count()

	return result


func get_action_count() -> int:
	var result := 0

	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_execute()
		):
			result += 1

	return result


func get_damage_dealt() -> int:
	var result := 0

	for outcome in action_outcomes:
		if outcome == null:
			continue

		result += outcome.get_total_applied_amount(
			&"damage"
		)

	return result


func did_kill_target() -> bool:
	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_target_die()
		):
			return true

	return false


func get_last_executed_plan() -> BattleAIPlan:
	var index := executed_plans.size() - 1

	while index >= 0:
		var plan := executed_plans[index]

		if plan != null:
			return plan

		index -= 1

	return null


func get_last_action_plan() -> BattleAIPlan:
	var index := executed_plans.size() - 1

	while index >= 0:
		var plan := executed_plans[index]

		if plan != null and plan.has_action():
			return plan

		index -= 1

	return null


func get_last_score() -> float:
	var plan := get_last_executed_plan()

	if plan == null:
		return 0.0

	return plan.get_score()