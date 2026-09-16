class_name BattleTacticalOverlay
extends Node2D

@export var marker_scene: PackedScene = preload("res://presentation/battle/overlay/battle_tactical_marker_view.tscn")

var layout: BattleArenaLayout
var state: BattleTacticalState
var _markers: Dictionary = {}


func bind(value: BattleTacticalState, arena: BattleArenaLayout) -> void:
	if state != null and state.changed.is_connected(_refresh):
		state.changed.disconnect(_refresh)
	for marker in _markers.values():
		remove_child(marker)
		marker.queue_free()
	_markers.clear()
	state = value
	layout = arena
	for anchor in layout.get_anchors():
		var instance := marker_scene.instantiate()
		if not instance is BattleTacticalMarkerView:
			instance.free()
			push_error("Tactical marker scene must extend BattleTacticalMarkerView.")
			continue
		add_child(instance)
		instance.bind_anchor(anchor)
		_markers[anchor.coordinate] = instance
	state.changed.connect(_refresh)
	_refresh()


func get_marker(coordinate: Vector2i) -> BattleTacticalMarkerView:
	return _markers.get(coordinate) as BattleTacticalMarkerView


func _refresh() -> void:
	if state == null:
		return
	var preview_flags: Dictionary = {}
	for preview in state.surface_previews:
		var kind := BattleTacticalState.Kind.VALID_TARGET if preview.can_place else BattleTacticalState.Kind.INVALID_TARGET
		preview_flags[preview.coordinate] = int(preview_flags.get(preview.coordinate, 0)) | kind | BattleTacticalState.Kind.AOE
	for coordinate in _markers:
		var marker: BattleTacticalMarkerView = _markers[coordinate]
		marker.set_flags(state.get_flags(coordinate) | int(preview_flags.get(coordinate, 0)))


func _exit_tree() -> void:
	if state != null and state.changed.is_connected(_refresh):
		state.changed.disconnect(_refresh)
