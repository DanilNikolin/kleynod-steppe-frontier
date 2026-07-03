class_name BattleAIPlanGenerator
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_GRID: StringName = (
	&"invalid_grid"
)

const FAILURE_INVALID_ACTOR: StringName = (
	&"invalid_actor"
)

const FAILURE_ACTOR_DEAD: StringName = (
	&"actor_dead"
)

const FAILURE_ACTOR_NOT_IN_SESSION: StringName = (
	&"actor_not_in_session"
)

const FAILURE_INVALID_MOVEMENT_COST: StringName = (
	&"invalid_movement_cost"
)

const FAILURE_NO_AIM_COORDINATES: StringName = (
	&"no_aim_coordinates"
)

const FAILURE_MOVEMENT_RESTRICTED: StringName = (
	&"movement_restricted"
)

const FAILURE_NOT_ENOUGH_STAMINA_FOR_MOVEMENT: StringName = (
	&"not_enough_stamina_for_movement"
)

const FAILURE_SNAPSHOT_CREATION_FAILED: StringName = (
	&"snapshot_creation_failed"
)

const FAILURE_SNAPSHOT_ACTOR_MISSING: StringName = (
	&"snapshot_actor_missing"
)

const FAILURE_SNAPSHOT_MOVEMENT_COMMIT_FAILED: StringName = (
	&"snapshot_movement_commit_failed"
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
		"BattleAIPlanGenerator requires "
		+"a movement service."
	)

	assert(
		p_action_service != null,
		"BattleAIPlanGenerator requires "
		+"an action service."
	)

	assert(
		p_targeting_service != null,
		"BattleAIPlanGenerator requires "
		+"a targeting service."
	)

	movement_service = p_movement_service
	action_service = p_action_service
	targeting_service = p_targeting_service


func create_report(
	session: BattleSession,
	actor: CombatantState,
	stamina_cost_per_step: int = 1
) -> BattleAIPlanningReport:
	var report := BattleAIPlanningReport.new()

	if actor != null:
		report.actor_id = actor.instance_id

	var validation_failure := (
		_get_validation_failure(
			session,
			actor,
			stamina_cost_per_step
		)
	)

	if validation_failure != &"":
		report.failure_code = validation_failure
		return report

	_append_wait_plan(
		report,
		actor
	)

	_append_action_plans(
		report,
		session,
		actor
	)

	var movement_plans := (
		_append_movement_plans(
			report,
			session,
			actor,
			stamina_cost_per_step
		)
	)

	_append_movement_action_plans(
		report,
		session,
		actor,
		movement_plans
	)

	_append_ally_swap_plans(
		report,
		session,
		actor,
		stamina_cost_per_step
	)

	report.sort_plans()
	report.is_valid = true

	return report


func _append_wait_plan(
	report: BattleAIPlanningReport,
	actor: CombatantState
) -> void:
	var plan := _create_base_plan(
		actor
	)

	plan.remaining_stamina = (
		actor.current_stamina
	)

	plan.is_valid = true

	report.add_plan(
		plan
	)


func _append_action_plans(
	report: BattleAIPlanningReport,
	session: BattleSession,
	actor: CombatantState
) -> void:
	var abilities := actor.get_abilities()

	abilities.sort_custom(
		Callable(
			self,
			"_is_ability_before"
		)
	)

	for ability in abilities:
		var ability_failure := (
			_get_ability_precheck_failure(
				actor,
				ability
			)
		)

		if ability_failure != &"":
			report.add_rejection(
				ability_failure
			)

			continue

		var aim_coordinates := (
			targeting_service.get_aim_coordinates(
				session,
				actor,
				ability
			)
		)

		_sort_coordinates(
			aim_coordinates
		)

		if aim_coordinates.is_empty():
			report.add_rejection(
				FAILURE_NO_AIM_COORDINATES
			)

			continue

		for aim_coordinate in aim_coordinates:
			var command := BattleActionCommand.new(
				actor,
				ability,
				aim_coordinate
			)

			var failure_code := (
				action_service
				.get_validation_failure(
					session,
					command
				)
			)

			if failure_code != &"":
				report.add_rejection(
					failure_code
				)

				continue

			var plan := _create_base_plan(
				actor
			)

			plan.ability = ability
			plan.aim_coordinate = (
				aim_coordinate
			)

			plan.action_stamina_cost = (
				ability.stamina_cost
			)

			_finalize_plan_costs(
				plan,
				actor.current_stamina
			)

			plan.is_valid = true

			report.add_plan(
				plan
			)


func _append_movement_plans(
	report: BattleAIPlanningReport,
	session: BattleSession,
	actor: CombatantState,
	stamina_cost_per_step: int
) -> Array[BattleMovementPlan]:
	var valid_movement_plans: Array[BattleMovementPlan] = []

	if actor.is_movement_restricted():
		report.add_rejection(
			FAILURE_MOVEMENT_RESTRICTED
		)

		return valid_movement_plans

	var maximum_steps := floori(
		float(actor.current_stamina)
		/ float(stamina_cost_per_step)
	)

	if maximum_steps <= 0:
		report.add_rejection(
			FAILURE_NOT_ENOUGH_STAMINA_FOR_MOVEMENT
		)

		return valid_movement_plans

	var reachable_coordinates := (
		movement_service
		.get_reachable_coordinates(
			session.grid,
			actor.grid_position,
			maximum_steps,
			actor.team_id
		)
	)

	_sort_coordinates(
		reachable_coordinates
	)

	for coordinate in reachable_coordinates:
		if coordinate == actor.grid_position:
			continue

		var movement_plan := (
			movement_service.create_plan(
				session.grid,
				actor,
				coordinate,
				stamina_cost_per_step
			)
		)

		if not movement_plan.is_valid:
			report.add_rejection(
				movement_plan.failure_code
			)

			continue

		valid_movement_plans.append(
			movement_plan
		)

		var plan := _create_base_plan(
			actor
		)

		plan.movement_plan = movement_plan

		plan.movement_stamina_cost = (
			movement_plan.stamina_cost
		)

		_finalize_plan_costs(
			plan,
			actor.current_stamina
		)

		plan.is_valid = true

		report.add_plan(
			plan
		)

	return valid_movement_plans


func _append_movement_action_plans(
	report: BattleAIPlanningReport,
	session: BattleSession,
	actor: CombatantState,
	movement_plans: Array[BattleMovementPlan]
) -> void:
	if movement_plans.is_empty():
		return

	var abilities := actor.get_abilities()

	abilities.sort_custom(
		Callable(
			self,
			"_is_ability_before"
		)
	)

	for movement_plan in movement_plans:
		if (
			movement_plan == null
			or not movement_plan.is_valid
		):
			continue

		var snapshot_session := (
			session.create_runtime_copy()
		)

		if snapshot_session == null:
			report.add_rejection(
				FAILURE_SNAPSHOT_CREATION_FAILED
			)

			continue

		var snapshot_actor := (
			snapshot_session.get_combatant(
				actor.instance_id
			)
		)

		if snapshot_actor == null:
			report.add_rejection(
				FAILURE_SNAPSHOT_ACTOR_MISSING
			)

			continue

		if not movement_service.commit_plan(
			snapshot_session.grid,
			snapshot_actor,
			movement_plan
		):
			report.add_rejection(
				FAILURE_SNAPSHOT_MOVEMENT_COMMIT_FAILED
			)

			continue

		for ability in abilities:
			var ability_failure := (
				_get_ability_precheck_failure(
					snapshot_actor,
					ability
				)
			)

			if ability_failure != &"":
				report.add_rejection(
					ability_failure
				)

				continue

			var aim_coordinates := (
				targeting_service
					.get_aim_coordinates(
						snapshot_session,
						snapshot_actor,
						ability
					)
			)

			_sort_coordinates(
				aim_coordinates
			)

			if aim_coordinates.is_empty():
				report.add_rejection(
					FAILURE_NO_AIM_COORDINATES
				)

				continue

			for aim_coordinate in aim_coordinates:
				var command := BattleActionCommand.new(
					snapshot_actor,
					ability,
					aim_coordinate
				)

				var failure_code := (
					action_service
						.get_validation_failure(
							snapshot_session,
							command
						)
				)

				if failure_code != &"":
					report.add_rejection(
						failure_code
					)

					continue

				var plan := _create_base_plan(
					actor
				)

				plan.movement_plan = (
					movement_plan
				)

				plan.ability = ability
				plan.aim_coordinate = (
					aim_coordinate
				)

				plan.movement_stamina_cost = (
					movement_plan.stamina_cost
				)

				plan.action_stamina_cost = (
					ability.stamina_cost
				)

				_finalize_plan_costs(
					plan,
					actor.current_stamina
				)

				plan.is_valid = true

				report.add_plan(
					plan
				)
                
func _append_ally_swap_plans(
	report: BattleAIPlanningReport,
	session: BattleSession,
	actor: CombatantState,
	stamina_cost: int
) -> void:
	if actor.is_movement_restricted():
		return

	var allies := session.get_team_combatants(
		actor.team_id,
		true
	)

	allies.sort_custom(
		Callable(
			self,
			"_is_combatant_before"
		)
	)

	for ally in allies:
		if ally == null or ally == actor:
			continue

		var failure_code := (
			movement_service
			.get_ally_swap_failure(
				session,
				actor,
				ally,
				stamina_cost
			)
		)

		if failure_code != &"":
			report.add_rejection(
				failure_code
			)

			continue

		var plan := _create_base_plan(
			actor
		)

		plan.ally_swap_target_id = (
			ally.instance_id
		)

		plan.ally_swap_target_coordinate = (
			ally.grid_position
		)

		plan.ally_swap_stamina_cost = (
			stamina_cost
		)

		_finalize_plan_costs(
			plan,
			actor.current_stamina
		)

		plan.is_valid = true

		report.add_plan(
			plan
		)


func _create_base_plan(
	actor: CombatantState
) -> BattleAIPlan:
	var plan := BattleAIPlan.new()

	plan.actor_id = actor.instance_id

	plan.origin_coordinate = (
		actor.grid_position
	)

	plan.available_stamina_before = (
		actor.current_stamina
	)

	return plan


func _finalize_plan_costs(
	plan: BattleAIPlan,
	available_stamina: int
) -> void:
	plan.total_stamina_cost = (
		plan.movement_stamina_cost
		+ plan.ally_swap_stamina_cost
		+ plan.action_stamina_cost
	)

	plan.remaining_stamina = maxi(
		0,
		available_stamina
		- plan.total_stamina_cost
	)


func _get_validation_failure(
	session: BattleSession,
	actor: CombatantState,
	stamina_cost_per_step: int
) -> StringName:
	if session == null:
		return FAILURE_INVALID_SESSION

	if session.grid == null:
		return FAILURE_INVALID_GRID

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if not actor.is_alive:
		return FAILURE_ACTOR_DEAD

	if not session.has_combatant(
		actor.instance_id
	):
		return FAILURE_ACTOR_NOT_IN_SESSION

	if stamina_cost_per_step <= 0:
		return FAILURE_INVALID_MOVEMENT_COST

	return &""


func _get_ability_precheck_failure(
	actor: CombatantState,
	ability: AbilityDefinition
) -> StringName:
	if ability == null:
		return BattleActionService.FAILURE_INVALID_ABILITY

	if not ability.is_valid_definition():
		return (
			BattleActionService
			.FAILURE_INVALID_ABILITY_DEFINITION
		)

	if not actor.has_ability(
		ability.ability_id
	):
		return (
			BattleActionService
			.FAILURE_ABILITY_NOT_IN_LOADOUT
		)

	if actor.is_ability_locked(
		ability.ability_id
	):
		return (
			BattleActionService
			.FAILURE_ABILITY_ON_COOLDOWN
		)

	if actor.is_ability_restricted(
		ability.ability_id
	):
		return (
			BattleActionService
			.FAILURE_ABILITY_RESTRICTED
		)

	if not actor.can_spend_stamina(
		ability.stamina_cost
	):
		return (
			BattleActionService
			.FAILURE_NOT_ENOUGH_STAMINA
		)

	return &""


func _sort_coordinates(
	coordinates: Array[Vector2i]
) -> void:
	coordinates.sort_custom(
		Callable(
			self,
			"_is_coordinate_before"
		)
	)


func _is_coordinate_before(
	first: Vector2i,
	second: Vector2i
) -> bool:
	if first.y != second.y:
		return first.y < second.y

	return first.x < second.x


func _is_ability_before(
	first: AbilityDefinition,
	second: AbilityDefinition
) -> bool:
	if first == null:
		return false

	if second == null:
		return true

	return (
		String(first.ability_id)
		< String(second.ability_id)
	)


func _is_combatant_before(
	first: CombatantState,
	second: CombatantState
) -> bool:
	if first == null:
		return false

	if second == null:
		return true

	return (
		String(first.instance_id)
		< String(second.instance_id)
	)