@tool
class_name BattleSideRules
extends Resource


@export_group("Teams")

@export
var left_team_id: StringName = &"team_player"

@export
var right_team_id: StringName = &"team_enemy"


@export_group("Divider")

## Первый столбец правой стороны.
## При значении 5 левая сторона занимает 0–4,
## правая сторона занимает 5–9.
@export_range(1, 99, 1)
var divider_column: int = 5


func is_valid_for_grid(
	columns: int
) -> bool:
	return get_validation_errors(
		columns
	).is_empty()


func get_validation_errors(
	columns: int
) -> PackedStringArray:
	var errors := PackedStringArray()

	if left_team_id == &"":
		errors.append(
			"Left team ID is empty."
		)

	if right_team_id == &"":
		errors.append(
			"Right team ID is empty."
		)

	if (
		left_team_id != &""
		and left_team_id == right_team_id
	):
		errors.append(
			"Left and right team IDs must be different."
		)

	if columns < 2:
		errors.append(
			"Side-based grid requires at least two columns."
		)

	elif (
		divider_column <= 0
		or divider_column >= columns
	):
		errors.append(
			"Divider column must be inside the grid."
		)

	return errors


func is_team_supported(
	team_id: StringName
) -> bool:
	return (
		team_id == left_team_id
		or team_id == right_team_id
	)


func is_coordinate_allowed(
	team_id: StringName,
	coordinate: Vector2i,
	rows: int,
	columns: int
) -> bool:
	if (
		coordinate.x < 0
		or coordinate.x >= columns
		or coordinate.y < 0
		or coordinate.y >= rows
	):
		return false

	if team_id == left_team_id:
		return coordinate.x < divider_column

	if team_id == right_team_id:
		return coordinate.x >= divider_column

	return false


func get_forward_direction(
	team_id: StringName
) -> int:
	if team_id == left_team_id:
		return 1

	if team_id == right_team_id:
		return -1

	return 0