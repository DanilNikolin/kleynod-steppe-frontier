class_name BattleActionRunner
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_COMMAND: StringName = (
	&"invalid_command"
)

const FAILURE_EXECUTION_FAILED: StringName = (
	&"execution_failed"
)

const FAILURE_PRESENTATION_FAILED: StringName = (
	&"presentation_failed"
)

const FAILURE_FORCED_MOVEMENT_PRESENTATION_FAILED: StringName = (
	&"forced_movement_presentation_failed"
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
		"BattleActionRunner requires "
		+"an action service."
	)

	assert(
		p_combatant_presenter != null,
		"BattleActionRunner requires "
		+"a combatant presenter."
	)

	action_service = p_action_service
	combatant_presenter = (
		p_combatant_presenter
	)


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

	return action_service.get_validation_failure(
		session,
		command
	)


func execute_action(
	session: BattleSession,
	command: BattleActionCommand,
	animated: bool = true,
	remove_defeated_views: bool = true
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

	var target_ids := (
		outcome.action_result
		.affected_target_ids
	)

	var defeated_target_ids := (
		outcome.action_result
		.get_defeated_target_ids()
	)

	outcome.action_presented = await (
		combatant_presenter
		.play_action_feedback(
			command.actor.instance_id,
			target_ids,
			defeated_target_ids,
			animated
		)
	)

	if not outcome.action_presented:
		outcome.failure_code = (
			FAILURE_PRESENTATION_FAILED
		)

		return outcome

	for effect_result in (
		outcome.action_result
		.get_forced_movement_results()
	):
		if effect_result.movement_path.is_empty():
			continue

		if effect_result.target_died:
			continue

		var movement_presented := await (
			combatant_presenter
			.move_along_grid_path(
				effect_result.target_id,
				effect_result.movement_path,
				animated
			)
		)

		if not movement_presented:
			outcome.failure_code = (
				FAILURE_FORCED_MOVEMENT_PRESENTATION_FAILED
			)

			return outcome

		outcome.forced_movement_view_ids_presented.append(
			effect_result.target_id
		)

	if remove_defeated_views:
		for target_id in (
			defeated_target_ids
		):
			var removed := (
				combatant_presenter
				.remove_view(
					target_id
				)
			)

			if not removed:
				outcome.failure_code = (
					FAILURE_DEFEATED_VIEW_REMOVAL_FAILED
				)

				return outcome

			outcome.defeated_view_ids_removed.append(
				target_id
			)

	outcome.is_successful = true
	return outcome
