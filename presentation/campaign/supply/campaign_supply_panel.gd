class_name CampaignSupplyPanel
extends PanelContainer
signal state_changed
var runtime: CampaignRuntimeService
var _status: String = ""
var _revision: int = 0
func bind(service: CampaignRuntimeService) -> void:
	runtime = service
	var style := StyleBoxFlat.new()
	style.bg_color = Color("20262b")
	add_theme_stylebox_override("panel", style)
	refresh()
func label(text: String, parent: Node, size: int = 22) -> Label:
	var result := Label.new()
	result.text = text
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", size)
	parent.add_child(result)
	return result
func button(text: String, error: String, parent: Node, action: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.disabled = not error.is_empty()
	result.tooltip_text = error
	result.custom_minimum_size.y = 48
	result.pressed.connect(action)
	parent.add_child(result)
	return result
func refresh() -> void:
	_revision += 1
	var revision := _revision
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	scroll.add_child(body)
	var state := runtime.campaign_state
	var inventory := state.inventory_state
	label("ГРУЗ И ПОСТАВКИ", body, 30)
	label("Запас HOME: %d материалов · В пути с отрядом: %d · Гроші: %d" % [state.materials, inventory.get_carried_materials(), inventory.gold], body)
	label("ИНВЕНТАРЬ · %d / %d мест" % [inventory.items.size(), inventory.slot_capacity], body, 26)
	label("Каждый предмет, включая снаряжение и каждую связку, занимает одно место. Связки нужно разгрузить в HOME перед строительством и кузнечными работами.", body, 19)
	var counts: Dictionary = {}
	for item in inventory.items:
		var name := item.definition.display_name
		counts[name] = int(counts.get(name, 0)) + 1
	for name in counts:
		label("%s × %d" % [name, counts[name]], body, 20)
	var unload_error := runtime.get_unload_materials_error()
	button("РАЗГРУЗИТЬ ВСЕ МАТЕРИАЛЫ", unload_error, body, _confirm_unload.bind(revision)).name = "UnloadButton"
	if not unload_error.is_empty():
		label(unload_error, body, 19)
	label("ПОСТАВКИ", body, 27)
	if not runtime.has_active_home_settlement_effect(&"material_supply_access"):
		label("Общий склад откроет заказы поставок. Найденные материалы можно разгружать уже сейчас.", body)
	else:
		if state.supplier_relationship_ids.is_empty():
			label("Нет установленных поставщиков. Договоритесь о материалах с торговым контактом в другом поселении.", body)
		for id in state.supplier_relationship_ids:
			var supplier := runtime.campaign_definition.get_supplier(id)
			label(supplier.display_name, body, 25)
			label("Репутация: %d · Требование поставщика: %d · Скидка по торговым связям, не более %d%%." % [state.reputation, supplier.minimum_reputation, roundi((1.0 - supplier.minimum_price_multiplier) * 100)], body, 19)
			var delivery := runtime.supply_service.get_delivery(state, id)
			if delivery != null:
				var remaining := maxi(0, delivery.arrives_at - state.current_day * 1440 - state.current_minute_of_day)
				label("В ПУТИ: %d материалов · оплачено %d гр. · осталось %.1f ч.\nПрибудет в HOME: день %d, %02d:%02d" % [delivery.amount, delivery.paid_gold, remaining / 60.0, delivery.arrives_at / 1440 + 1, delivery.arrives_at % 1440 / 60, delivery.arrives_at % 60], body)
			for offer in supplier.packages:
				var price := runtime.supply_service.price(runtime.campaign_definition, state, supplier, offer)
				var error := runtime.get_supply_order_error(id, offer.package_id)
				button("%s · %d материалов · %d гр. · %.1f дн. · репутация %d" % [offer.display_name, offer.amount, price, offer.duration_minutes / 1440.0, maxi(supplier.minimum_reputation, offer.minimum_reputation)], error, body, _confirm_order.bind(id, offer.package_id, price, revision))
				if not error.is_empty():
					label(error, body, 18)
		label("DEV: партии, цены и сроки предварительные. Поставки покупают удобство; самостоятельная добыча бесплатна.", body, 18)
	label(_status, body)
func _confirm_unload(revision: int) -> void:
	if revision != _revision:
		return
	_confirm("Разгрузить все связки? В HOME поступит %d материалов." % runtime.campaign_state.inventory_state.get_carried_materials(), func() -> void:
		_status = runtime.unload_materials()
		if _status.is_empty():
			_status = "Груз разгружен в домашний запас."
	, revision)
func _confirm_order(id: StringName, package_id: StringName, price: int, revision: int) -> void:
	if revision != _revision:
		return
	_confirm("Оплатить %d гр. за доставку партии? Материалы прибудут в HOME после указанного срока." % price, func() -> void:
		_status = runtime.order_material_supply(id, package_id, price)
		if _status.is_empty():
			_status = "Заказ оплачен. Партия в пути."
	, revision)
func _confirm(text: String, action: Callable, revision: int) -> void:
	var expected_state := runtime.campaign_state
	var dialog := ConfirmationDialog.new()
	dialog.name = "LogisticsConfirmation"
	dialog.title = "Подтверждение"
	dialog.dialog_text = text
	dialog.ok_button_text = "Подтвердить"
	dialog.cancel_button_text = "Отмена"
	add_child(dialog)
	dialog.confirmed.connect(func() -> void:
		if revision == _revision and runtime.campaign_state == expected_state:
			action.call()
			state_changed.emit()
			refresh()
	)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(700, 180))
