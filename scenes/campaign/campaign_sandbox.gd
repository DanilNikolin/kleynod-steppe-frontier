class_name CampaignSandbox
extends Control


const HERO_PREPARATION_PANEL_SCENE: PackedScene = preload(
	"res://presentation/campaign/hero_preparation/"
	+"hero_preparation_panel.tscn"
)


var _is_preparation_open: bool = false


func _ready() -> void:
	if not CampaignRuntime.ensure_campaign_started():
		_show_initialization_error()
		return

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	if _is_preparation_open:
		_show_preparation_interface()
		return

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

	root_column.add_child(
		_create_header_panel()
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

	var party_panel := CampaignPartyPanel.new()

	party_panel.custom_minimum_size = Vector2(
		920,
		0
	)

	party_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	party_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	party_panel.state_changed.connect(
		_on_party_state_changed
	)

	party_panel.preparation_requested.connect(
		_on_preparation_requested
	)

	body_row.add_child(
		party_panel
	)

	party_panel.bind(
		CampaignRuntime.get_campaign_state()
	)

	var locations_panel := _create_locations_panel()

	locations_panel.custom_minimum_size = Vector2(
		520,
		0
	)

	locations_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_child(
		locations_panel
	)

	root_column.add_child(
		_create_result_panel()
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

	var party_label := Label.new()

	party_label.text = (
		"В поход отправятся:\n%s"
		% _get_party_names()
	)

	party_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		party_label
	)

	content.add_child(
		HSeparator.new()
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

	start_button.text = "Отправиться отрядом"

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

		var battle_party_names := (
			_get_hero_names(
				state
					.last_battle_result
					.party_member_hero_ids
			)
		)

		var experience_text := (
			"опыт: +%d каждому (%d всего)"
			% [
				state
					.last_battle_result
					.experience_per_party_member,
				state
					.last_battle_result
					.defeated_enemy_experience_pool,
			]
		)

		result_label.text = (
			"%s · %s · отряд: %s · %s · завершено боёв: %d"
			% [
				location_name,
				state
					.last_battle_result
					.get_outcome_display_name(),
				battle_party_names,
				experience_text,
				state.completed_battle_count,
			]
		)

		if (
			state
				.last_battle_result
				.has_level_ups()
		):
			var level_up_names := PackedStringArray()

			for hero_id_value in (
				state
					.last_battle_result
					.level_ups_by_hero_id
					.keys()
			):
				var hero_id := StringName(
					hero_id_value
				)

				var hero_state := state.get_hero(
					hero_id
				)

				var hero_name := (
					hero_state.get_display_name()
					if hero_state != null
					else String(hero_id)
				)

				var gained_levels := (
					state
						.last_battle_result
						.get_level_ups_for_hero(
							hero_id
						)
				)

				level_up_names.append(
					"%s +%d ур."
					% [
						hero_name,
						gained_levels,
					]
				)

			if not level_up_names.is_empty():
				result_label.text += (
					" · LEVEL UP: %s"
					% ", ".join(
						level_up_names
					)
				)

	result_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		result_label
	)

	return panel


func _show_preparation_interface() -> void:
	var panel := (
		HERO_PREPARATION_PANEL_SCENE.instantiate()
		as HeroPreparationPanel
	)
	
	if panel == null:
		_is_preparation_open = false
		_show_initialization_error()
		return

	add_child(
		panel
	)

	panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	panel.close_requested.connect(
		_on_preparation_closed
	)

	panel.bind_campaign(
		CampaignRuntime.get_campaign_state()
	)


func _get_party_names() -> String:
	var state := CampaignRuntime.get_campaign_state()

	if state == null:
		return "—"

	var lines := PackedStringArray()

	for party_index in range(
		state.party_member_hero_ids.size()
	):
		var hero_state := state.get_hero(
			state.party_member_hero_ids[
				party_index
			]
		)

		if hero_state == null:
			continue

		lines.append(
			"%d. %s"
			% [
				party_index + 1,
				hero_state.get_display_name(),
			]
		)

	if lines.is_empty():
		return "—"

	return "\n".join(
		lines
	)


func _get_hero_names(
	hero_ids: Array[StringName]
) -> String:
	var state := CampaignRuntime.get_campaign_state()
	var names := PackedStringArray()

	if state == null:
		return "—"

	for hero_id in hero_ids:
		var hero_state := state.get_hero(
			hero_id
		)

		if hero_state == null:
			names.append(
				String(hero_id)
			)

		else:
			names.append(
				hero_state.get_display_name()
			)

	if names.is_empty():
		return "—"

	return ", ".join(
		names
	)


func _on_party_state_changed() -> void:
	call_deferred(
		"_rebuild_interface"
	)


func _on_preparation_requested(
	_hero_id: StringName
) -> void:
	_is_preparation_open = true

	_rebuild_interface()


func _on_preparation_closed() -> void:
	_is_preparation_open = false

	_rebuild_interface()


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
	_is_preparation_open = false

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


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()
