class_name BasicMeleeAIController
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_SESSION: StringName = &"invalid_session"
const FAILURE_INVALID_ACTOR: StringName = &"invalid_actor"
const FAILURE_INVALID_ABILITY: StringName = &"invalid_ability"
const FAILURE_UNSUPPORTED_ABILITY: StringName = &"unsupported_ability"

const FAILURE_ACTOR_DEAD: StringName = &"actor_dead"
const FAILURE_ACTOR_NOT_IN_SESSION: StringName = &"actor_not_in_session"
const FAILURE_INVALID_MOVEMENT_COST: StringName = &"invalid_movement_cost"

const FAILURE_NO_TARGETS: StringName = &"no_targets"
const FAILURE_NO_REACHABLE_TARGET: StringName = &"no_reachable_target"
const FAILURE_NOT_ENOUGH_STAMINA: StringName = &"not_enough_stamina"
const FAILURE_NOT_ENOUGH_STAMINA_FOR_ATTACK: StringName = (
	&"not_enough_stamina_for_attack"
)


var movement_service: BattleMovementService
var action_service: BattleActionService


func _init(
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService
) -> void:
	assert(
		p_movement_service != null,
		"BasicMeleeAIController requires a movement service."
	)

	assert(
		p_action_service != null,
		"BasicMeleeAIController requires an action service."
	)

	movement_service = p_movement_service
	action_service = p_action_service


func create_turn_plan(
	grid: BattleGrid,
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	stamina_cost_per_step: int = 1
) -> BasicMeleeAITurnPlan:
	var plan := BasicMeleeAITurnPlan.new()

	plan.actor = actor
	plan.ability = ability

	var validation_failure := _get_validation_failure(
		grid,
		session,
		actor,
		ability,
		stamina_cost_per_step
	)

	if validation_failure != &"":
		plan.failure_code = validation_failure
		return plan

	var targets := _get_enemy_targets(
		session,
		actor
	)

	if targets.is_empty():
		plan.failure_code = FAILURE_NO_TARGETS
		return plan

	var immediate_target := _find_immediate_target(
		grid,
		actor,
		targets,
		ability
	)

	if immediate_target != null:
		plan.target = immediate_target
		plan.expects_attack_after_movement = true
		plan.is_valid = true
		return plan

	var adjacent_target := _find_adjacent_target(
		grid,
		actor,
		targets
	)

	if adjacent_target != null:
		plan.target = adjacent_target
		plan.failure_code = (
			FAILURE_NOT_ENOUGH_STAMINA_FOR_ATTACK
		)
		return plan

	var best_target: CombatantState
	var best_path: Array[Vector2i] = []
	var best_destination := BattleGrid.INVALID_COORDINATE

	for target in targets:
		var attack_positions := (
			grid.get_orthogonal_neighbors(
				target.grid_position,
				true
			)
		)

		for destination in attack_positions:
			var candidate_path := (
				movement_service.find_shortest_path(
					grid,
					actor.grid_position,
					destination
				)
			)

			if candidate_path.is_empty():
				continue

			if _is_better_route(
				candidate_path,
				target,
				destination,
				best_path,
				best_target,
				best_destination
			):
				best_path = candidate_path
				best_target = target
				best_destination = destination

	if best_target == null or best_path.is_empty():
		plan.failure_code = FAILURE_NO_REACHABLE_TARGET
		return plan

	plan.target = best_target

	var maximum_steps := floori(
		float(actor.current_stamina)
		/ float(stamina_cost_per_step)
	)

	if maximum_steps <= 0:
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return plan

	var planned_steps := mini(
		maximum_steps,
		best_path.size()
	)

	var movement_destination := (
		best_path[planned_steps - 1]
	)

	var movement_plan := movement_service.create_plan(
		grid,
		actor,
		movement_destination,
		stamina_cost_per_step
	)

	if not movement_plan.is_valid:
		plan.failure_code = movement_plan.failure_code
		return plan

	plan.movement_plan = movement_plan

	var reaches_attack_position := (
		planned_steps == best_path.size()
	)

	var total_cost_with_attack := (
		movement_plan.stamina_cost
		+ ability.stamina_cost
	)

	plan.expects_attack_after_movement = (
		reaches_attack_position
		and actor.current_stamina >= total_cost_with_attack
	)

	plan.is_valid = true
	return plan


func _get_validation_failure(
	grid: BattleGrid,
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	stamina_cost_per_step: int
) -> StringName:
	if grid == null:
		return FAILURE_INVALID_GRID

	if session == null:
		return FAILURE_INVALID_SESSION

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if ability == null or not ability.is_valid_definition():
		return FAILURE_INVALID_ABILITY

	if (
		ability.target_relation
		!= AbilityDefinition.TargetRelation.ENEMY
		or ability.minimum_range != 1
		or ability.maximum_range != 1
	):
		return FAILURE_UNSUPPORTED_ABILITY

	if not actor.is_alive:
		return FAILURE_ACTOR_DEAD

	if not session.has_combatant(actor.instance_id):
		return FAILURE_ACTOR_NOT_IN_SESSION

	if stamina_cost_per_step <= 0:
		return FAILURE_INVALID_MOVEMENT_COST

	return &""


func _get_enemy_targets(
	session: BattleSession,
	actor: CombatantState
) -> Array[CombatantState]:
	var targets: Array[CombatantState] = []

	for combatant in session.get_living_combatants():
		if combatant == actor:
			continue

		if combatant.team_id == actor.team_id:
			continue

		targets.append(combatant)

	return targets


func _find_immediate_target(
	grid: BattleGrid,
	actor: CombatantState,
	targets: Array[CombatantState],
	ability: AbilityDefinition
) -> CombatantState:
	var best_target: CombatantState

	for target in targets:
		var command := BattleActionCommand.new(
			actor,
			target,
			ability
		)

		if not action_service.can_execute(
			grid,
			command
		):
			continue

		if _is_preferred_target(
			target,
			best_target
		):
			best_target = target

	return best_target


func _find_adjacent_target(
	grid: BattleGrid,
	actor: CombatantState,
	targets: Array[CombatantState]
) -> CombatantState:
	var best_target: CombatantState

	for target in targets:
		if not grid.are_orthogonally_adjacent(
			actor.grid_position,
			target.grid_position
		):
			continue

		if _is_preferred_target(
			target,
			best_target
		):
			best_target = target

	return best_target


func _is_preferred_target(
	candidate: CombatantState,
	current_best: CombatantState
) -> bool:
	if current_best == null:
		return true

	if candidate.current_health != current_best.current_health:
		return candidate.current_health < current_best.current_health

	return (
		String(candidate.instance_id)
		< String(current_best.instance_id)
	)


func _is_better_route(
	candidate_path: Array[Vector2i],
	candidate_target: CombatantState,
	candidate_destination: Vector2i,
	best_path: Array[Vector2i],
	best_target: CombatantState,
	best_destination: Vector2i
) -> bool:
	if best_target == null:
		return true

	if candidate_path.size() != best_path.size():
		return candidate_path.size() < best_path.size()

	if candidate_target.current_health != best_target.current_health:
		return (
			candidate_target.current_health
			< best_target.current_health
		)

	var candidate_id := String(
		candidate_target.instance_id
	)

	var best_id := String(
		best_target.instance_id
	)

	if candidate_id != best_id:
		return candidate_id < best_id

	if candidate_destination.y != best_destination.y:
		return candidate_destination.y < best_destination.y

	return candidate_destination.x < best_destination.x