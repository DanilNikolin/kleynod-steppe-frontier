class_name BattleTacticalOverlay
extends Node2D

var layout: BattleArenaLayout
var state: BattleTacticalState


func bind(value: BattleTacticalState, arena: BattleArenaLayout) -> void:
	if state != null and state.changed.is_connected(queue_redraw):
		state.changed.disconnect(queue_redraw)
	state = value
	layout = arena
	state.changed.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if state == null or not is_instance_valid(layout):
		return
	for anchor in layout.get_anchors():
		var flags := state.get_flags(anchor.coordinate)
		if (flags & ~BattleTacticalState.Kind.SURFACE) == 0:
			continue
		var color := Color(0.35, 0.75, 0.85, 0.35)
		if flags & BattleTacticalState.Kind.INVALID_TARGET:
			color = Color(0.9, 0.25, 0.2, 0.5)
		if flags & BattleTacticalState.Kind.VALID_TARGET:
			color = Color(1.0, 0.48, 0.15, 0.65)
		if flags & BattleTacticalState.Kind.SWAP:
			color = Color(0.35, 0.9, 0.5, 0.65)
		if flags & BattleTacticalState.Kind.PATH:
			color = Color(1.0, 0.8, 0.25, 0.75)
		if flags & BattleTacticalState.Kind.OBSTACLE:
			color = Color(0.55, 0.55, 0.6, 0.7)
		if flags & BattleTacticalState.Kind.AOE:
			color = Color(0.8, 0.45, 1, 0.8)
		if flags & BattleTacticalState.Kind.SELECTED:
			color = Color(1, 0.86, 0.3, 0.9)
		if flags & BattleTacticalState.Kind.HOVER:
			color = Color(0.9, 0.98, 1, 0.95)
		_draw_marker(anchor, color)
	for preview in state.surface_previews:
		var anchor := layout.get_slot_anchor(preview.coordinate)
		if anchor != null:
			_draw_marker(anchor, Color(0.6, 0.45, 1, 0.8) if preview.can_place else Color(1, 0.15, 0.15, 0.8))


func _draw_marker(anchor: BattleSlotAnchor, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(49):
		var angle := TAU * index / 48.0
		var local_point := Vector2(cos(angle), sin(angle)) * anchor.interaction_radii * 0.82
		points.append(to_local(anchor.to_global(local_point)))
	draw_colored_polygon(points, Color(color, color.a * 0.15))
	draw_polyline(points, color, 2.0, true)
