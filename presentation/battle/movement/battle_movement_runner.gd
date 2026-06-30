class_name BattleMovementRunner
extends RefCounted


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


var movement_service: BattleMovementService
var combatant_presenter: BattleCombatantPresenter


func _init(
	p_movement_service: BattleMovementService,
	p_combatant_presenter: BattleCombatantPresenter
) -> void:
	assert(
		p_movement_service != null,
		"BattleMovementRunner requires a movement service."
	)

	assert(
		p_combatant_presenter != null,
		"BattleMovementRunner requires a combatant presenter."
	)

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

	outcome.movement_committed = (
		movement_service.commit_plan(
			grid,
			combatant,
			plan
		)
	)

	if not outcome.movement_committed:
		outcome.failure_code = FAILURE_COMMIT_FAILED
		return outcome

	outcome.movement_presented = await (
		combatant_presenter.move_along_grid_path(
			combatant.instance_id,
			plan.path,
			animated
		)
	)

	if not outcome.movement_presented:
		outcome.failure_code = (
			FAILURE_PRESENTATION_FAILED
		)

		return outcome

	outcome.is_successful = true
	return outcome