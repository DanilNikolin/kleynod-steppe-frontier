class_name HeroCoreIndicator
extends Control

@export var active_texture: Texture2D
@export var inactive_texture: Texture2D
@export_multiline var tooltip_description: String = ""

@onready var icon: TextureRect = $Icon

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	var icon_node := get_node_or_null("Icon") as Control
	if icon_node != null:
		icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label_node := get_node_or_null("MagnitudeLabel") as Control
	if label_node != null:
		label_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_tooltip(0)

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
	_update_tooltip(value)

func _update_tooltip(value: int = 0) -> void:
	tooltip_text = tooltip_description
	if value > 0:
		if name == "ExhaustionDebt":
			tooltip_text = tooltip_description + "\nТекущий долг: %d" % value
		elif name == "MaxStaminaPenalty":
			tooltip_text = tooltip_description + "\nТекущий штраф: %d" % value
		else:
			tooltip_text += "\nТекущее значение: %d" % value

