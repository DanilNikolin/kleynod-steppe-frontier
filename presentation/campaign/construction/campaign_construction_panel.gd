class_name CampaignConstructionPanel
extends PanelContainer

signal close_requested
signal state_changed

var runtime: CampaignRuntimeService
var source_id: StringName = &""
var selected_project_id: StringName = &"forge_shell"
var selected_crew: int = 2
var _status: String = ""
var _body: VBoxContainer


func bind(service: CampaignRuntimeService, crew_source_id: StringName = &"") -> void:
	runtime = service
	source_id = crew_source_id
	var background := StyleBoxFlat.new()
	background.bg_color = Color("20262b")
	add_theme_stylebox_override("panel", background)
	refresh()


func label(text: String, parent: Node, size: int = 21) -> Label:
	var item := Label.new()
	item.text = text
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size", size)
	parent.add_child(item)
	return item


func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	margin.add_child(layout)
	label("Строительство HOME" if source_id == &"" else "Староста · бригада для проекта", layout, 30)
	label("Плотник обещал поставить кузницу. Его работа — без отдельной платы." if source_id == &"" else "Работники нанимаются под выбранный проект. Здесь выбирается бригада; полная оплата — при подписании контракта в HOME.", layout)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 28)
	layout.add_child(row)
	var catalog := VBoxContainer.new()
	catalog.custom_minimum_size.x = 290
	row.add_child(catalog)
	var state := runtime.campaign_state
	var campaign := runtime.campaign_definition
	for project in campaign.construction_projects:
		var button := Button.new()
		button.text = project.display_name
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(290, 64)
		button.toggle_mode = true
		button.button_pressed = project.project_id == selected_project_id
		button.pressed.connect(func() -> void:
			selected_project_id = project.project_id
			_status = ""
			refresh()
		)
		catalog.add_child(button)
		var gate := runtime.construction_service.get_project_gate(campaign, state, project)
		if not gate.is_empty():
			button.modulate = Color("b5b5b5")
			button.tooltip_text = gate
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	row.add_child(scroll)
	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 12)
	scroll.add_child(_body)
	var project := campaign.get_construction_project(selected_project_id)
	if project != null:
		show_project(project)
	label(_status, layout)
	var close := Button.new()
	close.text = "Вернуться в локацию"
	close.custom_minimum_size.y = 48
	close.pressed.connect(func() -> void: close_requested.emit())
	layout.add_child(close)


func show_project(project: CampaignConstructionProjectDefinition) -> void:
	var campaign := runtime.campaign_definition
	var state := runtime.campaign_state
	var service := runtime.construction_service
	var contract := service.get_contract(state, project.project_id)
	label(project.display_name, _body, 27)
	label(project.description, _body)
	label("Знание: %s\nСогласие: %s" % ["есть" if state.construction_knowledge_ids.has(project.required_knowledge_id) else "нужно изучить", "есть" if state.construction_agreement_ids.has(project.required_agreement_id) else "плотник пока не согласен"], _body)
	var gate := service.get_project_gate(campaign, state, project)
	if not gate.is_empty():
		label(gate, _body)
		return
	if contract != null and contract.status == CampaignConstructionContract.Status.COMPLETED:
		label("ЗДАНИЕ ПОСТРОЕНО\nБригада закончила работу. Для действующей кузницы нужны кузнец и профессиональное оборудование. Услуги пока не открыты.", _body)
		label("Оплачено: %d гр. · Использовано: %d материалов" % [contract.paid_gold, contract.paid_materials], _body)
		return
	if contract != null and contract.status == CampaignConstructionContract.Status.ACTIVE:
		var remaining := maxi(0, contract.completes_at - state.current_day * 1440 - state.current_minute_of_day)
		label("СТРОИТСЯ · осталось %.1f дн.\nБригада: %d работников. Всё оплачено: %d гр.\nМожно отправляться в путешествие — строительство идёт вместе с временем кампании." % [float(remaining) / 1440, contract.crew_size, contract.paid_gold], _body)
		return
	label("Материалы: %d / %d\nРабота: %d человеко-дней\nБригада: минимум %d, не более %d эффективных работников\nГроші: %d" % [state.materials, project.material_cost, project.labor_worker_days, project.minimum_crew, project.maximum_effective_crew, state.inventory_state.gold], _body)
	if state.materials < project.material_cost:
		label("Лесоматериал для первой кузницы можно собрать в Ближней роще.", _body)
	var source := campaign.get_crew_source(source_id if source_id != &"" else (contract.source_id if contract != null else &"village_crew"))
	if source == null:
		label("Источник работников не найден.", _body)
		return
	if source_id != &"":
		label("%s · свободно: %d\nРанняя бригада доступна без набора репутации." % [source.display_name, service.available_workers(campaign, state, source, project.project_id)], _body)
		var spin := SpinBox.new()
		spin.min_value = project.minimum_crew
		spin.max_value = project.maximum_effective_crew
		spin.step = 1
		spin.value = selected_crew
		spin.prefix = "Работников: "
		spin.custom_minimum_size.y = 44
		_body.add_child(spin)
		spin.value_changed.connect(func(value: float) -> void:
			selected_crew = int(value)
			refresh.call_deferred()
		)
	var crew := selected_crew if source_id != &"" else (contract.crew_size if contract != null else project.minimum_crew)
	var price := service.quote(project, source, crew)
	if not price.is_empty():
		label("Контракт: %d работников · %.1f дн. · ВСЕГО %d гр.\nОплата труда: %d гр. · Сбор бригады: %d гр.\nПлотнику: 0 гр. · Покупные компоненты: %d гр.\nОдна оплата при запуске, ежедневных платежей нет." % [crew, float(price.minutes) / 1440, int(price.gold), int(price.labor_gold), int(price.mobilization_gold), project.component_gold_cost], _body)
	if contract == null and source_id == &"":
		label("Это предварительный расчёт. Бригада ещё не выбрана — обратитесь к старосте в Малом селе.", _body)
	elif contract != null:
		label("Договорённость: %s, %d работников. Контракт ещё не оплачен." % [campaign.get_crew_source(contract.source_id).display_name, contract.crew_size], _body)
	var error := service.start_error(campaign, state, project.project_id) if source_id == &"" else service.reservation_error(campaign, state, project.project_id, source_id, crew)
	if not runtime.construction_context_error().is_empty():
		error = runtime.construction_context_error()
	var start := Button.new()
	start.text = "ПОДПИСАТЬ КОНТРАКТ И НАЧАТЬ СТРОЙКУ" if source_id == &"" else "ДОГОВОРИТЬСЯ О БРИГАДЕ · БЕЗ ОПЛАТЫ"
	start.custom_minimum_size.y = 54
	start.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start.disabled = not error.is_empty()
	start.pressed.connect(func() -> void:
		var result := runtime.start_construction_project(project.project_id) if source_id == &"" else runtime.reserve_construction_crew(project.project_id, source_id, crew)
		_status = result if not result.is_empty() else ("Контракт оплачен. Стройка началась." if source_id == &"" else "Бригада согласована. Возвращайтесь к рабочему месту плотника в HOME.")
		state_changed.emit()
		refresh()
	)
	_body.add_child(start)
	if not error.is_empty():
		label(error, _body)
	if source_id != &"" and contract != null:
		var cancel := Button.new()
		cancel.text = "Отменить договорённость о бригаде"
		cancel.pressed.connect(func() -> void:
			_status = service.release_reservation(campaign, state, project.project_id)
			state_changed.emit()
			refresh()
		)
		_body.add_child(cancel)
	label("DEV: объём работ, материалы, ставки и сроки — текущие проверочные значения, не финальный баланс.", _body, 16)
