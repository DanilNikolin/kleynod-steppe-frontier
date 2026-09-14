class_name LocalResidentPresenceVisual
extends Node2D

@export var resident_id: StringName = &""

func _ready() -> void:
	if not Engine.is_editor_hint():
		set_present(false)

func set_present(present: bool) -> void:
	visible = present

	var controllers := find_children(
		"*",
		"IntermittentDetailAnimation",
		true,
		false
	)

	for node in controllers:
		if node is IntermittentDetailAnimation:
			node.set_active(present)
