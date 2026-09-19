class_name HeroCoreIndicator
extends Control

@export var active_texture: Texture2D
@export var inactive_texture: Texture2D

@onready var icon: TextureRect = $Icon

func set_active(is_active: bool) -> void:
	if icon == null:
		icon = get_node_or_null("Icon")
	if icon != null:
		icon.texture = active_texture if is_active else inactive_texture

func set_magnitude(value: int) -> void:
	var label := get_node_or_null("MagnitudeLabel") as Label
	if label != null:
		label.visible = value > 0
		label.text = str(value)
