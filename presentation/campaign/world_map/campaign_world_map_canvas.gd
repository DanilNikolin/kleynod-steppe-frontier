class_name CampaignWorldMapCanvas
extends Control


signal node_selected(
	node_id: StringName
)


const NODE_SIZE := Vector2(
	150.0,
	58.0
)

const MAP_PADDING := Vector2(
	28.0,
	28.0
)


var _world_map: CampaignWorldMapDefinition
var _state: CampaignState

var _settlement_definition: CampaignSettlementDefinition
var _settlement_state: CampaignSettlementState

var _route_access_service := (
	CampaignWorldRouteAccessService.new()
)

var _selected_node_id: StringName = &""

var _buttons_by_node_id: Dictionary = {}

var _pending_travel: CampaignPendingTravel

var _travel_display_progress: float = -1.0

var _party_marker: Label

var _event_marker: Button


func _ready() -> void:
	resized.connect(
		_on_resized
	)

	_build_travel_markers()


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

	_travel_display_progress = (
		pending_travel.progress
		if pending_travel != null
		else -1.0
	)

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

	_rebuild_node_buttons()

	_refresh_travel_markers()

	queue_redraw()


func set_selected_node(
	node_id: StringName
) -> void:
	_selected_node_id = node_id

	_refresh_button_texts()

	queue_redraw()


func _draw() -> void:
	if (
		_world_map == null
		or _world_map.nodes.is_empty()
	):
		return

	for route in _world_map.routes:
		if route == null:
			continue

		if not (
			_route_access_service
				.is_route_available(
					route,
					_settlement_definition,
					_settlement_state
				)
		):
			continue

		var node_a := _world_map.get_node(
			route.node_a_id
		)

		var node_b := _world_map.get_node(
			route.node_b_id
		)

		if (
			node_a == null
			or node_b == null
		):
			continue

		var point_a := _map_position_to_canvas(
			node_a.map_position
		)

		var point_b := _map_position_to_canvas(
			node_b.map_position
		)

		draw_line(
			point_a,
			point_b,
			Color(
				0.34,
				0.37,
				0.42,
				1.0
			),
			3.0,
			true
		)

	if (
		_state == null
		or _pending_travel != null
	):
		return

	var current_node := _world_map.get_node(
		_state.current_world_node_id
	)

	if current_node == null:
		return

	draw_circle(
		_map_position_to_canvas(
			current_node.map_position
		),
		38.0,
		Color(
			0.75,
			0.66,
			0.28,
			0.18
		)
	)


func _rebuild_node_buttons() -> void:
	for button_value in (
		_buttons_by_node_id.values()
	):
		var button := button_value as Button

		if button == null:
			continue

		remove_child(
			button
		)

		button.queue_free()

	_buttons_by_node_id.clear()

	if _world_map == null:
		return

	for node in _world_map.nodes:
		if node == null:
			continue

		var button := Button.new()

		button.custom_minimum_size = (
			NODE_SIZE
		)

		button.size = NODE_SIZE

		button.tooltip_text = (
			_get_node_type_name(
				node.node_type
			)
		)

		button.pressed.connect(
			_on_node_pressed.bind(
				node.node_id
			)
		)

		add_child(
			button
		)

		_buttons_by_node_id[
			node.node_id
		] = button

	_refresh_button_texts()
	_layout_node_buttons()


func _refresh_button_texts() -> void:
	if _world_map == null:
		return

	for node in _world_map.nodes:
		if node == null:
			continue

		if not _buttons_by_node_id.has(
			node.node_id
		):
			continue

		var button := (
			_buttons_by_node_id[
				node.node_id
			] as Button
		)

		if button == null:
			continue

		button.disabled = (
			_pending_travel != null
		)

		var prefix := ""

		if (
			_state != null
			and node.node_id
				== _state.current_world_node_id
		):
			prefix = "● "

		elif (
			node.node_id
			== _selected_node_id
		):
			prefix = "→ "

		button.text = (
			prefix
			+ node.display_name
		)


func _layout_node_buttons() -> void:
	if _world_map == null:
		return

	for node in _world_map.nodes:
		if node == null:
			continue

		if not _buttons_by_node_id.has(
			node.node_id
		):
			continue

		var button := (
			_buttons_by_node_id[
				node.node_id
			] as Button
		)

		if button == null:
			continue

		var center := _map_position_to_canvas(
			node.map_position
		)

		button.position = (
			center
			- NODE_SIZE * 0.5
		)

		button.size = NODE_SIZE


func _map_position_to_canvas(
	map_position: Vector2
) -> Vector2:
	if (
		_world_map == null
		or _world_map.nodes.is_empty()
	):
		return size * 0.5

	var has_position := false

	var minimum := Vector2.ZERO
	var maximum := Vector2.ZERO

	for node in _world_map.nodes:
		if node == null:
			continue

		if not has_position:
			minimum = node.map_position
			maximum = node.map_position
			has_position = true
			continue

		minimum.x = minf(
			minimum.x,
			node.map_position.x
		)

		minimum.y = minf(
			minimum.y,
			node.map_position.y
		)

		maximum.x = maxf(
			maximum.x,
			node.map_position.x
		)

		maximum.y = maxf(
			maximum.y,
			node.map_position.y
		)

	if not has_position:
		return size * 0.5

	var source_size := (
		maximum - minimum
	)

	var normalized := Vector2(
		0.5,
		0.5
	)

	if source_size.x > 0.0:
		normalized.x = (
			(map_position.x - minimum.x)
			/ source_size.x
		)

	if source_size.y > 0.0:
		normalized.y = (
			(map_position.y - minimum.y)
			/ source_size.y
		)

	var half_node := (
		NODE_SIZE * 0.5
	)

	var left := (
		MAP_PADDING.x
		+ half_node.x
	)

	var top := (
		MAP_PADDING.y
		+ half_node.y
	)

	var right := maxf(
		size.x
		- MAP_PADDING.x
		- half_node.x,
		left
	)

	var bottom := maxf(
		size.y
		- MAP_PADDING.y
		- half_node.y,
		top
	)

	return Vector2(
		lerpf(
			left,
			right,
			normalized.x
		),
		lerpf(
			top,
			bottom,
			normalized.y
		)
	)


func set_pending_travel(
	pending_travel: CampaignPendingTravel
) -> void:
	_pending_travel = pending_travel

	if pending_travel == null:
		_travel_display_progress = -1.0

	else:
		_travel_display_progress = (
			pending_travel.progress
		)

	_refresh_button_texts()
	_refresh_travel_markers()

	queue_redraw()


func set_travel_display_progress(
	progress: float
) -> void:
	if _pending_travel == null:
		return

	_travel_display_progress = clampf(
		progress,
		0.0,
		1.0
	)

	_refresh_travel_markers()


func set_event_marker_visible(
	target_visible: bool
) -> void:
	if _event_marker == null:
		return

	_event_marker.visible = (
		target_visible
		and _pending_travel != null
		and _pending_travel.has_unresolved_event()
	)

	if _event_marker.visible:
		_layout_event_marker()


func _build_travel_markers() -> void:
	_party_marker = Label.new()

	_party_marker.text = "● ОТРЯД"

	_party_marker.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	_party_marker.add_theme_font_size_override(
		"font_size",
		18
	)

	_party_marker.z_index = 20

	_party_marker.visible = false

	add_child(
		_party_marker
	)

	_event_marker = Button.new()

	_event_marker.text = "⚠ СОБЫТИЕ"

	_event_marker.disabled = true

	_event_marker.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	_event_marker.custom_minimum_size = (
		Vector2(
			120,
			42
		)
	)

	_event_marker.size = (
		Vector2(
			120,
			42
		)
	)

	_event_marker.z_index = 19

	_event_marker.visible = false

	add_child(
		_event_marker
	)


func _refresh_travel_markers() -> void:
	if (
		_party_marker == null
		or _event_marker == null
	):
		return

	if (
		_pending_travel == null
		or _world_map == null
	):
		_party_marker.visible = false
		_event_marker.visible = false
		return

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

	if (
		origin == null
		or destination == null
	):
		_party_marker.visible = false
		_event_marker.visible = false
		return

	_party_marker.visible = true

	var map_position := (
		origin.map_position.lerp(
			destination.map_position,
			clampf(
				_travel_display_progress,
				0.0,
				1.0
			)
		)
	)

	var canvas_position := (
		_map_position_to_canvas(
			map_position
		)
	)

	_party_marker.reset_size()

	_party_marker.position = (
		canvas_position
		- Vector2(
			_party_marker.size.x * 0.5,
			_party_marker.size.y * 0.5
		)
	)

	if _event_marker.visible:
		_layout_event_marker()


func _layout_event_marker() -> void:
	if (
		_event_marker == null
		or _pending_travel == null
		or _world_map == null
		or not _pending_travel.has_event()
	):
		return

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

	if (
		origin == null
		or destination == null
	):
		return

	var event_map_position := (
		origin.map_position.lerp(
			destination.map_position,
			_pending_travel.event_progress
		)
	)

	var event_canvas_position := (
		_map_position_to_canvas(
			event_map_position
		)
	)

	_event_marker.position = (
		event_canvas_position
		+ Vector2(
			16,
			-52
		)
	)


func _get_node_type_name(
	node_type: int
) -> String:
	match node_type:
		CampaignWorldNodeDefinition.NodeType.HOME_SETTLEMENT:
			return "Родное поселение"

		CampaignWorldNodeDefinition.NodeType.VILLAGE:
			return "Село"

		CampaignWorldNodeDefinition.NodeType.CITY:
			return "Город"

		CampaignWorldNodeDefinition.NodeType.ADVENTURE:
			return "Приключенческая точка"

		_:
			return "Неизвестная точка"


func _on_node_pressed(
	node_id: StringName
) -> void:
	set_selected_node(
		node_id
	)

	node_selected.emit(
		node_id
	)


func _on_resized() -> void:
	_layout_node_buttons()
	_refresh_travel_markers()

	queue_redraw()