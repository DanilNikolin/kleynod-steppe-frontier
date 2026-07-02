class_name BattleActionPreviewBadge
extends PanelContainer


@onready
var value_label: Label = (
	$ContentMargin/ValueLabel
)


func _ready() -> void:
	visible = false


func show_preview(
	text: String
) -> void:
	if text.strip_edges().is_empty():
		clear_preview()
		return

	value_label.text = text
	visible = true


func clear_preview() -> void:
	value_label.text = ""
	visible = false