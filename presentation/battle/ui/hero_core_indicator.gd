class_name HeroCoreIndicator
extends Control

signal hover_started(indicator: HeroCoreIndicator)
signal hover_ended(indicator: HeroCoreIndicator)
signal hover_content_changed(indicator: HeroCoreIndicator)

@export var active_texture: Texture2D
@export var inactive_texture: Texture2D
@export var indicator_title: String = ""
@export_multiline var indicator_description: String = ""
@export var magnitude_caption: String = ""

var current_magnitude: int = 0
var is_hovered: bool = false

@onready var icon: TextureRect = $Icon

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var icon_node := get_node_or_null("Icon") as Control
	if icon_node != null:
		icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label_node := get_node_or_null("MagnitudeLabel") as Control
	if label_node != null:
		label_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func set_active(is_active: bool) -> void:
	if icon == null:
		icon = get_node_or_null("Icon")
	if icon != null:
		icon.texture = active_texture if is_active else inactive_texture

func set_magnitude(value: int) -> void:
	current_magnitude = maxi(0, value)
	var label := get_node_or_null("MagnitudeLabel") as Label
	if label != null:
		label.visible = current_magnitude > 0
		label.text = str(current_magnitude)
	if is_hovered:
		hover_content_changed.emit(self)

func get_hover_title() -> String:
	return indicator_title

func get_hover_description() -> String:
	return indicator_description

func get_hover_value_text() -> String:
	if current_magnitude <= 0:
		return ""
	if magnitude_caption.is_empty():
		return ""
	return "%s: %d" % [
		magnitude_caption,
		current_magnitude,
	]

func _on_mouse_entered() -> void:
	is_hovered = true
	hover_started.emit(self)

func _on_mouse_exited() -> void:
	is_hovered = false
	hover_ended.emit(self)
