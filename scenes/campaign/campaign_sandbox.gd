class_name CampaignSandbox
extends Control


const HERO_PREPARATION_PANEL_SCENE: PackedScene = preload(
	"res://presentation/campaign/hero_preparation/"
	+"hero_preparation_panel.tscn"
)


var _is_preparation_open: bool = false
var _is_local_location_open: bool = false
var _save_status_text: String = ""


func _ready() -> void:
	if not CampaignRuntime.ensure_campaign_started():
		_show_initialization_error()
		return

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	if _is_local_location_open:
		_show_local_location_interface()
		return

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

	var world_panel := _create_world_panel()

	world_panel.custom_minimum_size = Vector2(
		540,
		0
	)

	world_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	world_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	body_row.add_child(
		world_panel
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

	var inventory := (
		CampaignRuntime.get_inventory_state()
	)

	var gold_label := Label.new()

	gold_label.text = (
		"Золото: %d"
		% (
			inventory.gold
			if inventory != null
			else 0
		)
	)

	gold_label.add_theme_font_size_override(
		"font_size",
		18
	)

	content.add_child(
		gold_label
	)

	var state := (
		CampaignRuntime.get_campaign_state()
	)

	var world_resources_label := Label.new()

	world_resources_label.text = (
		"Материалы: %d · Репутация: %d"
		% [
			state.materials
			if state != null
			else 0,
			state.reputation
			if state != null
			else 0,
		]
	)

	world_resources_label.add_theme_font_size_override(
		"font_size",
		16
	)

	content.add_child(
		world_resources_label
	)

	var calendar_label := Label.new()

	calendar_label.text = (
		_get_calendar_display_text()
	)

	calendar_label.add_theme_font_size_override(
		"font_size",
		16
	)

	content.add_child(
		calendar_label
	)

	var save_status := Label.new()

	save_status.text = _save_status_text

	save_status.custom_minimum_size = Vector2(
		170,
		0
	)

	content.add_child(
		save_status
	)

	var save_button := Button.new()

	save_button.text = "СОХРАНИТЬ"

	save_button.pressed.connect(
		_on_save_campaign_pressed
	)

	content.add_child(
		save_button
	)

	var load_button := Button.new()

	load_button.text = "ЗАГРУЗИТЬ"

	load_button.pressed.connect(
		_on_load_campaign_pressed
	)

	content.add_child(
		load_button
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


func _create_world_panel() -> Control:
	var panel := CampaignWorldMapPanel.new()

	panel.travel_requested.connect(
		_on_world_travel_requested
	)

	panel.enter_requested.connect(
		_on_world_enter_requested
	)

	panel.adventure_requested.connect(
		_on_world_adventure_requested
	)

	panel.bind(
		CampaignRuntime.get_world_map_definition(),
		CampaignRuntime.get_campaign_state()
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

		var loot_text := (
			_get_battle_loot_text(
				state.last_battle_result
			)
		)

		result_label.text = (
			"%s · %s · отряд: %s · %s · %s · завершено боёв: %d"
			% [
				location_name,
				state
					.last_battle_result
					.get_outcome_display_name(),
				battle_party_names,
				experience_text,
				loot_text,
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


func _get_battle_loot_text(
	result: CampaignBattleResult
) -> String:
	if result == null:
		return "добыча: —"

	if (
		result.outcome
		!= CampaignBattleResult
			.Outcome
			.VICTORY
	):
		return "добыча: —"

	var parts := PackedStringArray()

	for item_name in (
		result.loot_item_display_names
	):
		parts.append(
			item_name
		)

	if result.gold_reward > 0:
		parts.append(
			"%d зол."
			% result.gold_reward
		)

	if parts.is_empty():
		return "добыча: ничего"

	return (
		"добыча: %s"
		% " + ".join(
			parts
		)
	)


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


func _show_local_location_interface() -> void:
	var definition := (
		CampaignRuntime
			.get_current_local_location_definition()
	)

	if definition == null:
		_is_local_location_open = false

		push_warning(
			"Current world node has no local location."
		)

		call_deferred(
			"_rebuild_interface"
		)

		return

	var panel := (
		CampaignLocalLocationPanel.new()
	)

	add_child(
		panel
	)

	panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	panel.exit_requested.connect(
		_on_local_location_exit_requested
	)

	panel.settlement_build_requested.connect(
		_on_home_settlement_build_requested.bind(
			panel
		)
	)

	var settlement_definition: CampaignSettlementDefinition
	var settlement_state: CampaignSettlementState

	var current_world_node := (
		CampaignRuntime.get_current_world_node()
	)

	var home_settlement_definition := (
		CampaignRuntime
			.get_home_settlement_definition()
	)

	if (
		current_world_node != null
		and home_settlement_definition != null
		and current_world_node.node_id
			== home_settlement_definition.world_node_id
	):
		settlement_definition = (
			home_settlement_definition
		)

		settlement_state = (
			CampaignRuntime
				.get_home_settlement_state()
		)

	panel.bind(
		definition,
		CampaignRuntime.get_campaign_state(),
		settlement_definition,
		settlement_state
	)


func _get_calendar_display_text() -> String:
	var season_name := (
		_get_season_display_name(
			CampaignRuntime.get_current_season()
		)
	)

	return (
		"%s · день %d/%d · год %d · %s"
		% [
			season_name,
			CampaignRuntime
				.get_current_day_in_season(),
			CampaignRuntime
				.get_days_per_season(),
			CampaignRuntime
				.get_current_year_number(),
			CampaignRuntime
				.get_current_time_text(),
		]
	)


func _get_season_display_name(
	season: int
) -> String:
	match season:
		CampaignCalendarRules.Season.SPRING:
			return "Весна"

		CampaignCalendarRules.Season.SUMMER:
			return "Лето"

		CampaignCalendarRules.Season.AUTUMN:
			return "Осень"

		CampaignCalendarRules.Season.WINTER:
			return "Зима"

		_:
			return "Неизвестный сезон"

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


func _on_world_travel_requested(
	destination_node_id: StringName
) -> void:
	var travelled := (
		CampaignRuntime.travel_to_world_node(
			destination_node_id
		)
	)

	if not travelled:
		push_warning(
			"Campaign world travel failed."
		)

		return

	_rebuild_interface()


func _on_world_enter_requested(
	node_id: StringName
) -> void:
	var state := (
		CampaignRuntime.get_campaign_state()
	)

	if (
		state == null
		or node_id == &""
		or node_id
			!= state.current_world_node_id
	):
		push_warning(
			"Cannot enter a world node "
			+ "where the party is not located."
		)

		return

	var local_definition := (
		CampaignRuntime
			.get_current_local_location_definition()
	)

	if local_definition == null:
		push_warning(
			"Current world node is not enterable."
		)

		return

	_is_preparation_open = false
	_is_local_location_open = true

	_rebuild_interface()


func _on_home_settlement_build_requested(
	zone_id: StringName,
	building_id: StringName,
	panel: CampaignLocalLocationPanel
) -> void:
	var constructed := (
		CampaignRuntime
			.construct_home_settlement_building(
				zone_id,
				building_id
			)
	)

	if not constructed:
		push_warning(
			"Home settlement construction failed."
		)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()


func _on_local_location_exit_requested() -> void:
	_is_local_location_open = false

	_rebuild_interface()


func _on_world_adventure_requested() -> void:
	var started := (
		CampaignRuntime
			.start_current_world_adventure()
	)

	if not started:
		push_warning(
			"Campaign world adventure could not be started."
		)

func _on_save_campaign_pressed() -> void:
	var result := (
		CampaignRuntime.save_campaign()
	)

	_apply_save_result(
		result
	)

	_rebuild_interface()


func _on_load_campaign_pressed() -> void:
	var result := (
		CampaignRuntime.load_campaign()
	)

	if result.is_successful:
		_is_preparation_open = false
		_is_local_location_open = false

	_apply_save_result(
		result
	)

	_rebuild_interface()


func _apply_save_result(
	result: CampaignSaveResult
) -> void:
	if result == null:
		_save_status_text = (
			"Ошибка Save / Load"
		)

		return

	match result.status_code:
		CampaignSaveService.STATUS_SAVED:
			_save_status_text = "Сохранено"

		CampaignSaveService.STATUS_LOADED:
			_save_status_text = "Загружено"

		CampaignSaveService.STATUS_NO_SAVE:
			_save_status_text = "Сохранения нет"

		CampaignSaveService.STATUS_SAVE_ERROR:
			_save_status_text = "Ошибка сохранения"

		CampaignSaveService.STATUS_LOAD_ERROR:
			_save_status_text = "Ошибка загрузки"

		_:
			_save_status_text = (
				"Ошибка Save / Load"
			)

	if (
		not result.is_successful
		and result.status_code
			!= CampaignSaveService.STATUS_NO_SAVE
	):
		push_warning(
			"Campaign Save / Load: %s"
			% result.message
		)


func _on_reset_campaign_pressed() -> void:
	_is_preparation_open = false
	_is_local_location_open = false
	_save_status_text = ""

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
