class_name CampaignLocalLocationPanel
extends PanelContainer


signal exit_requested

signal interaction_action_requested(
	interaction_id: StringName,
	action_label: String
)


var _definition: CampaignLocalLocationDefinition
var _state: CampaignState

var _selected_interaction_id: StringName = &""

var _time_service := (
	CampaignTimeService.new()
)


var _canvas: CampaignLocalLocationCanvas
var _interaction_title: Label
var _interaction_description: Label
var _actions_row: HBoxContainer
var _status_label: Label


func bind(
	definition: CampaignLocalLocationDefinition,
	state: CampaignState
) -> void:
	_definition = definition
	_state = state

	_selected_interaction_id = &""

	_build_interface()
	_refresh_interaction_panel()


func _build_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		32
	)

	margin.add_theme_constant_override(
		"margin_top",
		24
	)

	margin.add_theme_constant_override(
		"margin_right",
		32
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		24
	)

	add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.add_theme_constant_override(
		"separation",
		14
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
		_definition.display_name
		if _definition != null
		else "Локальная локация"
	)

	title.add_theme_font_size_override(
		"font_size",
		32
	)

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	header.add_child(
		title
	)

	var time_label := Label.new()

	time_label.text = (
		"Время · %s"
		% _time_service.get_time_text(
			_state
		)
	)

	time_label.add_theme_font_size_override(
		"font_size",
		20
	)

	header.add_child(
		time_label
	)

	var description := Label.new()

	description.text = (
		_definition.description
		if _definition != null
		else ""
	)

	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	root.add_child(
		description
	)

	root.add_child(
		HSeparator.new()
	)

	_canvas = (
		CampaignLocalLocationCanvas.new()
	)

	_canvas.custom_minimum_size = Vector2(
		900,
		460
	)

	_canvas.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_canvas.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	_canvas.interaction_selected.connect(
		_on_interaction_selected
	)

	root.add_child(
		_canvas
	)

	_canvas.bind(
		_definition
	)

	root.add_child(
		HSeparator.new()
	)

	var interaction_panel := (
		PanelContainer.new()
	)

	root.add_child(
		interaction_panel
	)

	var interaction_content := (
		VBoxContainer.new()
	)

	interaction_content.add_theme_constant_override(
		"separation",
		8
	)

	interaction_panel.add_child(
		interaction_content
	)

	_interaction_title = Label.new()

	_interaction_title.add_theme_font_size_override(
		"font_size",
		22
	)

	interaction_content.add_child(
		_interaction_title
	)

	_interaction_description = Label.new()

	_interaction_description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	interaction_content.add_child(
		_interaction_description
	)

	_actions_row = HBoxContainer.new()

	_actions_row.add_theme_constant_override(
		"separation",
		8
	)

	interaction_content.add_child(
		_actions_row
	)

	_status_label = Label.new()

	_status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	interaction_content.add_child(
		_status_label
	)

	var exit_button := Button.new()

	exit_button.text = (
		"← ВЫЙТИ НА ГЛОБАЛЬНУЮ КАРТУ"
	)

	exit_button.pressed.connect(
		_on_exit_pressed
	)

	root.add_child(
		exit_button
	)


func _refresh_interaction_panel() -> void:
	_clear_action_buttons()

	if (
		_definition == null
		or _selected_interaction_id == &""
	):
		_interaction_title.text = (
			"Выберите персонажа или объект"
		)

		_interaction_description.text = (
			"Нажмите на точку внутри локации."
		)

		_status_label.text = ""

		return

	var interaction := (
		_definition.get_interaction(
			_selected_interaction_id
		)
	)

	if interaction == null:
		_interaction_title.text = "—"
		_interaction_description.text = ""
		_status_label.text = ""

		return

	_interaction_title.text = (
		interaction.display_name
	)

	_interaction_description.text = (
		interaction.description
	)

	_status_label.text = ""

	for action_label in (
		interaction.action_labels
	):
		var button := Button.new()

		button.text = action_label

		button.pressed.connect(
			_on_action_pressed.bind(
				action_label
			)
		)

		_actions_row.add_child(
			button
		)


func _clear_action_buttons() -> void:
	if _actions_row == null:
		return

	for child in _actions_row.get_children():
		_actions_row.remove_child(
			child
		)

		child.queue_free()


func _on_interaction_selected(
	interaction_id: StringName
) -> void:
	_selected_interaction_id = (
		interaction_id
	)

	_refresh_interaction_panel()


func _on_action_pressed(
	action_label: String
) -> void:
	if _selected_interaction_id == &"":
		return

	_status_label.text = (
		"%s → %s · механика будет подключена позже."
		% [
			_get_selected_display_name(),
			action_label,
		]
	)

	interaction_action_requested.emit(
		_selected_interaction_id,
		action_label
	)


func _get_selected_display_name() -> String:
	if _definition == null:
		return "—"

	var interaction := (
		_definition.get_interaction(
			_selected_interaction_id
		)
	)

	if interaction == null:
		return "—"

	return interaction.display_name


func _on_exit_pressed() -> void:
	exit_requested.emit()