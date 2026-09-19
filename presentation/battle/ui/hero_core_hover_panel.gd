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

func show_for_control(
	source: Control,
	title: String,
	description: String,
	value_text: String = ""
) -> void:
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	custom_minimum_size = Vector2(310, 0)
	size.x = 310

	show_info(title, description, value_text)
	if source == null or not source.is_inside_tree():
		return

	# Force layout update to determine real height based on wrapped text
	reset_size()

	var panel_size: Vector2 = get_combined_minimum_size()
	panel_size.x = maxf(panel_size.x, 310.0)
	panel_size.y = maxf(panel_size.y, size.y)

	var vp_rect: Rect2 = get_viewport_rect()
	var src_rect: Rect2 = source.get_global_rect()

	const OFFSET: float = 10.0
	const PADDING: float = 12.0

	# 1. Preferred: above source, aligned to source center
	var target_pos := Vector2(
		src_rect.position.x + (src_rect.size.x - panel_size.x) * 0.5,
		src_rect.position.y - panel_size.y - OFFSET
	)

	# 2. If not enough room on top, check to the right, then below
	if target_pos.y < PADDING:
		if src_rect.end.x + OFFSET + panel_size.x <= vp_rect.size.x - PADDING:
			target_pos.x = src_rect.end.x + OFFSET
			target_pos.y = src_rect.position.y + (src_rect.size.y - panel_size.y) * 0.5
		elif src_rect.end.y + OFFSET + panel_size.y <= vp_rect.size.y - PADDING:
			target_pos.y = src_rect.end.y + OFFSET

	# 3. Strict clamp to viewport with safe margin ~12px
	target_pos.x = clampf(target_pos.x, PADDING, maxf(PADDING, vp_rect.size.x - panel_size.x - PADDING))
	target_pos.y = clampf(target_pos.y, PADDING, maxf(PADDING, vp_rect.size.y - panel_size.y - PADDING))

	global_position = target_pos

func hide_panel() -> void:
	visible = false
