class_name CampaignShell
extends Control


signal section_requested(
	section_id: StringName
)

signal back_requested
signal menu_requested


const SECTION_WORLD_MAP: StringName = &"world_map"
const SECTION_PARTY: StringName = &"party"
const SECTION_QUESTS: StringName = &"quests"


var _location_label: Label
var _calendar_label: Label
var _resources_label: Label

var _back_button: Button
var _map_button: Button
var _party_button: Button
var _quests_button: Button

var _content_host: MarginContainer
var _modal_layer: Control


func _ready() -> void:
	_ensure_interface()


func refresh_hud(
	state: CampaignState,
	location_text: String,
	calendar_text: String,
	active_section_id: StringName,
	can_go_back: bool,
	can_access_party: bool
) -> void:
	_ensure_interface()

	_location_label.text = (
		location_text
		if not location_text.is_empty()
		else "Неизвестная местность"
	)

	_calendar_label.text = calendar_text

	var gold := 0
	var materials := 0
	var reputation := 0
	var uncollected_gold := 0
	var active_quest_count := 0

	if state != null:
		materials = state.materials
		reputation = state.reputation

		if state.inventory_state != null:
			gold = state.inventory_state.gold

		if state.home_settlement_state != null:
			uncollected_gold = (
				state
					.home_settlement_state
					.uncollected_gold
			)

		for quest_state in state.quests:
			if (
				quest_state != null
				and quest_state.is_active()
			):
				active_quest_count += 1

	_resources_label.text = (
		"Гроші: %d · Материалы: %d · Репутация: %d"
		% [
			gold,
			materials,
			reputation,
		]
	)

	if uncollected_gold > 0:
		_resources_label.text += (
			" · В поселении накоплено: %d гр."
			% uncollected_gold
		)

	_quests_button.text = (
		"ЗАДАНИЯ (%d)"
		% active_quest_count
	)

	_back_button.visible = can_go_back

	_map_button.disabled = (
		active_section_id
		== SECTION_WORLD_MAP
	)

	_party_button.disabled = (
		not can_access_party
		or active_section_id
			== SECTION_PARTY
	)

	_party_button.tooltip_text = (
		"Управление отрядом доступно "
		+ "в HOME после обустройства места отряда."
		if not can_access_party
		else ""
	)

	_quests_button.disabled = (
		active_section_id
		== SECTION_QUESTS
	)


func set_content(
	content: Control
) -> void:
	_ensure_interface()

	for child in _content_host.get_children():
		_content_host.remove_child(
			child
		)

		child.queue_free()

	if content == null:
		return

	content.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	content.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	_content_host.add_child(
		content
	)


func show_modal(
	modal: Control
) -> void:
	_ensure_interface()

	clear_modal()

	if modal == null:
		return

	_modal_layer.visible = true

	_modal_layer.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	_modal_layer.add_child(
		modal
	)

	modal.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


func clear_modal() -> void:
	if _modal_layer == null:
		return

	for child in _modal_layer.get_children():
		_modal_layer.remove_child(
			child
		)

		child.queue_free()

	_modal_layer.visible = false

	_modal_layer.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)


func has_modal() -> bool:
	return (
		_modal_layer != null
		and _modal_layer.visible
		and not _modal_layer.get_children().is_empty()
	)


func _ensure_interface() -> void:
	if _content_host != null:
		return

	_build_interface()


func _build_interface() -> void:
	var background := ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.045,
		0.05,
		0.06,
		1.0
	)

	add_child(
		background
	)

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left",
		24
	)

	margin.add_theme_constant_override(
		"margin_top",
		20
	)

	margin.add_theme_constant_override(
		"margin_right",
		24
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	root.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_theme_constant_override(
		"separation",
		12
	)

	margin.add_child(
		root
	)

	root.add_child(
		_create_hud_panel()
	)

	root.add_child(
		_create_navigation_panel()
	)

	var content_frame := PanelContainer.new()

	content_frame.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	content_frame.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_child(
		content_frame
	)

	_content_host = MarginContainer.new()

	_content_host.add_theme_constant_override(
		"margin_left",
		8
	)

	_content_host.add_theme_constant_override(
		"margin_top",
		8
	)

	_content_host.add_theme_constant_override(
		"margin_right",
		8
	)

	_content_host.add_theme_constant_override(
		"margin_bottom",
		8
	)

	content_frame.add_child(
		_content_host
	)

	_modal_layer = Control.new()

	_modal_layer.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	_modal_layer.z_index = 100
	_modal_layer.visible = false

	_modal_layer.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	add_child(
		_modal_layer
	)


func _create_hud_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		6
	)

	panel.add_child(
		content
	)

	var top_row := HBoxContainer.new()

	top_row.add_theme_constant_override(
		"separation",
		16
	)

	content.add_child(
		top_row
	)

	var brand := Label.new()

	brand.text = "КЛЕЙНОД"

	brand.custom_minimum_size = Vector2(
		190,
		0
	)

	brand.add_theme_font_size_override(
		"font_size",
		26
	)

	top_row.add_child(
		brand
	)

	_location_label = Label.new()

	_location_label.text = "—"

	_location_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_location_label.add_theme_font_size_override(
		"font_size",
		20
	)

	top_row.add_child(
		_location_label
	)

	_calendar_label = Label.new()

	_calendar_label.text = "—"

	_calendar_label.add_theme_font_size_override(
		"font_size",
		16
	)

	top_row.add_child(
		_calendar_label
	)

	_resources_label = Label.new()

	_resources_label.text = "—"

	_resources_label.add_theme_font_size_override(
		"font_size",
		16
	)

	content.add_child(
		_resources_label
	)

	return panel


func _create_navigation_panel() -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		row
	)

	_back_button = Button.new()

	_back_button.text = "← НАЗАД"

	_back_button.custom_minimum_size = Vector2(
		130,
		42
	)

	_back_button.visible = false

	_back_button.pressed.connect(
		_on_back_pressed
	)

	row.add_child(
		_back_button
	)

	_map_button = _create_section_button(
		"КАРТА",
		SECTION_WORLD_MAP
	)

	row.add_child(
		_map_button
	)

	_party_button = _create_section_button(
		"ОТРЯД",
		SECTION_PARTY
	)

	row.add_child(
		_party_button
	)

	_quests_button = _create_section_button(
		"ЗАДАНИЯ (0)",
		SECTION_QUESTS
	)

	row.add_child(
		_quests_button
	)

	var spacer := Control.new()

	spacer.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	row.add_child(
		spacer
	)

	var menu_button := Button.new()

	menu_button.text = "МЕНЮ"

	menu_button.custom_minimum_size = Vector2(
		130,
		42
	)

	menu_button.pressed.connect(
		_on_menu_pressed
	)

	row.add_child(
		menu_button
	)

	return panel


func _create_section_button(
	text: String,
	section_id: StringName
) -> Button:
	var button := Button.new()

	button.text = text

	button.custom_minimum_size = Vector2(
		150,
		42
	)

	button.pressed.connect(
		_on_section_pressed.bind(
			section_id
		)
	)

	return button


func _on_section_pressed(
	section_id: StringName
) -> void:
	section_requested.emit(
		section_id
	)


func _on_back_pressed() -> void:
	back_requested.emit()


func _on_menu_pressed() -> void:
	menu_requested.emit()