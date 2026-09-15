@tool
class_name BattleSlotAnchor
extends Marker2D

## This origin is the combatant's ground contact, never its sprite center.
@export var coordinate: Vector2i = Vector2i.ZERO:
	set(value):
		coordinate = value
		queue_redraw()
		if is_inside_tree() and get_parent() != null:
			get_parent().update_configuration_warnings()

## Ellipse radii in anchor-local space; the same ellipse is drawn and hit-tested.
@export var interaction_radii: Vector2 = Vector2(60, 32):
	set(value):
		interaction_radii = Vector2(maxf(value.x, 1), maxf(value.y, 1))
		queue_redraw()


func _ready() -> void:
	# Diagnostic markers remain legible over environment foreground artwork.
	z_as_relative = false
	z_index = 900
	queue_redraw()


func contains_world_position(world_position: Vector2) -> bool:
	var normalized := to_local(world_position) / interaction_radii
	return normalized.length_squared() <= 1.0


func _draw() -> void:
	var layout := get_parent()
	if layout == null:
		return
	if not Engine.is_editor_hint() and not (OS.is_debug_build() and layout.get("debug_preview") == true):
		return
	var divider: int = layout.get("preview_divider_column") if layout.get("preview_divider_column") != null else 3
	var left := coordinate.x < divider
	var color := Color(0.35, 0.8, 1.0) if left else Color(1.0, 0.55, 0.35)
	var points := PackedVector2Array()
	for index in range(49):
		var angle := TAU * index / 48.0
		points.append(Vector2(cos(angle), sin(angle)) * interaction_radii)
	draw_colored_polygon(points, Color(color, 0.12))
	draw_polyline(points, color, 2.0, true)
	draw_line(Vector2(-9, 0), Vector2(9, 0), color, 2.0)
	draw_line(Vector2(0, -9), Vector2(0, 9), color, 2.0)
	var label := "%s (%d,%d)" % ["L" if left else "R", coordinate.x, coordinate.y]
	draw_string(ThemeDB.fallback_font, Vector2(-36, -interaction_radii.y - 8), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
