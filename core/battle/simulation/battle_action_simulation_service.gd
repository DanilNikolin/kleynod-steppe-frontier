class_name BattleActionSimulationService
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_REQUEST: StringName = (
	&"invalid_simulation_request"
)

const FAILURE_INVALID_ACTOR: StringName = (
	&"invalid_actor"
)

const FAILURE_ACTOR_NOT_IN_SESSION: StringName = (
	&"actor_not_in_session"
)

const FAILURE_CONFLICTING_MOVEMENT: StringName = (
	&"conflicting_simulation_movement"
)

const FAILURE_INVALID_MOVEMENT_PLAN: StringName = (
	&"invalid_simulation_movement_plan"
)

const FAILURE_MOVEMENT_ACTOR_MISMATCH: StringName = (
	&"simulation_movement_actor_mismatch"
)

const FAILURE_INVALID_CRITICAL_MODE: StringName = (
	&"invalid_simulation_critical_mode"
)

const FAILURE_SNAPSHOT_CREATION_FAILED: StringName = (
	&"simulation_snapshot_creation_failed"
)

const FAILURE_SNAPSHOT_ACTOR_MISSING: StringName = (
	&"simulation_snapshot_actor_missing"
)

const FAILURE_SNAPSHOT_SWAP_TARGET_MISSING: StringName = (
	&"simulation_snapshot_swap_target_missing"
)

const FAILURE_MOVEMENT_STEP_COMMIT_FAILED: StringName = (
	&"simulation_movement_step_commit_failed"
)

const FAILURE_ALLY_SWAP_FAILED: StringName = (
	&"simulation_ally_swap_failed"
)


const INTERRUPTION_SURFACE_EFFECT: StringName = (
	&"surface_effect"
)

const INTERRUPTION_ACTOR_DEFEATED: StringName = (
	&"actor_defeated"
)

const INTERRUPTION_POSITION_CHANGED: StringName = (
	&"position_changed_by_surface"
)

const INTERRUPTION_PATH_NOT_COMPLETED: StringName = (
	&"movement_path_not_completed"
)


const ACTION_SKIP_ACTOR_DEFEATED: StringName = (
	&"actor_defeated"
)

const ACTION_SKIP_MOVEMENT_INTERRUPTED: StringName = (
	&"movement_interrupted"
)


var movement_service: BattleMovementService
var action_service: BattleActionService


func _init(
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService
) -> void:
	assert(
		p_movement_service != null,
		"BattleActionSimulationService requires "
		+"a movement service."
	)

	assert(
		p_action_service != null,
		"BattleActionSimulationService requires "
		+"an action service."
	)

	movement_service = p_movement_service
	action_service = p_action_service


func simulate(
	session: BattleSession,
	request: BattleActionSimulationRequest
) -> BattleActionSimulationResult:
	var result := (
		BattleActionSimulationResult.new()
	)

	if request != null:
		result.actor_id = request.actor_id

	var validation_failure := (
		_get_validation_failure(
			session,
			request
		)
	)

	if validation_failure != &"":
		result.failure_code = validation_failure
		return result

	var simulated_session := (
		session.create_runtime_copy()
	)

	if simulated_session == null:
		result.failure_code = (
			FAILURE_SNAPSHOT_CREATION_FAILED
		)

		return result

	result.simulated_session = (
		simulated_session
	)

	var simulated_actor := (
		simulated_session.get_combatant(
			request.actor_id
		)
	)

	if simulated_actor == null:
		result.failure_code = (
			FAILURE_SNAPSHOT_ACTOR_MISSING
		)

		return result

	result.initial_actor_coordinate = (
		simulated_actor.grid_position
	)

	result.initial_stamina = (
		simulated_actor.current_stamina
	)

	_capture_initial_actor_surfaces(
		simulated_session,
		result
	)

	if request.has_movement():
		var movement_failure := (
			_simulate_movement(
				simulated_session,
				simulated_actor,
				request.movement_plan,
				result
			)
		)

		if movement_failure != &"":
			result.failure_code = (
				movement_failure
			)

			_finalize_result(
				result,
				simulated_actor
			)

			return result

	elif request.has_ally_swap():
		var swap_target := (
			simulated_session.get_combatant(
				request.ally_swap_target_id
			)
		)

		if swap_target == null:
			result.failure_code = (
				FAILURE_SNAPSHOT_SWAP_TARGET_MISSING
			)

			_finalize_result(
				result,
				simulated_actor
			)

			return result

		result.ally_swap_result = (
			movement_service.commit_ally_swap(
				simulated_session,
				simulated_actor,
				swap_target,
				request.ally_swap_stamina_cost
			)
		)

		if (
			result.ally_swap_result == null
			or not result
				.ally_swap_result
				.is_successful
		):
			result.failure_code = (
				result
					.ally_swap_result
					.failure_code
				if result.ally_swap_result != null
				else FAILURE_ALLY_SWAP_FAILED
			)

			_finalize_result(
				result,
				simulated_actor
			)

			return result

	result.action_was_requested = (
		request.has_action()
	)

	if request.has_action():
		if not simulated_actor.is_alive:
			result.action_was_skipped = true
			result.action_skip_reason = (
				ACTION_SKIP_ACTOR_DEFEATED
			)

		elif (
			request.has_movement()
			and not result.movement_completed
		):
			result.action_was_skipped = true
			result.action_skip_reason = (
				ACTION_SKIP_MOVEMENT_INTERRUPTED
			)

		else:
			result.action_was_attempted = true

			var command := BattleActionCommand.new(
				simulated_actor,
				request.ability,
				request.aim_coordinate
			)

			result.action_result = (
				action_service.execute(
					simulated_session,
					command,
					request.standard_critical_mode
				)
			)

	_finalize_result(
		result,
		simulated_actor
	)

	result.is_valid = true
	return result


func _capture_initial_actor_surfaces(
	session: BattleSession,
	result: BattleActionSimulationResult
) -> void:
	if (
		session == null
		or result == null
		or session.surface_effect_controller == null
		or result.initial_actor_coordinate
			== BattleGrid.INVALID_COORDINATE
	):
		return

	for surface_instance in (
		session
			.surface_effect_controller
			.get_effects_at(
				result.initial_actor_coordinate
			)
	):
		if (
			surface_instance == null
			or surface_instance.definition == null
		):
			continue

		result.initial_actor_surface_definitions.append(
			surface_instance.definition
		)

		result.initial_actor_surface_source_team_ids.append(
			surface_instance.source_team_id
		)
		
func _simulate_movement(
	session: BattleSession,
	actor: CombatantState,
	movement_plan: BattleMovementPlan,
	result: BattleActionSimulationResult
) -> StringName:
	result.movement_was_requested = true

	result.movement_origin = (
		actor.grid_position
	)

	result.movement_requested_destination = (
		movement_plan.target_coordinate
	)

	var applied_step_count := 0

	for step_coordinate in movement_plan.path:
		if not movement_service.commit_step(
			session.grid,
			actor,
			step_coordinate,
			movement_plan.stamina_cost_per_step
		):
			return (
				FAILURE_MOVEMENT_STEP_COMMIT_FAILED
			)

		applied_step_count += 1

		result.movement_applied_path.append(
			step_coordinate
		)

		var should_stop := false

		if session.surface_effect_controller != null:
			var trigger_results := (
				session
					.surface_effect_controller
					.trigger_for_combatant(
						session,
						actor,
						BattleSurfaceEffectDefinition
							.TriggerTiming
							.ON_ENTER
					)
			)

			for trigger_result in trigger_results:
				if trigger_result == null:
					continue

				result.movement_surface_results.append(
					trigger_result
				)

				if trigger_result.stops_movement:
					should_stop = true

					if (
						result
							.movement_interruption_reason
						== &""
					):
						result.movement_interruption_reason = (
							INTERRUPTION_SURFACE_EFFECT
						)

		if not actor.is_alive:
			should_stop = true
			result.movement_interruption_reason = (
				INTERRUPTION_ACTOR_DEFEATED
			)

		elif actor.grid_position != step_coordinate:
			should_stop = true
			result.movement_interruption_reason = (
				INTERRUPTION_POSITION_CHANGED
			)

		if should_stop:
			break

	result.movement_stamina_spent = (
		applied_step_count
		* movement_plan.stamina_cost_per_step
	)

	result.movement_completed = (
		actor.is_alive
		and applied_step_count
			== movement_plan.path.size()
		and actor.grid_position
			== movement_plan.target_coordinate
	)

	result.movement_interrupted = (
		not result.movement_completed
	)

	if result.movement_completed:
		result.movement_interruption_reason = &""

	elif (
		result.movement_interruption_reason
		== &""
	):
		result.movement_interruption_reason = (
			INTERRUPTION_PATH_NOT_COMPLETED
		)

	return &""


func _finalize_result(
	result: BattleActionSimulationResult,
	actor: CombatantState
) -> void:
	if result == null or actor == null:
		return

	result.final_actor_coordinate = (
		actor.grid_position
	)

	result.final_stamina = (
		actor.current_stamina
	)

	result.total_stamina_spent = (
		result.movement_stamina_spent
	)

	if result.ally_swap_result != null:
		result.total_stamina_spent += (
			result
				.ally_swap_result
				.stamina_spent
		)

	if result.action_result != null:
		result.total_stamina_spent += (
			result.action_result.stamina_spent
		)


func _get_validation_failure(
	session: BattleSession,
	request: BattleActionSimulationRequest
) -> StringName:
	if session == null or session.grid == null:
		return FAILURE_INVALID_SESSION

	if request == null:
		return FAILURE_INVALID_REQUEST

	if request.actor_id == &"":
		return FAILURE_INVALID_ACTOR

	if not session.has_combatant(
		request.actor_id
	):
		return FAILURE_ACTOR_NOT_IN_SESSION

	if (
		request.movement_plan != null
		and request.has_ally_swap()
	):
		return FAILURE_CONFLICTING_MOVEMENT

	if request.movement_plan != null:
		if (
			not request.movement_plan.is_valid
			or not request
				.movement_plan
				.has_path()
			or request
				.movement_plan
				.stamina_cost_per_step <= 0
			or request
				.movement_plan
				.path.is_empty()
			or request
				.movement_plan
				.path[
					request
						.movement_plan
						.path.size() - 1
				]
				!= request
					.movement_plan
					.target_coordinate
		):
			return FAILURE_INVALID_MOVEMENT_PLAN

		if (
			request
				.movement_plan
				.combatant_id
			!= request.actor_id
		):
			return FAILURE_MOVEMENT_ACTOR_MISMATCH

	if request.ally_swap_stamina_cost < 0:
		return FAILURE_INVALID_REQUEST

	if (
		request.ability == null
		and request.aim_coordinate
			!= BattleGrid.INVALID_COORDINATE
	):
		return FAILURE_INVALID_REQUEST

	if (
		request.ability != null
		and request.aim_coordinate
			== BattleGrid.INVALID_COORDINATE
	):
		return FAILURE_INVALID_REQUEST

	match request.standard_critical_mode:
		EffectResolver.StandardCriticalMode.RANDOM:
			pass

		EffectResolver.StandardCriticalMode.NEVER:
			pass

		EffectResolver.StandardCriticalMode.ALWAYS:
			pass

		_:
			return FAILURE_INVALID_CRITICAL_MODE

	return &""