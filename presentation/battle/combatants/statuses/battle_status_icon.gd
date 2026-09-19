class_name BattleStatusIcon
extends Control

signal hover_started(icon: BattleStatusIcon)
signal hover_ended(icon: BattleStatusIcon)

var status: BattleStatusInstance
var semantic: String
var magnitude: int = 0

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	hover_started.emit(self)

func _on_mouse_exited() -> void:
	hover_ended.emit(self)

func get_hover_title() -> String:
	if status == null or status.definition == null:
		return ""
	return status.definition.display_name

func get_hover_description() -> String:
	if status == null or status.definition == null:
		return ""
	return status.definition.description

func get_hover_value_text() -> String:
	if status == null:
		return ""
	var parts: Array[String] = []
	if status.remaining_turns > 0:
		parts.append("Осталось: %d ходов" % status.remaining_turns)
	if status.stack_count > 1:
		parts.append("Стаки: %d" % status.stack_count)
	if magnitude > 0:
		parts.append("Величина: %d" % magnitude)
	return " · ".join(parts)

func bind_entry(entry: Dictionary, icon_size: int = 20, interactive: bool = false) -> void:
	status = entry.status
	semantic = entry.semantic
	magnitude = entry.get("magnitude", 0)
	custom_minimum_size = Vector2(icon_size, icon_size)
	$Icon.texture = BattleStatusVisualResolver.TEXTURES.get(semantic)
	$MagnitudeLabel.visible = magnitude > 1
	$MagnitudeLabel.text = str(magnitude)
	mouse_filter = Control.MOUSE_FILTER_PASS if interactive else Control.MOUSE_FILTER_IGNORE
	tooltip_text = ""
