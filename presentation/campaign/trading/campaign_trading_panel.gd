class_name CampaignTradingPanel
extends PanelContainer


signal close_requested

signal buy_requested(
	trader_id: StringName,
	item_instance_id: StringName
)

signal sell_requested(
	trader_id: StringName,
	item_instance_id: StringName
)


enum SelectionSide {
	TRADER,
	PLAYER,
}


var _trader_definition: CampaignTraderDefinition
var _trader_state: CampaignTraderState
var _campaign_state: CampaignState
var _settlement_definition: CampaignSettlementDefinition

var _trading_service := CampaignTradingService.new()

var _selected_side: SelectionSide = SelectionSide.TRADER
var _selected_item_instance_id: StringName = &""

var _status_text: String = ""


var _trader_gold_label: Label
var _trade_terms_label: Label
var _player_gold_label: Label

var _trader_items: VBoxContainer
var _player_items: VBoxContainer

var _detail_title: Label
var _detail_category: Label
var _detail_description: Label
var _detail_abilities: Label
var _detail_ownership: Label
var _detail_price: Label

var _action_button: Button
var _status_label: Label


func bind(
	trader_definition: CampaignTraderDefinition,
	trader_state: CampaignTraderState,
	campaign_state: CampaignState,
	settlement_definition: CampaignSettlementDefinition
) -> void:
	_trader_definition = trader_definition
	_trader_state = trader_state
	_campaign_state = campaign_state
	_settlement_definition = settlement_definition

	_selected_side = SelectionSide.TRADER
	_selected_item_instance_id = &""
	_status_text = ""

	_build_interface()
	refresh_state()


func refresh_state() -> void:
	_resolve_selection()

	_refresh_header()
	_rebuild_trader_list()
	_rebuild_player_list()
	_refresh_details()

	if _status_label != null:
		_status_label.text = _status_text


func show_status_message(
	message: String
) -> void:
	_status_text = message

	if _status_label != null:
		_status_label.text = message


func _build_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		22
	)

	margin.add_theme_constant_override(
		"margin_top",
		18
	)

	margin.add_theme_constant_override(
		"margin_right",
		22
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		18
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

	var header := HBoxContainer.new()

	header.add_theme_constant_override(
		"separation",
		16
	)

	root.add_child(
		header
	)

	var title := Label.new()

	title.text = (
		"ТОРГОВЛЯ · %s"
		% (
			_trader_definition.display_name
			if _trader_definition != null
			else "Торговец"
		)
	)

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	title.add_theme_font_size_override(
		"font_size",
		30
	)

	header.add_child(
		title
	)

	var close_button := Button.new()

	close_button.text = "← НАЗАД"

	close_button.custom_minimum_size = Vector2(
		130,
		44
	)

	close_button.pressed.connect(
		_on_close_pressed
	)

	header.add_child(
		close_button
	)

	if (
		_trader_definition != null
		and not _trader_definition
			.description
			.strip_edges()
			.is_empty()
	):
		var trader_description := Label.new()

		trader_description.text = (
			_trader_definition.description
		)

		trader_description.autowrap_mode = (
			TextServer.AUTOWRAP_WORD_SMART
		)

		root.add_child(
			trader_description
		)

	root.add_child(
		HSeparator.new()
	)

	var body := HBoxContainer.new()

	body.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	body.add_theme_constant_override(
		"separation",
		14
	)

	root.add_child(
		body
	)

	body.add_child(
		_create_trader_column()
	)

	body.add_child(
		_create_detail_column()
	)

	body.add_child(
		_create_player_column()
	)

	_status_label = Label.new()

	_status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	_status_label.custom_minimum_size = Vector2(
		0,
		26
	)

	root.add_child(
		_status_label
	)


func _create_trader_column() -> Control:
	var panel := PanelContainer.new()

	panel.custom_minimum_size = Vector2(
		330,
		0
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		12
	)

	margin.add_theme_constant_override(
		"margin_top",
		12
	)

	margin.add_theme_constant_override(
		"margin_right",
		12
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		12
	)

	panel.add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.add_theme_constant_override(
		"separation",
		8
	)

	margin.add_child(
		root
	)

	var title := Label.new()

	title.text = "У ТОРГОВЦА"

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	root.add_child(
		title
	)

	_trader_gold_label = Label.new()

	root.add_child(
		_trader_gold_label
	)

	_trade_terms_label = Label.new()

	_trade_terms_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	root.add_child(
		_trade_terms_label
	)

	root.add_child(
		HSeparator.new()
	)

	var scroll := ScrollContainer.new()

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_child(
		scroll
	)

	_trader_items = VBoxContainer.new()

	_trader_items.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_trader_items.add_theme_constant_override(
		"separation",
		6
	)

	scroll.add_child(
		_trader_items
	)

	return panel


func _create_player_column() -> Control:
	var panel := PanelContainer.new()

	panel.custom_minimum_size = Vector2(
		330,
		0
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		12
	)

	margin.add_theme_constant_override(
		"margin_top",
		12
	)

	margin.add_theme_constant_override(
		"margin_right",
		12
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		12
	)

	panel.add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.add_theme_constant_override(
		"separation",
		8
	)

	margin.add_child(
		root
	)

	var title := Label.new()

	title.text = "ВАШ ИНВЕНТАРЬ"

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	root.add_child(
		title
	)

	_player_gold_label = Label.new()

	root.add_child(
		_player_gold_label
	)

	root.add_child(
		HSeparator.new()
	)

	var scroll := ScrollContainer.new()

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_child(
		scroll
	)

	_player_items = VBoxContainer.new()

	_player_items.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_player_items.add_theme_constant_override(
		"separation",
		6
	)

	scroll.add_child(
		_player_items
	)

	return panel


func _create_detail_column() -> Control:
	var panel := PanelContainer.new()

	panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		18
	)

	margin.add_theme_constant_override(
		"margin_top",
		16
	)

	margin.add_theme_constant_override(
		"margin_right",
		18
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		16
	)

	panel.add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.add_theme_constant_override(
		"separation",
		10
	)

	margin.add_child(
		root
	)

	var heading := Label.new()

	heading.text = "ПРЕДМЕТ"

	heading.add_theme_font_size_override(
		"font_size",
		18
	)

	root.add_child(
		heading
	)

	_detail_title = Label.new()

	_detail_title.add_theme_font_size_override(
		"font_size",
		26
	)

	_detail_title.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	root.add_child(
		_detail_title
	)

	_detail_category = Label.new()

	root.add_child(
		_detail_category
	)

	root.add_child(
		HSeparator.new()
	)

	_detail_description = Label.new()

	_detail_description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	_detail_description.custom_minimum_size = Vector2(
		0,
		80
	)

	root.add_child(
		_detail_description
	)

	_detail_abilities = Label.new()

	_detail_abilities.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	root.add_child(
		_detail_abilities
	)

	_detail_ownership = Label.new()

	_detail_ownership.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	root.add_child(
		_detail_ownership
	)

	var spacer := Control.new()

	spacer.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_child(
		spacer
	)

	_detail_price = Label.new()

	_detail_price.add_theme_font_size_override(
		"font_size",
		22
	)

	root.add_child(
		_detail_price
	)

	_action_button = Button.new()

	_action_button.custom_minimum_size = Vector2(
		0,
		52
	)

	_action_button.pressed.connect(
		_on_action_pressed
	)

	root.add_child(
		_action_button
	)

	return panel


func _refresh_header() -> void:
	if _trader_gold_label != null:
		_trader_gold_label.text = (
			"Золото торговца: %d"
			% (
				_trader_state.gold
				if _trader_state != null
				else 0
			)
		)

	if _trade_terms_label != null:
		var tier := (
			_trader_definition
				.get_reputation_pricing_tier(
					_campaign_state.reputation
				)
			if (
				_trader_definition != null
				and _campaign_state != null
			)
			else null
		)

		if tier == null:
			_trade_terms_label.text = (
				"Репутация: %d · базовые цены"
				% (
					_campaign_state.reputation
					if _campaign_state != null
					else 0
				)
			)

		else:
			_trade_terms_label.text = (
				"Репутация: %d · %s"
				% [
					_campaign_state.reputation,
					tier.display_name,
				]
			)

	var player_gold := 0

	if (
		_campaign_state != null
		and _campaign_state.inventory_state != null
	):
		player_gold = (
			_campaign_state
				.inventory_state
				.gold
		)

	if _player_gold_label != null:
		_player_gold_label.text = (
			"Ваше золото: %d"
			% player_gold
		)


func _rebuild_trader_list() -> void:
	_clear_container(
		_trader_items
	)

	if (
		_trader_items == null
		or _trader_state == null
	):
		return

	var visible_item_count := 0

	for item in _trader_state.items:
		if (
			item == null
			or item.definition == null
		):
			continue

		if not _trading_service.is_stock_item_available(
			_campaign_state,
			_trader_definition,
			_settlement_definition,
			item.definition
		):
			continue

		visible_item_count += 1

		var price := (
			_trading_service.get_buy_price(
				_campaign_state,
				_trader_definition,
				item.definition
			)
		)

		var selected := (
			_selected_side
				== SelectionSide.TRADER
			and _selected_item_instance_id
				== item.instance_id
		)

		var button := Button.new()

		button.text = (
			"%s%s · %d зол."
			% [
				"→ " if selected else "",
				item.definition.display_name,
				price,
			]
		)

		button.alignment = (
			HORIZONTAL_ALIGNMENT_LEFT
		)

		button.pressed.connect(
			_on_item_selected.bind(
				SelectionSide.TRADER,
				item.instance_id
			)
		)

		_trader_items.add_child(
			button
		)

	if visible_item_count == 0:
		var empty := Label.new()

		empty.text = (
			"Сейчас доступных товаров нет."
		)

		empty.autowrap_mode = (
			TextServer.AUTOWRAP_WORD_SMART
		)

		_trader_items.add_child(
			empty
		)


func _rebuild_player_list() -> void:
	_clear_container(
		_player_items
	)

	if (
		_player_items == null
		or _campaign_state == null
		or _campaign_state.inventory_state == null
	):
		return

	var inventory := (
		_campaign_state.inventory_state
	)

	if inventory.items.is_empty():
		var empty := Label.new()

		empty.text = (
			"Инвентарь пуст."
		)

		_player_items.add_child(
			empty
		)

		return

	for item in inventory.items:
		if (
			item == null
			or item.definition == null
		):
			continue

		var selected := (
			_selected_side
				== SelectionSide.PLAYER
			and _selected_item_instance_id
				== item.instance_id
		)

		var price_text := "не продаётся"

		if item.definition.is_trade_enabled():
			price_text = (
				"%d зол."
				% _trading_service.get_sell_price(
					_campaign_state,
					_trader_definition,
					item.definition
				)
			)

		var owner := (
			_campaign_state.get_equipment_owner(
				item.instance_id
			)
		)

		var owner_suffix := ""

		if owner != null:
			owner_suffix = (
				" · экипировано"
			)

		var button := Button.new()

		button.text = (
			"%s%s · %s%s"
			% [
				"→ " if selected else "",
				item.definition.display_name,
				price_text,
				owner_suffix,
			]
		)

		button.alignment = (
			HORIZONTAL_ALIGNMENT_LEFT
		)

		button.pressed.connect(
			_on_item_selected.bind(
				SelectionSide.PLAYER,
				item.instance_id
			)
		)

		_player_items.add_child(
			button
		)


func _refresh_details() -> void:
	var item := _get_selected_item()

	if (
		item == null
		or item.definition == null
	):
		_detail_title.text = (
			"Предмет не выбран"
		)

		_detail_category.text = ""
		_detail_description.text = (
			"Выберите предмет у торговца "
			+"или в своём инвентаре."
		)

		_detail_abilities.text = ""
		_detail_ownership.text = ""
		_detail_price.text = ""

		_action_button.visible = false

		return

	var definition := item.definition

	_detail_title.text = (
		definition.display_name
	)

	_detail_category.text = (
		"Категория: %s"
		% _get_category_text(
			definition.category
		)
	)

	_detail_description.text = (
		definition.description
		if not definition
			.description
			.strip_edges()
			.is_empty()
		else "Описание отсутствует."
	)

	_detail_abilities.text = (
		_get_abilities_text(
			definition
		)
	)

	_refresh_ownership_text(
		item
	)

	_refresh_action(
		item
	)


func _refresh_ownership_text(
	item: HeroEquipmentItemInstance
) -> void:
	if (
		item == null
		or _campaign_state == null
	):
		_detail_ownership.text = ""

		return

	if _selected_side == SelectionSide.TRADER:
		_detail_ownership.text = (
			"Сейчас находится у торговца."
		)

		return

	var owner := (
		_campaign_state.get_equipment_owner(
			item.instance_id
		)
	)

	if owner == null:
		_detail_ownership.text = (
			"Находится в вашем инвентаре."
		)

		return

	_detail_ownership.text = (
		"Экипировано: %s."
		% owner.get_display_name()
	)


func _refresh_action(
	item: HeroEquipmentItemInstance
) -> void:
	if (
		item == null
		or item.definition == null
	):
		_action_button.visible = false

		return

	_action_button.visible = true

	if _selected_side == SelectionSide.TRADER:
		var price := (
			_trading_service.get_buy_price(
				_campaign_state,
				_trader_definition,
				item.definition
			)
		)

		_detail_price.text = (
			"Цена покупки: %d зол."
			% price
		)

		_action_button.text = (
			"КУПИТЬ · %d ЗОЛ."
			% price
		)

		var error := (
			_trading_service.get_buy_error(
				_campaign_state,
				_trader_definition,
				_trader_state,
				item.instance_id,
				_settlement_definition
			)
		)

		_action_button.disabled = (
			not error.is_empty()
		)

		_action_button.tooltip_text = (
			_get_error_display_text(
				error
			)
			if _action_button.disabled
			else ""
		)

		return

	var sell_price := (
		_trading_service.get_sell_price(
			_campaign_state,
			_trader_definition,
			item.definition
		)
	)

	_detail_price.text = (
		"Цена продажи: %d зол."
		% sell_price
		if sell_price > 0
		else "Этот предмет нельзя продать."
	)

	_action_button.text = (
		"ПРОДАТЬ · %d ЗОЛ."
		% sell_price
		if sell_price > 0
		else "ПРОДАТЬ"
	)

	var sell_error := (
		_trading_service.get_sell_error(
			_campaign_state,
			_trader_definition,
			_trader_state,
			item.instance_id
		)
	)

	_action_button.disabled = (
		not sell_error.is_empty()
	)

	_action_button.tooltip_text = (
		_get_error_display_text(
			sell_error
		)
		if _action_button.disabled
		else ""
	)


func _resolve_selection() -> void:
	if (
		_selected_item_instance_id != &""
		and _selected_side
			== SelectionSide.TRADER
		and _trader_state != null
		and _trader_state.has_item(
			_selected_item_instance_id
		)
		and _trading_service.is_stock_item_available(
			_campaign_state,
			_trader_definition,
			_settlement_definition,
			_trader_state
				.get_item(
					_selected_item_instance_id
				)
				.definition
		)
	):
		return

	if (
		_selected_item_instance_id != &""
		and _selected_side
			== SelectionSide.PLAYER
		and _campaign_state != null
		and _campaign_state.inventory_state != null
		and _campaign_state
			.inventory_state
			.has_item(
				_selected_item_instance_id
			)
	):
		return

	## После покупки/продажи тот же instance
	## физически переезжает на другую сторону.
	if _selected_item_instance_id != &"":
		if (
			_trader_state != null
			and _trader_state.has_item(
				_selected_item_instance_id
			)
		):
			_selected_side = (
				SelectionSide.TRADER
			)

			return

		if (
			_campaign_state != null
			and _campaign_state.inventory_state != null
			and _campaign_state
				.inventory_state
				.has_item(
					_selected_item_instance_id
				)
		):
			_selected_side = (
				SelectionSide.PLAYER
			)

			return

	_selected_item_instance_id = &""

	if _trader_state != null:
		for item in _trader_state.items:
			if (
				item == null
				or item.definition == null
			):
				continue

			if not _trading_service.is_stock_item_available(
				_campaign_state,
				_trader_definition,
				_settlement_definition,
				item.definition
			):
				continue

			_selected_side = (
				SelectionSide.TRADER
			)

			_selected_item_instance_id = (
				item.instance_id
			)

			return

	if (
		_campaign_state != null
		and _campaign_state.inventory_state != null
		and not _campaign_state
			.inventory_state
			.items
			.is_empty()
	):
		var item := (
			_campaign_state
				.inventory_state
				.items[0]
		)

		if item != null:
			_selected_side = (
				SelectionSide.PLAYER
			)

			_selected_item_instance_id = (
				item.instance_id
			)


func _get_selected_item() -> HeroEquipmentItemInstance:
	if _selected_item_instance_id == &"":
		return null

	if (
		_selected_side == SelectionSide.TRADER
		and _trader_state != null
	):
		return _trader_state.get_item(
			_selected_item_instance_id
		)

	if (
		_selected_side == SelectionSide.PLAYER
		and _campaign_state != null
		and _campaign_state.inventory_state != null
	):
		return (
			_campaign_state
				.inventory_state
				.get_item(
					_selected_item_instance_id
				)
		)

	return null


func _get_abilities_text(
	definition: HeroEquipmentItemDefinition
) -> String:
	if definition == null:
		return ""

	var lines := PackedStringArray()

	if definition.primary_ability != null:
		lines.append(
			"Основной приём: %s"
			% definition
				.primary_ability
				.display_name
		)

	for ability in definition.granted_abilities:
		if ability == null:
			continue

		lines.append(
			"Даёт способность: %s"
			% ability.display_name
		)

	if lines.is_empty():
		return "Особых способностей нет."

	return "\n".join(
		lines
	)


func _get_category_text(
	category: int
) -> String:
	match category:
		HeroEquipmentItemDefinition.Category.WEAPON:
			return "Оружие"

		HeroEquipmentItemDefinition.Category.HEAD:
			return "Голова"

		HeroEquipmentItemDefinition.Category.ARMOR:
			return "Броня"

		HeroEquipmentItemDefinition.Category.GLOVES:
			return "Перчатки"

		HeroEquipmentItemDefinition.Category.BOOTS:
			return "Обувь"

		HeroEquipmentItemDefinition.Category.CHARM:
			return "Оберег"

		HeroEquipmentItemDefinition.Category.RING:
			return "Кольцо"

	return "Неизвестно"


func _get_error_display_text(
	error: String
) -> String:
	match error:
		"":
			return ""

		"Not enough gold.":
			return "Недостаточно золота."

		"Trader does not have enough gold.":
			return "У торговца недостаточно золота."

		"Equipped items cannot be sold.":
			return (
				"Сначала снимите предмет с героя."
			)

		"Item is not tradeable.":
			return (
				"Этот предмет нельзя продать."
			)

		"Campaign party is not at this trader.":
			return (
				"Партия больше не находится у этого торговца."
			)

	return error


func _clear_container(
	container: Container
) -> void:
	if container == null:
		return

	for child in container.get_children():
		container.remove_child(
			child
		)

		child.queue_free()


func _on_item_selected(
	side: SelectionSide,
	item_instance_id: StringName
) -> void:
	_selected_side = side

	_selected_item_instance_id = (
		item_instance_id
	)

	_status_text = ""

	refresh_state()


func _on_action_pressed() -> void:
	var item := _get_selected_item()

	if (
		item == null
		or _trader_definition == null
	):
		return

	if _selected_side == SelectionSide.TRADER:
		buy_requested.emit(
			_trader_definition.trader_id,
			item.instance_id
		)

	else:
		sell_requested.emit(
			_trader_definition.trader_id,
			item.instance_id
		)


func _on_close_pressed() -> void:
	close_requested.emit()