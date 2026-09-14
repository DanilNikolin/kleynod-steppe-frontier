class_name CampaignMenuPanel
extends Control


signal close_requested
signal save_requested
signal load_requested
signal new_debug_requested
signal save_slot_requested(slot_index: int)
signal load_slot_requested(slot_index: int)


enum MenuState {
	MAIN,
	SAVE_SLOTS,
	LOAD_SLOTS,
}


var _menu_state: MenuState = MenuState.MAIN
var _slot_infos: Array = []
var _status_message: String = ""

var _status_label: Label
var _new_debug_button: Button

var _reset_confirmation: bool = false
var _pending_overwrite_slot: int = -1


func bind(
	status_text: String = "",
	slot_infos: Array = []
) -> void:
	_status_message = status_text
	_slot_infos = slot_infos
	_menu_state = MenuState.MAIN
	_reset_confirmation = false
	_pending_overwrite_slot = -1
	_build_interface()


func set_status_message(
	message: String
) -> void:
	_status_message = message
	if _status_label != null:
		_status_label.text = message


func set_slot_infos(
	slot_infos: Array
) -> void:
	_slot_infos = slot_infos
	_pending_overwrite_slot = -1
	if _menu_state != MenuState.MAIN:
		_build_interface()


func _build_interface() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	margin.add_child(content)

	match _menu_state:
		MenuState.MAIN:
			_build_main_menu(content)
		MenuState.SAVE_SLOTS:
			_build_slots_menu(content, true)
		MenuState.LOAD_SLOTS:
			_build_slots_menu(content, false)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.custom_minimum_size = Vector2(0, 28)
	_status_label.text = _status_message
	content.add_child(_status_label)


func _build_main_menu(content: VBoxContainer) -> void:
	var title := Label.new()
	title.text = "МЕНЮ"
	title.add_theme_font_size_override("font_size", 30)
	content.add_child(title)

	content.add_child(HSeparator.new())

	var save_button := Button.new()
	save_button.text = "СОХРАНИТЬ"
	save_button.custom_minimum_size = Vector2(0, 48)
	save_button.pressed.connect(_on_main_save_pressed)
	content.add_child(save_button)

	var load_button := Button.new()
	load_button.text = "ЗАГРУЗИТЬ"
	load_button.custom_minimum_size = Vector2(0, 48)
	load_button.pressed.connect(_on_main_load_pressed)
	content.add_child(load_button)

	content.add_child(HSeparator.new())

	_new_debug_button = Button.new()
	_new_debug_button.text = "НОВАЯ DEBUG-КАМПАНИЯ"
	_new_debug_button.custom_minimum_size = Vector2(0, 48)
	_new_debug_button.pressed.connect(_on_new_debug_pressed)
	content.add_child(_new_debug_button)

	var close_button := Button.new()
	close_button.text = "ЗАКРЫТЬ"
	close_button.custom_minimum_size = Vector2(0, 48)
	close_button.pressed.connect(_on_close_pressed)
	content.add_child(close_button)


func _build_slots_menu(content: VBoxContainer, is_saving: bool) -> void:
	var title := Label.new()
	title.text = "СОХРАНЕНИЕ" if is_saving else "ЗАГРУЗКА"
	title.add_theme_font_size_override("font_size", 28)
	content.add_child(title)

	content.add_child(HSeparator.new())

	for slot_idx in range(1, CampaignSaveService.SLOT_COUNT + 1):
		var info: Dictionary = _get_slot_info(slot_idx)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 48)

		var exists := bool(info.get("exists", false))
		var valid := bool(info.get("valid", true))

		if not exists:
			btn.text = "Слот %d · ПУСТО" % slot_idx
			if not is_saving:
				btn.disabled = true
			else:
				btn.pressed.connect(_on_save_slot_clicked.bind(slot_idx, false))
		elif not valid:
			btn.text = "Слот %d · СОХРАНЕНИЕ ПОВРЕЖДЕНО" % slot_idx
			if not is_saving:
				btn.disabled = true
			else:
				if _pending_overwrite_slot == slot_idx:
					btn.text = "СЛОТ %d ПОВРЕЖДЁН · НАЖМИТЕ ЕЩЁ РАЗ ДЛЯ ПЕРЕЗАПИСИ" % slot_idx
				btn.pressed.connect(_on_save_slot_clicked.bind(slot_idx, true))
		else:
			if is_saving and _pending_overwrite_slot == slot_idx:
				btn.text = "СЛОТ %d ЗАНЯТ · НАЖМИТЕ ЕЩЁ РАЗ ДЛЯ ПЕРЕЗАПИСИ" % slot_idx
			else:
				btn.text = _format_slot_text(slot_idx, info)

			if is_saving:
				btn.pressed.connect(_on_save_slot_clicked.bind(slot_idx, true))
			else:
				btn.pressed.connect(_on_load_slot_clicked.bind(slot_idx))

		content.add_child(btn)

	content.add_child(HSeparator.new())

	var back_button := Button.new()
	back_button.text = "НАЗАД"
	back_button.custom_minimum_size = Vector2(0, 48)
	back_button.pressed.connect(_on_back_pressed)
	content.add_child(back_button)


func _get_slot_info(slot_index: int) -> Dictionary:
	for info in _slot_infos:
		if int(info.get("slot_index", 0)) == slot_index:
			return info
	return {
		"slot_index": slot_index,
		"exists": false,
		"valid": true,
	}


func _format_slot_text(slot_index: int, info: Dictionary) -> String:
	var day := int(info.get("day", 0))
	var minute := int(info.get("minute_of_day", 0))
	var hours := int(float(minute) / 60.0)
	var mins := int(minute % 60)
	var time_str := "%02d:%02d" % [hours, mins]

	var loc_name: String = info.get("location_name", "")
	if loc_name.is_empty():
		loc_name = info.get("world_node_id", "")
	if loc_name.is_empty():
		loc_name = "Степь"

	var text := "Слот %d · День %d · %s · %s" % [slot_index, day, time_str, loc_name]

	var mod_time := int(info.get("modified_time", 0))
	if mod_time > 0:
		var dt := Time.get_datetime_dict_from_unix_time(mod_time)
		var date_str := "%02d.%02d %02d:%02d" % [dt.day, dt.month, dt.hour, dt.minute]
		text += " · %s" % date_str

	return text


func _on_main_save_pressed() -> void:
	_reset_confirmation = false
	_pending_overwrite_slot = -1
	_menu_state = MenuState.SAVE_SLOTS
	_build_interface()
	save_requested.emit()


func _on_main_load_pressed() -> void:
	_reset_confirmation = false
	_pending_overwrite_slot = -1
	_menu_state = MenuState.LOAD_SLOTS
	_build_interface()
	load_requested.emit()


func _on_save_slot_clicked(slot_index: int, is_occupied: bool) -> void:
	if not is_occupied:
		_pending_overwrite_slot = -1
		save_slot_requested.emit(slot_index)
		return

	if _pending_overwrite_slot == slot_index:
		_pending_overwrite_slot = -1
		save_slot_requested.emit(slot_index)
	else:
		_pending_overwrite_slot = slot_index
		_build_interface()


func _on_load_slot_clicked(slot_index: int) -> void:
	load_slot_requested.emit(slot_index)


func _on_back_pressed() -> void:
	_pending_overwrite_slot = -1
	_menu_state = MenuState.MAIN
	_build_interface()


func _on_new_debug_pressed() -> void:
	if not _reset_confirmation:
		_reset_confirmation = true
		_refresh_reset_button()
		return

	_reset_confirmation = false
	_refresh_reset_button()
	new_debug_requested.emit()


func _refresh_reset_button() -> void:
	if _new_debug_button == null:
		return

	_new_debug_button.text = (
		"ПОДТВЕРДИТЬ · НАЧАТЬ НОВУЮ DEBUG-КАМПАНИЮ"
		if _reset_confirmation
		else "НОВАЯ DEBUG-КАМПАНИЯ"
	)


func _on_close_pressed() -> void:
	close_requested.emit()