class_name CampaignForgePanel
extends PanelContainer

signal close_requested
signal state_changed
signal talk_requested(interaction_id: StringName)

var runtime: CampaignRuntimeService
var _status: String = ""
var _revision: int = 0
var _busy: bool = false

func bind(service: CampaignRuntimeService) -> void:
	runtime = service
	var background := StyleBoxFlat.new()
	background.bg_color = Color("20262b")
	add_theme_stylebox_override("panel", background)
	refresh()

func label(text: String, parent: Node, font_size: int = 21) -> Label:
	var item := Label.new()
	item.text = text
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", font_size)
	parent.add_child(item)
	return item

func button(text: String, parent: Node, error: String, action: Callable) -> Button:
	var item := Button.new()
	item.text = text
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.custom_minimum_size.y = 48
	item.disabled = not error.is_empty()
	item.tooltip_text = error
	parent.add_child(item)
	item.pressed.connect(action)
	return item

func refresh() -> void:
	_revision += 1
	var revision := _revision
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var campaign := runtime.campaign_definition
	var state := runtime.campaign_state
	var definition := campaign.home_settlement_definition
	var master := runtime.forge_service.get_master(campaign, state)
	var operation_error := runtime.forge_service.operational_error(campaign, state)
	label("КУЗНЯ · I", layout, 32)
	label("Статус: работает · Мастер: " + master.display_name if master != null else "Кузница не работает · Требуется кузнец", layout, 25)
	label("Гроші: %d · Материалы: %d · %s" % [state.inventory_state.gold, state.materials, "День %d · %02d:%02d" % [state.current_day + 1, state.current_minute_of_day / 60, state.current_minute_of_day % 60]], layout)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 32)
	scroll.add_child(columns)
	var equipment := VBoxContainer.new()
	equipment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment.size_flags_stretch_ratio = 1.0
	equipment.add_theme_constant_override("separation", 12)
	columns.add_child(equipment)
	var orders := VBoxContainer.new()
	orders.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	orders.size_flags_stretch_ratio = 1.2
	orders.add_theme_constant_override("separation", 12)
	columns.add_child(orders)
	var selected := state.home_settlement_state.forge_major_module_id
	var current := definition.get_forge_module(selected)
	label("ОСНАЩЕНИЕ", equipment, 27)
	label("Основные слоты: %d/1\nСейчас: %s" % [0 if current == null else 1, "без специализации" if current == null else current.display_name], equipment)
	for module in definition.forge_modules:
		label(module.display_name, equipment, 24)
		label(module.description, equipment, 19)
		var error := runtime.get_forge_retool_error(module.module_id, selected)
		button(("Установлено" if selected == module.module_id else ("Установить" if selected == &"" else "Переоснастить")) + " · %d гр. · %d мат. · %d ч." % [module.gold_cost, module.material_cost, module.duration_minutes / 60], equipment, error, _retool.bind(module.module_id, selected, revision))
		if not error.is_empty() and selected != module.module_id:
			label(error, equipment, 18)
	label("ЗАКАЗЫ", orders, 27)
	# Catalogs belong to residents. Show other masters' known recipes as locked,
	# preserving an explicit explanation instead of granting module-owned recipes.
	for resident in campaign.residents:
		if not resident.is_forge_master:
			continue
		for commission in resident.equipment_commissions:
			label(commission.display_name, orders, 24)
			label(commission.description, orders, 19)
			var error := operation_error
			if error.is_empty():
				error = runtime.get_home_resident_commission_error(resident.resident_id, commission.commission_id) if master == resident else "Этот мастер не умеет изготавливать данный предмет."
			button("Заказать · %d гр. · %d мат. · %d ч." % [commission.gold_cost, commission.material_cost, commission.duration_minutes / 60], orders, error, _commission.bind(resident.resident_id, commission.commission_id, revision))
			label("Доступно" if error.is_empty() else error, orders, 18)
	label(_status, layout)
	if master != null and master.dialogue != null:
		button("ПОГОВОРИТЬ · " + master.display_name, layout, "", func() -> void: talk_requested.emit(master.home_interaction_id))
	button("Вернуться в HOME", layout, "", func() -> void: close_requested.emit())

func _retool(module_id: StringName, expected: StringName, revision: int) -> void:
	if _busy or revision != _revision:
		return
	_busy = true
	var error := runtime.retool_forge(module_id, expected)
	var module := runtime.get_home_settlement_definition().get_forge_module(module_id)
	_status = "Оснастка установлена. Прошло %d мин." % module.duration_minutes if error.is_empty() else error
	_busy = false
	state_changed.emit()
	refresh()

func _commission(resident_id: StringName, commission_id: StringName, revision: int) -> void:
	if _busy or revision != _revision:
		return
	_busy = true
	var error := runtime.get_home_resident_commission_error(resident_id, commission_id)
	if error.is_empty():
		var item := runtime.commission_home_resident_item(resident_id, commission_id)
		_status = "Готово: %s. Предмет в инвентаре." % item.definition.display_name if item != null else "Не удалось выполнить заказ."
	else:
		_status = error
	_busy = false
	state_changed.emit()
	refresh()
