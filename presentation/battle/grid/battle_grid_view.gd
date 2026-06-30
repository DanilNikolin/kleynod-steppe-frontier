@tool
class_name BattleGridView
extends Node2D


signal cell_hovered(coordinate: Vector2i)
signal cell_clicked(coordinate: Vector2i, mouse_button: int)


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)


@export_group("Grid Size")

@export_range(1, 20, 1)
var rows: int = 5:
	set(value):
		rows = maxi(1, value)
		queue_redraw()


@export_range(1, 30, 1)
var columns: int = 10:
	set(value):
		columns = maxi(1, value)
		divider_column = clampi(divider_column, 0, columns)
		queue_redraw()


@export
var cell_size: Vector2 = Vector2(96.0, 84.0):
	set(value):
		cell_size = Vector2(
			maxf(1.0, value.x),
			maxf(1.0, value.y)
		)
		queue_redraw()


@export
var cell_gap: Vector2 = Vector2(8.0, 8.0):
	set(value):
		cell_gap = Vector2(
			maxf(0.0, value.x),
			maxf(0.0, value.y)
		)
		queue_redraw()


@export
var center_on_node: bool = true:
	set(value):
		center_on_node = value
		queue_redraw()


@export
var origin_offset: Vector2 = Vector2.ZERO:
	set(value):
		origin_offset = value
		queue_redraw()


@export_group("Sides")

@export_range(0, 30, 1)
var divider_column: int = 5:
	set(value):
		divider_column = clampi(value, 0, columns)
		queue_redraw()


@export
var player_side_color: Color = Color(0.12, 0.24, 0.32, 0.72):
	set(value):
		player_side_color = value
		queue_redraw()


@export
var enemy_side_color: Color = Color(0.34, 0.14, 0.14, 0.72):
	set(value):
		enemy_side_color = value
		queue_redraw()


@export_group("Lines")

@export
var grid_line_color: Color = Color(0.72, 0.76, 0.79, 0.72):
	set(value):
		grid_line_color = value
		queue_redraw()


@export_range(0.5, 10.0, 0.5)
var grid_line_width: float = 2.0:
	set(value):
		grid_line_width = maxf(0.5, value)
		queue_redraw()


@export
var divider_color: Color = Color(0.95, 0.82, 0.38, 0.92):
	set(value):
		divider_color = value
		queue_redraw()


@export_range(1.0, 16.0, 0.5)
var divider_width: float = 4.0:
	set(value):
		divider_width = maxf(1.0, value)
		queue_redraw()


@export_group("Interaction")

@export
var hover_color: Color = Color(1.0, 1.0, 1.0, 0.16):
	set(value):
		hover_color = value
		queue_redraw()


@export
var selected_color: Color = Color(1.0, 0.86, 0.30, 0.90):
	set(value):
		selected_color = value
		queue_redraw()


@export_range(1.0, 12.0, 0.5)
var selected_line_width: float = 4.0:
	set(value):
		selected_line_width = maxf(1.0, value)
		queue_redraw()

@export_group("Targeting Debug")

@export
var targeting_aim_marker_color: Color = Color(
	0.30,
	0.90,
	1.0,
	0.95
):
	set(value):
		targeting_aim_marker_color = value
		queue_redraw()

@export_range(2.0, 20.0, 0.5)
var targeting_aim_marker_radius: float = 5.0:
	set(value):
		targeting_aim_marker_radius = maxf(
			2.0,
			value
		)

		queue_redraw()

@export
var targeting_impact_marker_color: Color = Color(
	1.0,
	0.82,
	0.18,
	1.0
):
	set(value):
		targeting_impact_marker_color = value
		queue_redraw()

@export_range(4.0, 30.0, 0.5)
var targeting_impact_marker_size: float = 12.0:
	set(value):
		targeting_impact_marker_size = maxf(
			4.0,
			value
		)

		queue_redraw()

@export_range(1.0, 8.0, 0.5)
var targeting_impact_line_width: float = 3.0:
	set(value):
		targeting_impact_line_width = maxf(
			1.0,
			value
		)

		queue_redraw()

var hovered_cell: Vector2i = INVALID_COORDINATE
var selected_cell: Vector2i = INVALID_COORDINATE

var _cell_overlays: Dictionary = {}
var _targeting_aim_coordinates: Array[Vector2i] = []
var _targeting_impact_coordinates: Array[Vector2i] = []


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	for row in range(rows):
		for column in range(columns):
			var coordinate := Vector2i(column, row)
			var cell_rect := get_cell_rect(coordinate)

			var base_color := (
				player_side_color
				if column < divider_column
				else enemy_side_color
			)

			draw_rect(cell_rect, base_color, true)
			draw_rect(
				cell_rect,
				grid_line_color,
				false,
				grid_line_width,
				true
			)

			if _cell_overlays.has(coordinate):
				var overlay_color: Color = _cell_overlays[coordinate]
				draw_rect(cell_rect, overlay_color, true)

			if coordinate == hovered_cell:
				draw_rect(cell_rect, hover_color, true)

			if coordinate == selected_cell:
				draw_rect(
					cell_rect,
					selected_color,
					false,
					selected_line_width,
					true
				)

	_draw_side_divider()

	_draw_targeting_debug_markers()


func _draw_side_divider() -> void:
	if divider_column <= 0 or divider_column >= columns:
		return

	var origin := get_grid_origin()
	var divider_x := (
		origin.x
		+ divider_column * (cell_size.x + cell_gap.x)
		- cell_gap.x * 0.5
	)

	var grid_size := get_grid_size()

	draw_line(
		Vector2(divider_x, origin.y),
		Vector2(divider_x, origin.y + grid_size.y),
		divider_color,
		divider_width,
		true
	)

func _draw_targeting_debug_markers() -> void:
	for coordinate in (
		_targeting_aim_coordinates
	):
		if not is_valid_coordinate(
			coordinate
		):
			continue

		var cell_rect := get_cell_rect(
			coordinate
		)

		# Точка в левом верхнем углу клетки,
		# чтобы её не закрывал персонаж.
		var marker_position := (
			cell_rect.position
			+ Vector2(12.0, 12.0)
		)

		draw_circle(
			marker_position,
			targeting_aim_marker_radius,
			targeting_aim_marker_color,
			true
		)

	for coordinate in (
		_targeting_impact_coordinates
	):
		if not is_valid_coordinate(
			coordinate
		):
			continue

		var cell_rect := get_cell_rect(
			coordinate
		)

		# Крестик справа сверху, отдельно
		# от aim-точки.
		var marker_position := (
			cell_rect.position
			+ Vector2(
				cell_rect.size.x - 14.0,
				14.0
			)
		)

		var half_size := (
			targeting_impact_marker_size
			* 0.5
		)

		draw_line(
			marker_position
			+ Vector2(
				- half_size,
				- half_size
			),
			marker_position
			+ Vector2(
				half_size,
				half_size
			),
			targeting_impact_marker_color,
			targeting_impact_line_width,
			true
		)

		draw_line(
			marker_position
			+ Vector2(
				- half_size,
				half_size
			),
			marker_position
			+ Vector2(
				half_size,
				- half_size
			),
			targeting_impact_marker_color,
			targeting_impact_line_width,
			true
		)


func set_targeting_debug_markers(
	aim_coordinates: Array[Vector2i],
	impact_coordinates: Array[Vector2i]
) -> void:
	_targeting_aim_coordinates.clear()
	_targeting_impact_coordinates.clear()

	for coordinate in aim_coordinates:
		if not is_valid_coordinate(
			coordinate
		):
			continue

		if _targeting_aim_coordinates.has(
			coordinate
		):
			continue

		_targeting_aim_coordinates.append(
			coordinate
		)

	for coordinate in impact_coordinates:
		if not is_valid_coordinate(
			coordinate
		):
			continue

		if _targeting_impact_coordinates.has(
			coordinate
		):
			continue

		_targeting_impact_coordinates.append(
			coordinate
		)

	queue_redraw()


func clear_targeting_debug_markers() -> void:
	if (
		_targeting_aim_coordinates.is_empty()
		and _targeting_impact_coordinates.is_empty()
	):
		return

	_targeting_aim_coordinates.clear()
	_targeting_impact_coordinates.clear()

	queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseMotion:
		_update_hovered_cell(coordinate_from_local_position(
			get_local_mouse_position()
		))
		return

	if event is InputEventMouseButton and event.pressed:
		var coordinate := coordinate_from_local_position(
			get_local_mouse_position()
		)

		if coordinate == INVALID_COORDINATE:
			return

		cell_clicked.emit(coordinate, event.button_index)


func _update_hovered_cell(coordinate: Vector2i) -> void:
	if hovered_cell == coordinate:
		return

	hovered_cell = coordinate
	cell_hovered.emit(coordinate)
	queue_redraw()


func get_grid_size() -> Vector2:
	return Vector2(
		columns * cell_size.x + maxi(columns - 1, 0) * cell_gap.x,
		rows * cell_size.y + maxi(rows - 1, 0) * cell_gap.y
	)


func get_grid_origin() -> Vector2:
	if not center_on_node:
		return origin_offset

	return origin_offset - get_grid_size() * 0.5


func get_cell_rect(coordinate: Vector2i) -> Rect2:
	if not is_valid_coordinate(coordinate):
		return Rect2()

	var origin := get_grid_origin()
	var step := cell_size + cell_gap

	var cell_position := origin + Vector2(
		coordinate.x * step.x,
		coordinate.y * step.y
	)

	return Rect2(cell_position, cell_size)


func get_cell_center(coordinate: Vector2i) -> Vector2:
	return get_cell_rect(coordinate).get_center()


func get_cell_global_center(coordinate: Vector2i) -> Vector2:
	return to_global(get_cell_center(coordinate))


func coordinate_from_local_position(
	local_position: Vector2
) -> Vector2i:
	var origin := get_grid_origin()
	var relative_position := local_position - origin

	if relative_position.x < 0.0 or relative_position.y < 0.0:
		return INVALID_COORDINATE

	var step := cell_size + cell_gap

	var column := floori(relative_position.x / step.x)
	var row := floori(relative_position.y / step.y)
	var coordinate := Vector2i(column, row)

	if not is_valid_coordinate(coordinate):
		return INVALID_COORDINATE

	var position_inside_step := Vector2(
		fmod(relative_position.x, step.x),
		fmod(relative_position.y, step.y)
	)

	if (
		position_inside_step.x > cell_size.x
		or position_inside_step.y > cell_size.y
	):
		return INVALID_COORDINATE

	return coordinate


func is_valid_coordinate(coordinate: Vector2i) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)


func set_selected_cell(coordinate: Vector2i) -> void:
	selected_cell = (
		coordinate
			if is_valid_coordinate(coordinate)
			else INVALID_COORDINATE
	)

	queue_redraw()


func clear_selected_cell() -> void:
	selected_cell = INVALID_COORDINATE
	queue_redraw()


func set_cell_overlay(
	coordinate: Vector2i,
	color: Color
) -> void:
	if not is_valid_coordinate(coordinate):
		return

	_cell_overlays[coordinate] = color
	queue_redraw()


func remove_cell_overlay(coordinate: Vector2i) -> void:
	_cell_overlays.erase(coordinate)
	queue_redraw()


func clear_cell_overlays() -> void:
	_cell_overlays.clear()
	queue_redraw()