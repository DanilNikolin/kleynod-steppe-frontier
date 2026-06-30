class_name BasicMeleeAITurnRunner
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_PLAN: StringName = &"invalid_plan"


var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner


func _init(
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner
) -> void:
	assert(
		p_movement_runner != null,
		"BasicMeleeAITurnRunner requires a movement runner."
	)

	assert(
		p_action_runner != null,
		"BasicMeleeAITurnRunner requires an action runner."
	)

	movement_runner = p_movement_runner
	action_runner = p_action_runner


func execute(
	grid: BattleGrid,
	plan: BasicMeleeAITurnPlan,
	animate_movement: bool = true,
	animate_action: bool = true
) -> BasicMeleeAITurnOutcome:
	var outcome := BasicMeleeAITurnOutcome.new()

	if grid == null:
		outcome.failure_code = FAILURE_INVALID_GRID
		return outcome

	if (
		plan == null
		or not plan.is_valid
		or plan.actor == null
		or plan.target == null
		or plan.ability == null
	):
		outcome.failure_code = FAILURE_INVALID_PLAN
		return outcome

	outcome.actor_id = plan.actor.instance_id
	outcome.target_id = plan.target.instance_id

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
				outcome.movement_outcome.failure_code
			)

			return outcome

	if not plan.target.is_alive:
		outcome.is_successful = true
		return outcome

	var command := BattleActionCommand.new(
		plan.actor,
		plan.target,
		plan.ability
	)

	if not action_runner.can_execute(
		grid,
		command
	):
		outcome.is_successful = true
		return outcome

	outcome.action_outcome = await (
		action_runner.execute_melee(
			grid,
			command,
			animate_action
		)
	)

	if not outcome.action_outcome.is_successful:
		outcome.failure_code = (
			outcome.action_outcome.failure_code
		)

		return outcome

	outcome.is_successful = true
	return outcome