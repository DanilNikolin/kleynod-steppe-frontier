class_name BattleTargetingService
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

const FAILURE_INVALID_ABILITY: StringName = (
	&"invalid_ability"
)

const FAILURE_INVALID_ABILITY_DEFINITION: StringName = (
	&"invalid_ability_definition"
)

const FAILURE_ACTOR_DEAD: StringName = (
	&"actor_dead"
)

const FAILURE_ACTOR_NOT_IN_SESSION: StringName = (
	&"actor_not_in_session"
)

const FAILURE_ACTOR_NOT_ON_GRID: StringName = (
	&"actor_not_on_grid"
)

const FAILURE_INVALID_ORIGIN: StringName = (
	&"invalid_origin"
)

const FAILURE_INVALID_FORWARD_DIRECTION: StringName = (
	&"invalid_forward_direction"
)

const FAILURE_AIM_OUTSIDE_GRID: StringName = (
	&"aim_outside_grid"
)

const FAILURE_AIM_NOT_IN_PATTERN: StringName = (
	&"aim_not_in_pattern"
)

const FAILURE_AIM_CELL_MUST_BE_OCCUPIED: StringName = (
	&"aim_cell_must_be_occupied"
)

const FAILURE_AIM_CELL_MUST_BE_EMPTY: StringName = (
	&"aim_cell_must_be_empty"
)

const FAILURE_INVALID_AIM_RELATION: StringName = (
	&"invalid_aim_relation"
)

const FAILURE_TARGET_PROTECTED_BY_BLOCKER: StringName = (
	&"target_protected_by_blocker"
)


func create_result(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> BattleTargetingResult:
	var result := BattleTargetingResult.new()

	if actor != null:
		result.actor_id = actor.instance_id
		result.origin_coordinate = (
			actor.grid_position
		)

	if ability != null:
		result.ability_id = ability.ability_id

	result.aim_coordinate = aim_coordinate

	var origin_coordinate := (
		actor.grid_position
		if actor != null
		else BattleGrid.INVALID_COORDINATE
	)

	var failure_code := (
		_get_validation_failure(
			session,
			actor,
			ability,
			origin_coordinate,
			aim_coordinate,
			true
		)
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	var targeting := ability.targeting

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	var used_coordinates: Dictionary = {}
	var used_combatants: Dictionary = {}

	for impact_offset in (
		targeting.impact_offsets
	):
		var oriented_offset := Vector2i(
			impact_offset.x * forward_direction,
			impact_offset.y
		)

		var affected_coordinate := (
			aim_coordinate + oriented_offset
		)

		# Область за краем поля просто обрезается.
		if not session.grid.is_inside(
			affected_coordinate
		):
			continue

		if not used_coordinates.has(
			affected_coordinate
		):
			used_coordinates[
				affected_coordinate
			] = true

			result.affected_coordinates.append(
				affected_coordinate
			)

		var target := (
			_get_combatant_at_coordinate(
				session,
				affected_coordinate
			)
		)

		if (
			target == null
			or not target.is_alive
		):
			continue

		if not _is_relation_allowed(
			actor,
			target,
			targeting.affected_relation_mask
		):
			continue

		# Враждебные эффекты не попадают по цели,
		# если между атакующим и целью находится
		# живой союзный target blocker.
		if (
			get_target_blocker_from(
				session,
				actor,
				origin_coordinate,
				target
			) != null
		):
			continue

		if used_combatants.has(
			target.instance_id
		):
			continue

		used_combatants[
			target.instance_id
		] = true

		result.affected_combatants.append(
			target
		)

	result.is_valid = true
	return result


func get_aim_coordinates(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if (
		session == null
		or session.grid == null
		or actor == null
		or ability == null
		or ability.targeting == null
	):
		return result

	if not actor.is_alive:
		return result

	if not session.has_combatant(
		actor.instance_id
	):
		return result

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	if forward_direction == 0:
		return result

	var used_coordinates: Dictionary = {}

	for aim_offset in (
		ability.targeting.aim_offsets
	):
		var oriented_offset := Vector2i(
			aim_offset.x * forward_direction,
			aim_offset.y
		)

		var coordinate := (
			actor.grid_position
			+ oriented_offset
		)

		if not session.grid.is_inside(
			coordinate
		):
			continue

		if used_coordinates.has(
			coordinate
		):
			continue

		used_coordinates[
			coordinate
		] = true

		result.append(
			coordinate
		)

	return result


func get_impact_coordinates(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if (
		session == null
		or session.grid == null
		or actor == null
		or ability == null
		or ability.targeting == null
	):
		return result

	var aim_coordinates := (
		get_aim_coordinates(
			session,
			actor,
			ability
		)
	)

	if not aim_coordinates.has(
		aim_coordinate
	):
		return result

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	if forward_direction == 0:
		return result

	var used_coordinates: Dictionary = {}

	for impact_offset in (
		ability.targeting.impact_offsets
	):
		var oriented_offset := Vector2i(
			impact_offset.x * forward_direction,
			impact_offset.y
		)

		var coordinate := (
			aim_coordinate
			+ oriented_offset
		)

		if not session.grid.is_inside(
			coordinate
		):
			continue

		if used_coordinates.has(
			coordinate
		):
			continue

		used_coordinates[
			coordinate
		] = true

		result.append(
			coordinate
		)

	return result


func can_target(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> bool:
	if actor == null:
		return false

	return (
		_get_validation_failure(
			session,
			actor,
			ability,
			actor.grid_position,
			aim_coordinate,
			true
		) == &""
	)


## Используется ИИ для проверки гипотетической
## позиции, на которую актёр ещё только планирует прийти.
func can_target_from(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	origin_coordinate: Vector2i,
	aim_coordinate: Vector2i
) -> bool:
	return (
		_get_validation_failure(
			session,
			actor,
			ability,
			origin_coordinate,
			aim_coordinate,
			false
		) == &""
	)


func get_validation_failure(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	aim_coordinate: Vector2i
) -> StringName:
	if actor == null:
		return FAILURE_INVALID_ACTOR

	return _get_validation_failure(
		session,
		actor,
		ability,
		actor.grid_position,
		aim_coordinate,
		true
	)


func get_target_blocker(
	session: BattleSession,
	actor: CombatantState,
	target: CombatantState
) -> CombatantState:
	if actor == null:
		return null

	return get_target_blocker_from(
		session,
		actor,
		actor.grid_position,
		target
	)


func get_target_blocker_from(
	session: BattleSession,
	actor: CombatantState,
	origin_coordinate: Vector2i,
	target: CombatantState
) -> CombatantState:
	if (
		session == null
		or session.grid == null
		or actor == null
		or target == null
	):
		return null

	# Союзные и собственные эффекты стеной не блокируются.
	if actor.team_id == target.team_id:
		return null

	if not actor.is_alive or not target.is_alive:
		return null

	if not session.grid.is_inside(
		origin_coordinate
	):
		return null

	var target_coordinate := (
		target.grid_position
	)

	if not session.grid.is_inside(
		target_coordinate
	):
		return null

	if (
		origin_coordinate.x
		== target_coordinate.x
	):
		return null

	var minimum_x := mini(
		origin_coordinate.x,
		target_coordinate.x
	)

	var maximum_x := maxi(
		origin_coordinate.x,
		target_coordinate.x
	)

	var nearest_blocker: CombatantState = null
	var nearest_distance: int = 1_000_000_000

	for candidate in (
		session.get_team_combatants(
			target.team_id,
			true
		)
	):
		if (
			candidate == null
			or candidate == target
			or candidate.definition == null
		):
			continue

		if not (
			candidate
			.definition
			.blocks_hostile_targeting_behind
		):
			continue

		var candidate_coordinate := (
			candidate.grid_position
		)

		# Стена защищает только свой горизонтальный ряд.
		if (
			candidate_coordinate.y
			!= target_coordinate.y
		):
			continue

		# Blocker обязан находиться строго между
		# атакующим и защищаемой целью.
		if (
			candidate_coordinate.x <= minimum_x
			or candidate_coordinate.x >= maximum_x
		):
			continue

		if not session.grid.has_occupant(
			candidate.instance_id
		):
			continue

		if (
			session.grid.get_occupant_position(
				candidate.instance_id
			) != candidate_coordinate
		):
			continue

		var distance_from_origin := absi(
			candidate_coordinate.x
			- origin_coordinate.x
		)

		if (
			nearest_blocker == null
			or distance_from_origin
			< nearest_distance
			or (
				distance_from_origin
				== nearest_distance
				and String(
					candidate.instance_id
				) < String(
					nearest_blocker.instance_id
				)
			)
		):
			nearest_blocker = candidate
			nearest_distance = (
				distance_from_origin
			)

	return nearest_blocker


func _get_validation_failure(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	origin_coordinate: Vector2i,
	aim_coordinate: Vector2i,
	require_actor_at_origin: bool
) -> StringName:
	if session == null:
		return FAILURE_INVALID_SESSION

	var grid := session.grid

	if grid == null:
		return FAILURE_INVALID_GRID

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if ability == null:
		return FAILURE_INVALID_ABILITY

	if not ability.is_valid_definition():
		return FAILURE_INVALID_ABILITY_DEFINITION

	if not actor.is_alive:
		return FAILURE_ACTOR_DEAD

	if not session.has_combatant(
		actor.instance_id
	):
		return FAILURE_ACTOR_NOT_IN_SESSION

	if not grid.is_inside(
		origin_coordinate
	):
		return FAILURE_INVALID_ORIGIN

	if not session.is_coordinate_allowed_for_team(
		actor.team_id,
		origin_coordinate
	):
		return FAILURE_INVALID_ORIGIN

	if require_actor_at_origin:
		if (
			actor.grid_position
			!= origin_coordinate
		):
			return FAILURE_ACTOR_NOT_ON_GRID

		if not grid.has_occupant(
			actor.instance_id
		):
			return FAILURE_ACTOR_NOT_ON_GRID

		if (
			grid.get_occupant_position(
				actor.instance_id
			) != origin_coordinate
		):
			return FAILURE_ACTOR_NOT_ON_GRID

	var forward_direction := (
		session.get_team_forward_direction(
			actor.team_id
		)
	)

	if forward_direction == 0:
		return FAILURE_INVALID_FORWARD_DIRECTION

	if not grid.is_inside(
		aim_coordinate
	):
		return FAILURE_AIM_OUTSIDE_GRID

	if not _is_aim_coordinate_in_pattern(
		ability.targeting,
		origin_coordinate,
		aim_coordinate,
		forward_direction
	):
		return FAILURE_AIM_NOT_IN_PATTERN

	var aimed_combatant := (
		_get_combatant_at_coordinate(
			session,
			aim_coordinate
		)
	)

	match ability.targeting.aim_requirement:
		AbilityTargetingDefinition.AimRequirement.OCCUPIED_CELL:
			if (
				aimed_combatant == null
				or not aimed_combatant.is_alive
			):
				return (
					FAILURE_AIM_CELL_MUST_BE_OCCUPIED
				)

		AbilityTargetingDefinition.AimRequirement.EMPTY_CELL:
			if aimed_combatant != null:
				return (
					FAILURE_AIM_CELL_MUST_BE_EMPTY
				)

		AbilityTargetingDefinition.AimRequirement.ANY_CELL:
			pass

		_:
			return FAILURE_INVALID_ABILITY_DEFINITION

	if (
		aimed_combatant != null
		and not _is_relation_allowed(
			actor,
			aimed_combatant,
			ability.targeting.aim_relation_mask
		)
	):
		return FAILURE_INVALID_AIM_RELATION

	# Нельзя напрямую выбрать защищённого врага.
	if (
		aimed_combatant != null
		and get_target_blocker_from(
			session,
			actor,
			origin_coordinate,
			aimed_combatant
		) != null
	):
		return FAILURE_TARGET_PROTECTED_BY_BLOCKER

	return &""


func _is_aim_coordinate_in_pattern(
	targeting: AbilityTargetingDefinition,
	origin_coordinate: Vector2i,
	aim_coordinate: Vector2i,
	forward_direction: int
) -> bool:
	for aim_offset in targeting.aim_offsets:
		var oriented_offset := Vector2i(
			aim_offset.x * forward_direction,
			aim_offset.y
		)

		if (
			origin_coordinate + oriented_offset
			== aim_coordinate
		):
			return true

	return false


func _get_combatant_at_coordinate(
	session: BattleSession,
	coordinate: Vector2i
) -> CombatantState:
	if (
		session == null
		or session.grid == null
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


func _is_relation_allowed(
	actor: CombatantState,
	target: CombatantState,
	relation_mask: int
) -> bool:
	var relation_bit := (
		_get_relation_bit(
			actor,
			target
		)
	)

	return (
		relation_bit != 0
		and (
			relation_mask
			& relation_bit
		) != 0
	)


func _get_relation_bit(
	actor: CombatantState,
	target: CombatantState
) -> int:
	if actor == null or target == null:
		return 0

	if actor == target:
		return (
			AbilityTargetingDefinition
			.RelationMask.SELF
		)

	if actor.team_id == target.team_id:
		return (
			AbilityTargetingDefinition
			.RelationMask.ALLY
		)

	return (
		AbilityTargetingDefinition
		.RelationMask.ENEMY
	)