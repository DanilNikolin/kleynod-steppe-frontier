class_name HeroPreparationPanel
extends Control


signal close_requested
signal hero_state_changed


var campaign_state: CampaignState

var hero_state: CampaignHeroState
var inventory_state: CampaignInventoryState

var close_button_text: String = "Вернуться в лагерь"

var party_service := (
	CampaignPartyService.new()
)


func bind(
	p_hero_state: CampaignHeroState,
	p_inventory_state: CampaignInventoryState,
	p_close_button_text: String = "Вернуться в лагерь"
) -> void:
	campaign_state = null

	hero_state = p_hero_state
	inventory_state = p_inventory_state
	close_button_text = p_close_button_text

	_rebuild_interface()


func bind_campaign(
	p_campaign_state: CampaignState,
	p_close_button_text: String = "Вернуться в лагерь"
) -> void:
	campaign_state = p_campaign_state

	hero_state = (
		campaign_state.get_selected_hero()
		if campaign_state != null
		else null
	)

	inventory_state = (
		campaign_state.inventory_state
		if campaign_state != null
		else null
	)

	close_button_text = p_close_button_text

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	if campaign_state != null:
		hero_state = campaign_state.get_selected_hero()

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

	root_column.add_child(
		_create_header()
	)

	if campaign_state != null:
		root_column.add_child(
			_create_hero_switcher()
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

	if campaign_state != null:
		equipment_panel.bind_campaign(
			campaign_state,
			hero_state
		)

	else:
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
			% hero_state.get_display_name()
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


func _create_hero_switcher() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		8
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = (
		"ГЕРОИ РОСТЕРА · ОТРЯД %d/3"
		% campaign_state.party_member_hero_ids.size()
	)

	content.add_child(
		title
	)

	var buttons := HFlowContainer.new()

	buttons.add_theme_constant_override(
		"h_separation",
		8
	)

	buttons.add_theme_constant_override(
		"v_separation",
		8
	)

	content.add_child(
		buttons
	)

	for roster_hero in campaign_state.heroes:
		if roster_hero == null:
			continue

		var button := Button.new()

		var button_text := roster_hero.get_display_name()

		if campaign_state.is_hero_in_party(
			roster_hero.get_hero_id()
		):
			button_text += " · ОТРЯД"

		button.text = button_text

		button.disabled = (
			campaign_state.selected_hero_id
			== roster_hero.get_hero_id()
		)

		button.pressed.connect(
			_on_hero_switch_pressed.bind(
				roster_hero.get_hero_id()
			)
		)

		buttons.add_child(
			button
		)

	return panel


func _on_hero_switch_pressed(
	hero_id: StringName
) -> void:
	var result := party_service.select_hero(
		campaign_state,
		hero_id
	)

	if not result.is_successful:
		push_warning(
			"Hero Preparation switch failed: %s"
			% result.failure_code
		)

		return

	hero_state = campaign_state.get_selected_hero()

	hero_state_changed.emit()

	call_deferred(
		"_rebuild_interface"
	)


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
