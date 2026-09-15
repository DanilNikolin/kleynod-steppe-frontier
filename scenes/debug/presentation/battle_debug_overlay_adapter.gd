class_name BattleDebugOverlayAdapter
extends Node

var state: BattleTacticalState
var grid_view: BattleGridView
var _dirty: bool = false


func bind(value: BattleTacticalState, view: BattleGridView) -> void:
	state = value
	grid_view = view
	state.changed.connect(_queue_refresh)
	_queue_refresh()


func _queue_refresh() -> void:
	if _dirty:
		return
	_dirty = true
	_refresh.call_deferred()


func _refresh() -> void:
	_dirty = false
	grid_view.clear_cell_overlays()
	grid_view.clear_selected_cell()
	grid_view.clear_targeting_debug_markers()
	grid_view.clear_action_preview_cells()
	for coordinate in state.slots:
		var flags: int = state.slots[coordinate]
		var color := Color(0.2, 0.72, 0.88, 0.28)
		if flags & BattleTacticalState.Kind.OBSTACLE:
			color = Color(0.82, 0.26, 0.18, 0.62)
		if flags & BattleTacticalState.Kind.INVALID_TARGET:
			color = Color(0.82, 0.18, 0.14, 0.3)
		if flags & BattleTacticalState.Kind.SWAP:
			color = Color(0.28, 0.92, 0.48, 0.58)
		if flags & BattleTacticalState.Kind.VALID_TARGET:
			color = Color(1, 0.46, 0.12, 0.7)
		if flags & BattleTacticalState.Kind.PATH:
			color = Color(1, 0.82, 0.24, 0.52)
		grid_view.set_cell_overlay(coordinate, color)
		if flags & BattleTacticalState.Kind.SELECTED:
			grid_view.set_selected_cell(coordinate)
	grid_view.set_targeting_debug_markers(state.aim_coordinates, state.impact_coordinates)
	for preview in state.surface_previews:
		grid_view.set_action_preview_cell(preview.coordinate,
			BattleActionPreviewFormatter.build_surface_placement_text(preview),
			preview.presentation_color if preview.can_place else Color(0.95, 0.16, 0.1))
