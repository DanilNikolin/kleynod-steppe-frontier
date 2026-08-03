class_name CampaignSandbox
extends Control


var build_resolver := (
	HeroBattleBuildResolver.new()
)


func _ready() -> void:
	if not CampaignRuntime.ensure_campaign_started():
		_show_initialization_error()
		return

	_rebuild_interface()


func _rebuild_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

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
		48
	)

	margin.add_theme_constant_override(
		"margin_top",
		36
	)

	margin.add_theme_constant_override(
		"margin_right",
		48
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		36
	)

	add_child(
		margin
	)

	var root_column := VBoxContainer.new()

	root_column.add_theme_constant_override(
		"separation",
		20
	)

	margin.add_child(
		root_column
	)

	var header := _create_header_panel()

	root_column.add_child(
		header
	)

	var body_row := HBoxContainer.new()

	body_row.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_theme_constant_override(
		"separation",
		20
	)

	root_column.add_child(
		body_row
	)

	var hero_panel := _create_hero_panel()

	hero_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_child(
		hero_panel
	)

	var locations_panel := _create_locations_panel()

	locations_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_child(
		locations_panel
	)

	var result_panel := _create_result_panel()

	root_column.add_child(
		result_panel
	)


func _create_header_panel() -> Control:
	var panel := PanelContainer.new()
	var content := HBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = "ЛАГЕРЬ · CAMPAIGN FLOW SANDBOX"

	title.add_theme_font_size_override(
		"font_size",
		28
	)

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	content.add_child(
		title
	)

	var reset_button := Button.new()

	reset_button.text = "Новая debug-кампания"

	reset_button.pressed.connect(
		_on_reset_campaign_pressed
	)

	content.add_child(
		reset_button
	)

	return panel


func _create_hero_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = "АКТИВНЫЙ ГЕРОЙ"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	content.add_child(
		title
	)

	var hero_state := (
		CampaignRuntime.get_active_hero_state()
	)

	if (
		hero_state == null
		or not hero_state.is_valid_state()
	):
		var error_label := Label.new()

		error_label.text = (
			"Активный герой отсутствует "
			+"или имеет ошибочное состояние."
		)

		content.add_child(
			error_label
		)

		return panel

	var hero_name := Label.new()

	hero_name.text = (
		hero_state.hero_definition.display_name
	)

	hero_name.add_theme_font_size_override(
		"font_size",
		20
	)

	content.add_child(
		hero_name
	)

	var build := build_resolver.resolve(
		hero_state.hero_definition,
		hero_state.progression_state
	)

	var summary := Label.new()

	summary.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	if build == null:
		summary.text = (
			"Hero Battle Build не удалось собрать."
		)

	else:
		summary.text = _get_build_summary(
			build
		)

	content.add_child(
		summary
	)

	var preparation_button := Button.new()

	preparation_button.text = (
		"Подготовка героя — следующий этап"
	)

	preparation_button.disabled = true

	content.add_child(
		preparation_button
	)

	return panel


func _create_locations_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = "ДОСТУПНЫЕ ЛОКАЦИИ"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	content.add_child(
		title
	)

	for location in (
		CampaignRuntime.get_available_locations()
	):
		content.add_child(
			_create_location_card(
				location
			)
		)

	return panel


func _create_location_card(
	location: CampaignLocationDefinition
) -> Control:
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

	title.text = location.display_name

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	content.add_child(
		title
	)

	var description := Label.new()

	description.text = location.description

	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		description
	)

	var start_button := Button.new()

	start_button.text = "Отправиться"

	start_button.pressed.connect(
		_on_location_pressed.bind(
			location.location_id
		)
	)

	content.add_child(
		start_button
	)

	return panel


func _create_result_panel() -> Control:
	var panel := PanelContainer.new()
	var content := HBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	panel.add_child(
		content
	)

	var state := CampaignRuntime.get_campaign_state()

	var title := Label.new()

	title.text = "ПОСЛЕДНИЙ ПОХОД"

	title.custom_minimum_size = Vector2(
		220,
		0
	)

	content.add_child(
		title
	)

	var result_label := Label.new()

	result_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	if (
		state == null
		or state.last_battle_result == null
	):
		result_label.text = (
			"Походов ещё не было."
		)

	else:
		var location := CampaignRuntime.get_location(
			state.last_battle_result.location_id
		)

		var location_name := (
			location.display_name
			if location != null
			else String(
				state.last_battle_result.location_id
			)
		)

		result_label.text = (
			"%s · %s · завершено боёв: %d"
			% [
				location_name,
				state
					.last_battle_result
					.get_outcome_display_name(),
				state.completed_battle_count,
			]
		)

	content.add_child(
		result_label
	)

	return panel


func _get_build_summary(
	build: HeroBattleBuild
) -> String:
	var ability_names := PackedStringArray()

	for ability in build.loadout.get_abilities():
		ability_names.append(
			"• %s"
			% ability.display_name
		)

	var item_names := PackedStringArray()

	for item in build.equipped_items:
		if (
			item == null
			or item.definition == null
		):
			continue

		item_names.append(
			"• %s"
			% item.definition.display_name
		)

	if item_names.is_empty():
		item_names.append(
			"—"
		)

	return (
		"Уровень: %d\n"
		% CampaignRuntime
			.get_active_hero_state()
			.progression_state
			.level
		+"\n"
		+"Сила: %d\n"
		% build.strength_rank
		+"Спритность: %d\n"
		% build.agility_rank
		+"Воля: %d\n"
		% build.spirit_rank
		+"\n"
		+"HP: %d\n"
		% build.combatant_definition.max_health
		+"Armor: %d\n"
		% build.combatant_definition.base_armor
		+"Stamina: %d/%d · Regen %d\n"
		% [
			build.combatant_definition.start_stamina,
			build.combatant_definition.max_stamina,
			build
				.combatant_definition
				.stamina_regeneration,
		]
		+"\n"
		+"Боевые способности:\n%s\n"
		% "\n".join(
			ability_names
		)
		+"\n"
		+"Экипировка:\n%s"
		% "\n".join(
			item_names
		)
	)


func _on_location_pressed(
	location_id: StringName
) -> void:
	var started := CampaignRuntime.start_location(
		location_id
	)

	if not started:
		push_warning(
			"Campaign location could not be started."
		)


func _on_reset_campaign_pressed() -> void:
	if not CampaignRuntime.start_new_campaign():
		push_warning(
			"Campaign could not be reset."
		)

		return

	_rebuild_interface()


func _show_initialization_error() -> void:
	var label := Label.new()

	label.text = (
		"Campaign Flow Sandbox "
		+"не смог создать состояние кампании."
	)

	label.position = Vector2(
		32,
		32
	)

	add_child(
		label
	)