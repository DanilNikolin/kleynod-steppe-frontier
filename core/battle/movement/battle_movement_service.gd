class_name BattleMovementService
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_COMBATANT: StringName = &"invalid_combatant"
const FAILURE_DEAD_COMBATANT: StringName = &"dead_combatant"
const FAILURE_INVALID_COST: StringName = &"invalid_cost"
const FAILURE_INVALID_START: StringName = &"invalid_start"
const FAILURE_TARGET_OUTSIDE_GRID: StringName = &"target_outside_grid"
const FAILURE_TARGET_IS_START: StringName = &"target_is_start"
const FAILURE_TARGET_BLOCKED: StringName = &"target_blocked"
const FAILURE_NO_PATH: StringName = &"no_path"
const FAILURE_NOT_ENOUGH_STAMINA: StringName = &"not_enough_stamina"


func create_plan(
	grid: BattleGrid,
	combatant: CombatantState,
	target_coordinate: Vector2i,
	stamina_cost_per_step: int = 1
) -> BattleMovementPlan:
	var plan := BattleMovementPlan.new()

	plan.target_coordinate = target_coordinate
	plan.stamina_cost_per_step = stamina_cost_per_step

	if grid == null:
		plan.failure_code = FAILURE_INVALID_GRID
		return plan

	if combatant == null:
		plan.failure_code = FAILURE_INVALID_COMBATANT
		return plan

	plan.combatant_id = combatant.instance_id
	plan.start_coordinate = combatant.grid_position

	if not combatant.is_alive:
		plan.failure_code = FAILURE_DEAD_COMBATANT
		return plan

	if stamina_cost_per_step <= 0:
		plan.failure_code = FAILURE_INVALID_COST
		return plan

	if not grid.is_inside(combatant.grid_position):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if (
		not grid.has_occupant(combatant.instance_id)
		or grid.get_occupant_position(
			combatant.instance_id
		) != combatant.grid_position
	):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if not grid.is_inside(target_coordinate):
		plan.failure_code = FAILURE_TARGET_OUTSIDE_GRID
		return plan

	if target_coordinate == combatant.grid_position:
		plan.failure_code = FAILURE_TARGET_IS_START
		return plan

	var target_cell := grid.get_cell(target_coordinate)

	if target_cell == null or not target_cell.is_walkable():
		plan.failure_code = FAILURE_TARGET_BLOCKED
		return plan

	plan.path = find_shortest_path(
		grid,
		combatant.grid_position,
		target_coordinate
	)

	if plan.path.is_empty():
		plan.failure_code = FAILURE_NO_PATH
		return plan

	plan.stamina_cost = (
		plan.path.size()
		* stamina_cost_per_step
	)

	if not combatant.can_spend_stamina(
		plan.stamina_cost
	):
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return plan

	plan.is_valid = true
	return plan


func commit_plan(
	grid: BattleGrid,
	combatant: CombatantState,
	plan: BattleMovementPlan
) -> bool:
	if grid == null or combatant == null or plan == null:
		return false

	if not plan.is_valid:
		return false

	if combatant.instance_id != plan.combatant_id:
		return false

	if combatant.grid_position != plan.start_coordinate:
		return false

	if not combatant.can_spend_stamina(
		plan.stamina_cost
	):
		return false

	if not _is_path_currently_valid(
		grid,
		plan.start_coordinate,
		plan.path
	):
		return false

	if not combatant.spend_stamina(
		plan.stamina_cost
	):
		return false

	for step_coordinate in plan.path:
		var moved := grid.try_move_occupant(
			combatant.instance_id,
			step_coordinate
		)

		if not moved:
			_rollback_failed_movement(
				grid,
				combatant,
				plan
			)

			return false

		combatant.set_grid_position(
			step_coordinate
		)

	return true


func find_shortest_path(
	grid: BattleGrid,
	start_coordinate: Vector2i,
	target_coordinate: Vector2i
) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []

	if grid == null:
		return empty_path

	if (
		not grid.is_inside(start_coordinate)
		or not grid.is_inside(target_coordinate)
	):
		return empty_path

	if start_coordinate == target_coordinate:
		return empty_path

	var target_cell := grid.get_cell(target_coordinate)

	if target_cell == null or not target_cell.is_walkable():
		return empty_path

	var frontier: Array[Vector2i] = [
		start_coordinate
	]

	var frontier_index: int = 0

	var came_from: Dictionary = {
		start_coordinate: start_coordinate,
	}

	while frontier_index < frontier.size():
		var current_coordinate: Vector2i = (
			frontier[frontier_index]
		)

		frontier_index += 1

		if current_coordinate == target_coordinate:
			break

		var neighbors := grid.get_orthogonal_neighbors(
			current_coordinate,
			true
		)

		for neighbor_coordinate in neighbors:
			if came_from.has(neighbor_coordinate):
				continue

			came_from[neighbor_coordinate] = (
				current_coordinate
			)

			frontier.append(
				neighbor_coordinate
			)

	if not came_from.has(target_coordinate):
		return empty_path

	var reversed_path: Array[Vector2i] = []
	var cursor := target_coordinate

	while cursor != start_coordinate:
		reversed_path.append(cursor)

		var previous_coordinate: Vector2i = (
			came_from[cursor]
		)

		cursor = previous_coordinate

	reversed_path.reverse()

	return reversed_path


func get_reachable_coordinates(
	grid: BattleGrid,
	start_coordinate: Vector2i,
	maximum_steps: int
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if grid == null:
		return result

	if maximum_steps <= 0:
		return result

	if not grid.is_inside(start_coordinate):
		return result

	var frontier: Array[Vector2i] = [
		start_coordinate
	]

	var frontier_index: int = 0

	var distances: Dictionary = {
		start_coordinate: 0,
	}

	while frontier_index < frontier.size():
		var current_coordinate: Vector2i = (
			frontier[frontier_index]
		)

		frontier_index += 1

		var current_distance: int = (
			distances[current_coordinate]
		)

		if current_distance >= maximum_steps:
			continue

		var neighbors := grid.get_orthogonal_neighbors(
			current_coordinate,
			true
		)

		for neighbor_coordinate in neighbors:
			if distances.has(neighbor_coordinate):
				continue

			var neighbor_distance := (
				current_distance + 1
			)

			distances[neighbor_coordinate] = (
				neighbor_distance
			)

			frontier.append(
				neighbor_coordinate
			)

			result.append(
				neighbor_coordinate
			)

	return result


func _is_path_currently_valid(
	grid: BattleGrid,
	start_coordinate: Vector2i,
	path: Array[Vector2i]
) -> bool:
	if path.is_empty():
		return false

	var previous_coordinate := start_coordinate

	for step_coordinate in path:
		if not grid.are_orthogonally_adjacent(
			previous_coordinate,
			step_coordinate
		):
			return false

		var step_cell := grid.get_cell(
			step_coordinate
		)

		if step_cell == null or not step_cell.is_walkable():
			return false

		previous_coordinate = step_coordinate

	return true


func _rollback_failed_movement(
	grid: BattleGrid,
	combatant: CombatantState,
	plan: BattleMovementPlan
) -> void:
	var current_coordinate := (
		grid.get_occupant_position(
			combatant.instance_id
		)
	)

	if current_coordinate != BattleGrid.INVALID_COORDINATE:
		grid.try_move_occupant(
			combatant.instance_id,
			plan.start_coordinate
		)

	combatant.set_grid_position(
		plan.start_coordinate
	)

	combatant.restore_stamina(
		plan.stamina_cost
	)