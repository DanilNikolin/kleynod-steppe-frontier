class_name BattleActionRunner
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_COMMAND: StringName = &"invalid_command"

const FAILURE_EXECUTION_FAILED: StringName = (
	&"execution_failed"
)

const FAILURE_PRESENTATION_FAILED: StringName = (
	&"presentation_failed"
)

const FAILURE_DEFEATED_VIEW_REMOVAL_FAILED: StringName = (
	&"defeated_view_removal_failed"
)


var action_service: BattleActionService
var combatant_presenter: BattleCombatantPresenter


func _init(
	p_action_service: BattleActionService,
	p_combatant_presenter: BattleCombatantPresenter
) -> void:
	assert(
		p_action_service != null,
		"BattleActionRunner requires an action service."
	)

	assert(
		p_combatant_presenter != null,
		"BattleActionRunner requires a combatant presenter."
	)

	action_service = p_action_service
	combatant_presenter = p_combatant_presenter


func can_execute(
	grid: BattleGrid,
	command: BattleActionCommand
) -> bool:
	return get_validation_failure(
		grid,
		command
	) == &""


func get_validation_failure(
	grid: BattleGrid,
	command: BattleActionCommand
) -> StringName:
	if grid == null:
		return FAILURE_INVALID_GRID

	if command == null:
		return FAILURE_INVALID_COMMAND

	return action_service.get_validation_failure(
		grid,
		command
	)


func execute_melee(
	grid: BattleGrid,
	command: BattleActionCommand,
	animated: bool = true,
	remove_defeated_view: bool = true
) -> BattleActionOutcome:
	var outcome := BattleActionOutcome.new()

	outcome.command = command

	var validation_failure := get_validation_failure(
		grid,
		command
	)

	if validation_failure != &"":
		outcome.failure_code = validation_failure
		return outcome

	outcome.action_result = action_service.execute(
		grid,
		command
	)

	if not outcome.action_result.is_successful:
		outcome.failure_code = (
			outcome.action_result.failure_code
			if outcome.action_result.failure_code != &""
			else FAILURE_EXECUTION_FAILED
		)

		return outcome

	outcome.action_presented = await (
		combatant_presenter.play_melee_feedback(
			command.actor.instance_id,
			command.target.instance_id,
			outcome.action_result.did_target_die(),
			animated
		)
	)

	if not outcome.action_presented:
		outcome.failure_code = (
			FAILURE_PRESENTATION_FAILED
		)

		return outcome

	if (
		remove_defeated_view
		and outcome.action_result.did_target_die()
	):
		outcome.defeated_view_removed = (
			combatant_presenter.remove_view(
				command.target.instance_id
			)
		)

		if not outcome.defeated_view_removed:
			outcome.failure_code = (
				FAILURE_DEFEATED_VIEW_REMOVAL_FAILED
			)

			return outcome

	outcome.is_successful = true
	return outcome