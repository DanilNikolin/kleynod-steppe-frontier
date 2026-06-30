class_name BasicMeleeAIController
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_SESSION: StringName = &"invalid_session"
const FAILURE_INVALID_ACTOR: StringName = &"invalid_actor"
const FAILURE_INVALID_ABILITY: StringName = &"invalid_ability"
const FAILURE_UNSUPPORTED_ABILITY: StringName = &"unsupported_ability"

const FAILURE_ACTOR_DEAD: StringName = &"actor_dead"
const FAILURE_ACTOR_NOT_IN_SESSION: StringName = (
	&"actor_not_in_session"
)
const FAILURE_INVALID_MOVEMENT_COST: StringName = (
	&"invalid_movement_cost"
)

const FAILURE_NO_TARGETS: StringName = &"no_targets"
const FAILURE_NO_REACHABLE_TARGET: StringName = (
	&"no_reachable_target"
)
const FAILURE_NOT_ENOUGH_STAMINA: StringName = (
	&"not_enough_stamina"
)
const FAILURE_NOT_ENOUGH_STAMINA_FOR_ATTACK: StringName = (
	&"not_enough_stamina_for_attack"
)


var movement_service: BattleMovementService
var action_service: BattleActionService
var targeting_service: BattleTargetingService


func _init(
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService,
	p_targeting_service: BattleTargetingService
) -> void:
	assert(
		p_movement_service != null,
		"BasicMeleeAIController requires "
		+ "a movement service."
	)

	assert(
		p_action_service != null,
		"BasicMeleeAIController requires "
		+ "an action service."
	)

	assert(
		p_targeting_service != null,
		"BasicMeleeAIController requires "
		+ "a targeting service."
	)

	movement_service = p_movement_service
	action_service = p_action_service
	targeting_service = p_targeting_service


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
		session,
		actor,
		targets,
		ability
	)

	if immediate_target != null:
		plan.target = immediate_target
		plan.aim_coordinate = (
			immediate_target.grid_position
		)
		plan.expects_attack_after_movement = true
		plan.is_valid = true
		return plan

	# Если стоим рядом, но не хватает выносливости
	# на удар, двигаться уже некуда.
	var targetable_without_stamina := (
		_find_targetable_without_stamina(
			session,
			actor,
			targets,
			ability
		)
	)

	if targetable_without_stamina != null:
		plan.target = (
			targetable_without_stamina
		)

		plan.aim_coordinate = (
			targetable_without_stamina
			.grid_position
		)

		plan.failure_code = (
			FAILURE_NOT_ENOUGH_STAMINA_FOR_ATTACK
		)

		return plan

	var maximum_steps := floori(
		float(actor.current_stamina)
		/ float(stamina_cost_per_step)
	)

	if maximum_steps <= 0:
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return plan

	# Сначала ищем нормальный маршрут до клетки,
	# с которой можно будет атаковать цель.
	var best_attack_target: CombatantState = null
	var best_attack_path: Array[Vector2i] = []
	var best_attack_destination := (
		BattleGrid.INVALID_COORDINATE
	)

	for target in targets:
		var attack_positions := (
			_get_attack_positions(
				session,
				actor,
				target,
				ability
			)
		)

		for destination in attack_positions:
			var candidate_path := (
				movement_service.find_shortest_path(
					grid,
					actor.grid_position,
					destination,
					actor.team_id
				)
			)

			if candidate_path.is_empty():
				continue

			if _is_better_attack_route(
				candidate_path,
				target,
				destination,
				best_attack_path,
				best_attack_target,
				best_attack_destination
			):
				best_attack_path = candidate_path
				best_attack_target = target
				best_attack_destination = destination

	if (
		best_attack_target != null
		and not best_attack_path.is_empty()
	):
		var attack_plan_created := (
			_apply_movement_path_to_plan(
				plan,
				grid,
				actor,
				best_attack_target,
				ability,
				best_attack_path,
				maximum_steps,
				stamina_cost_per_step,
				true
			)
		)

		if attack_plan_created:
			return plan

	# Если клетки атаки временно перекрыты союзниками
	# или узким проходом, всё равно пытаемся занять
	# лучшую доступную позицию ближе к противнику.
	var approach_plan_created := (
		_try_create_approach_plan(
			plan,
			grid,
			session,
			actor,
			targets,
			ability,
			maximum_steps,
			stamina_cost_per_step
		)
	)

	if approach_plan_created:
		return plan

	plan.failure_code = FAILURE_NO_REACHABLE_TARGET
	return plan


func _try_create_approach_plan(
	plan: BasicMeleeAITurnPlan,
	grid: BattleGrid,
	session: BattleSession,
	actor: CombatantState,
	targets: Array[CombatantState],
	ability: AbilityDefinition,
	maximum_steps: int,
	stamina_cost_per_step: int
) -> bool:
	var best_target: CombatantState = null
	var best_path: Array[Vector2i] = []
	var best_destination := BattleGrid.INVALID_COORDINATE

	var best_remaining_distance: int = 1_000_000_000

	for target in targets:
		var current_distance := _get_manhattan_distance(
			actor.grid_position,
			target.grid_position
		)

		for y in range(grid.rows):
			for x in range(grid.columns):
				var destination := Vector2i(
					x,
					y
				)

				if destination == actor.grid_position:
					continue

				if not session.is_coordinate_allowed_for_team(
					actor.team_id,
					destination
				):
					continue

				var candidate_path := (
					movement_service.find_shortest_path(
						grid,
						actor.grid_position,
						destination,
						actor.team_id
					)
				)

				if candidate_path.is_empty():
					continue

				if candidate_path.size() > maximum_steps:
					continue

				var remaining_distance := (
					_get_manhattan_distance(
						destination,
						target.grid_position
					)
				)

				# Не тратим ход на движение, которое
				# вообще не приближает нас к цели.
				if remaining_distance >= current_distance:
					continue

				if _is_better_approach_route(
					candidate_path,
					target,
					destination,
					remaining_distance,
					best_path,
					best_target,
					best_destination,
					best_remaining_distance
				):
					best_path = candidate_path
					best_target = target
					best_destination = destination
					best_remaining_distance = (
						remaining_distance
					)

	if best_target == null or best_path.is_empty():
		return false

	return _apply_movement_path_to_plan(
		plan,
		grid,
		actor,
		best_target,
		ability,
		best_path,
		maximum_steps,
		stamina_cost_per_step,
		false
	)


func _apply_movement_path_to_plan(
	plan: BasicMeleeAITurnPlan,
	grid: BattleGrid,
	actor: CombatantState,
	target: CombatantState,
	ability: AbilityDefinition,
	path: Array[Vector2i],
	maximum_steps: int,
	stamina_cost_per_step: int,
	path_ends_in_attack_position: bool
) -> bool:
	if path.is_empty():
		return false

	var planned_steps := mini(
		maximum_steps,
		path.size()
	)

	if planned_steps <= 0:
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return false

	var movement_destination := (
		path[planned_steps - 1]
	)

	var movement_plan := movement_service.create_plan(
		grid,
		actor,
		movement_destination,
		stamina_cost_per_step
	)

	if not movement_plan.is_valid:
		plan.failure_code = movement_plan.failure_code
		return false

	plan.target = target
	plan.aim_coordinate = (
		target.grid_position
	)
	plan.movement_plan = movement_plan

	var reaches_path_destination := (
		planned_steps == path.size()
	)

	var total_cost_with_attack := (
		movement_plan.stamina_cost
		+ ability.stamina_cost
	)

	plan.expects_attack_after_movement = (
		path_ends_in_attack_position
		and reaches_path_destination
		and actor.current_stamina
		>= total_cost_with_attack
	)

	plan.is_valid = true
	return true


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
		ability.targeting == null
		or not ability.targeting
		.is_single_enemy_targeting()
	):
		return FAILURE_UNSUPPORTED_ABILITY

	if not actor.is_alive:
		return FAILURE_ACTOR_DEAD

	if not session.has_combatant(
		actor.instance_id
	):
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

		targets.append(
			combatant
		)

	return targets


func _find_immediate_target(
	session: BattleSession,
	actor: CombatantState,
	targets: Array[CombatantState],
	ability: AbilityDefinition
) -> CombatantState:
	var best_target: CombatantState = null

	for target in targets:
		var command := BattleActionCommand.new(
			actor,
			ability,
			target.grid_position
		)

		if not action_service.can_execute(
			session,
			command
		):
			continue

		if _is_preferred_target(
			target,
			best_target
		):
			best_target = target

	return best_target


func _find_targetable_without_stamina(
	session: BattleSession,
	actor: CombatantState,
	targets: Array[CombatantState],
	ability: AbilityDefinition
) -> CombatantState:
	if actor.can_spend_stamina(
		ability.stamina_cost
	):
		return null

	var best_target: CombatantState = null

	for target in targets:
		if not targeting_service.can_target(
			session,
			actor,
			ability,
			target.grid_position
		):
			continue

		if _is_preferred_target(
			target,
			best_target
		):
			best_target = target

	return best_target


func _get_attack_positions(
	session: BattleSession,
	actor: CombatantState,
	target: CombatantState,
	ability: AbilityDefinition
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if (
		session == null
		or session.grid == null
		or actor == null
		or target == null
		or ability == null
	):
		return result

	var grid := session.grid

	for coordinate in (
		grid.get_all_coordinates()
	):
		if not session.is_coordinate_allowed_for_team(
			actor.team_id,
			coordinate
		):
			continue

		if coordinate != actor.grid_position:
			var cell := grid.get_cell(
				coordinate
			)

			if (
				cell == null
				or not cell.is_walkable()
			):
				continue

		if not targeting_service.can_target_from(
			session,
			actor,
			ability,
			coordinate,
			target.grid_position
		):
			continue

		result.append(
			coordinate
		)

	return result


func _is_preferred_target(
	candidate: CombatantState,
	current_best: CombatantState
) -> bool:
	if current_best == null:
		return true

	if (
		candidate.current_health
		!= current_best.current_health
	):
		return (
			candidate.current_health
			< current_best.current_health
		)

	return (
		String(candidate.instance_id)
		< String(current_best.instance_id)
	)


func _is_better_attack_route(
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
		return (
			candidate_path.size()
			< best_path.size()
		)

	if (
		candidate_target.current_health
		!= best_target.current_health
	):
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
		return (
			candidate_destination.y
			< best_destination.y
		)

	return (
		candidate_destination.x
		< best_destination.x
	)


func _is_better_approach_route(
	candidate_path: Array[Vector2i],
	candidate_target: CombatantState,
	candidate_destination: Vector2i,
	candidate_remaining_distance: int,
	best_path: Array[Vector2i],
	best_target: CombatantState,
	best_destination: Vector2i,
	best_remaining_distance: int
) -> bool:
	if best_target == null:
		return true

	# Главное — оказаться как можно ближе к врагу.
	if (
		candidate_remaining_distance
		!= best_remaining_distance
	):
		return (
			candidate_remaining_distance
			< best_remaining_distance
		)

	# Если дистанция одинаковая, выбираем более
	# короткое и экономное перемещение.
	if candidate_path.size() != best_path.size():
		return (
			candidate_path.size()
			< best_path.size()
		)

	# Затем предпочитаем более раненую цель.
	if (
		candidate_target.current_health
		!= best_target.current_health
	):
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
		return (
			candidate_destination.y
			< best_destination.y
		)

	return (
		candidate_destination.x
		< best_destination.x
	)


func _get_manhattan_distance(
	from_coordinate: Vector2i,
	to_coordinate: Vector2i
) -> int:
	return (
		absi(
			from_coordinate.x
			- to_coordinate.x
		)
		+ absi(
			from_coordinate.y
			- to_coordinate.y
		)
	)