class_name CampaignMenuPanel
extends Control


signal close_requested
signal save_requested
signal load_requested
signal new_debug_requested


var _status_label: Label
var _new_debug_button: Button

var _reset_confirmation: bool = false


func bind(
	status_text: String = ""
) -> void:
	_build_interface()

	set_status_message(
		status_text
	)


func set_status_message(
	message: String
) -> void:
	if _status_label == null:
		return

	_status_label.text = message


func _build_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	var dim := ColorRect.new()

	dim.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	dim.color = Color(
		0.0,
		0.0,
		0.0,
		0.72
	)

	dim.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	add_child(
		dim
	)

	var center := CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(
		center
	)

	var panel := PanelContainer.new()

	panel.custom_minimum_size = Vector2(
		460,
		0
	)

	center.add_child(
		panel
	)

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		28
	)

	margin.add_theme_constant_override(
		"margin_top",
		24
	)

	margin.add_theme_constant_override(
		"margin_right",
		28
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		24
	)

	panel.add_child(
		margin
	)

	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	margin.add_child(
		content
	)

	var title := Label.new()

	title.text = "МЕНЮ"

	title.add_theme_font_size_override(
		"font_size",
		30
	)

	content.add_child(
		title
	)

	content.add_child(
		HSeparator.new()
	)

	var save_button := Button.new()

	save_button.text = "СОХРАНИТЬ"

	save_button.custom_minimum_size = Vector2(
		0,
		48
	)

	save_button.pressed.connect(
		_on_save_pressed
	)

	content.add_child(
		save_button
	)

	var load_button := Button.new()

	load_button.text = "ЗАГРУЗИТЬ"

	load_button.custom_minimum_size = Vector2(
		0,
		48
	)

	load_button.pressed.connect(
		_on_load_pressed
	)

	content.add_child(
		load_button
	)

	content.add_child(
		HSeparator.new()
	)

	_new_debug_button = Button.new()

	_new_debug_button.text = (
		"НОВАЯ DEBUG-КАМПАНИЯ"
	)

	_new_debug_button.custom_minimum_size = Vector2(
		0,
		48
	)

	_new_debug_button.pressed.connect(
		_on_new_debug_pressed
	)

	content.add_child(
		_new_debug_button
	)

	_status_label = Label.new()

	_status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	_status_label.custom_minimum_size = Vector2(
		0,
		28
	)

	content.add_child(
		_status_label
	)

	var close_button := Button.new()

	close_button.text = "ЗАКРЫТЬ"

	close_button.custom_minimum_size = Vector2(
		0,
		48
	)

	close_button.pressed.connect(
		_on_close_pressed
	)

	content.add_child(
		close_button
	)


func _on_save_pressed() -> void:
	_reset_confirmation = false

	_refresh_reset_button()

	save_requested.emit()


func _on_load_pressed() -> void:
	_reset_confirmation = false

	_refresh_reset_button()

	load_requested.emit()


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