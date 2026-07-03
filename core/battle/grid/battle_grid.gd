class_name BattleGrid
extends RefCounted


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)
const EMPTY_ID: StringName = &""


var rows: int
var columns: int

var _cells: Array[BattleGridCell] = []
var _occupant_positions: Dictionary = {}
var _obstacle_positions: Dictionary = {}


func _init(p_rows: int = 3, p_columns: int = 10) -> void:
	assert(p_rows > 0, "BattleGrid requires at least one row.")
	assert(p_columns > 0, "BattleGrid requires at least one column.")

	rows = p_rows
	columns = p_columns

	_build_cells()


func _build_cells() -> void:
	_cells.clear()
	_cells.resize(rows * columns)

	for row in range(rows):
		for column in range(columns):
			var coordinate := Vector2i(column, row)
			_cells[_coordinate_to_index(coordinate)] = BattleGridCell.new(coordinate)


func _coordinate_to_index(coordinate: Vector2i) -> int:
	return coordinate.y * columns + coordinate.x


func is_inside(coordinate: Vector2i) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)


func get_cell(coordinate: Vector2i) -> BattleGridCell:
	if not is_inside(coordinate):
		return null

	return _cells[_coordinate_to_index(coordinate)]


func get_all_coordinates() -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for row in range(rows):
		for column in range(columns):
			result.append(Vector2i(column, row))

	return result


func get_cells_in_row(row: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if row < 0 or row >= rows:
		return result

	for column in range(columns):
		result.append(Vector2i(column, row))

	return result


func get_cells_in_column(column: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if column < 0 or column >= columns:
		return result

	for row in range(rows):
		result.append(Vector2i(column, row))

	return result


func get_orthogonal_neighbors(
	coordinate: Vector2i,
	walkable_only: bool = false
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	for direction in directions:
		var neighbor := coordinate + direction

		if not is_inside(neighbor):
			continue

		if walkable_only:
			var neighbor_cell := get_cell(neighbor)

			if neighbor_cell == null or not neighbor_cell.is_walkable():
				continue

		result.append(neighbor)

	return result


func get_manhattan_distance(
	first_coordinate: Vector2i,
	second_coordinate: Vector2i
) -> int:
	return (
		absi(first_coordinate.x - second_coordinate.x)
		+ absi(first_coordinate.y - second_coordinate.y)
	)


func are_orthogonally_adjacent(
	first_coordinate: Vector2i,
	second_coordinate: Vector2i
) -> bool:
	return get_manhattan_distance(first_coordinate, second_coordinate) == 1


func has_occupant(occupant_id: StringName) -> bool:
	return _occupant_positions.has(occupant_id)


func get_occupant_position(occupant_id: StringName) -> Vector2i:
	return _occupant_positions.get(occupant_id, INVALID_COORDINATE)


func try_place_occupant(
	occupant_id: StringName,
	coordinate: Vector2i
) -> bool:
	if occupant_id == EMPTY_ID:
		return false

	if _occupant_positions.has(occupant_id):
		return false

	var cell := get_cell(coordinate)

	if cell == null or not cell.is_walkable():
		return false

	cell.occupant_id = occupant_id
	_occupant_positions[occupant_id] = coordinate

	return true


func try_move_occupant(
	occupant_id: StringName,
	target_coordinate: Vector2i
) -> bool:
	if not _occupant_positions.has(occupant_id):
		return false

	var source_coordinate: Vector2i = _occupant_positions[occupant_id]

	if source_coordinate == target_coordinate:
		return false

	var source_cell := get_cell(source_coordinate)
	var target_cell := get_cell(target_coordinate)

	if source_cell == null or target_cell == null:
		return false

	if not target_cell.is_walkable():
		return false

	source_cell.occupant_id = EMPTY_ID
	target_cell.occupant_id = occupant_id
	_occupant_positions[occupant_id] = target_coordinate

	return true


func try_swap_occupants(
	first_occupant_id: StringName,
	second_occupant_id: StringName
) -> bool:
	if (
		first_occupant_id == EMPTY_ID
		or second_occupant_id == EMPTY_ID
		or first_occupant_id == second_occupant_id
	):
		return false

	if (
		not _occupant_positions.has(
			first_occupant_id
		)
		or not _occupant_positions.has(
			second_occupant_id
		)
	):
		return false

	var first_coordinate: Vector2i = (
		_occupant_positions[
			first_occupant_id
		]
	)

	var second_coordinate: Vector2i = (
		_occupant_positions[
			second_occupant_id
		]
	)

	if first_coordinate == second_coordinate:
		return false

	var first_cell := get_cell(
		first_coordinate
	)

	var second_cell := get_cell(
		second_coordinate
	)

	if (
		first_cell == null
		or second_cell == null
		or first_cell.occupant_id
			!= first_occupant_id
		or second_cell.occupant_id
			!= second_occupant_id
	):
		return false

	first_cell.occupant_id = second_occupant_id
	second_cell.occupant_id = first_occupant_id

	_occupant_positions[
		first_occupant_id
	] = second_coordinate

	_occupant_positions[
		second_occupant_id
	] = first_coordinate

	return true

func remove_occupant(occupant_id: StringName) -> bool:
	if not _occupant_positions.has(occupant_id):
		return false

	var coordinate: Vector2i = _occupant_positions[occupant_id]
	var cell := get_cell(coordinate)

	if cell != null and cell.occupant_id == occupant_id:
		cell.occupant_id = EMPTY_ID

	_occupant_positions.erase(occupant_id)
	return true


func has_obstacle(obstacle_id: StringName) -> bool:
	return _obstacle_positions.has(obstacle_id)


func get_obstacle_position(obstacle_id: StringName) -> Vector2i:
	return _obstacle_positions.get(obstacle_id, INVALID_COORDINATE)


func try_place_obstacle(
	obstacle_id: StringName,
	coordinate: Vector2i
) -> bool:
	if obstacle_id == EMPTY_ID:
		return false

	if _obstacle_positions.has(obstacle_id):
		return false

	var cell := get_cell(coordinate)

	if cell == null or not cell.is_walkable():
		return false

	cell.obstacle_id = obstacle_id
	_obstacle_positions[obstacle_id] = coordinate

	return true


func remove_obstacle(obstacle_id: StringName) -> bool:
	if not _obstacle_positions.has(obstacle_id):
		return false

	var coordinate: Vector2i = _obstacle_positions[obstacle_id]
	var cell := get_cell(coordinate)

	if cell != null and cell.obstacle_id == obstacle_id:
		cell.obstacle_id = EMPTY_ID

	_obstacle_positions.erase(obstacle_id)
	return true


func clear() -> void:
	for cell in _cells:
		cell.clear()

	_occupant_positions.clear()
	_obstacle_positions.clear()

func create_runtime_copy() -> BattleGrid:
	var result := BattleGrid.new(
		rows,
		columns
	)

	for coordinate in get_all_coordinates():
		var source_cell := get_cell(
			coordinate
		)

		var target_cell := result.get_cell(
			coordinate
		)

		if (
			source_cell == null
			or target_cell == null
		):
			continue

		target_cell.occupant_id = (
			source_cell.occupant_id
		)

		target_cell.obstacle_id = (
			source_cell.obstacle_id
		)

		for surface_effect_id in (
			source_cell.surface_effect_ids
		):
			target_cell.surface_effect_ids.append(
				surface_effect_id
			)

	result._occupant_positions = (
		_occupant_positions.duplicate(
			true
		)
	)

	result._obstacle_positions = (
		_obstacle_positions.duplicate(
			true
		)
	)

	return result