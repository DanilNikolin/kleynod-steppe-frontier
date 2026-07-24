@tool
class_name BattleSideRules
extends Resource


@export_group("Teams")

@export
var left_team_id: StringName = &"team_player"

@export
var right_team_id: StringName = &"team_enemy"


@export_group("Divider")

## При включённом автоматическом режиме поле
## всегда делится на две равные стороны.
##
## 6 колонок:
## левая сторона 0–2;
## правая сторона 3–5.
##
## 10 колонок:
## левая сторона 0–4;
## правая сторона 5–9.
@export
var use_automatic_divider: bool = true

## Используется только при выключенном
## автоматическом разделении.
@export_range(1, 99, 1)
var divider_column: int = 3


func get_effective_divider_column(
	columns: int
) -> int:
	if use_automatic_divider:
		return floori(
			float(columns) / 2.0
		)

	return divider_column


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

		return errors

	if (
		use_automatic_divider
		and columns % 2 != 0
	):
		errors.append(
			"Automatic side division requires "
			+"an even number of columns."
		)

		return errors

	var effective_divider := (
		get_effective_divider_column(
			columns
		)
	)

	if (
		effective_divider <= 0
		or effective_divider >= columns
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

	var effective_divider := (
		get_effective_divider_column(
			columns
		)
	)

	if team_id == left_team_id:
		return coordinate.x < effective_divider

	if team_id == right_team_id:
		return coordinate.x >= effective_divider

	return false


func get_forward_direction(
	team_id: StringName
) -> int:
	if team_id == left_team_id:
		return 1

	if team_id == right_team_id:
		return -1

	return 0