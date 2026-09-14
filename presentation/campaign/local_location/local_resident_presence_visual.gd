class_name LocalResidentPresenceVisual
extends Node2D

@export var resident_id: StringName = &""

var _has_explicit_presence: bool = false
var _is_present: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		if _has_explicit_presence:
			set_present(_is_present)
		else:
			set_present(false)

func set_present(present: bool) -> void:
	_has_explicit_presence = true
	_is_present = present
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
