class_name HeroPreparationPanel
extends Control


signal close_requested
signal hero_state_changed


enum PreparationTab {
	PROGRESSION,
	ABILITIES,
	EQUIPMENT,
	SUMMARY,
}


var campaign_state: CampaignState

var hero_state: CampaignHeroState
var inventory_state: CampaignInventoryState

var close_button_text: String = "Вернуться в лагерь"

var party_service := (
	CampaignPartyService.new()
)
var experience_service := HeroExperienceService.new()

var _current_tab: PreparationTab = (
	PreparationTab.PROGRESSION
)

var _selected_ability_id: StringName = &""


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

	root_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	root_column.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

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

	root_column.add_child(
		_create_tabs()
	)

	var separator := HSeparator.new()

	root_column.add_child(
		separator
	)

	var content := _create_active_tab_content()

	content.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	content.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root_column.add_child(
		content
	)


func _create_header() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		8
	)

	panel.add_child(
		content
	)

	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		12
	)

	content.add_child(
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

	if (
		hero_state != null
		and hero_state.progression_state != null
	):
		content.add_child(
			_create_experience_progress()
		)

	return panel


func _create_experience_progress() -> Control:
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		12
	)

	var progression := hero_state.progression_state

	var summary := Label.new()

	summary.custom_minimum_size = Vector2(
		300,
		0
	)

	var bar := ProgressBar.new()

	bar.custom_minimum_size = Vector2(
		360,
		18
	)

	bar.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	bar.show_percentage = false

	if progression.level >= (
		HeroExperienceService.MAX_LEVEL
	):
		summary.text = (
			"Уровень %d · MAX · SP %d"
			% [
				progression.level,
				progression.unspent_skill_points,
			]
		)

		bar.min_value = 0.0
		bar.max_value = 1.0
		bar.value = 1.0

	else:
		var required_experience := (
			experience_service
				.get_experience_required_for_next_level(
					progression.level
				)
		)

		summary.text = (
			"Уровень %d · XP %d/%d · SP %d"
			% [
				progression.level,
				progression.experience,
				required_experience,
				progression.unspent_skill_points,
			]
		)

		bar.min_value = 0.0
		bar.max_value = float(
			maxi(
				required_experience,
				1
			)
		)

		bar.value = float(
			clampi(
				progression.experience,
				0,
				maxi(
					required_experience,
					1
				)
			)
		)

	row.add_child(
		summary
	)

	row.add_child(
		bar
	)

	return row


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


func _create_tabs() -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		8
	)

	panel.add_child(
		row
	)

	var button_group := ButtonGroup.new()

	button_group.allow_unpress = false

	row.add_child(
		_create_tab_button(
			"РАЗВИТИЕ",
			PreparationTab.PROGRESSION,
			button_group
		)
	)

	row.add_child(
		_create_tab_button(
			"УМЕНИЯ",
			PreparationTab.ABILITIES,
			button_group
		)
	)

	row.add_child(
		_create_tab_button(
			"СНАРЯЖЕНИЕ",
			PreparationTab.EQUIPMENT,
			button_group
		)
	)

	row.add_child(
		_create_tab_button(
			"СВОДКА",
			PreparationTab.SUMMARY,
			button_group
		)
	)

	return panel


func _create_tab_button(
	button_text: String,
	tab: PreparationTab,
	button_group: ButtonGroup
) -> Button:
	var button := Button.new()

	button.text = button_text
	button.toggle_mode = true
	button.button_group = button_group

	button.custom_minimum_size = Vector2(
		170,
		46
	)

	button.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	button.set_pressed_no_signal(
		_current_tab == tab
	)

	button.pressed.connect(
		_on_tab_pressed.bind(
			tab
		)
	)

	return button


func _create_active_tab_content() -> Control:
	match _current_tab:
		PreparationTab.PROGRESSION:
			return _create_progression_tab()

		PreparationTab.ABILITIES:
			return _create_abilities_tab()

		PreparationTab.EQUIPMENT:
			return _create_equipment_tab()

		PreparationTab.SUMMARY:
			return _create_summary_tab()

	var fallback := Label.new()

	fallback.text = "Неизвестная вкладка."

	return fallback


func _create_progression_tab() -> Control:
	var root := VBoxContainer.new()

	root.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	root.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_theme_constant_override(
		"separation",
		10
	)

	root.add_child(
		_create_progression_qa_bar()
	)

	var skill_grid_panel := HeroSkillGridPanel.new()

	skill_grid_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	skill_grid_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	skill_grid_panel.state_changed.connect(
		_on_section_state_changed
	)

	root.add_child(
		skill_grid_panel
	)

	skill_grid_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	return root


func _create_abilities_tab() -> Control:
	var abilities_panel := HeroAbilitiesPanel.new()

	abilities_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	abilities_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	abilities_panel.state_changed.connect(
		_on_section_state_changed
	)

	abilities_panel.ability_selected.connect(
		_on_ability_selected
	)

	abilities_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state,
		_selected_ability_id
	)

	return abilities_panel


func _create_equipment_tab() -> Control:
	var equipment_panel := HeroEquipmentPanel.new()

	equipment_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	equipment_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	equipment_panel.state_changed.connect(
		_on_section_state_changed
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

	return equipment_panel


func _create_summary_tab() -> Control:
	var summary_panel := HeroBuildSummaryPanel.new()

	summary_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	summary_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	summary_panel.bind(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	return summary_panel


func _create_progression_qa_bar() -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		row
	)

	var progression := (
		hero_state.progression_state
	)

	var label := Label.new()

	label.text = (
		"QA · Skill Points: %d · Куплено нод: %d"
		% [
			progression.unspent_skill_points,
			progression.purchased_node_ids.size(),
		]
	)

	label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	row.add_child(
		label
	)

	var add_points_button := Button.new()

	add_points_button.text = "+20 SP"

	add_points_button.pressed.connect(
		_on_qa_add_skill_points_pressed
	)

	row.add_child(
		add_points_button
	)

	var reset_button := Button.new()

	reset_button.text = "Сбросить Skill Grid"

	reset_button.pressed.connect(
		_on_qa_reset_skill_grid_pressed
	)

	row.add_child(
		reset_button
	)

	return panel

func _on_qa_add_skill_points_pressed() -> void:
	if (
		hero_state == null
		or hero_state.progression_state == null
	):
		return

	var progression := (
		hero_state.progression_state
	)

	progression.unspent_skill_points = clampi(
		progression.unspent_skill_points + 20,
		0,
		999
	)

	hero_state_changed.emit()

	call_deferred(
		"_rebuild_interface"
	)


func _on_qa_reset_skill_grid_pressed() -> void:
	if (
		hero_state == null
		or hero_state.hero_definition == null
		or hero_state.progression_state == null
	):
		return

	var hero_definition := (
		hero_state.hero_definition
	)

	var progression := (
		hero_state.progression_state
	)

	var refunded_skill_points := 0

	if hero_definition.skill_grid != null:
		for node_id in progression.purchased_node_ids:
			var node := (
				hero_definition
					.skill_grid
					.get_node_definition(
						node_id
					)
			)

			if node == null:
				continue

			refunded_skill_points += (
				node.skill_point_cost
			)

	progression.unspent_skill_points = clampi(
		progression.unspent_skill_points
			+ refunded_skill_points,
		0,
		999
	)

	progression.purchased_node_ids.clear()

	progression.selected_personal_ability_ids.clear()

	if hero_definition.default_ability_id != &"":
		progression.selected_personal_ability_ids.append(
			hero_definition.default_ability_id
		)

	for ability_id in (
		hero_definition.starting_known_ability_ids
	):
		if (
			progression
				.selected_personal_ability_ids
				.size()
			>= hero_definition.starting_active_slot_count
		):
			break

		if (
			progression
				.selected_personal_ability_ids
				.has(
					ability_id
				)
		):
			continue

		progression.selected_personal_ability_ids.append(
			ability_id
		)

	_selected_ability_id = &""

	hero_state_changed.emit()

	call_deferred(
		"_rebuild_interface"
	)

func _on_tab_pressed(
	tab: PreparationTab
) -> void:
	if _current_tab == tab:
		return

	_current_tab = tab

	_rebuild_interface()


func _on_ability_selected(
	ability_id: StringName
) -> void:
	_selected_ability_id = ability_id


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

	_selected_ability_id = &""

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
