class_name BattleStatusIcon
extends Control

var status: BattleStatusInstance
var semantic: String

func bind_entry(entry: Dictionary, icon_size: int = 20, interactive: bool = false) -> void:
	status = entry.status
	semantic = entry.semantic
	var magnitude: int = entry.get("magnitude", 0)
	custom_minimum_size = Vector2(icon_size, icon_size)
	$Icon.texture = BattleStatusVisualResolver.TEXTURES.get(semantic)
	$MagnitudeLabel.visible = magnitude > 1
	$MagnitudeLabel.text = str(magnitude)
	mouse_filter = Control.MOUSE_FILTER_PASS if interactive else Control.MOUSE_FILTER_IGNORE
	tooltip_text = "%s\n%s\nОсталось ходов: %d" % [status.definition.display_name, status.definition.description, status.remaining_turns] if interactive else ""
	if interactive and status.stack_count > 1:
		tooltip_text += "\nСтаки: %d" % status.stack_count
