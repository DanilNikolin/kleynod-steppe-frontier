class_name CampaignAdventureAreaPanel
extends PanelContainer


signal exit_requested

signal battle_site_requested(
	area_id: StringName,
	site_id: StringName
)

signal landmark_site_requested(
	area_id: StringName,
	site_id: StringName
)


var _definition: CampaignAdventureAreaDefinition
var _state: CampaignAdventureAreaState

var _selected_site_id: StringName = &""

var _canvas: CampaignAdventureAreaCanvas

var _site_title: Label
var _site_status: Label
var _site_description: Label
var _action_button: Button


func bind(
	definition: CampaignAdventureAreaDefinition,
	state: CampaignAdventureAreaState
) -> void:
	_definition = definition
	_state = state

	_selected_site_id = (
		_get_first_visible_site_id()
	)

	_build_interface()

	_canvas.bind(
		_definition,
		_state
	)

	_canvas.set_selected_site(
		_selected_site_id
	)

	_refresh_details()


func _build_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		24
	)

	margin.add_theme_constant_override(
		"margin_top",
		20
	)

	margin.add_theme_constant_override(
		"margin_right",
		24
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.add_theme_constant_override(
		"separation",
		12
	)

	margin.add_child(
		root
	)

	var title := Label.new()

	title.text = (
		_definition.display_name
		if _definition != null
		else "Регион"
	)

	title.add_theme_font_size_override(
		"font_size",
		30
	)

	root.add_child(
		title
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
		CampaignAdventureAreaCanvas.new()
	)

	_canvas.custom_minimum_size = Vector2(
		900,
		440
	)

	_canvas.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_canvas.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	_canvas.site_selected.connect(
		_on_site_selected
	)

	root.add_child(
		_canvas
	)

	root.add_child(
		HSeparator.new()
	)

	var detail_panel := PanelContainer.new()

	root.add_child(
		detail_panel
	)

	var detail_content := VBoxContainer.new()

	detail_content.add_theme_constant_override(
		"separation",
		8
	)

	detail_panel.add_child(
		detail_content
	)

	_site_title = Label.new()

	_site_title.add_theme_font_size_override(
		"font_size",
		22
	)

	detail_content.add_child(
		_site_title
	)

	_site_status = Label.new()

	detail_content.add_child(
		_site_status
	)

	_site_description = Label.new()

	_site_description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	detail_content.add_child(
		_site_description
	)

	_action_button = Button.new()

	_action_button.custom_minimum_size = Vector2(
		0,
		46
	)

	_action_button.pressed.connect(
		_on_action_pressed
	)

	detail_content.add_child(
		_action_button
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


func _refresh_details() -> void:
	var site_definition := (
		_definition.get_site(
			_selected_site_id
		)
		if _definition != null
		else null
	)

	var site_state := (
		_state.get_site(
			_selected_site_id
		)
		if _state != null
		else null
	)

	if (
		site_definition == null
		or site_state == null
	):
		_site_title.text = (
			"Выберите место"
		)

		_site_status.text = ""
		_site_description.text = ""

		_action_button.visible = false

		return

	_site_title.text = (
		site_definition.display_name
	)

	_site_description.text = (
		site_definition.description
	)

	if site_state.is_cleared():
		_action_button.visible = true
		_action_button.disabled = true

		if (
			site_definition.site_type
			== CampaignAdventureSiteDefinition
				.SiteType
				.BATTLE
		):
			_site_status.text = (
				"Состояние: зачищено."
			)

			_action_button.text = "ЗАЧИЩЕНО"

		else:
			_site_status.text = (
				"Состояние: исследовано."
			)

			_action_button.text = "ИССЛЕДОВАНО"

		return

	_site_status.text = (
		"Состояние: доступно."
	)

	_action_button.visible = true

	if (
		site_definition.site_type
		== CampaignAdventureSiteDefinition
			.SiteType
			.BATTLE
	):
		_action_button.disabled = false

		_action_button.text = (
			"ВСТУПИТЬ В БОЙ · %s"
			% site_definition.display_name
		)

	else:
		if site_definition.exploration_enabled:
			_action_button.disabled = false

			_action_button.text = (
				site_definition
					.exploration_action_label
			)

			if site_definition.material_reward > 0:
				_action_button.text += (
					" · +%d мат."
					% site_definition.material_reward
				)

		else:
			_action_button.disabled = true

			_action_button.text = (
				"ДЕЙСТВИЙ ПОКА НЕТ"
			)


func _get_first_visible_site_id() -> StringName:
	if (
		_definition == null
		or _state == null
	):
		return &""

	for site in _definition.sites:
		if site == null:
			continue

		var site_state := (
			_state.get_site(
				site.site_id
			)
		)

		if (
			site_state != null
			and not site_state.is_hidden()
		):
			return site.site_id

	return &""


func _on_site_selected(
	site_id: StringName
) -> void:
	_selected_site_id = site_id

	_refresh_details()


func _on_action_pressed() -> void:
	if (
		_definition == null
		or _state == null
		or _selected_site_id == &""
	):
		return

	var site_definition := (
		_definition.get_site(
			_selected_site_id
		)
	)

	var site_state := (
		_state.get_site(
			_selected_site_id
		)
	)

	if (
		site_definition == null
		or site_state == null
		or not site_state.is_available()
	):
		return

	match site_definition.site_type:
		CampaignAdventureSiteDefinition.SiteType.BATTLE:
			battle_site_requested.emit(
				_definition.area_id,
				_selected_site_id
			)

		CampaignAdventureSiteDefinition.SiteType.LANDMARK:
			if not site_definition.exploration_enabled:
				return

			landmark_site_requested.emit(
				_definition.area_id,
				_selected_site_id
			)


func _on_exit_pressed() -> void:
	exit_requested.emit()