class_name BattleRelocationService
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = &"invalid_session"
const FAILURE_INVALID_COMBATANT: StringName = &"invalid_combatant"
const FAILURE_SAME_COMBATANT: StringName = &"same_combatant"
const FAILURE_DEAD_COMBATANT: StringName = &"dead_combatant"

const FAILURE_POSITION_LOCKED: StringName = (
	&"position_locked"
)

const FAILURE_MOVEMENT_RESTRICTED: StringName = (
	&"movement_restricted"
)

const FAILURE_INVALID_GRID_POSITION: StringName = (
	&"invalid_grid_position"
)

const FAILURE_TEAM_MISMATCH: StringName = &"team_mismatch"
const FAILURE_NOT_ADJACENT: StringName = &"not_adjacent"

const FAILURE_INVALID_STAMINA_COST: StringName = (
	&"invalid_stamina_cost"
)

const FAILURE_NOT_ENOUGH_STAMINA: StringName = (
	&"not_enough_stamina"
)

const FAILURE_DESTINATION_OUTSIDE_GRID: StringName = (
	&"destination_outside_grid"
)

const FAILURE_DESTINATION_IS_ORIGIN: StringName = (
	&"destination_is_origin"
)

const FAILURE_DESTINATION_BLOCKED: StringName = (
	&"destination_blocked"
)

const FAILURE_COMMIT_FAILED: StringName = &"commit_failed"


func get_swap_failure(
	session: BattleSession,
	first: CombatantState,
	second: CombatantState,
	require_same_team: bool = false,
	require_adjacent: bool = false,
	first_stamina_cost: int = 0
) -> StringName:
	var first_failure := _get_combatant_failure(
		session,
		first
	)

	if first_failure != &"":
		return first_failure

	var second_failure := _get_combatant_failure(
		session,
		second
	)

	if second_failure != &"":
		return second_failure

	if first == second:
		return FAILURE_SAME_COMBATANT

	if (
		require_same_team
		and first.team_id != second.team_id
	):
		return FAILURE_TEAM_MISMATCH

	if (
		require_adjacent
		and not session.grid.are_orthogonally_adjacent(
			first.grid_position,
			second.grid_position
		)
	):
		return FAILURE_NOT_ADJACENT

	if first_stamina_cost < 0:
		return FAILURE_INVALID_STAMINA_COST

	if not first.can_spend_stamina(
		first_stamina_cost
	):
		return FAILURE_NOT_ENOUGH_STAMINA

	return &""


func can_swap(
	session: BattleSession,
	first: CombatantState,
	second: CombatantState,
	require_same_team: bool = false,
	require_adjacent: bool = false,
	first_stamina_cost: int = 0
) -> bool:
	return get_swap_failure(
		session,
		first,
		second,
		require_same_team,
		require_adjacent,
		first_stamina_cost
	) == &""


func swap(
	session: BattleSession,
	first: CombatantState,
	second: CombatantState,
	require_same_team: bool = false,
	require_adjacent: bool = false,
	first_stamina_cost: int = 0
) -> BattleRelocationResult:
	var result := BattleRelocationResult.new()

	result.relocation_kind = (
		BattleRelocationResult.KIND_SWAP
	)

	result.stamina_cost = first_stamina_cost

	if first != null:
		result.primary_combatant_id = (
			first.instance_id
		)

		result.primary_origin = (
			first.grid_position
		)

	if second != null:
		result.secondary_combatant_id = (
			second.instance_id
		)

		result.secondary_origin = (
			second.grid_position
		)

	var failure_code := get_swap_failure(
		session,
		first,
		second,
		require_same_team,
		require_adjacent,
		first_stamina_cost
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	var first_origin := first.grid_position
	var second_origin := second.grid_position

	if first_stamina_cost > 0:
		if not first.spend_stamina(
			first_stamina_cost
		):
			result.failure_code = (
				FAILURE_NOT_ENOUGH_STAMINA
			)

			return result

		result.stamina_spent = first_stamina_cost

	if not session.grid.try_swap_occupants(
		first.instance_id,
		second.instance_id
	):
		if result.stamina_spent > 0:
			first.restore_stamina(
				result.stamina_spent
			)

			result.stamina_spent = 0

		result.failure_code = FAILURE_COMMIT_FAILED
		return result

	first.set_grid_position(
		second_origin
	)

	second.set_grid_position(
		first_origin
	)

	result.primary_destination = (
		first.grid_position
	)

	result.secondary_destination = (
		second.grid_position
	)

	_trigger_on_enter(
		session,
		first,
		result.primary_surface_results
	)

	_trigger_on_enter(
		session,
		second,
		result.secondary_surface_results
	)

	result.is_successful = true
	return result


func get_teleport_failure(
	session: BattleSession,
	combatant: CombatantState,
	destination: Vector2i,
	stamina_cost: int = 0
) -> StringName:
	var combatant_failure := (
		_get_combatant_failure(
			session,
			combatant
		)
	)

	if combatant_failure != &"":
		return combatant_failure

	if stamina_cost < 0:
		return FAILURE_INVALID_STAMINA_COST

	if not combatant.can_spend_stamina(
		stamina_cost
	):
		return FAILURE_NOT_ENOUGH_STAMINA

	if not session.grid.is_inside(
		destination
	):
		return FAILURE_DESTINATION_OUTSIDE_GRID

	if destination == combatant.grid_position:
		return FAILURE_DESTINATION_IS_ORIGIN

	var destination_cell := session.grid.get_cell(
		destination
	)

	if (
		destination_cell == null
		or not destination_cell.is_walkable()
	):
		return FAILURE_DESTINATION_BLOCKED

	return &""


func can_teleport(
	session: BattleSession,
	combatant: CombatantState,
	destination: Vector2i,
	stamina_cost: int = 0
) -> bool:
	return get_teleport_failure(
		session,
		combatant,
		destination,
		stamina_cost
	) == &""


func teleport(
	session: BattleSession,
	combatant: CombatantState,
	destination: Vector2i,
	stamina_cost: int = 0
) -> BattleRelocationResult:
	var result := BattleRelocationResult.new()

	result.relocation_kind = (
		BattleRelocationResult.KIND_TELEPORT
	)

	result.stamina_cost = stamina_cost

	if combatant != null:
		result.primary_combatant_id = (
			combatant.instance_id
		)

		result.primary_origin = (
			combatant.grid_position
		)

	result.primary_destination = destination

	var failure_code := get_teleport_failure(
		session,
		combatant,
		destination,
		stamina_cost
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	if stamina_cost > 0:
		if not combatant.spend_stamina(
			stamina_cost
		):
			result.failure_code = (
				FAILURE_NOT_ENOUGH_STAMINA
			)

			return result

		result.stamina_spent = stamina_cost

	if not session.grid.try_move_occupant(
		combatant.instance_id,
		destination
	):
		if result.stamina_spent > 0:
			combatant.restore_stamina(
				result.stamina_spent
			)

			result.stamina_spent = 0

		result.failure_code = FAILURE_COMMIT_FAILED
		return result

	combatant.set_grid_position(
		destination
	)

	result.primary_destination = (
		combatant.grid_position
	)

	_trigger_on_enter(
		session,
		combatant,
		result.primary_surface_results
	)

	result.is_successful = true
	return result


func _get_combatant_failure(
	session: BattleSession,
	combatant: CombatantState
) -> StringName:
	if (
		session == null
		or session.grid == null
	):
		return FAILURE_INVALID_SESSION

	if combatant == null:
		return FAILURE_INVALID_COMBATANT

	if not combatant.is_alive:
		return FAILURE_DEAD_COMBATANT

	## В relocation v1 пассивные боевые объекты
	## считаются неподвижными.
	if (
		combatant.definition == null
		or not combatant
			.definition
			.participates_in_turn_order
	):
		return FAILURE_POSITION_LOCKED

	if combatant.is_movement_restricted():
		return FAILURE_MOVEMENT_RESTRICTED

	if not session.grid.is_inside(
		combatant.grid_position
	):
		return FAILURE_INVALID_GRID_POSITION

	if (
		not session.grid.has_occupant(
			combatant.instance_id
		)
		or session.grid.get_occupant_position(
			combatant.instance_id
		) != combatant.grid_position
	):
		return FAILURE_INVALID_GRID_POSITION

	return &""


func _trigger_on_enter(
	session: BattleSession,
	combatant: CombatantState,
	output: Array[BattleSurfaceTriggerResult]
) -> void:
	if (
		session == null
		or combatant == null
		or not combatant.is_alive
		or session.surface_effect_controller == null
	):
		return

	var trigger_results := (
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

	for trigger_result in trigger_results:
		if trigger_result != null:
			output.append(
				trigger_result
			)