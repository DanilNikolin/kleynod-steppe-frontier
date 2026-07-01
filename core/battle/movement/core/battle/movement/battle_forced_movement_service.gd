class_name BattleForcedMovementService
extends RefCounted


const FAILURE_INVALID_GRID: StringName = (
	&"invalid_grid"
)

const FAILURE_INVALID_SOURCE: StringName = (
	&"invalid_source"
)

const FAILURE_INVALID_TARGET: StringName = (
	&"invalid_target"
)

const FAILURE_INVALID_EFFECT: StringName = (
	&"invalid_effect"
)

const FAILURE_TARGET_DEAD: StringName = (
	&"target_dead"
)

const FAILURE_SAME_COORDINATE: StringName = (
	&"same_coordinate"
)


const BLOCK_OUTSIDE_GRID: StringName = (
	&"outside_grid"
)

const BLOCK_CELL_OCCUPIED_OR_OBSTRUCTED: StringName = (
	&"cell_occupied_or_obstructed"
)


func create_resolution(
	grid: BattleGrid,
	source: CombatantState,
	target: CombatantState,
	effect: ForcedMovementEffect
) -> BattleForcedMovementResolution:
	var resolution := (
		BattleForcedMovementResolution.new()
	)

	if grid == null:
		resolution.failure_code = (
			FAILURE_INVALID_GRID
		)

		return resolution

	if source == null:
		resolution.failure_code = (
			FAILURE_INVALID_SOURCE
		)

		return resolution

	if target == null:
		resolution.failure_code = (
			FAILURE_INVALID_TARGET
		)

		return resolution

	if effect == null or not effect.is_valid_effect():
		resolution.failure_code = (
			FAILURE_INVALID_EFFECT
		)

		return resolution

	if not target.is_alive:
		resolution.failure_code = (
			FAILURE_TARGET_DEAD
		)

		return resolution

	resolution.origin = target.grid_position
	resolution.destination = target.grid_position
	resolution.requested_distance = effect.distance

	var direction := _get_direction(
		source.grid_position,
		target.grid_position,
		effect.direction_mode
	)

	if direction == Vector2i.ZERO:
		resolution.failure_code = (
			FAILURE_SAME_COORDINATE
		)

		return resolution

	resolution.direction = direction

	var cursor := target.grid_position

	for _step_index in range(
		effect.distance
	):
		var next_coordinate := (
			cursor + direction
		)

		if not grid.is_inside(
			next_coordinate
		):
			resolution.was_blocked = true
			resolution.block_reason = (
				BLOCK_OUTSIDE_GRID
			)

			break

		var next_cell := grid.get_cell(
			next_coordinate
		)

		if (
			next_cell == null
			or not next_cell.is_walkable()
		):
			resolution.was_blocked = true
			resolution.block_reason = (
				BLOCK_CELL_OCCUPIED_OR_OBSTRUCTED
			)

			break

		resolution.path.append(
			next_coordinate
		)

		cursor = next_coordinate

	resolution.destination = cursor
	resolution.is_valid = true

	return resolution


func commit_resolution(
	grid: BattleGrid,
	target: CombatantState,
	resolution: BattleForcedMovementResolution
) -> bool:
	if (
		grid == null
		or target == null
		or resolution == null
		or not resolution.is_valid
	):
		return false

	if resolution.path.is_empty():
		return true

	if (
		target.grid_position
		!= resolution.origin
	):
		return false

	var original_coordinate := (
		target.grid_position
	)

	for coordinate in resolution.path:
		var moved := grid.try_move_occupant(
			target.instance_id,
			coordinate
		)

		if not moved:
			_rollback_movement(
				grid,
				target,
				original_coordinate
			)

			return false

		target.set_grid_position(
			coordinate
		)

	return true


func _get_direction(
	source_coordinate: Vector2i,
	target_coordinate: Vector2i,
	direction_mode: int
) -> Vector2i:
	var delta: Vector2i

	match direction_mode:
		ForcedMovementEffect.DirectionMode.PUSH_AWAY:
			delta = (
				target_coordinate
				- source_coordinate
			)

		ForcedMovementEffect.DirectionMode.PULL_TOWARD:
			delta = (
				source_coordinate
				- target_coordinate
			)

		_:
			return Vector2i.ZERO

	return _to_cardinal_direction(
		delta
	)


func _to_cardinal_direction(
	delta: Vector2i
) -> Vector2i:
	if delta == Vector2i.ZERO:
		return Vector2i.ZERO

	# При равенстве осей приоритет получает X.
	# Это делает результат детерминированным.
	if (
		absi(delta.x) >= absi(delta.y)
		and delta.x != 0
	):
		return Vector2i(
			1 if delta.x > 0 else -1,
			0
		)

	if delta.y != 0:
		return Vector2i(
			0,
			1 if delta.y > 0 else -1
		)

	return Vector2i.ZERO


func _rollback_movement(
	grid: BattleGrid,
	target: CombatantState,
	original_coordinate: Vector2i
) -> void:
	var current_coordinate := (
		grid.get_occupant_position(
			target.instance_id
		)
	)

	if (
		current_coordinate
		!= BattleGrid.INVALID_COORDINATE
		and current_coordinate
		!= original_coordinate
	):
		grid.try_move_occupant(
			target.instance_id,
			original_coordinate
		)

	target.set_grid_position(
		original_coordinate
	)