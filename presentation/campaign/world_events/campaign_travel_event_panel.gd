class_name CampaignTravelEventPanel
extends Control


signal choice_requested(
	choice_id: StringName,
	revision: int
)


var _title: Label
var _text: Label
var _choices: VBoxContainer
var _status: Label
var _scroll: ScrollContainer

var _busy: bool = false


func _ready() -> void:
	_build_interface()


func show_session(
	session: CampaignTravelEventSession,
	error: String = ""
) -> void:
	if (
		session == null
		or session.definition == null
		or session.node == null
	):
		return

	_busy = false

	_title.text = (
		"ДОРОЖНОЕ СОБЫТИЕ · %s"
		% session.definition.display_name
	)

	_text.text = session.node.text
	_status.text = error

	for child in _choices.get_children():
		_choices.remove_child(
			child
		)

		child.queue_free()

	for choice in session.node.choices:
		if choice == null:
			continue

		var unavailable := (
			session.get_choice_error(
				choice
			)
		)

		var button := Button.new()

		button.text = (
			_get_choice_display_text(
				choice
			)
		)

		button.autowrap_mode = (
			TextServer.AUTOWRAP_WORD_SMART
		)

		button.alignment = (
			HORIZONTAL_ALIGNMENT_LEFT
		)

		button.custom_minimum_size.y = 52

		button.add_theme_font_size_override(
			"font_size",
			21
		)

		button.disabled = (
			not unavailable.is_empty()
		)

		button.pressed.connect(
			_on_choice_pressed.bind(
				choice.choice_id,
				session.revision
			)
		)

		_choices.add_child(
			button
		)

		if not unavailable.is_empty():
			var reason := Label.new()

			reason.text = unavailable

			reason.autowrap_mode = (
				TextServer.AUTOWRAP_WORD_SMART
			)

			reason.add_theme_color_override(
				"font_color",
				Color("c8b99c")
			)

			_choices.add_child(
				reason
			)

	_scroll.scroll_vertical = 0

	_focus_answers.call_deferred()


func _get_choice_display_text(
	choice: CampaignTravelEventChoice
) -> String:
	if (
		choice.action
		== CampaignTravelEventChoice.Action.CHANCE
	):
		return (
			"%s · %d%%"
			% [
				choice.text,
				int(
					round(
						choice.success_chance
							* 100.0
					)
				),
			]
		)

	return choice.text


func _focus_answers() -> void:
	if not is_inside_tree():
		return

	var buttons: Array[Button] = []

	for child in _choices.get_children():
		if (
			child is Button
			and not child.disabled
		):
			buttons.append(
				child
			)

	if buttons.is_empty():
		return

	for index in range(
		buttons.size()
	):
		var button := buttons[
			index
		]

		var next := buttons[(index + 1) % buttons.size()]
		var previous := buttons[(index + buttons.size() - 1) % buttons.size()]

		button.focus_next = (
			button.get_path_to(
				next
			)
		)

		button.focus_previous = (
			button.get_path_to(
				previous
			)
		)

		button.focus_neighbor_bottom = (
			button.get_path_to(
				next
			)
		)

		button.focus_neighbor_top = (
			button.get_path_to(
				previous
			)
		)

	buttons[0].grab_focus()


func _on_choice_pressed(
	choice_id: StringName,
	revision: int
) -> void:
	if _busy:
		return

	_busy = true

	for child in _choices.get_children():
		if child is Button:
			child.disabled = true

	choice_requested.emit(
		choice_id,
		revision
	)


func _unhandled_key_input(
	event: InputEvent
) -> void:
	if event.is_action_pressed(
		"ui_cancel"
	):
		# Travel Event нельзя бесплатно закрыть Esc.
		# Ситуацию нужно реально разрешить.
		get_viewport().set_input_as_handled()


func _build_interface() -> void:
	var shade := ColorRect.new()

	shade.color = Color(
		0.02,
		0.025,
		0.03,
		0.84
	)

	shade.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(
		shade
	)

	var frame := PanelContainer.new()

	frame.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	frame.anchor_left = 0.16
	frame.anchor_right = 0.84
	frame.anchor_top = 0.12
	frame.anchor_bottom = 0.88

	var style := StyleBoxFlat.new()

	style.bg_color = Color("20262b")
	style.border_color = Color("a38b60")

	style.set_border_width_all(
		2
	)

	style.set_corner_radius_all(
		8
	)

	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 22
	style.content_margin_bottom = 22

	frame.add_theme_stylebox_override(
		"panel",
		style
	)

	add_child(
		frame
	)

	var column := VBoxContainer.new()

	column.add_theme_constant_override(
		"separation",
		16
	)

	frame.add_child(
		column
	)

	_title = Label.new()

	_title.add_theme_font_size_override(
		"font_size",
		30
	)

	_title.add_theme_color_override(
		"font_color",
		Color("e7cc93")
	)

	column.add_child(
		_title
	)

	column.add_child(
		HSeparator.new()
	)

	_scroll = ScrollContainer.new()

	_scroll.follow_focus = true

	_scroll.horizontal_scroll_mode = (
		ScrollContainer
			.SCROLL_MODE_DISABLED
	)

	_scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	column.add_child(
		_scroll
	)

	var body := VBoxContainer.new()

	body.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body.add_theme_constant_override(
		"separation",
		24
	)

	_scroll.add_child(
		body
	)

	_text = Label.new()

	_text.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	_text.add_theme_font_size_override(
		"font_size",
		24
	)

	_text.add_theme_color_override(
		"font_color",
		Color("eee8da")
	)

	body.add_child(
		_text
	)

	_choices = VBoxContainer.new()

	_choices.add_theme_constant_override(
		"separation",
		10
	)

	body.add_child(
		_choices
	)

	_status = Label.new()

	_status.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	_status.add_theme_color_override(
		"font_color",
		Color("f0bc91")
	)

	column.add_child(
		_status
	)