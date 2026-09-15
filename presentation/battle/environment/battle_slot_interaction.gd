class_name BattleSlotInteraction
extends Node2D

signal slot_hovered(coordinate: Vector2i)
signal slot_clicked(coordinate: Vector2i, mouse_button: int)

const NO_SLOT := Vector2i(-1, -1)

var layout: BattleArenaLayout
var hovered_coordinate: Vector2i = NO_SLOT
var _motion_serial: int = 0
var _unhandled_motion_serial: int = -1


func set_layout(value: BattleArenaLayout) -> void:
	layout = value
	_set_hover(NO_SLOT)


func _input(event: InputEvent) -> void:
	# Defer clearing until GUI has had a chance to consume the event.
	if event is InputEventMouseMotion:
		_motion_serial += 1
		_clear_gui_hover.call_deferred(_motion_serial)


func _clear_gui_hover(serial: int) -> void:
	if serial == _motion_serial and _unhandled_motion_serial != serial:
		_set_hover(NO_SLOT)


func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(layout):
		return
	if not (event is InputEventMouseMotion or event is InputEventMouseButton):
		return
	if event is InputEventMouseMotion:
		_unhandled_motion_serial = _motion_serial
	var world_position: Vector2 = get_canvas_transform().affine_inverse() * (event as InputEventMouse).position
	var anchor := layout.pick_slot(world_position)
	_set_hover(anchor.coordinate if anchor != null else NO_SLOT)
	if anchor != null and event is InputEventMouseButton and event.pressed:
		slot_clicked.emit(anchor.coordinate, event.button_index)
		get_viewport().set_input_as_handled()


func _set_hover(coordinate: Vector2i) -> void:
	if coordinate == hovered_coordinate:
		return
	hovered_coordinate = coordinate
	slot_hovered.emit(coordinate)
