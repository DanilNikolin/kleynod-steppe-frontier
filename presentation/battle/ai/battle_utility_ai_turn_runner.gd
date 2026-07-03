class_name BattleUtilityAITurnRunner
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_ACTOR: StringName = (
	&"invalid_actor"
)

const FAILURE_INVALID_PLAN_GENERATOR: StringName = (
	&"invalid_plan_generator"
)

const FAILURE_INVALID_MOVEMENT_RUNNER: StringName = (
	&"invalid_movement_runner"
)

const FAILURE_INVALID_ACTION_RUNNER: StringName = (
	&"invalid_action_runner"
)

const FAILURE_PLANNING_FAILED: StringName = (
	&"planning_failed"
)

const FAILURE_ACTION_LIMIT_REACHED: StringName = (
	&"utility_action_limit_reached"
)

const FAILURE_MOVEMENT_FAILED: StringName = (
	&"utility_movement_failed"
)

const FAILURE_ALLY_SWAP_TARGET_MISSING: StringName = (
	&"utility_ally_swap_target_missing"
)

const FAILURE_ALLY_SWAP_FAILED: StringName = (
	&"utility_ally_swap_failed"
)

const FAILURE_ACTION_FAILED: StringName = (
	&"utility_action_failed"
)


const STOP_NO_PLAN: StringName = &"no_plan"
const STOP_WAIT: StringName = &"wait"
const STOP_NO_USEFUL_PLAN: StringName = &"no_useful_plan"
const STOP_ACTOR_DEFEATED: StringName = &"actor_defeated"
const STOP_NO_PROGRESS: StringName = &"no_progress"

const STOP_LOW_VALUE_AFTER_ACTION: StringName = (
	&"low_value_after_action"
)


const MAX_ATOMIC_PLANS_PER_TURN: int = 64
const MIN_USEFUL_SCORE: float = 0.0
const MIN_USEFUL_SCORE_AFTER_ACTION: float = 8.0


var plan_generator: BattleAIPlanGenerator
var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner


func _init(
	p_plan_generator: BattleAIPlanGenerator,
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner
) -> void:
	assert(
		p_plan_generator != null,
		"BattleUtilityAITurnRunner requires "
		+"a plan generator."
	)

	assert(
		p_movement_runner != null,
		"BattleUtilityAITurnRunner requires "
		+"a movement runner."
	)

	assert(
		p_action_runner != null,
		"BattleUtilityAITurnRunner requires "
		+"an action runner."
	)

	plan_generator = p_plan_generator
	movement_runner = p_movement_runner
	action_runner = p_action_runner


func execute(
	session: BattleSession,
	actor: CombatantState,
	stamina_cost_per_step: int = 1,
	animate_movement: bool = true,
	animate_action: bool = true
) -> BattleUtilityAITurnOutcome:
	var outcome := BattleUtilityAITurnOutcome.new()

	if actor != null:
		outcome.actor_id = actor.instance_id

	var validation_failure := (
		_get_validation_failure(
			session,
			actor
		)
	)

	if validation_failure != &"":
		outcome.failure_code = validation_failure
		return outcome

	var executed_plan_count := 0

	while actor.is_alive:
		if (
			executed_plan_count
			>= MAX_ATOMIC_PLANS_PER_TURN
		):
			outcome.failure_code = (
				FAILURE_ACTION_LIMIT_REACHED
			)

			return outcome

		var report := (
			plan_generator.create_report(
				session,
				actor,
				stamina_cost_per_step
			)
		)

		outcome.add_planning_report(
			report
		)

		if report == null or not report.is_valid:
			outcome.failure_code = (
				report.failure_code
				if report != null
				else FAILURE_PLANNING_FAILED
			)

			return outcome

		var selected_plan := (
			report.selected_plan
		)

		if selected_plan == null:
			outcome.stop_reason = STOP_NO_PLAN
			outcome.is_successful = true
			return outcome

		if selected_plan.is_wait():
			outcome.stop_reason = STOP_WAIT
			outcome.is_successful = true
			return outcome

		if selected_plan.get_score() <= MIN_USEFUL_SCORE:
			outcome.stop_reason = STOP_NO_USEFUL_PLAN
			outcome.is_successful = true
			return outcome

		if (
			outcome.did_act()
			and not selected_plan.has_action()
			and selected_plan.get_score()
				< MIN_USEFUL_SCORE_AFTER_ACTION
		):
			outcome.stop_reason = (
				STOP_LOW_VALUE_AFTER_ACTION
			)

			outcome.is_successful = true
			return outcome
            
		outcome.add_executed_plan(
			selected_plan
		)

		var progressed := await _execute_selected_plan(
			session,
			actor,
			selected_plan,
			outcome,
			animate_movement,
			animate_action
		)

		if outcome.failure_code != &"":
			return outcome

		executed_plan_count += 1

		if not actor.is_alive:
			outcome.stop_reason = STOP_ACTOR_DEFEATED
			outcome.is_successful = true
			return outcome

		if not progressed:
			outcome.stop_reason = STOP_NO_PROGRESS
			outcome.is_successful = true
			return outcome

	outcome.stop_reason = STOP_ACTOR_DEFEATED
	outcome.is_successful = true
	return outcome


func _execute_selected_plan(
	session: BattleSession,
	actor: CombatantState,
	plan: BattleAIPlan,
	outcome: BattleUtilityAITurnOutcome,
	animate_movement: bool,
	animate_action: bool
) -> bool:
	var progressed := false
	var reached_planned_destination := true

	if plan.has_movement():
		var planned_destination := (
			plan.get_destination_coordinate()
		)

		var movement_outcome := await (
			movement_runner.execute(
				session.grid,
				actor,
				plan.movement_plan,
				animate_movement
			)
		)

		outcome.add_movement_outcome(
			movement_outcome
		)

		if (
			movement_outcome == null
			or not movement_outcome.is_successful
		):
			outcome.failure_code = (
				movement_outcome.failure_code
				if movement_outcome != null
				else FAILURE_MOVEMENT_FAILED
			)

			return false

		progressed = (
			progressed
			or movement_outcome.did_move()
		)

		reached_planned_destination = (
			actor.grid_position
			== planned_destination
		)

	elif plan.has_ally_swap():
		var ally := (
			session.get_combatant(
				plan.ally_swap_target_id
			)
		)

		if ally == null:
			outcome.failure_code = (
				FAILURE_ALLY_SWAP_TARGET_MISSING
			)

			return false

		var swap_outcome := await (
			movement_runner.execute_ally_swap(
				actor,
				ally,
				plan.ally_swap_stamina_cost,
				animate_movement
			)
		)

		outcome.add_movement_outcome(
			swap_outcome
		)

		if (
			swap_outcome == null
			or not swap_outcome.is_successful
		):
			outcome.failure_code = (
				swap_outcome.failure_code
				if swap_outcome != null
				else FAILURE_ALLY_SWAP_FAILED
			)

			return false

		progressed = (
			progressed
			or swap_outcome.did_swap()
		)

	if not actor.is_alive:
		return progressed

	if plan.has_action():
		## Если поверхность или другой эффект остановил
		## обычное движение раньше запланированной клетки,
		## не выполняем старую aim-команду вслепую.
		if plan.has_movement() and not reached_planned_destination:
			return progressed

		var command := (
			plan.create_action_command(
				actor
			)
		)

		if (
			command == null
			or not action_runner.can_execute(
				session,
				command
			)
		):
			return progressed

		var action_outcome := await (
			action_runner.execute_action(
				session,
				command,
				animate_action
			)
		)

		outcome.add_action_outcome(
			action_outcome
		)

		if (
			action_outcome == null
			or not action_outcome.is_successful
		):
			outcome.failure_code = (
				action_outcome.failure_code
				if action_outcome != null
				else FAILURE_ACTION_FAILED
			)

			return false

		progressed = true

	return progressed


func _get_validation_failure(
	session: BattleSession,
	actor: CombatantState
) -> StringName:
	if session == null or session.grid == null:
		return FAILURE_INVALID_SESSION

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if plan_generator == null:
		return FAILURE_INVALID_PLAN_GENERATOR

	if movement_runner == null:
		return FAILURE_INVALID_MOVEMENT_RUNNER

	if action_runner == null:
		return FAILURE_INVALID_ACTION_RUNNER

	return &""