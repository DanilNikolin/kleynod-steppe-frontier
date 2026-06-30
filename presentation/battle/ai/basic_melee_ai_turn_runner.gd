class_name BasicMeleeAITurnRunner
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_PLAN: StringName = (
	&"invalid_plan"
)

const FAILURE_ACTION_LIMIT_REACHED: StringName = (
	&"action_limit_reached"
)


const MAX_ACTIONS_PER_TURN: int = 64


var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner


func _init(
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner
) -> void:
	assert(
		p_movement_runner != null,
		"BasicMeleeAITurnRunner requires "
		+"a movement runner."
	)

	assert(
		p_action_runner != null,
		"BasicMeleeAITurnRunner requires "
		+"an action runner."
	)

	movement_runner = p_movement_runner
	action_runner = p_action_runner


func execute(
	session: BattleSession,
	plan: BasicMeleeAITurnPlan,
	animate_movement: bool = true,
	animate_action: bool = true
) -> BasicMeleeAITurnOutcome:
	var outcome := BasicMeleeAITurnOutcome.new()

	if session == null or session.grid == null:
		outcome.failure_code = (
			FAILURE_INVALID_SESSION
		)

		return outcome

	if (
		plan == null
		or not plan.is_valid
		or plan.actor == null
		or plan.target == null
		or plan.ability == null
	):
		outcome.failure_code = (
			FAILURE_INVALID_PLAN
		)

		return outcome

	var grid := session.grid

	outcome.actor_id = (
		plan.actor.instance_id
	)

	outcome.target_id = (
		plan.target.instance_id
	)

	if plan.has_movement():
		outcome.movement_outcome = await (
			movement_runner.execute(
				grid,
				plan.actor,
				plan.movement_plan,
				animate_movement
			)
		)

		if not outcome.movement_outcome.is_successful:
			outcome.failure_code = (
				outcome.movement_outcome
				.failure_code
			)

			return outcome

	if not plan.actor.is_alive:
		outcome.is_successful = true
		return outcome

	if not plan.target.is_alive:
		outcome.is_successful = true
		return outcome

	var executed_action_count: int = 0

	while (
		plan.actor.is_alive
		and plan.target.is_alive
	):
		if (
			executed_action_count
			>= MAX_ACTIONS_PER_TURN
		):
			outcome.failure_code = (
				FAILURE_ACTION_LIMIT_REACHED
			)

			return outcome

		var command := BattleActionCommand.new(
			plan.actor,
			plan.ability,
			plan.target.grid_position
		)

		if not action_runner.can_execute(
			session,
			command
		):
			break

		var previous_actor_stamina := (
			plan.actor.current_stamina
		)

		var previous_target_health := (
			plan.target.current_health
		)

		var current_action_outcome := await (
			action_runner.execute_melee(
				session,
				command,
				animate_action
			)
		)

		if not current_action_outcome.is_successful:
			outcome.failure_code = (
				current_action_outcome
				.failure_code
			)

			return outcome

		outcome.add_action_outcome(
			current_action_outcome
		)

		executed_action_count += 1

		var stamina_changed := (
			plan.actor.current_stamina
			!= previous_actor_stamina
		)

		var health_changed := (
			plan.target.current_health
			!= previous_target_health
		)

		if not stamina_changed and not health_changed:
			break

	outcome.is_successful = true
	return outcome