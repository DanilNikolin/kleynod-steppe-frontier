class_name CampaignLocalLocationPanel
extends PanelContainer


signal exit_requested

signal interaction_action_requested(
	interaction_id: StringName,
	action_label: String
)

signal settlement_build_requested(
	zone_id: StringName,
	building_id: StringName
)


var _definition: CampaignLocalLocationDefinition
var _state: CampaignState

var _settlement_definition: CampaignSettlementDefinition
var _settlement_state: CampaignSettlementState

var _selected_interaction_id: StringName = &""

var _time_service := (
	CampaignTimeService.new()
)

var _construction_service := (
	CampaignSettlementConstructionService.new()
)


var _canvas: CampaignLocalLocationCanvas

var _camera_navigation: HBoxContainer
var _camera_left_button: Button
var _camera_right_button: Button
var _camera_label: Label
var _resources_label: Label
var _time_label: Label

var _interaction_title: Label
var _interaction_description: Label
var _actions_row: HBoxContainer
var _status_label: Label


func bind(
	definition: CampaignLocalLocationDefinition,
	state: CampaignState,
	settlement_definition: CampaignSettlementDefinition = null,
	settlement_state: CampaignSettlementState = null
) -> void:
	_definition = definition
	_state = state

	_settlement_definition = (
		settlement_definition
	)

	_settlement_state = (
		settlement_state
	)

	_selected_interaction_id = &""

	_build_interface()
	_refresh_camera_navigation()
	refresh_state()


func refresh_state() -> void:
	_refresh_header_state()
	_refresh_settlement_visuals()
	_refresh_interaction_panel()


func _refresh_header_state() -> void:
	if _time_label != null:
		_time_label.text = (
			"Время · %s"
			% _time_service.get_time_text(
				_state
			)
		)

	if _resources_label == null:
		return

	var gold := 0
	var materials := 0

	if _state != null:
		materials = _state.materials

		if _state.inventory_state != null:
			gold = _state.inventory_state.gold

	_resources_label.text = (
		"Gold: %d · Materials: %d"
		% [
			gold,
			materials,
		]
	)


func _refresh_settlement_visuals() -> void:
	if _canvas == null:
		return

	var overrides: Dictionary = {}

	if (
		_settlement_definition == null
		or _settlement_state == null
	):
		_canvas.set_interaction_display_overrides(
			overrides
		)

		return

	for zone in _settlement_definition.zones:
		if (
			zone == null
			or zone.local_interaction_id == &""
		):
			continue

		var zone_state := (
			_settlement_state.get_zone(
				zone.zone_id
			)
		)

		if (
			zone_state == null
			or zone_state.is_empty()
		):
			overrides[
				zone.local_interaction_id
			] = zone.display_name

			continue

		var building := zone.get_building(
			zone_state.building_id
		)

		var building_name := (
			building.display_name
			if building != null
			else String(
				zone_state.building_id
			)
		)

		overrides[
			zone.local_interaction_id
		] = (
			"%s · ур. %d"
			% [
				building_name,
				zone_state.building_level,
			]
		)

	_canvas.set_interaction_display_overrides(
		overrides
	)


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

	_resources_label = Label.new()

	_resources_label.add_theme_font_size_override(
		"font_size",
		18
	)

	header.add_child(
		_resources_label
	)

	_time_label = Label.new()

	_time_label.add_theme_font_size_override(
		"font_size",
		20
	)

	header.add_child(
		_time_label
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

	_camera_navigation = (
		HBoxContainer.new()
	)

	_camera_navigation.add_theme_constant_override(
		"separation",
		12
	)

	root.add_child(
		_camera_navigation
	)

	_camera_left_button = Button.new()

	_camera_left_button.text = "←"

	_camera_left_button.custom_minimum_size = Vector2(
		90,
		42
	)

	_camera_left_button.pressed.connect(
		_on_camera_left_pressed
	)

	_camera_navigation.add_child(
		_camera_left_button
	)

	_camera_label = Label.new()

	_camera_label.text = (
		"Обзор локации"
	)

	_camera_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	_camera_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_camera_label.add_theme_font_size_override(
		"font_size",
		18
	)

	_camera_navigation.add_child(
		_camera_label
	)

	_camera_right_button = Button.new()

	_camera_right_button.text = "→"

	_camera_right_button.custom_minimum_size = Vector2(
		90,
		42
	)

	_camera_right_button.pressed.connect(
		_on_camera_right_pressed
	)

	_camera_navigation.add_child(
		_camera_right_button
	)

	_canvas = (
		CampaignLocalLocationCanvas.new()
	)

	_canvas.custom_minimum_size = Vector2(
		900,
		430
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

	_canvas.camera_target_changed.connect(
		_refresh_camera_navigation
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


func _refresh_camera_navigation() -> void:
	if (
		_canvas == null
		or _camera_navigation == null
	):
		return

	var has_pan := (
		_canvas.has_horizontal_pan()
	)

	_camera_navigation.visible = has_pan

	if not has_pan:
		return

	_camera_left_button.disabled = (
		not _canvas.can_pan_left()
	)

	_camera_right_button.disabled = (
		not _canvas.can_pan_right()
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

	var settlement_zone := (
		_get_selected_settlement_zone()
	)

	if settlement_zone != null:
		_interaction_title.text = (
			_get_settlement_zone_title(
				settlement_zone
			)
		)

		_interaction_description.text = (
			_get_settlement_zone_text(
				settlement_zone
			)
		)

		_status_label.text = ""

		_create_settlement_zone_actions(
			settlement_zone
		)

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


func _get_settlement_zone_title(
	zone: CampaignSettlementZoneDefinition
) -> String:
	if (
		zone == null
		or _settlement_state == null
	):
		return "—"

	var zone_state := _settlement_state.get_zone(
		zone.zone_id
	)

	if (
		zone_state == null
		or zone_state.is_empty()
	):
		return zone.display_name

	var building := zone.get_building(
		zone_state.building_id
	)

	if building == null:
		return zone.display_name

	return (
		"%s · уровень %d"
		% [
			building.display_name,
			zone_state.building_level,
		]
	)


func _create_settlement_zone_actions(
	zone: CampaignSettlementZoneDefinition
) -> void:
	if (
		zone == null
		or _settlement_state == null
	):
		return

	var zone_state := _settlement_state.get_zone(
		zone.zone_id
	)

	if zone_state == null:
		return

	if not zone_state.is_empty():
		var built_button := Button.new()

		built_button.text = (
			"Услуги постройки · подключим следующим шагом"
		)

		built_button.disabled = true

		_actions_row.add_child(
			built_button
		)

		return

	for building in zone.allowed_buildings:
		if building == null:
			continue

		var button := Button.new()

		if not building.construction_enabled:
			button.text = (
				"%s · пока недоступно"
				% building.display_name
			)

			button.disabled = true

			_actions_row.add_child(
				button
			)

			continue

		button.text = (
			"ПОСТРОИТЬ · %s · %d зол. · %d мат. · %s"
			% [
				building.display_name,
				building.construction_gold_cost,
				building.construction_material_cost,
				_get_duration_text(
					building.construction_minutes
				),
			]
		)

		var construction_error := (
			_construction_service
				.get_construction_error(
					_state,
					_settlement_definition,
					zone.zone_id,
					building.building_id
				)
		)

		button.disabled = (
			not construction_error.is_empty()
		)

		if button.disabled:
			button.tooltip_text = (
				construction_error
			)

		else:
			button.pressed.connect(
				_on_settlement_build_pressed.bind(
					zone.zone_id,
					building.building_id
				)
			)

		_actions_row.add_child(
			button
		)


func _get_duration_text(
	minutes: int
) -> String:
	if (
		minutes > 0
		and minutes
			% CampaignTimeService.MINUTES_PER_DAY
			== 0
	):
		return (
			"%d дн."
			% (
				minutes
				/ CampaignTimeService.MINUTES_PER_DAY
			)
		)

	if (
		minutes > 0
		and minutes
			% CampaignTimeService.MINUTES_PER_HOUR
			== 0
	):
		return (
			"%d ч."
			% (
				minutes
				/ CampaignTimeService.MINUTES_PER_HOUR
			)
		)

	return "%d мин." % minutes


func _get_selected_settlement_zone() -> CampaignSettlementZoneDefinition:
	if (
		_settlement_definition == null
		or _selected_interaction_id == &""
	):
		return null

	return (
		_settlement_definition
			.get_zone_by_local_interaction_id(
				_selected_interaction_id
			)
	)


func _get_settlement_zone_text(
	zone: CampaignSettlementZoneDefinition
) -> String:
	if zone == null:
		return ""

	var lines := PackedStringArray()

	lines.append(
		zone.description
	)

	var zone_state: CampaignSettlementZoneState

	if _settlement_state != null:
		zone_state = (
			_settlement_state.get_zone(
				zone.zone_id
			)
		)

	if zone_state == null:
		lines.append(
			"Состояние: недоступно."
		)

		return "\n".join(
			lines
		)

	if zone_state.is_empty():
		lines.append(
			"Состояние: пустой участок."
		)

		var building_names := (
			PackedStringArray()
		)

		for building in (
			zone.allowed_buildings
		):
			if building == null:
				continue

			building_names.append(
				building.display_name
			)

		if not building_names.is_empty():
			lines.append(
				"Возможные постройки: %s"
				% " / ".join(
					building_names
				)
			)

	else:
		var building := zone.get_building(
			zone_state.building_id
		)

		var building_name := (
			building.display_name
			if building != null
			else String(
				zone_state.building_id
			)
		)

		lines.append(
			"Построено: %s · уровень %d."
			% [
				building_name,
				zone_state.building_level,
			]
		)

	return "\n".join(
		lines
	)


func _clear_action_buttons() -> void:
	if _actions_row == null:
		return

	for child in (
		_actions_row.get_children()
	):
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


func _on_settlement_build_pressed(
	zone_id: StringName,
	building_id: StringName
) -> void:
	settlement_build_requested.emit(
		zone_id,
		building_id
	)


func _on_camera_left_pressed() -> void:
	if _canvas == null:
		return

	_canvas.pan_horizontal(
		-1
	)

	_refresh_camera_navigation()


func _on_camera_right_pressed() -> void:
	if _canvas == null:
		return

	_canvas.pan_horizontal(
		1
	)

	_refresh_camera_navigation()


func _on_exit_pressed() -> void:
	exit_requested.emit()