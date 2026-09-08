class_name CampaignSandbox
extends Control


const HERO_PREPARATION_PANEL_SCENE: PackedScene = preload(
	"res://presentation/campaign/hero_preparation/"
	+"hero_preparation_panel.tscn"
)


enum View {
	WORLD_MAP,
	PARTY,
	QUEST_JOURNAL,
	LOCAL_LOCATION,
	ADVENTURE_AREA,
	TRADING,
	HERO_PREPARATION,
}


var _shell: CampaignShell

var _current_view: View = View.WORLD_MAP

var _view_stack: Array[int] = []

var _save_status_text: String = ""

var _current_menu_panel: CampaignMenuPanel

var _active_trader_id: StringName = &""


func _ready() -> void:
	if not CampaignRuntime.ensure_campaign_started():
		_show_initialization_error()
		return

	_build_shell()

	var return_area_id := (
		CampaignRuntime
			.consume_return_adventure_area_id()
	)

	var current_node := (
		CampaignRuntime.get_current_world_node()
	)

	if (
		return_area_id != &""
		and current_node != null
		and current_node.adventure_area_id
			== return_area_id
	):
		_show_view(
			View.ADVENTURE_AREA
		)

	else:
		_show_view(
			View.WORLD_MAP
		)


func _build_shell() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	_shell = CampaignShell.new()

	add_child(
		_shell
	)

	_shell.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	_shell.section_requested.connect(
		_on_shell_section_requested
	)

	_shell.back_requested.connect(
		_on_shell_back_requested
	)

	_shell.menu_requested.connect(
		_on_shell_menu_requested
	)


func _show_view(
	view: View,
	push_current: bool = false
) -> void:
	if _shell == null:
		return

	if (
		push_current
		and view != _current_view
	):
		_push_current_view()

	_current_view = view

	var content: Control

	match view:
		View.WORLD_MAP:
			content = _create_world_map_panel()

		View.PARTY:
			content = _create_party_panel()

		View.QUEST_JOURNAL:
			content = _create_quest_journal_panel()

		View.LOCAL_LOCATION:
			content = _create_local_location_panel()

		View.ADVENTURE_AREA:
			content = (
				_create_adventure_area_panel()
			)

		View.TRADING:
			content = _create_trading_panel()

		View.HERO_PREPARATION:
			content = _create_hero_preparation_panel()

	if content == null:
		push_warning(
			"Campaign view could not be created."
		)

		_view_stack.clear()

		_current_view = (
			View.WORLD_MAP
		)

		content = _create_world_map_panel()

	_shell.set_content(
		content
	)

	_refresh_shell()


func _refresh_current_view() -> void:
	_show_view(
		_current_view,
		false
	)


func _refresh_shell() -> void:
	if _shell == null:
		return

	var state := (
		CampaignRuntime.get_campaign_state()
	)

	var current_node := (
		CampaignRuntime.get_current_world_node()
	)

	var location_text := (
		current_node.display_name
		if current_node != null
		else "Неизвестная местность"
	)

	_shell.refresh_hud(
		state,
		location_text,
		_get_calendar_display_text(),
		_get_active_section_id(),
		not _view_stack.is_empty()
	)


func _get_active_section_id() -> StringName:
	match _current_view:
		View.WORLD_MAP:
			return (
				CampaignShell.SECTION_WORLD_MAP
			)

		View.PARTY:
			return (
				CampaignShell.SECTION_PARTY
			)

		View.HERO_PREPARATION:
			return (
				CampaignShell.SECTION_PARTY
			)

		View.QUEST_JOURNAL:
			return (
				CampaignShell.SECTION_QUESTS
			)

	return &""


func _push_current_view() -> void:
	var current_value := int(
		_current_view
	)

	if (
		not _view_stack.is_empty()
		and _view_stack.back()
			== current_value
	):
		return

	_view_stack.append(
		current_value
	)


func _go_back() -> void:
	if _view_stack.is_empty():
		_show_view(
			View.WORLD_MAP
		)

		return

	var previous_view := int(
		_view_stack.pop_back()
	)

	_show_view(
		previous_view as View
	)


func _create_adventure_area_panel() -> Control:
	var current_node := (
		CampaignRuntime.get_current_world_node()
	)

	if (
		current_node == null
		or current_node.adventure_area_id == &""
	):
		return null

	var area_definition := (
		CampaignRuntime
			.get_adventure_area_definition(
				current_node.adventure_area_id
			)
	)

	var area_state := (
		CampaignRuntime
			.get_adventure_area_state(
				current_node.adventure_area_id
			)
	)

	if (
		area_definition == null
		or area_state == null
	):
		return null

	var panel := (
		CampaignAdventureAreaPanel.new()
	)

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.exit_requested.connect(
		_on_adventure_area_exit_requested
	)

	panel.battle_site_requested.connect(
		_on_adventure_site_battle_requested
	)

	panel.bind(
		area_definition,
		area_state
	)

	return panel


func _create_world_map_panel() -> Control:
	var panel := CampaignWorldMapPanel.new()

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

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
		CampaignRuntime.get_campaign_state(),
		CampaignRuntime.get_home_settlement_definition(),
		CampaignRuntime.get_home_settlement_state()
	)

	return panel


func _create_party_panel() -> Control:
	var panel := CampaignPartyPanel.new()

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.state_changed.connect(
		_on_party_state_changed
	)

	panel.preparation_requested.connect(
		_on_preparation_requested
	)

	panel.bind(
		CampaignRuntime.get_campaign_state()
	)

	return panel


func _create_quest_journal_panel() -> Control:
	var panel := (
		CampaignQuestJournalPanel.new()
	)

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.close_requested.connect(
		_on_shell_back_requested
	)

	panel.abandon_requested.connect(
		_on_quest_journal_abandon_requested.bind(
			panel
		)
	)

	panel.bind(
		CampaignRuntime.get_quest_definitions(),
		CampaignRuntime.get_resident_definitions(),
		CampaignRuntime.get_campaign_state(),
		false
	)

	return panel


func _create_hero_preparation_panel() -> Control:
	var panel := (
		HERO_PREPARATION_PANEL_SCENE.instantiate()
		as HeroPreparationPanel
	)

	if panel == null:
		return null

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.close_requested.connect(
		_on_preparation_closed
	)

	panel.hero_state_changed.connect(
		_refresh_shell
	)

	panel.bind_campaign(
		CampaignRuntime.get_campaign_state(),
		"← К ОТРЯДУ"
	)

	return panel


func _create_trading_panel() -> Control:
	if _active_trader_id == &"":
		return null

	var trader_definition := (
		CampaignRuntime.get_trader_definition(
			_active_trader_id
		)
	)

	var trader_state := (
		CampaignRuntime.get_trader_state(
			_active_trader_id
		)
	)

	var campaign_state := (
		CampaignRuntime.get_campaign_state()
	)

	if (
		trader_definition == null
		or trader_state == null
		or campaign_state == null
	):
		return null

	var panel := CampaignTradingPanel.new()

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.close_requested.connect(
		_on_trading_close_requested
	)

	panel.buy_requested.connect(
		_on_trading_buy_requested.bind(
			panel
		)
	)

	panel.sell_requested.connect(
		_on_trading_sell_requested.bind(
			panel
		)
	)

	panel.bind(
		trader_definition,
		trader_state,
		campaign_state
	)

	return panel


func _create_local_location_panel() -> Control:
	var definition := (
		CampaignRuntime
			.get_current_local_location_definition()
	)

	if definition == null:
		push_warning(
			"Current world node has no local location."
		)

		return null

	var panel := (
		CampaignLocalLocationPanel.new()
	)

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.exit_requested.connect(
		_on_local_location_exit_requested
	)

	panel.interaction_action_requested.connect(
		_on_local_interaction_action_requested.bind(
			panel
		)
	)

	panel.settlement_build_requested.connect(
		_on_home_settlement_build_requested.bind(
			panel
		)
	)

	panel.settlement_demolish_requested.connect(
		_on_home_settlement_demolish_requested.bind(
			panel
		)
	)

	panel.settlement_upgrade_requested.connect(
		_on_home_settlement_upgrade_requested.bind(
			panel
		)
	)

	panel.resident_invite_requested.connect(
		_on_resident_invite_requested.bind(
			panel
		)
	)

	panel.resident_commission_requested.connect(
		_on_resident_commission_requested.bind(
			panel
		)
	)

	panel.quest_start_requested.connect(
		_on_quest_start_requested.bind(
			panel
		)
	)

	panel.quest_turn_in_requested.connect(
		_on_quest_turn_in_requested.bind(
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
		settlement_state,
		CampaignRuntime.get_resident_definitions(),
		CampaignRuntime.get_quest_definitions(),
		true
	)

	return panel


func _on_shell_section_requested(
	section_id: StringName
) -> void:
	var target_view: View

	match section_id:
		CampaignShell.SECTION_WORLD_MAP:
			target_view = View.WORLD_MAP

		CampaignShell.SECTION_PARTY:
			target_view = View.PARTY

		CampaignShell.SECTION_QUESTS:
			target_view = View.QUEST_JOURNAL

		_:
			return

	if target_view == _current_view:
		return

	## Верхняя навигация не уничтожает контекст.
	## Текущий экран становится предыдущим,
	## поэтому игрок может пройти назад
	## ровно по той цепочке, по которой пришёл.
	_show_view(
		target_view,
		true
	)


func _on_shell_back_requested() -> void:
	_go_back()


func _on_shell_menu_requested() -> void:
	if (
		_shell == null
		or _shell.has_modal()
	):
		return

	var panel := CampaignMenuPanel.new()

	_current_menu_panel = panel

	panel.close_requested.connect(
		_on_menu_close_requested
	)

	panel.save_requested.connect(
		_on_menu_save_requested.bind(
			panel
		)
	)

	panel.load_requested.connect(
		_on_menu_load_requested.bind(
			panel
		)
	)

	panel.new_debug_requested.connect(
		_on_menu_new_debug_requested
	)

	panel.bind(
		_save_status_text
	)

	_shell.show_modal(
		panel
	)


func _on_menu_close_requested() -> void:
	if _shell != null:
		_shell.clear_modal()

	_current_menu_panel = null


func _on_menu_save_requested(
	panel: CampaignMenuPanel
) -> void:
	var result := (
		CampaignRuntime.save_campaign()
	)

	_apply_save_result(
		result
	)

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.set_status_message(
			_save_status_text
		)

	_refresh_shell()


func _on_menu_load_requested(
	panel: CampaignMenuPanel
) -> void:
	var result := (
		CampaignRuntime.load_campaign()
	)

	_apply_save_result(
		result
	)

	if not result.is_successful:
		if (
			panel != null
			and is_instance_valid(panel)
		):
			panel.set_status_message(
				_save_status_text
			)

		return

	_view_stack.clear()

	if _shell != null:
		_shell.clear_modal()

	_current_menu_panel = null

	_active_trader_id = &""

	_show_view(
		View.WORLD_MAP
	)


func _on_menu_new_debug_requested() -> void:
	_save_status_text = ""

	if not CampaignRuntime.start_new_campaign():
		push_warning(
			"Campaign could not be reset."
		)

		return

	_view_stack.clear()

	if _shell != null:
		_shell.clear_modal()

	_current_menu_panel = null

	_active_trader_id = &""

	_show_view(
		View.WORLD_MAP
	)


func _on_party_state_changed() -> void:
	_refresh_current_view()


func _on_preparation_requested(
	_hero_id: StringName
) -> void:
	_show_view(
		View.HERO_PREPARATION,
		true
	)


func _on_preparation_closed() -> void:
	_go_back()


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

	## После реального travel нельзя Back-нуться
	## в старую локальную локацию.
	_view_stack.clear()

	_active_trader_id = &""

	_show_view(
		View.WORLD_MAP
	)


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
			+"where the party is not located."
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

	_show_view(
		View.LOCAL_LOCATION,
		true
	)


func _on_world_adventure_requested() -> void:
	var current_node := (
		CampaignRuntime.get_current_world_node()
	)

	if current_node == null:
		return

	if current_node.adventure_area_id != &"":
		_show_view(
			View.ADVENTURE_AREA,
			true
		)

		return

	var started := (
		CampaignRuntime
			.start_current_world_adventure()
	)

	if not started:
		push_warning(
			"Campaign world adventure could not be started."
		)


func _on_adventure_area_exit_requested() -> void:
	_go_back()


func _on_adventure_site_battle_requested(
	area_id: StringName,
	site_id: StringName
) -> void:
	var started := (
		CampaignRuntime.start_adventure_site(
			area_id,
			site_id
		)
	)

	if not started:
		push_warning(
			"Adventure site battle could not be started."
		)


func _on_local_location_exit_requested() -> void:
	_go_back()


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

	_refresh_shell()


func _on_home_settlement_demolish_requested(
	zone_id: StringName,
	panel: CampaignLocalLocationPanel
) -> void:
	var demolished := (
		CampaignRuntime
			.demolish_home_settlement_building(
				zone_id
			)
	)

	if not demolished:
		push_warning(
			"Home settlement demolition failed."
		)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

	_refresh_shell()


func _on_home_settlement_upgrade_requested(
	zone_id: StringName,
	panel: CampaignLocalLocationPanel
) -> void:
	var upgraded := (
		CampaignRuntime
			.upgrade_home_settlement_building(
				zone_id
			)
	)

	if not upgraded:
		push_warning(
			"Home settlement upgrade failed."
		)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

		panel.show_status_message(
			"Постройка улучшена."
		)

	_refresh_shell()


func _on_resident_invite_requested(
	resident_id: StringName,
	panel: CampaignLocalLocationPanel
) -> void:
	var recruited := (
		CampaignRuntime.invite_resident(
			resident_id
		)
	)

	if not recruited:
		push_warning(
			"Resident invitation failed."
		)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

	_refresh_shell()


func _on_resident_commission_requested(
	resident_id: StringName,
	commission_id: StringName,
	panel: CampaignLocalLocationPanel
) -> void:
	var created_item := (
		CampaignRuntime
			.commission_home_resident_item(
				resident_id,
				commission_id
			)
	)

	if created_item == null:
		push_warning(
			"Resident equipment commission failed."
		)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

		panel.show_status_message(
			"Заказ выполнен: %s · предмет добавлен в инвентарь."
			% created_item.definition.display_name
		)

	_refresh_shell()


func _on_quest_start_requested(
	quest_id: StringName,
	panel: CampaignLocalLocationPanel
) -> void:
	if not CampaignRuntime.start_quest(
		quest_id
	):
		push_warning(
			"Quest could not be started."
		)

		return

	var quest := (
		CampaignRuntime.get_quest_definition(
			quest_id
		)
	)

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

		panel.show_status_message(
			"Задание принято: %s."
			% (
				quest.display_name
				if quest != null
				else String(quest_id)
			)
		)

	_refresh_shell()


func _on_quest_turn_in_requested(
	quest_id: StringName,
	panel: CampaignLocalLocationPanel
) -> void:
	var quest := (
		CampaignRuntime.get_quest_definition(
			quest_id
		)
	)

	if not CampaignRuntime.turn_in_quest(
		quest_id
	):
		push_warning(
			"Quest could not be turned in."
		)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

		panel.show_status_message(
			"Задание завершено: %s."
			% (
				quest.display_name
				if quest != null
				else String(quest_id)
			)
		)

	_refresh_shell()


func _on_quest_journal_abandon_requested(
	quest_id: StringName,
	panel: CampaignQuestJournalPanel
) -> void:
	var quest := (
		CampaignRuntime.get_quest_definition(
			quest_id
		)
	)

	if not CampaignRuntime.abandon_quest(
		quest_id
	):
		push_warning(
			"Quest could not be abandoned."
		)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

		panel.show_status_message(
			"Задание отменено: %s."
			% (
				quest.display_name
				if quest != null
				else String(quest_id)
			)
		)

	_refresh_shell()


func _on_local_interaction_action_requested(
	interaction_id: StringName,
	action_label: String,
	_panel: CampaignLocalLocationPanel
) -> void:
	var trader := (
		CampaignRuntime.get_trader_for_interaction(
			interaction_id
		)
	)

	if trader == null:
		return

	if action_label != trader.open_action_label:
		return

	_active_trader_id = trader.trader_id

	_show_view(
		View.TRADING,
		true
	)


func _on_trading_buy_requested(
	trader_id: StringName,
	item_instance_id: StringName,
	panel: CampaignTradingPanel
) -> void:
	var trader_state := (
		CampaignRuntime.get_trader_state(
			trader_id
		)
	)

	var item := (
		trader_state.get_item(
			item_instance_id
		)
		if trader_state != null
		else null
	)

	var item_name := (
		item.definition.display_name
		if (
			item != null
			and item.definition != null
		)
		else String(item_instance_id)
	)

	var price := (
		CampaignRuntime.get_trader_buy_price(
			trader_id,
			item_instance_id
		)
	)

	if not CampaignRuntime.buy_from_trader(
		trader_id,
		item_instance_id
	):
		if (
			panel != null
			and is_instance_valid(panel)
		):
			panel.show_status_message(
				"Покупка не выполнена."
			)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

		panel.show_status_message(
			"Куплено: %s за %d зол."
			% [
				item_name,
				price,
			]
		)

	_refresh_shell()


func _on_trading_sell_requested(
	trader_id: StringName,
	item_instance_id: StringName,
	panel: CampaignTradingPanel
) -> void:
	var campaign_state := (
		CampaignRuntime.get_campaign_state()
	)

	var item := (
		campaign_state
			.inventory_state
			.get_item(
				item_instance_id
			)
		if (
			campaign_state != null
			and campaign_state.inventory_state != null
		)
		else null
	)

	var item_name := (
		item.definition.display_name
		if (
			item != null
			and item.definition != null
		)
		else String(item_instance_id)
	)

	var price := (
		CampaignRuntime.get_trader_sell_price(
			trader_id,
			item_instance_id
		)
	)

	if not CampaignRuntime.sell_to_trader(
		trader_id,
		item_instance_id
	):
		if (
			panel != null
			and is_instance_valid(panel)
		):
			panel.show_status_message(
				"Продажа не выполнена."
			)

		return

	if (
		panel != null
		and is_instance_valid(panel)
	):
		panel.refresh_state()

		panel.show_status_message(
			"Продано: %s за %d зол."
			% [
				item_name,
				price,
			]
		)

	_refresh_shell()


func _on_trading_close_requested() -> void:
	_go_back()


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
			_save_status_text = (
				"Ошибка сохранения"
			)

		CampaignSaveService.STATUS_LOAD_ERROR:
			_save_status_text = (
				"Ошибка загрузки"
			)

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