class_name BattleMovementRunner
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = &"invalid_session"
const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_COMBATANT: StringName = &"invalid_combatant"
const FAILURE_INVALID_PLAN: StringName = &"invalid_plan"

const FAILURE_COMBATANT_MISMATCH: StringName = (
	&"combatant_mismatch"
)

const FAILURE_COMMIT_FAILED: StringName = &"commit_failed"

const FAILURE_PRESENTATION_FAILED: StringName = (
	&"presentation_failed"
)


var session: BattleSession
var movement_service: BattleMovementService
var combatant_presenter: BattleCombatantPresenter


func _init(
	p_session: BattleSession,
	p_movement_service: BattleMovementService,
	p_combatant_presenter: BattleCombatantPresenter
) -> void:
	assert(
		p_session != null,
		"BattleMovementRunner requires a battle session."
	)

	assert(
		p_movement_service != null,
		"BattleMovementRunner requires a movement service."
	)

	assert(
		p_combatant_presenter != null,
		"BattleMovementRunner requires a combatant presenter."
	)

	session = p_session
	movement_service = p_movement_service
	combatant_presenter = p_combatant_presenter


func execute(
	grid: BattleGrid,
	combatant: CombatantState,
	plan: BattleMovementPlan,
	animated: bool = true
) -> BattleMovementOutcome:
	var outcome := BattleMovementOutcome.new()

	outcome.movement_plan = plan

	if session == null:
		outcome.failure_code = FAILURE_INVALID_SESSION
		return outcome

	if grid == null:
		outcome.failure_code = FAILURE_INVALID_GRID
		return outcome

	if combatant == null:
		outcome.failure_code = FAILURE_INVALID_COMBATANT
		return outcome

	outcome.combatant_id = combatant.instance_id

	if (
		plan == null
		or not plan.is_valid
		or not plan.has_path()
	):
		outcome.failure_code = FAILURE_INVALID_PLAN
		return outcome

	if plan.combatant_id != combatant.instance_id:
		outcome.failure_code = FAILURE_COMBATANT_MISMATCH
		return outcome

	if (
		combatant.grid_position
		!= plan.start_coordinate
		or not combatant.can_spend_stamina(
			plan.stamina_cost
		)
	):
		outcome.failure_code = FAILURE_COMMIT_FAILED
		return outcome

	var requested_path := (
		plan.path.duplicate()
	)

	var applied_path: Array[Vector2i] = []

	for step_coordinate in requested_path:
		var committed := (
			movement_service.commit_step(
				grid,
				combatant,
				step_coordinate,
				plan.stamina_cost_per_step
			)
		)

		if not committed:
			outcome.failure_code = (
				FAILURE_COMMIT_FAILED
			)

			return outcome

		applied_path.append(
			step_coordinate
		)

		outcome.movement_committed = true

		var presented := await (
			combatant_presenter
			.move_along_grid_path(
				combatant.instance_id,
				[step_coordinate],
				animated
			)
		)

		if not presented:
			outcome.failure_code = (
				FAILURE_PRESENTATION_FAILED
			)

			return outcome

		outcome.movement_presented = true

		var surface_results: Array[BattleSurfaceTriggerResult] = []

		if session.surface_effect_controller != null:
			surface_results = (
				session
				.surface_effect_controller
				.trigger_for_combatant(
					session,
					combatant,
					BattleSurfaceEffectDefinition
						.TriggerTiming
						.ON_ENTER
				)
			)

		if (
			not combatant.is_alive
			or combatant.is_movement_restricted()
			or _surface_results_stop_movement(
				surface_results
			)
		):
			break

	## Outcome и AI должны видеть фактически пройденный путь,
	## а не путь, который планировался до ловушки или смерти.
	plan.path = applied_path
	plan.target_coordinate = (
		combatant.grid_position
	)

	plan.stamina_cost = (
		applied_path.size()
		* plan.stamina_cost_per_step
	)

	if applied_path.is_empty():
		outcome.failure_code = FAILURE_COMMIT_FAILED
		return outcome

	outcome.is_successful = true
	return outcome


func _surface_results_stop_movement(
	results: Array[BattleSurfaceTriggerResult]
) -> bool:
	for result in results:
		if (
			result != null
			and result.stops_movement
		):
			return true

	return false