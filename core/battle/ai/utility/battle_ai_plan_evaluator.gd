class_name BattleAIPlanEvaluator
extends RefCounted


const SCORE_SIMULATION_MISSING: StringName = (
	&"simulation_missing"
)

const SCORE_SIMULATION_INVALID: StringName = (
	&"simulation_invalid"
)

const SCORE_ACTION_FAILED: StringName = (
	&"action_failed"
)

const SCORE_ACTION_SKIPPED: StringName = (
	&"action_skipped"
)

const SCORE_MOVEMENT_INTERRUPTED: StringName = (
	&"movement_interrupted"
)

const SCORE_WAIT: StringName = &"wait"

const SCORE_DAMAGE: StringName = &"damage"
const SCORE_GUARD_DAMAGE: StringName = &"guard_damage"
const SCORE_KILL: StringName = &"kill"
const SCORE_OVERKILL: StringName = &"overkill"

const SCORE_FRIENDLY_DAMAGE: StringName = (
	&"friendly_damage"
)

const SCORE_FRIENDLY_GUARD_DAMAGE: StringName = (
	&"friendly_guard_damage"
)

const SCORE_FRIENDLY_KILL: StringName = (
	&"friendly_kill"
)

const SCORE_POSITION: StringName = &"position"

const SCORE_STAMINA: StringName = &"stamina"
const SCORE_MOVEMENT: StringName = &"movement"
const SCORE_COOLDOWN: StringName = &"cooldown"


const SIMULATION_MISSING_PENALTY: float = -10000.0
const SIMULATION_INVALID_PENALTY: float = -10000.0
const ACTION_FAILED_PENALTY: float = -500.0
const ACTION_SKIPPED_PENALTY: float = -120.0
const MOVEMENT_INTERRUPTED_PENALTY: float = -80.0
const WAIT_PENALTY: float = -1.0

const DAMAGE_SCORE_PER_HP: float = 10.0
const GUARD_DAMAGE_SCORE_PER_POINT: float = 4.0
const KILL_SCORE: float = 80.0
const OVERKILL_PENALTY_PER_HP: float = -3.0

const FRIENDLY_DAMAGE_PENALTY_PER_HP: float = -20.0
const FRIENDLY_GUARD_DAMAGE_PENALTY_PER_POINT: float = -8.0
const FRIENDLY_KILL_PENALTY: float = -250.0

const STAMINA_PENALTY_PER_POINT: float = -0.5
const MOVEMENT_PENALTY_PER_POINT: float = -0.25
const COOLDOWN_PENALTY_PER_TURN: float = -2.0
const APPROACH_SCORE_PER_TILE: float = 4.0
const RETREAT_PENALTY_PER_TILE: float = -3.0
const FORWARD_SCORE_PER_TILE: float = 0.75


func evaluate_plan(
	plan: BattleAIPlan
) -> BattleAIScoreBreakdown:
	if plan == null:
		return BattleAIScoreBreakdown.new()

	plan.score_breakdown.clear()

	var breakdown := (
		plan.score_breakdown
	)

	var simulation := (
		plan.simulation_result
	)

	if simulation == null:
		breakdown.add_score(
			SCORE_SIMULATION_MISSING,
			SIMULATION_MISSING_PENALTY
		)

		return breakdown

	if not simulation.is_valid:
		breakdown.add_score(
			SCORE_SIMULATION_INVALID,
			SIMULATION_INVALID_PENALTY
		)

		return breakdown

	if plan.is_wait():
		breakdown.add_score(
			SCORE_WAIT,
			WAIT_PENALTY
		)

	if simulation.movement_interrupted:
		breakdown.add_score(
			SCORE_MOVEMENT_INTERRUPTED,
			MOVEMENT_INTERRUPTED_PENALTY
		)

	if simulation.action_was_skipped:
		breakdown.add_score(
			SCORE_ACTION_SKIPPED,
			ACTION_SKIPPED_PENALTY
		)

	if simulation.action_was_attempted:
		_score_action_result(
			breakdown,
			simulation
		)

	_score_effect_results(
		breakdown,
		simulation
	)

	_score_positioning(
		breakdown,
		plan,
		simulation
	)

	_score_costs(
		breakdown,
		plan,
		simulation
	)

	return breakdown


func _score_action_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult
) -> void:
	if simulation.action_result == null:
		breakdown.add_score(
			SCORE_ACTION_FAILED,
			ACTION_FAILED_PENALTY
		)

		return

	if not simulation.action_result.is_successful:
		breakdown.add_score(
			SCORE_ACTION_FAILED,
			ACTION_FAILED_PENALTY
		)

		return

	if simulation.action_result.cooldown_started:
		breakdown.add_score(
			SCORE_COOLDOWN,
			float(
				simulation
					.action_result
					.cooldown_turns
			)
			* COOLDOWN_PENALTY_PER_TURN
		)


func _score_effect_results(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult
) -> void:
	var actor := simulation.get_simulated_actor()

	if actor == null:
		return

	var scored_kill_ids: Dictionary = {}

	for effect_result in (
		simulation.get_all_effect_results()
	):
		if effect_result == null:
			continue

		_score_effect_result(
			breakdown,
			simulation,
			actor,
			effect_result,
			scored_kill_ids
		)


func _score_effect_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult,
	scored_kill_ids: Dictionary
) -> void:
	if effect_result.effect_kind == &"damage":
		_score_damage_result(
			breakdown,
			simulation,
			actor,
			effect_result,
			scored_kill_ids
		)

	for defeated_id in (
		effect_result.relocation_defeated_ids
	):
		_score_kill(
			breakdown,
			simulation,
			actor,
			defeated_id,
			scored_kill_ids
		)


func _score_damage_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult,
	scored_kill_ids: Dictionary
) -> void:
	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	var is_enemy := (
		target.team_id != actor.team_id
	)

	if is_enemy:
		breakdown.add_score(
			SCORE_DAMAGE,
			float(
				effect_result.applied_amount
			)
			* DAMAGE_SCORE_PER_HP
		)

		breakdown.add_score(
			SCORE_GUARD_DAMAGE,
			float(
				effect_result.guard_absorbed_amount
			)
			* GUARD_DAMAGE_SCORE_PER_POINT
		)

		breakdown.add_score(
			SCORE_OVERKILL,
			float(
				effect_result.overkill_amount
			)
			* OVERKILL_PENALTY_PER_HP
		)

	else:
		breakdown.add_score(
			SCORE_FRIENDLY_DAMAGE,
			float(
				effect_result.applied_amount
			)
			* FRIENDLY_DAMAGE_PENALTY_PER_HP
		)

		breakdown.add_score(
			SCORE_FRIENDLY_GUARD_DAMAGE,
			float(
				effect_result.guard_absorbed_amount
			)
			* FRIENDLY_GUARD_DAMAGE_PENALTY_PER_POINT
		)

	if effect_result.target_died:
		_score_kill(
			breakdown,
			simulation,
			actor,
			effect_result.target_id,
			scored_kill_ids
		)


func _score_kill(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	target_id: StringName,
	scored_kill_ids: Dictionary
) -> void:
	if target_id == &"":
		return

	if scored_kill_ids.has(
		target_id
	):
		return

	var target := (
		simulation.get_simulated_combatant(
			target_id
		)
	)

	if target == null:
		return

	scored_kill_ids[
		target_id
	] = true

	if target.team_id != actor.team_id:
		breakdown.add_score(
			SCORE_KILL,
			KILL_SCORE
		)

	else:
		breakdown.add_score(
			SCORE_FRIENDLY_KILL,
			FRIENDLY_KILL_PENALTY
		)


func _score_positioning(
	breakdown: BattleAIScoreBreakdown,
	plan: BattleAIPlan,
	simulation: BattleActionSimulationResult
) -> void:
	if (
		plan == null
		or simulation == null
		or not simulation.is_valid
	):
		return

	## Если план уже сделал действие, его ценность
	## должна определяться эффектами действия.
	## Positioning пока нужен только для "что делать,
	## когда ударить нечем".
	if plan.has_action():
		return

	if (
		not plan.has_movement()
		and not plan.has_ally_swap()
	):
		return

	var actor := (
		simulation.get_simulated_actor()
	)

	if (
		actor == null
		or simulation.simulated_session == null
	):
		return

	var start_coordinate := (
		simulation.initial_actor_coordinate
	)

	var final_coordinate := (
		simulation.final_actor_coordinate
	)

	if (
		start_coordinate
			== BattleGrid.INVALID_COORDINATE
		or final_coordinate
			== BattleGrid.INVALID_COORDINATE
	):
		return

	var initial_distance := (
		_get_nearest_enemy_distance(
			simulation.simulated_session,
			actor,
			start_coordinate
		)
	)

	var final_distance := (
		_get_nearest_enemy_distance(
			simulation.simulated_session,
			actor,
			final_coordinate
		)
	)

	if initial_distance < 0 or final_distance < 0:
		return

	var distance_delta := (
		initial_distance - final_distance
	)

	if distance_delta > 0:
		breakdown.add_score(
			SCORE_POSITION,
			float(distance_delta)
			* APPROACH_SCORE_PER_TILE
		)

	elif distance_delta < 0:
		breakdown.add_score(
			SCORE_POSITION,
			float(
				- distance_delta
			)
			* RETREAT_PENALTY_PER_TILE
		)

	var forward_delta := (
		_get_forward_delta(
			simulation.simulated_session,
			actor,
			start_coordinate,
			final_coordinate
		)
	)

	if forward_delta > 0:
		breakdown.add_score(
			SCORE_POSITION,
			float(forward_delta)
			* FORWARD_SCORE_PER_TILE
		)


func _get_nearest_enemy_distance(
	session: BattleSession,
	actor: CombatantState,
	from_coordinate: Vector2i
) -> int:
	if (
		session == null
		or session.grid == null
		or actor == null
	):
		return -1

	var best_distance := -1

	for combatant in session.get_living_combatants():
		if combatant == null:
			continue

		if combatant.team_id == actor.team_id:
			continue

		## Пассивные объекты вроде стены могут быть целями,
		## но для базового сближения пока не считаем их
		## "боевой угрозой".
		if (
			combatant.definition != null
			and not combatant
				.definition
				.participates_in_turn_order
		):
			continue

		var distance := (
			session.grid.get_manhattan_distance(
				from_coordinate,
				combatant.grid_position
			)
		)

		if (
			best_distance < 0
			or distance < best_distance
		):
			best_distance = distance

	return best_distance


func _get_forward_delta(
	session: BattleSession,
	actor: CombatantState,
	start_coordinate: Vector2i,
	final_coordinate: Vector2i
) -> int:
	if session == null or actor == null:
		return 0

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	if forward_direction == 0:
		return 0

	return (
		final_coordinate.x
		- start_coordinate.x
	) * forward_direction
    
func _score_costs(
	breakdown: BattleAIScoreBreakdown,
	plan: BattleAIPlan,
	simulation: BattleActionSimulationResult
) -> void:
	breakdown.add_score(
		SCORE_STAMINA,
		float(
			simulation.total_stamina_spent
		)
		* STAMINA_PENALTY_PER_POINT
	)

	breakdown.add_score(
		SCORE_MOVEMENT,
		float(
			plan.movement_stamina_cost
			+ plan.ally_swap_stamina_cost
		)
		* MOVEMENT_PENALTY_PER_POINT
	)