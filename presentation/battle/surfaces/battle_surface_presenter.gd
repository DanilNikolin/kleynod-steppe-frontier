class_name BattleSurfacePresenter
extends Node2D

var layout: BattleArenaLayout
var controller: BattleSurfaceEffectController
var tactical_state: BattleTacticalState


func bind(value: BattleSurfaceEffectController, arena: BattleArenaLayout, state: BattleTacticalState = null) -> void:
	unbind()
	controller = value
	layout = arena
	tactical_state = state
	controller.surface_effect_added.connect(_on_changed)
	controller.surface_effect_updated.connect(_on_changed)
	controller.surface_effect_removed.connect(_on_removed)
	_refresh()


func unbind() -> void:
	if controller == null:
		return
	controller.surface_effect_added.disconnect(_on_changed)
	controller.surface_effect_updated.disconnect(_on_changed)
	controller.surface_effect_removed.disconnect(_on_removed)
	controller = null


func _exit_tree() -> void:
	unbind()


func _on_changed(_instance: BattleSurfaceEffectInstance) -> void:
	_refresh()


func _on_removed(_coordinate: Vector2i, _id: StringName) -> void:
	_refresh()


func _refresh() -> void:
	if tactical_state != null:
		tactical_state.set_surfaces(controller.get_affected_coordinates())
	queue_redraw()


func _draw() -> void:
	if controller == null or not is_instance_valid(layout):
		return
	for coordinate in controller.get_affected_coordinates():
		var anchor := layout.get_slot_anchor(coordinate)
		if anchor == null:
			continue
		var instances := controller.get_effects_at(coordinate)
		for index in range(instances.size()):
			var color := instances[index].definition.presentation_color
			color.a = 0.35
			var points := PackedVector2Array()
			for step in range(49):
				var angle := TAU * step / 48.0
				var radius_scale := 0.95 - minf(index * 0.12, 0.5)
				points.append(to_local(anchor.to_global(
					Vector2(cos(angle), sin(angle)) * anchor.interaction_radii * radius_scale)))
			draw_colored_polygon(points, color)
			draw_polyline(points, Color(color, 0.65), 2.0, true)
