class_name BattleActionRunner
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_COMMAND: StringName = (
	&"invalid_command"
)

const FAILURE_REQUIRES_SINGLE_TARGET: StringName = (
	&"requires_single_target"
)

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
		"BattleActionRunner requires "
		+"a combatant presenter."
	)

	action_service = p_action_service
	combatant_presenter = p_combatant_presenter


func can_execute(
	session: BattleSession,
	command: BattleActionCommand
) -> bool:
	return get_validation_failure(
		session,
		command
	) == &""


func get_validation_failure(
	session: BattleSession,
	command: BattleActionCommand
) -> StringName:
	if session == null:
		return FAILURE_INVALID_SESSION

	if command == null:
		return FAILURE_INVALID_COMMAND

	var action_failure := (
		action_service.get_validation_failure(
			session,
			command
		)
	)

	if action_failure != &"":
		return action_failure

	var targeting_result := (
		action_service.get_targeting_result(
			session,
			command
		)
	)

	if (
		not targeting_result.is_valid
		or targeting_result
		.affected_combatants.size() != 1
	):
		return FAILURE_REQUIRES_SINGLE_TARGET

	return &""


func execute_melee(
	session: BattleSession,
	command: BattleActionCommand,
	animated: bool = true,
	remove_defeated_view: bool = true
) -> BattleActionOutcome:
	var outcome := BattleActionOutcome.new()

	outcome.command = command

	var validation_failure := (
		get_validation_failure(
			session,
			command
		)
	)

	if validation_failure != &"":
		outcome.failure_code = (
			validation_failure
		)

		return outcome

	outcome.action_result = (
		action_service.execute(
			session,
			command
		)
	)

	if not outcome.action_result.is_successful:
		outcome.failure_code = (
			outcome.action_result.failure_code
			if outcome.action_result.failure_code
			!= &""
			else FAILURE_EXECUTION_FAILED
		)

		return outcome

	var target_id := (
		outcome.action_result
		.get_primary_target_id()
	)

	var target_died := (
		outcome.action_result.did_target_die(
			target_id
		)
	)

	outcome.action_presented = await (
		combatant_presenter.play_melee_feedback(
			command.actor.instance_id,
			target_id,
			target_died,
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
		and target_died
	):
		outcome.defeated_view_removed = (
			combatant_presenter.remove_view(
				target_id
			)
		)

		if not outcome.defeated_view_removed:
			outcome.failure_code = (
				FAILURE_DEFEATED_VIEW_REMOVAL_FAILED
			)

			return outcome

	outcome.is_successful = true
	return outcome