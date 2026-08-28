class_name CampaignWorldMapPanel
extends PanelContainer


signal travel_requested(
	destination_node_id: StringName
)

signal adventure_requested

signal enter_requested(
	node_id: StringName
)


var _world_map: CampaignWorldMapDefinition
var _state: CampaignState

var _selected_node_id: StringName = &""

var _travel_service := (
	CampaignTravelService.new()
)


var _map_canvas: CampaignWorldMapCanvas
var _current_location_label: Label
var _selection_label: Label
var _travel_button: Button
var _enter_button: Button
var _adventure_button: Button


func bind(
	world_map: CampaignWorldMapDefinition,
	state: CampaignState
) -> void:
	_world_map = world_map
	_state = state

	_selected_node_id = (
		state.current_world_node_id
		if state != null
		else &""
	)

	_build_interface()
	_refresh_selection()


func _build_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		16
	)

	margin.add_theme_constant_override(
		"margin_top",
		16
	)

	margin.add_theme_constant_override(
		"margin_right",
		16
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		16
	)

	add_child(
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

	title.text = "ГЛОБАЛЬНАЯ КАРТА"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	content.add_child(
		title
	)

	_current_location_label = Label.new()

	_current_location_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		_current_location_label
	)

	content.add_child(
		HSeparator.new()
	)

	_map_canvas = (
		CampaignWorldMapCanvas.new()
	)

	_map_canvas.custom_minimum_size = Vector2(
		480,
		360
	)

	_map_canvas.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_map_canvas.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	_map_canvas.node_selected.connect(
		_on_node_selected
	)

	content.add_child(
		_map_canvas
	)

	_map_canvas.bind(
		_world_map,
		_state
	)

	content.add_child(
		HSeparator.new()
	)

	_selection_label = Label.new()

	_selection_label.custom_minimum_size = Vector2(
		0,
		52
	)

	_selection_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		_selection_label
	)

	_travel_button = Button.new()

	_travel_button.text = "ОТПРАВИТЬСЯ"

	_travel_button.pressed.connect(
		_on_travel_pressed
	)

	content.add_child(
		_travel_button
	)

	_enter_button = Button.new()

	_enter_button.text = "ВОЙТИ"

	_enter_button.pressed.connect(
		_on_enter_pressed
	)

	content.add_child(
		_enter_button
	)

	_adventure_button = Button.new()

	_adventure_button.text = (
		"НАЧАТЬ ПРИКЛЮЧЕНИЕ"
	)

	_adventure_button.pressed.connect(
		_on_adventure_pressed
	)

	content.add_child(
		_adventure_button
	)


func _refresh_selection() -> void:
	if (
		_world_map == null
		or _state == null
	):
		_current_location_label.text = (
			"Мир недоступен."
		)

		_selection_label.text = "—"

		_travel_button.disabled = true
		_enter_button.visible = false
		_adventure_button.visible = false

		return

	var current_node := (
		_world_map.get_node(
			_state.current_world_node_id
		)
	)

	if current_node == null:
		_current_location_label.text = (
			"Текущая точка неизвестна."
		)

		_selection_label.text = "—"

		_travel_button.disabled = true
		_enter_button.visible = false
		_adventure_button.visible = false

		return

	_current_location_label.text = (
		"Сейчас: %s"
		% current_node.display_name
	)

	_enter_button.visible = (
		current_node.local_location_definition
		!= null
	)

	if _enter_button.visible:
		_enter_button.text = (
			"ВОЙТИ · %s"
			% current_node.display_name
		)

	_adventure_button.visible = (
		current_node.campaign_location_id
		!= &""
	)

	var selected_node := (
		_world_map.get_node(
			_selected_node_id
		)
	)

	if selected_node == null:
		_selection_label.text = (
			"Выберите точку на карте."
		)

		_travel_button.disabled = true

		return

	if (
		selected_node.node_id
		== current_node.node_id
	):
		_selection_label.text = (
			"%s · Вы находитесь здесь."
			% selected_node.display_name
		)

		_travel_button.disabled = true

		return

	var travel_days := (
		_travel_service.get_travel_days(
			_world_map,
			current_node.node_id,
			selected_node.node_id
		)
	)

	if (
		travel_days
		== CampaignTravelService
			.INVALID_TRAVEL_DAYS
	):
		_selection_label.text = (
			"%s · Прямого маршрута отсюда нет."
			% selected_node.display_name
		)

		_travel_button.disabled = true

		return

	_selection_label.text = (
		"%s · Путь: %d дн."
		% [
			selected_node.display_name,
			travel_days,
		]
	)

	_travel_button.disabled = false


func _on_node_selected(
	node_id: StringName
) -> void:
	_selected_node_id = node_id

	_refresh_selection()


func _on_travel_pressed() -> void:
	if (
		_selected_node_id == &""
		or _state == null
		or _selected_node_id
			== _state.current_world_node_id
	):
		return

	travel_requested.emit(
		_selected_node_id
	)


func _on_adventure_pressed() -> void:
	adventure_requested.emit()


func _on_enter_pressed() -> void:
	if (
		_state == null
		or _state.current_world_node_id == &""
	):
		return

	enter_requested.emit(
		_state.current_world_node_id
	)