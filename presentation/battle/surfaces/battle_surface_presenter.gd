class_name BattleSurfacePresenter
extends Node2D

## Presentation-only registry. Gameplay surface definitions contain no PackedScene.
@export var surface_scenes: Dictionary[StringName, PackedScene] = {
	&"surface_debug_fire": preload("res://presentation/battle/surfaces/visuals/debug_fire_surface_view.tscn"),
	&"surface_bayda_burning_fissure": preload("res://presentation/battle/surfaces/visuals/bayda_burning_fissure_surface_view.tscn"),
}
@export var fallback_scene: PackedScene = preload("res://presentation/battle/surfaces/battle_surface_view.tscn")

var layout: BattleArenaLayout
var controller: BattleSurfaceEffectController
var tactical_state: BattleTacticalState
## Runtime instance identity, not just coordinate: multiple surfaces can coexist.
var _views: Dictionary = {}


func bind(value: BattleSurfaceEffectController, arena: BattleArenaLayout, state: BattleTacticalState = null) -> void:
	unbind()
	controller = value
	layout = arena
	tactical_state = state
	controller.surface_effect_added.connect(_on_changed)
	controller.surface_effect_updated.connect(_on_changed)
	controller.surface_effect_removed.connect(_on_removed)
	_refresh()


func resolve_scene(surface_id: StringName) -> PackedScene:
	return surface_scenes.get(surface_id, fallback_scene)


func get_view(instance: BattleSurfaceEffectInstance) -> BattleSurfaceView:
	return _views.get(instance) as BattleSurfaceView


func unbind() -> void:
	if controller != null:
		controller.surface_effect_added.disconnect(_on_changed)
		controller.surface_effect_updated.disconnect(_on_changed)
		controller.surface_effect_removed.disconnect(_on_removed)
	controller = null
	for view in _views.values():
		remove_child(view)
		view.queue_free()
	_views.clear()
	if tactical_state != null:
		tactical_state.set_surfaces([])
	tactical_state = null


func _exit_tree() -> void:
	unbind()


func _on_changed(_instance: BattleSurfaceEffectInstance) -> void:
	_refresh()


func _on_removed(_coordinate: Vector2i, _id: StringName) -> void:
	_refresh()


func _refresh() -> void:
	if controller == null or not is_instance_valid(layout):
		return
	var retained: Dictionary = {}
	for coordinate in controller.get_affected_coordinates():
		var anchor := layout.get_slot_anchor(coordinate)
		if anchor == null:
			continue
		var index := 0
		for instance in controller.get_effects_at(coordinate):
			var view := get_view(instance)
			if view == null:
				var scene := resolve_scene(instance.definition.surface_effect_id)
				if scene == null:
					continue
				var candidate := scene.instantiate()
				if not candidate is BattleSurfaceView:
					candidate.free()
					push_error("Surface visual scene must extend BattleSurfaceView.")
					continue
				view = candidate
				add_child(view)
				_views[instance] = view
			view.bind_surface(instance, anchor)
			view.z_index = index
			index += 1
			retained[instance] = true
	for instance in _views.keys():
		if not retained.has(instance):
			var view: BattleSurfaceView = _views[instance]
			remove_child(view)
			view.queue_free()
			_views.erase(instance)
	if tactical_state != null:
		tactical_state.set_surfaces(controller.get_affected_coordinates())
