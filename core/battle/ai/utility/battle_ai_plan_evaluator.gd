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

const SCORE_HEAL: StringName = &"heal"
const SCORE_OVERHEAL: StringName = &"overheal"
const SCORE_ENEMY_HEAL: StringName = &"enemy_heal"

const SCORE_GUARD: StringName = &"guard"
const SCORE_OVERGUARD: StringName = &"overguard"
const SCORE_ENEMY_GUARD: StringName = &"enemy_guard"

const SCORE_STATUS: StringName = &"status"
const SCORE_BAD_STATUS: StringName = &"bad_status"
const SCORE_CLEANSE: StringName = &"cleanse"
const SCORE_BAD_CLEANSE: StringName = &"bad_cleanse"
const SCORE_ARMOR_SHIFT: StringName = &"armor_shift"
const SCORE_SURFACE_CELL: StringName = (
	&"surface_cell"
)
const SCORE_SURFACE_ESCAPE: StringName = (
	&"surface_escape"
)
const SCORE_PLACE_SURFACE: StringName = (
	&"place_surface"
)

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

const SCORE_HEALTH_COST: StringName = (
	&"health_cost"
)

const SCORE_STAMINA_RESTORE: StringName = (
	&"stamina_restore"
)

const SCORE_STAMINA_DEBT_PAYMENT: StringName = (
	&"stamina_debt_payment"
)

const SCORE_CORE_SURVIVAL: StringName = (
	&"core_survival"
)

const SCORE_MAX_STAMINA_PENALTY: StringName = (
	&"max_stamina_penalty"
)

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
const HEAL_SCORE_PER_HP: float = 7.0
const OVERHEAL_PENALTY_PER_HP: float = -1.0
const ENEMY_HEAL_PENALTY_PER_HP: float = -14.0

const GUARD_SCORE_PER_POINT: float = 5.0
const OVERGUARD_PENALTY_PER_POINT: float = -1.0
const ENEMY_GUARD_PENALTY_PER_POINT: float = -10.0

const HARMFUL_STATUS_SCORE: float = 18.0
const BENEFICIAL_STATUS_SCORE: float = 14.0
const BAD_STATUS_PENALTY: float = -22.0

const CLEANSE_SCORE: float = 16.0
const BAD_CLEANSE_PENALTY: float = -20.0

const ARMOR_SHIFT_SCORE_PER_POINT: float = 10.0

const HARMFUL_SURFACE_ON_SELF_PENALTY: float = -10.0
const BENEFICIAL_SURFACE_ON_SELF_SCORE: float = 6.0
const SURFACE_ESCAPE_SCORE_MULTIPLIER: float = 1.0

const HARMFUL_SURFACE_ON_ENEMY_SCORE: float = 14.0
const HARMFUL_SURFACE_ON_ALLY_PENALTY: float = -18.0

const BENEFICIAL_SURFACE_ON_ALLY_SCORE: float = 12.0
const BENEFICIAL_SURFACE_ON_ENEMY_PENALTY: float = -16.0

const FRIENDLY_DAMAGE_PENALTY_PER_HP: float = -20.0
const FRIENDLY_GUARD_DAMAGE_PENALTY_PER_POINT: float = -8.0
const FRIENDLY_KILL_PENALTY: float = -250.0

const STAMINA_PENALTY_PER_POINT: float = -0.5

## Добровольная HP-цена ощутима, но дешевле
## случайного урона союзнику.
const HEALTH_COST_PENALTY_PER_HP: float = -8.0

## На четверти HP или ниже добровольная цена
## становится вдвое опаснее.
const LOW_HEALTH_COST_MULTIPLIER: float = 2.0

const STAMINA_RESTORE_SCORE_PER_POINT: float = 1.5

## Погашенный долг полезен, но не равен
## ресурсу, доступному прямо сейчас.
const STAMINA_DEBT_PAYMENT_SCORE_PER_POINT: float = 0.5

const ENEMY_STAMINA_RESTORE_PENALTY_PER_POINT: float = -3.0

const ENEMY_STAMINA_DEBT_PAYMENT_PENALTY_PER_POINT: float = -1.0

const UNBROKEN_RESTORE_SCORE: float = 40.0
const FRACTURE_REMOVE_SCORE: float = 20.0

const MAX_STAMINA_PENALTY_PER_POINT: float = -6.0

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

	_score_surface_awareness(
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
	match effect_result.effect_kind:
		&"damage":
			_score_damage_result(
				breakdown,
				simulation,
				actor,
				effect_result,
				scored_kill_ids
			)

		&"heal":
			_score_heal_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

		&"health_cost":
			_score_health_cost_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

		&"restore_stamina":
			_score_restore_stamina_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

		&"hero_core":
			_score_hero_core_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

		&"grant_guard":
			_score_guard_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

		&"apply_status":
			_score_apply_status_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

		&"remove_status":
			_score_remove_status_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

		&"place_surface":
			_score_place_surface_result(
				breakdown,
				simulation,
				actor,
				effect_result
			)

	_score_armor_shift(
		breakdown,
		simulation,
		actor,
		effect_result
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


func _score_health_cost_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	var score := (
		float(
			effect_result.applied_amount
		)
		* HEALTH_COST_PENALTY_PER_HP
	)

	## Сейчас HealthCostEffect разрешён только
	## для владельца способности.
	if target.team_id != actor.team_id:
		score = - score

	elif (
		target.max_health > 0
		and effect_result.current_value * 4
			<= target.max_health
	):
		score *= (
			LOW_HEALTH_COST_MULTIPLIER
		)

	breakdown.add_score(
		SCORE_HEALTH_COST,
		score
	)


func _score_restore_stamina_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	var is_ally := (
		target.team_id == actor.team_id
	)

	if is_ally:
		breakdown.add_score(
			SCORE_STAMINA_RESTORE,
			float(
				effect_result.applied_amount
			)
			* STAMINA_RESTORE_SCORE_PER_POINT
		)

		breakdown.add_score(
			SCORE_STAMINA_DEBT_PAYMENT,
			float(
				effect_result
					.stamina_restoration_debt_paid_amount
			)
			* STAMINA_DEBT_PAYMENT_SCORE_PER_POINT
		)

	else:
		breakdown.add_score(
			SCORE_STAMINA_RESTORE,
			float(
				effect_result.applied_amount
			)
			* ENEMY_STAMINA_RESTORE_PENALTY_PER_POINT
		)

		breakdown.add_score(
			SCORE_STAMINA_DEBT_PAYMENT,
			float(
				effect_result
					.stamina_restoration_debt_paid_amount
			)
			* ENEMY_STAMINA_DEBT_PAYMENT_PENALTY_PER_POINT
		)


func _score_hero_core_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if (
		target == null
		or target.team_id != actor.team_id
	):
		return

	if effect_result.unbroken_was_restored:
		breakdown.add_score(
			SCORE_CORE_SURVIVAL,
			UNBROKEN_RESTORE_SCORE
		)

	if effect_result.fracture_was_removed:
		breakdown.add_score(
			SCORE_CORE_SURVIVAL,
			FRACTURE_REMOVE_SCORE
		)

	breakdown.add_score(
		SCORE_MAX_STAMINA_PENALTY,
		float(
			effect_result
				.max_stamina_penalty_applied_amount
		)
		* MAX_STAMINA_PENALTY_PER_POINT
	)

	breakdown.add_score(
		SCORE_STAMINA_RESTORE,
		float(
			effect_result.applied_amount
		)
		* STAMINA_RESTORE_SCORE_PER_POINT
	)

	breakdown.add_score(
		SCORE_STAMINA_DEBT_PAYMENT,
		float(
			effect_result
				.stamina_restoration_debt_paid_amount
		)
		* STAMINA_DEBT_PAYMENT_SCORE_PER_POINT
	)
	
func _score_heal_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	if target.team_id == actor.team_id:
		breakdown.add_score(
			SCORE_HEAL,
			float(
				effect_result.applied_amount
			)
			* HEAL_SCORE_PER_HP
		)

		breakdown.add_score(
			SCORE_OVERHEAL,
			float(
				effect_result.overheal_amount
			)
			* OVERHEAL_PENALTY_PER_HP
		)

	else:
		breakdown.add_score(
			SCORE_ENEMY_HEAL,
			float(
				effect_result.applied_amount
			)
			* ENEMY_HEAL_PENALTY_PER_HP
		)


func _score_guard_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	if target.team_id == actor.team_id:
		breakdown.add_score(
			SCORE_GUARD,
			float(
				effect_result.applied_amount
			)
			* GUARD_SCORE_PER_POINT
		)

		breakdown.add_score(
			SCORE_OVERGUARD,
			float(
				effect_result.overguard_amount
			)
			* OVERGUARD_PENALTY_PER_POINT
		)

	else:
		breakdown.add_score(
			SCORE_ENEMY_GUARD,
			float(
				effect_result.applied_amount
			)
			* ENEMY_GUARD_PENALTY_PER_POINT
		)


func _score_apply_status_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	if (
		not effect_result.is_successful
		or effect_result
			.status_application_blocked_by_immunity
	):
		return

	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	var changed_status := (
		effect_result.status_was_added
		or effect_result.current_status_stack_count
			!= effect_result
				.previous_status_stack_count
		or effect_result.current_status_remaining_turns
			!= effect_result
				.previous_status_remaining_turns
	)

	if not changed_status:
		return

	var is_ally := (
		target.team_id == actor.team_id
	)

	match effect_result.status_polarity:
		BattleStatusDefinition.Polarity.HARMFUL:
			if is_ally:
				breakdown.add_score(
					SCORE_BAD_STATUS,
					BAD_STATUS_PENALTY
				)

			else:
				breakdown.add_score(
					SCORE_STATUS,
					HARMFUL_STATUS_SCORE
				)

		BattleStatusDefinition.Polarity.BENEFICIAL:
			if is_ally:
				breakdown.add_score(
					SCORE_STATUS,
					BENEFICIAL_STATUS_SCORE
				)

			else:
				breakdown.add_score(
					SCORE_BAD_STATUS,
					BAD_STATUS_PENALTY
				)


func _score_remove_status_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	if not effect_result.is_successful:
		return

	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	var is_ally := (
		target.team_id == actor.team_id
	)

	for polarity in (
		effect_result.removed_status_polarities
	):
		match polarity:
			BattleStatusDefinition.Polarity.HARMFUL:
				if is_ally:
					breakdown.add_score(
						SCORE_CLEANSE,
						CLEANSE_SCORE
					)

				else:
					breakdown.add_score(
						SCORE_BAD_CLEANSE,
						BAD_CLEANSE_PENALTY
					)

			BattleStatusDefinition.Polarity.BENEFICIAL:
				if is_ally:
					breakdown.add_score(
						SCORE_BAD_CLEANSE,
						BAD_CLEANSE_PENALTY
					)

				else:
					breakdown.add_score(
						SCORE_CLEANSE,
						CLEANSE_SCORE
					)


func _score_armor_shift(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	var previous_armor := (
		effect_result.previous_target_effective_armor
	)

	var current_armor := (
		effect_result.current_target_effective_armor
	)

	if previous_armor == current_armor:
		return

	var target := (
		simulation.get_simulated_combatant(
			effect_result.target_id
		)
	)

	if target == null:
		return

	var armor_delta := (
		current_armor - previous_armor
	)

	var is_ally := (
		target.team_id == actor.team_id
	)

	var useful_delta := 0

	if is_ally:
		useful_delta = armor_delta

	else:
		useful_delta = - armor_delta

	breakdown.add_score(
		SCORE_ARMOR_SHIFT,
		float(useful_delta)
		* ARMOR_SHIFT_SCORE_PER_POINT
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


func _score_surface_awareness(
	breakdown: BattleAIScoreBreakdown,
	plan: BattleAIPlan,
	simulation: BattleActionSimulationResult
) -> void:
	if (
		breakdown == null
		or plan == null
		or simulation == null
		or not simulation.is_valid
		or simulation.simulated_session == null
	):
		return

	var actor := (
		simulation.get_simulated_actor()
	)

	if actor == null:
		return

	var initial_coordinate := (
		simulation.initial_actor_coordinate
	)

	if initial_coordinate == BattleGrid.INVALID_COORDINATE:
		initial_coordinate = actor.grid_position

	var final_coordinate := (
		simulation.final_actor_coordinate
	)

	if final_coordinate == BattleGrid.INVALID_COORDINATE:
		final_coordinate = actor.grid_position

	if final_coordinate == BattleGrid.INVALID_COORDINATE:
		final_coordinate = initial_coordinate

	if final_coordinate == BattleGrid.INVALID_COORDINATE:
		return

	var final_surface_score := (
		_get_surface_score_for_combatant_at(
			simulation.simulated_session,
			actor,
			final_coordinate
		)
	)

	breakdown.add_score(
		SCORE_SURFACE_CELL,
		final_surface_score
	)

	if initial_coordinate == BattleGrid.INVALID_COORDINATE:
		return

	var initial_surface_score := (
		_get_surface_score_from_snapshot(
			actor,
			simulation.initial_actor_surface_definitions,
			simulation.initial_actor_surface_source_team_ids
		)
	)

	var surface_improvement := (
		final_surface_score
		- initial_surface_score
	)

	if surface_improvement <= 0.0:
		return

	breakdown.add_score(
		SCORE_SURFACE_ESCAPE,
		surface_improvement
		* SURFACE_ESCAPE_SCORE_MULTIPLIER
	)

func _score_place_surface_result(
	breakdown: BattleAIScoreBreakdown,
	simulation: BattleActionSimulationResult,
	actor: CombatantState,
	effect_result: BattleEffectResult
) -> void:
	if (
		breakdown == null
		or simulation == null
		or actor == null
		or effect_result == null
		or not effect_result.is_successful
		or simulation.simulated_session == null
		or simulation
			.simulated_session
			.surface_effect_controller == null
	):
		return

	if (
		effect_result.effect_coordinate
		== BattleGrid.INVALID_COORDINATE
		or effect_result.surface_effect_id == &""
	):
		return

	## Повторное размещение той же поверхности на той же клетке
	## пока не считается новым полезным действием.
	## Иначе AI спамит обновление огня под уже горящей целью.
	if not effect_result.surface_was_added:
		return

	var placed_instance := (
		simulation
			.simulated_session
			.surface_effect_controller
			.get_effect_at(
				effect_result.effect_coordinate,
				effect_result.surface_effect_id
			)
	)

	if (
		placed_instance == null
		or placed_instance.definition == null
	):
		return

	var target := _get_combatant_at_coordinate(
		simulation.simulated_session,
		effect_result.effect_coordinate
	)

	if target == null:
		return

	var surface_value := _get_surface_definition_value_for_team(
		placed_instance.definition,
		placed_instance.source_team_id,
		target.team_id
	)

	if is_zero_approx(surface_value):
		return

	var is_ally := (
		target.team_id == actor.team_id
	)

	var score := 0.0

	if surface_value < 0.0:
		if is_ally:
			score = HARMFUL_SURFACE_ON_ALLY_PENALTY

		else:
			score = HARMFUL_SURFACE_ON_ENEMY_SCORE

	else:
		if is_ally:
			score = BENEFICIAL_SURFACE_ON_ALLY_SCORE

		else:
			score = BENEFICIAL_SURFACE_ON_ENEMY_PENALTY

	breakdown.add_score(
		SCORE_PLACE_SURFACE,
		score
	)


func _get_surface_score_from_snapshot(
	combatant: CombatantState,
	surface_definitions: Array[BattleSurfaceEffectDefinition],
	surface_source_team_ids: Array[StringName]
) -> float:
	if combatant == null:
		return 0.0

	var score := 0.0

	for surface_index in range(
		surface_definitions.size()
	):
		var definition := (
			surface_definitions[
				surface_index
			]
		)

		if definition == null:
			continue

		var source_team_id := &""

		if surface_index < surface_source_team_ids.size():
			source_team_id = (
				surface_source_team_ids[
					surface_index
				]
			)

		var surface_value := _get_surface_definition_value_for_team(
			definition,
			source_team_id,
			combatant.team_id
		)

		if surface_value < 0.0:
			score += HARMFUL_SURFACE_ON_SELF_PENALTY

		elif surface_value > 0.0:
			score += BENEFICIAL_SURFACE_ON_SELF_SCORE

	return score
    
func _get_surface_score_for_combatant_at(
	session: BattleSession,
	combatant: CombatantState,
	coordinate: Vector2i
) -> float:
	if (
		session == null
		or session.surface_effect_controller == null
		or combatant == null
		or coordinate == BattleGrid.INVALID_COORDINATE
	):
		return 0.0

	var score := 0.0

	for surface_instance in (
		session
			.surface_effect_controller
			.get_effects_at(
				coordinate
			)
	):
		if (
			surface_instance == null
			or surface_instance.definition == null
		):
			continue

		var surface_value := _get_surface_definition_value_for_team(
			surface_instance.definition,
			surface_instance.source_team_id,
			combatant.team_id
		)

		if surface_value < 0.0:
			score += HARMFUL_SURFACE_ON_SELF_PENALTY

		elif surface_value > 0.0:
			score += BENEFICIAL_SURFACE_ON_SELF_SCORE

	return score


func _get_surface_definition_value_for_team(
	definition: BattleSurfaceEffectDefinition,
	source_team_id: StringName,
	target_team_id: StringName
) -> float:
	if definition == null:
		return 0.0

	if not definition.can_affect_team(
		source_team_id,
		target_team_id
	):
		return 0.0

	var result := 0.0

	for effect in definition.effects:
		result += _get_surface_effect_value(
			effect
		)

	return result


func _get_surface_effect_value(
	effect: BattleEffect
) -> float:
	if effect == null:
		return 0.0

	if effect is DamageEffect:
		return -1.0

	if effect is HealEffect:
		return 1.0

	if effect is GrantGuardEffect:
		return 1.0

	if effect is ApplyStatusEffect:
		var status_effect := (
			effect as ApplyStatusEffect
		)

		if status_effect.status_definition == null:
			return 0.0

		match status_effect.status_definition.polarity:
			BattleStatusDefinition.Polarity.HARMFUL:
				return -1.0

			BattleStatusDefinition.Polarity.BENEFICIAL:
				return 1.0

	if effect is RemoveStatusEffect:
		return 0.0

	if effect is ForcedMovementEffect:
		return -0.25

	return 0.0


func _get_combatant_at_coordinate(
	session: BattleSession,
	coordinate: Vector2i
) -> CombatantState:
	if (
		session == null
		or session.grid == null
		or coordinate == BattleGrid.INVALID_COORDINATE
	):
		return null

	var cell := session.grid.get_cell(
		coordinate
	)

	if (
		cell == null
		or not cell.is_occupied()
	):
		return null

	return session.get_combatant(
		cell.occupant_id
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