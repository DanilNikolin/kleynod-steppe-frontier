class_name HeroCoreHoverPanel
extends PanelContainer

@onready var title_label: Label = $ContentMargin/VBoxContainer/TitleLabel
@onready var description_label: Label = $ContentMargin/VBoxContainer/DescriptionLabel
@onready var value_label: Label = $ContentMargin/VBoxContainer/ValueLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_panel()

func show_info(
	title: String,
	description: String,
	value_text: String = ""
) -> void:
	title_label.text = title
	description_label.text = description

	value_label.text = value_text
	value_label.visible = not value_text.is_empty()

	visible = true

func hide_panel() -> void:
	visible = false
