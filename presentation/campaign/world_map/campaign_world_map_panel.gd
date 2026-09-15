class_name CampaignWorldMapPanel
extends PanelContainer


signal travel_requested(
	destination_node_id: StringName
)

signal adventure_requested

signal enter_requested(
	node_id: StringName
)

signal travel_progressed(progress: float)

signal travel_animation_finished


var _world_map: CampaignWorldMapDefinition
var _state: CampaignState

var _pending_travel: CampaignPendingTravel

const TRAVEL_PIXELS_PER_SECOND: float = 300.0
const CLOCK_UPDATE_INTERVAL: float = 0.05
var _animation_duration: float = 0.0
var _animation_span: float = 1.0
var _last_clock_progress: float = 0.0

var _travel_tween: Tween

var _settlement_definition: CampaignSettlementDefinition
var _settlement_state: CampaignSettlementState

var _selected_node_id: StringName = &""

var _travel_service := (
	CampaignTravelService.new()
)

var _route_access_service := (
	CampaignWorldRouteAccessService.new()
)


var _map_canvas: CampaignWorldMapCanvas
var _current_location_label: Label
var _selection_label: Label
var _travel_button: Button
var _enter_button: Button
var _adventure_button: Button


func bind(
	world_map: CampaignWorldMapDefinition,
	state: CampaignState,
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState,
	pending_travel: CampaignPendingTravel = null
) -> void:
	_world_map = world_map
	_state = state

	_pending_travel = pending_travel

	_settlement_definition = (
		settlement_definition
	)

	_settlement_state = (
		settlement_state
	)

	_selected_node_id = (
		pending_travel.destination_node_id
		if pending_travel != null
		else (
			state.current_world_node_id
			if state != null
			else &""
		)
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
		_state,
		_settlement_definition,
		_settlement_state,
		_pending_travel
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

	if _pending_travel != null:
		var origin := (
			_world_map.get_node(
				_pending_travel.from_node_id
			)
		)

		var destination := (
			_world_map.get_node(
				_pending_travel.destination_node_id
			)
		)

		_current_location_label.text = (
			"В пути: %s → %s"
			% [
				(
					origin.display_name
					if origin != null
					else "?"
				),
				(
					destination.display_name
					if destination != null
					else "?"
				),
			]
		)

		_selection_label.text = (
			"Путешествие продолжается · %d%%"
			% int(
				round(
					_pending_travel.progress
						* 100.0
				)
			)
		)

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
		or current_node.adventure_area_id
			!= &""
	)

	if _adventure_button.visible:
		if current_node.adventure_area_id != &"":
			_adventure_button.text = (
				"ВОЙТИ В РЕГИОН · %s"
				% current_node.display_name
			)

		else:
			_adventure_button.text = (
				"НАЧАТЬ ПРИКЛЮЧЕНИЕ"
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

	var path := _travel_service.get_shortest_path(_world_map, current_node.node_id,
		selected_node.node_id, _settlement_definition, _settlement_state)
	if path.size() < 2:
		_selection_label.text = "%s · Доступного маршрута нет." % selected_node.display_name
		_travel_button.disabled = true
		return
	var minutes: int = 0
	var names := PackedStringArray()
	for i in range(path.size()):
		names.append(_world_map.get_node(path[i]).display_name)
		if i > 0:
			minutes += _travel_service.get_travel_minutes(_world_map, path[i - 1], path[i])
	_selection_label.text = "%s\nВ пути: %d дн. %d ч. %d мин." % [
		" → ".join(names), minutes / 1440, (minutes % 1440) / 60, minutes % 60]

	_travel_button.disabled = false


func sync_pending_travel(
	pending_travel: CampaignPendingTravel
) -> void:
	_pending_travel = pending_travel

	_map_canvas.set_pending_travel(
		pending_travel
	)

	_refresh_selection()


func animate_pending_travel_to_next_stop() -> bool:
	if (
		_pending_travel == null
		or _map_canvas == null
	):
		return false

	if (
		_travel_tween != null
		and _travel_tween.is_running()
	):
		return false

	var from_progress := (
		_pending_travel.progress
	)

	var to_progress := (
		_pending_travel
			.get_next_stop_progress()
	)

	if to_progress < from_progress:
		return false

	_map_canvas.set_event_marker_visible(
		false
	)

	_map_canvas.set_travel_display_progress(
		from_progress
	)

	var distance := (
		to_progress
		- from_progress
	)

	var origin := _world_map.get_node(_pending_travel.from_node_id)
	var destination := _world_map.get_node(_pending_travel.destination_node_id)
	var pixels := _map_canvas.get_display_distance(origin.map_position, destination.map_position)
	var duration := maxf(pixels * distance / TRAVEL_PIXELS_PER_SECOND, 0.001)
	_animation_duration = duration
	_animation_span = distance
	_last_clock_progress = from_progress

	_travel_tween = create_tween()

	_travel_tween.set_trans(
		Tween.TRANS_LINEAR
	)

	_travel_tween.set_ease(
		Tween.EASE_IN_OUT
	)

	_travel_tween.tween_method(
		_animate_progress,
		from_progress,
		to_progress,
		duration
	)

	_travel_tween.finished.connect(
		func() -> void:
			if (
				_pending_travel != null
				and _pending_travel
					.has_unresolved_event()
				and is_equal_approx(
					to_progress,
					_pending_travel
						.event_progress
				)
			):
				_map_canvas.set_event_marker_visible(true)

			travel_animation_finished.emit()
	)

	return true


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

func _animate_progress(progress: float) -> void:
	# Keep movement per-frame, but avoid full campaign validation and HUD layout
	# on every rendered frame. Always settle the exact clock at a stop.
	var elapsed := (progress - _last_clock_progress) * _animation_duration / maxf(_animation_span, 0.000001)
	if elapsed >= CLOCK_UPDATE_INTERVAL or progress >= _pending_travel.get_next_stop_progress():
		travel_progressed.emit(progress)
		_last_clock_progress = progress
		_refresh_selection()
	_map_canvas.set_travel_display_progress(progress)
