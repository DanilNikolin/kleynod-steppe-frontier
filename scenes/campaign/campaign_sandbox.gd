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

var _dialogue_session: CampaignDialogueSession
var _dialogue_panel: CampaignDialoguePanel
var _dialogue_local_panel: CampaignLocalLocationPanel

var _world_map_panel: CampaignWorldMapPanel

var _travel_event_session: CampaignTravelEventSession

var _travel_event_panel: CampaignTravelEventPanel

var _travel_animation_active: bool = false


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

	if CampaignRuntime.has_pending_travel():
		call_deferred(
			"_resume_or_present_pending_travel"
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
		content,
		view == View.LOCAL_LOCATION
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

	var pending := (
		CampaignRuntime.get_pending_travel()
	)

	if pending != null:
		var world_map := (
			CampaignRuntime
				.get_world_map_definition()
		)

		if world_map != null:
			var origin := (
				world_map.get_node(
					pending.from_node_id
				)
			)

			var destination := (
				world_map.get_node(
					pending.destination_node_id
				)
			)

			if (
				origin != null
				and destination != null
			):
				location_text = (
					"В пути: %s → %s"
					% [
						origin.display_name,
						destination.display_name,
					]
				)

	_shell.refresh_hud(
		state,
		location_text,
		_get_calendar_display_text(),
		_get_active_section_id(),
		not _view_stack.is_empty(),
		_is_party_management_available()
	)


func _is_party_management_available() -> bool:
	if not CampaignRuntime.has_active_home_settlement_effect(
		&"party_management_access"
	):
		return false

	var current_node := (
		CampaignRuntime.get_current_world_node()
	)

	var home_definition := (
		CampaignRuntime.get_home_settlement_definition()
	)

	if (
		current_node == null
		or home_definition == null
		or current_node.node_id
			!= home_definition.world_node_id
	):
		return false

	## Управление отрядом физически привязано
	## к месту отряда внутри HOME.
	##
	## PARTY / HERO_PREPARATION оставляем true,
	## чтобы уже открытый контекст не ломал сам себя.
	return (
		_current_view == View.LOCAL_LOCATION
		or _current_view == View.PARTY
		or _current_view == View.HERO_PREPARATION
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

	panel.landmark_site_requested.connect(
		_on_adventure_site_landmark_requested
	)

	panel.bind(
		area_definition,
		area_state
	)

	return panel


func _create_world_map_panel() -> Control:
	var panel := CampaignWorldMapPanel.new()

	_world_map_panel = panel

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.travel_requested.connect(
		_on_world_travel_requested
	)

	panel.travel_animation_finished.connect(
		_on_world_travel_animation_finished
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
		CampaignRuntime.get_home_settlement_state(),
		CampaignRuntime.get_pending_travel()
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
		"← К ОТРЯДУ",
		CampaignRuntime
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
		campaign_state,
		CampaignRuntime.get_home_settlement_definition()
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

	panel.construction_projects = CampaignRuntime.campaign_definition.construction_projects
	panel.dialogue_requested.connect(_on_dialogue_requested.bind(panel))

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
	if (
		_shell.has_modal()
		or _travel_animation_active
		or CampaignRuntime.has_pending_travel()
	):
		return

	var target_view: View

	match section_id:
		CampaignShell.SECTION_WORLD_MAP:
			target_view = View.WORLD_MAP

		CampaignShell.SECTION_PARTY:
			if not _is_party_management_available():
				return

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
	if (
		_shell.has_modal()
		or _travel_animation_active
		or CampaignRuntime.has_pending_travel()
	):
		return

	_go_back()


func _on_shell_menu_requested() -> void:
	if (
		_shell == null
		or _shell.has_modal()
		or _travel_animation_active
		or CampaignRuntime.has_pending_travel()
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
	if (
		_travel_animation_active
		or CampaignRuntime.has_pending_travel()
	):
		return

	var started := (
		CampaignRuntime.begin_travel(
			destination_node_id
		)
	)

	if not started:
		push_warning(
			"Campaign world travel could not begin."
		)

		return

	## После начала настоящего travel нельзя
	## Back-нуться в старую local location.
	_view_stack.clear()

	_active_trader_id = &""

	_show_view(
		View.WORLD_MAP
	)

	call_deferred(
		"_animate_pending_travel"
	)


func _resume_or_present_pending_travel() -> void:
	var pending := (
		CampaignRuntime.get_pending_travel()
	)

	if pending == null:
		return

	if pending.has_reached_event():
		_show_travel_event()
		return

	_animate_pending_travel()


func _animate_pending_travel() -> void:
	if _travel_animation_active:
		return

	var pending := (
		CampaignRuntime.get_pending_travel()
	)

	if (
		pending == null
		or _world_map_panel == null
		or not is_instance_valid(
			_world_map_panel
		)
	):
		return

	_world_map_panel.sync_pending_travel(
		pending
	)

	_travel_animation_active = true

	if not (
		_world_map_panel
			.animate_pending_travel_to_next_stop()
	):
		_travel_animation_active = false

		push_warning(
			"Pending travel animation "
			+ "could not start."
		)


func _on_world_travel_animation_finished() -> void:
	if not _travel_animation_active:
		return

	_travel_animation_active = false

	if not (
		CampaignRuntime
			.advance_pending_travel_to_next_stop()
	):
		push_warning(
			"Campaign pending travel "
			+ "could not advance."
		)

		return

	_refresh_shell()

	var pending := (
		CampaignRuntime.get_pending_travel()
	)

	if pending == null:
		# Destination reached.
		_show_view(
			View.WORLD_MAP
		)

		return

	if (
		_world_map_panel != null
		and is_instance_valid(
			_world_map_panel
		)
	):
		_world_map_panel.sync_pending_travel(
			pending
		)

	if pending.has_reached_event():
		_show_travel_event()
		return

	call_deferred(
		"_animate_pending_travel"
	)


func _show_travel_event(
	error: String = ""
) -> void:
	if (
		_shell == null
		or _shell.has_modal()
	):
		return

	var session := (
		CampaignTravelEventSession.new()
	)

	if not session.begin(
		CampaignRuntime
	):
		push_warning(
			"Travel event session could not begin."
		)

		return

	_travel_event_session = session

	_travel_event_panel = (
		CampaignTravelEventPanel.new()
	)

	_travel_event_panel.choice_requested.connect(
		_on_travel_event_choice
	)

	_shell.show_modal(
		_travel_event_panel
	)

	_travel_event_panel.show_session(
		_travel_event_session,
		error
	)


func _on_travel_event_choice(
	choice_id: StringName,
	revision: int
) -> void:
	if _travel_event_session == null:
		return

	var error := (
		_travel_event_session.choose(
			choice_id,
			revision
		)
	)

	_refresh_shell()

	# START_BATTLE уже инициировал смену сцены.
	if CampaignRuntime.has_pending_battle():
		return

	if _travel_event_session.closed:
		_travel_event_session = null
		_travel_event_panel = null

		if _shell != null:
			_shell.clear_modal()

		var pending := (
			CampaignRuntime.get_pending_travel()
		)

		if (
			pending != null
			and _world_map_panel != null
			and is_instance_valid(
				_world_map_panel
			)
		):
			_world_map_panel.sync_pending_travel(
				pending
			)

		call_deferred(
			"_animate_pending_travel"
		)

		return

	if (
		_travel_event_panel != null
		and is_instance_valid(
			_travel_event_panel
		)
	):
		_travel_event_panel.show_session(
			_travel_event_session,
			error
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


func _on_adventure_site_landmark_requested(
	area_id: StringName,
	site_id: StringName
) -> void:
	var explored := (
		CampaignRuntime.explore_adventure_site(
			area_id,
			site_id
		)
	)

	if not explored:
		push_warning(
			"Adventure landmark could not be explored."
		)

		return

	_refresh_current_view()


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
	var campaign := CampaignRuntime.campaign_definition
	var state := CampaignRuntime.campaign_state
	if not CampaignRuntime.construction_context_error().is_empty():
		return
	var local := CampaignRuntime.get_current_local_location_definition()
	var interaction := local.get_interaction(interaction_id) if local != null else null
	if interaction == null or not interaction.action_labels.has(action_label):
		return
	if action_label == "ОТКРЫТЬ КУЗНИЦУ":
		var settlement := campaign.home_settlement_definition
		var forge_zone := settlement.get_zone(settlement.forge_zone_id)
		var master := CampaignRuntime.forge_service.get_master(campaign, state)
		var valid_interaction := forge_zone != null and forge_zone.local_interaction_id == interaction_id
		valid_interaction = valid_interaction or (master != null and master.home_interaction_id == interaction_id)
		if valid_interaction and state.current_world_node_id == settlement.world_node_id and CampaignRuntime.forge_service.has_shell(settlement, state.home_settlement_state):
			_show_forge_panel(_panel)
		return
	var source_id: StringName = &""
	var construction := false
	if interaction_id == campaign.construction_worksite_interaction_id:
		construction = state.current_world_node_id == campaign.home_settlement_definition.world_node_id and CampaignRuntime.construction_service.worksite_available(campaign, state)
	else:
		for source in campaign.crew_sources:
			if source.interaction_id == interaction_id and source.world_node_id == state.current_world_node_id:
				source_id = source.source_id
				construction = true
	if construction:
		var panel := CampaignConstructionPanel.new()
		panel.close_requested.connect(func() -> void:
			_shell.clear_modal()
			if is_instance_valid(_panel):
				_panel.refresh_state()
			_refresh_shell()
		)
		panel.state_changed.connect(_refresh_shell)
		_shell.show_modal(panel)
		panel.bind(CampaignRuntime, source_id)
		return
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
			"Куплено: %s за %d гр."
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
			"Продано: %s за %d гр."
			% [
				item_name,
				price,
			]
		)

	_refresh_shell()


func _on_trading_close_requested() -> void:
	if _dialogue_session != null and _dialogue_session.pending_trader_id != &"":
		var error := _dialogue_session.resume_from_trading()
		_active_trader_id = &""
		if not error.is_empty():
			var local_panel := _dialogue_local_panel
			_on_dialogue_closed(local_panel)
			if is_instance_valid(local_panel):
				local_panel.show_status_message(error)
		else:
			_show_dialogue_panel()
		_refresh_shell()
		return
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

func _on_dialogue_requested(interaction_id: StringName, local_panel: CampaignLocalLocationPanel) -> void:
	if _shell.has_modal():
		return
	var session := CampaignDialogueSession.new()
	if not session.begin(CampaignRuntime, interaction_id):
		local_panel.show_status_message("Сейчас не удаётся начать разговор.")
		return
	_dialogue_session = session
	_dialogue_local_panel = local_panel
	_show_dialogue_panel()


func _show_dialogue_panel(error: String = "") -> void:
	var local_panel := _dialogue_local_panel
	_dialogue_panel = CampaignDialoguePanel.new()
	_dialogue_panel.close_requested.connect(_on_dialogue_closed.bind(local_panel))
	_dialogue_panel.choice_requested.connect(_on_dialogue_choice.bind(local_panel))
	_shell.show_modal(_dialogue_panel)
	_dialogue_panel.show_session(_dialogue_session, error)


func _on_dialogue_choice(choice_id: StringName, revision: int, local_panel: CampaignLocalLocationPanel) -> void:
	if _dialogue_session == null:
		return
	var error := _dialogue_session.choose(choice_id, revision)
	_refresh_shell()
	if _dialogue_session.closed:
		_on_dialogue_closed(local_panel)
	elif _dialogue_session.pending_trader_id != &"":
		_active_trader_id = _dialogue_session.pending_trader_id
		var trading_panel := _create_trading_panel() as CampaignTradingPanel
		if trading_panel == null:
			_dialogue_session.resume_from_trading()
			_dialogue_panel.show_session(_dialogue_session, "Торговлю открыть не удалось.")
			return
		_dialogue_panel = null
		trading_panel.set_return_to_dialogue(true)
		_shell.show_modal(trading_panel)
	else:
		_dialogue_panel.show_session(_dialogue_session, error)


func _on_dialogue_closed(local_panel: CampaignLocalLocationPanel) -> void:
	if _dialogue_session != null:
		_dialogue_session.close()
	_dialogue_session = null
	_dialogue_panel = null
	_dialogue_local_panel = null
	_shell.clear_modal()
	if is_instance_valid(local_panel):
		local_panel.refresh_state()
	_refresh_shell()
	if _forge_return_pending and is_instance_valid(local_panel):
		_forge_return_pending = false
		_show_forge_panel(local_panel)


var _forge_return_pending: bool = false

func _show_forge_panel(local_panel: CampaignLocalLocationPanel) -> void:
	var panel := CampaignForgePanel.new()
	panel.close_requested.connect(func() -> void:
		_forge_return_pending = false
		_shell.clear_modal()
		if is_instance_valid(local_panel):
			local_panel.refresh_state()
		_refresh_shell()
	)
	panel.state_changed.connect(_refresh_shell)
	panel.talk_requested.connect(func(interaction_id: StringName) -> void:
		_forge_return_pending = true
		_shell.clear_modal()
		_on_dialogue_requested(interaction_id, local_panel)
		if _dialogue_session == null:
			_forge_return_pending = false
			_show_forge_panel(local_panel)
	)
	_shell.show_modal(panel)
	panel.bind(CampaignRuntime)
