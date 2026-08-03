class_name HeroPreparationPanel
extends Control


signal close_requested
signal hero_state_changed


var hero_state: CampaignHeroState
var inventory_state: CampaignInventoryState

var close_button_text: String = "Вернуться в лагерь"


func bind(
	p_hero_state: CampaignHeroState,
	p_inventory_state: CampaignInventoryState,
	p_close_button_text: String = "Вернуться в лагерь"
) -> void:
	hero_state = p_hero_state
	inventory_state = p_inventory_state
	close_button_text = p_close_button_text

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	var background := ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.055,
		0.06,
		0.07,
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
		24
	)

	margin.add_theme_constant_override(
		"margin_right",
		24
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		24
	)

	add_child(
		margin
	)

	var root_column := VBoxContainer.new()

	root_column.add_theme_constant_override(
		"separation",
		16
	)

	margin.add_child(
		root_column
	)

	var header := _create_header()

	root_column.add_child(
		header
	)

	if (
		hero_state == null
		or not hero_state.is_valid_state()
	):
		var error_label := Label.new()

		error_label.text = (
			"Hero Preparation не получил "
			+"валидного CampaignHeroState."
		)

		root_column.add_child(
			error_label
		)

		return

	var main_row := HBoxContainer.new()

	main_row.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	main_row.add_theme_constant_override(
		"separation",
		20
	)

	root_column.add_child(
		main_row
	)

	var skill_grid_panel := HeroSkillGridPanel.new()

	skill_grid_panel.custom_minimum_size = Vector2(
		520,
		0
	)

	skill_grid_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	skill_grid_panel.state_changed.connect(
		_on_section_state_changed
	)

	main_row.add_child(
		skill_grid_panel
	)

	skill_grid_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var center_column := VBoxContainer.new()

	center_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	center_column.add_theme_constant_override(
		"separation",
		16
	)

	main_row.add_child(
		center_column
	)

	var summary_panel := HeroBuildSummaryPanel.new()

	summary_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	summary_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	center_column.add_child(
		summary_panel
	)

	summary_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var loadout_panel := HeroLoadoutPanel.new()

	loadout_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	loadout_panel.state_changed.connect(
		_on_section_state_changed
	)

	center_column.add_child(
		loadout_panel
	)

	loadout_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var equipment_panel := HeroEquipmentPanel.new()

	equipment_panel.custom_minimum_size = Vector2(
		430,
		0
	)

	equipment_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	equipment_panel.state_changed.connect(
		_on_section_state_changed
	)

	main_row.add_child(
		equipment_panel
	)

	equipment_panel.bind(
		hero_state.progression_state,
		inventory_state
	)


func _create_header() -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		row
	)

	var title := Label.new()

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	if (
		hero_state != null
		and hero_state.hero_definition != null
	):
		title.text = (
			"ПОДГОТОВКА ГЕРОЯ · %s"
			% hero_state.hero_definition.display_name
		)

	else:
		title.text = "ПОДГОТОВКА ГЕРОЯ"

	title.add_theme_font_size_override(
		"font_size",
		26
	)

	row.add_child(
		title
	)

	var close_button := Button.new()

	close_button.text = close_button_text

	close_button.pressed.connect(
		_on_close_pressed
	)

	row.add_child(
		close_button
	)

	return panel


func _on_section_state_changed() -> void:
	hero_state_changed.emit()

	call_deferred(
		"_rebuild_interface"
	)


func _on_close_pressed() -> void:
	close_requested.emit()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()