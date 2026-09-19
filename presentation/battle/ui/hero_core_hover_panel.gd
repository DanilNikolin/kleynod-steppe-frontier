class_name HeroCoreHoverPanel
extends PanelContainer

const COMPACT_WIDTH := 310.0

@onready var title_label: Label = $ContentMargin/VBoxContainer/TitleLabel
@onready var description_label: Label = $ContentMargin/VBoxContainer/DescriptionLabel
@onready var value_label: Label = $ContentMargin/VBoxContainer/ValueLabel

var _layout_revision: int = 0

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
	_layout_revision += 1
	var revision := _layout_revision

	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.text = title
	description_label.text = description
	value_label.text = value_text
	value_label.visible = not value_text.is_empty()

	custom_minimum_size.x = COMPACT_WIDTH
	custom_minimum_size.y = 0.0
	size.x = COMPACT_WIDTH

	# Do not expose stale geometry
	modulate.a = 0.0
	visible = true

	_finalize_show.call_deferred(source, revision)

func _finalize_show(source: Control, revision: int) -> void:
	if revision != _layout_revision:
		return

	if source == null or not is_instance_valid(source) or not source.is_inside_tree():
		hide_panel()
		return

	reset_size()
	var minimum := get_combined_minimum_size()
	size = Vector2(COMPACT_WIDTH, minimum.y)

	var vp_rect: Rect2 = get_viewport_rect()
	var src_rect: Rect2 = source.get_global_rect()

	const OFFSET: float = 10.0
	const PADDING: float = 12.0

	# 1. Preferred: above source, aligned to source center
	var target_pos := Vector2(
		src_rect.position.x + (src_rect.size.x - size.x) * 0.5,
		src_rect.position.y - size.y - OFFSET
	)

	# 2. If not enough room on top, check to the right, then below
	if target_pos.y < PADDING:
		if src_rect.end.x + OFFSET + size.x <= vp_rect.size.x - PADDING:
			target_pos.x = src_rect.end.x + OFFSET
			target_pos.y = src_rect.position.y + (src_rect.size.y - size.y) * 0.5
		elif src_rect.end.y + OFFSET + size.y <= vp_rect.size.y - PADDING:
			target_pos.y = src_rect.end.y + OFFSET

	# 3. Strict clamp to viewport with safe margin ~12px
	target_pos.x = clampf(target_pos.x, PADDING, maxf(PADDING, vp_rect.size.x - size.x - PADDING))
	target_pos.y = clampf(target_pos.y, PADDING, maxf(PADDING, vp_rect.size.y - size.y - PADDING))

	global_position = target_pos
	modulate.a = 1.0

func hide_panel() -> void:
	_layout_revision += 1
	visible = false
	modulate.a = 1.0
