class_name BattlePreviewGridState
extends RefCounted


var rows: int = 0
var columns: int = 0

var _obstacle_coordinates: Dictionary = {}
var _occupant_by_coordinate: Dictionary = {}
var _coordinate_by_occupant: Dictionary = {}


func _init(
	session: BattleSession
) -> void:
	assert(
		session != null,
		"Preview grid requires a battle session."
	)

	assert(
		session.grid != null,
		"Preview grid requires a battle grid."
	)

	rows = session.grid.rows
	columns = session.grid.columns

	for row in range(rows):
		for column in range(columns):
			var coordinate := Vector2i(
				column,
				row
			)

			var cell := session.grid.get_cell(
				coordinate
			)

			if cell == null:
				continue

			if cell.has_obstacle():
				_obstacle_coordinates[
					coordinate
				] = true

			if not cell.is_occupied():
				continue

			var occupant_id := (
				cell.occupant_id
			)

			_occupant_by_coordinate[
				coordinate
			] = occupant_id

			_coordinate_by_occupant[
				occupant_id
			] = coordinate


func is_inside(
	coordinate: Vector2i
) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)


func is_walkable(
	coordinate: Vector2i
) -> bool:
	if not is_inside(
		coordinate
	):
		return false

	return (
		not _obstacle_coordinates.has(
			coordinate
		)
		and not _occupant_by_coordinate.has(
			coordinate
		)
	)


func get_occupant_position(
	occupant_id: StringName
) -> Vector2i:
	if not _coordinate_by_occupant.has(
		occupant_id
	):
		return BattleGrid.INVALID_COORDINATE

	return _coordinate_by_occupant[
		occupant_id
	]


func try_move_occupant(
	occupant_id: StringName,
	destination: Vector2i
) -> bool:
	if occupant_id == &"":
		return false

	if not is_walkable(
		destination
	):
		return false

	var origin := get_occupant_position(
		occupant_id
	)

	if (
		origin
		== BattleGrid.INVALID_COORDINATE
	):
		return false

	_occupant_by_coordinate.erase(
		origin
	)

	_occupant_by_coordinate[
		destination
	] = occupant_id

	_coordinate_by_occupant[
		occupant_id
	] = destination

	return true


func remove_occupant(
	occupant_id: StringName
) -> void:
	var coordinate := get_occupant_position(
		occupant_id
	)

	if (
		coordinate
		!= BattleGrid.INVALID_COORDINATE
	):
		_occupant_by_coordinate.erase(
			coordinate
		)

	_coordinate_by_occupant.erase(
		occupant_id
	)