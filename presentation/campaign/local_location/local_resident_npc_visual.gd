class_name LocalResidentNpcVisual
extends LocalResidentPresenceVisual

signal resident_clicked(resident_id: StringName)

@export var camera_focus_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()

	var click_area := get_node_or_null("ClickArea") as Button
	if click_area != null:
		click_area.pressed.connect(_on_click_area_pressed)


func get_camera_focus_position() -> Vector2:
	return global_position + camera_focus_offset


func _on_click_area_pressed() -> void:
	resident_clicked.emit(resident_id)
