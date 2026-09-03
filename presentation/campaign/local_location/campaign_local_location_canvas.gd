class_name CampaignLocalLocationCanvas
extends SubViewportContainer


signal interaction_selected(
	interaction_id: StringName
)

signal camera_target_changed


const INTERACTION_SIZE := Vector2(
	180.0,
	60.0
)

## За одно нажатие камера проходит примерно
## 72% видимой области.
##
## Поэтому соседние части локации немного
## перекрываются, а не работают как страницы.
const PAN_FRACTION: float = 0.72

const CAMERA_SMOOTHING_SPEED: float = 7.0


var _definition: CampaignLocalLocationDefinition

var _selected_interaction_id: StringName = &""

var _camera_target_x: float = 0.0
var _needs_initial_camera_position: bool = true

var _viewport: SubViewport
var _world_root: Node2D
var _content_root: Node2D
var _camera: Camera2D

var _buttons_by_interaction_id: Dictionary = {}
var _display_text_overrides: Dictionary = {}


func _ready() -> void:
	stretch = true

	_ensure_viewport_scene()

	resized.connect(
		_on_resized
	)


func bind(
	definition: CampaignLocalLocationDefinition
) -> void:
	_definition = definition

	_selected_interaction_id = &""
	_display_text_overrides.clear()

	_camera_target_x = 0.0
	_needs_initial_camera_position = true

	_ensure_viewport_scene()
	_rebuild_world()

	_sync_viewport_size()

	call_deferred(
		"_sync_viewport_size"
	)


func set_selected_interaction(
	interaction_id: StringName
) -> void:
	_selected_interaction_id = (
		interaction_id
	)

	_refresh_button_texts()


func set_interaction_display_overrides(
	overrides: Dictionary
) -> void:
	_display_text_overrides = (
		overrides.duplicate()
	)

	_refresh_button_texts()


func has_horizontal_pan() -> bool:
	if (
		_definition == null
		or _camera == null
	):
		return false

	var visible_world_width := (
		_get_visible_world_width()
	)

	return (
		_definition.reference_size.x
		> visible_world_width + 1.0
	)


func can_pan_left() -> bool:
	if not has_horizontal_pan():
		return false

	return (
		_camera_target_x
		> _get_min_camera_x() + 1.0
	)


func can_pan_right() -> bool:
	if not has_horizontal_pan():
		return false

	return (
		_camera_target_x
		< _get_max_camera_x() - 1.0
	)


func pan_horizontal(
	direction: int
) -> bool:
	if (
		direction == 0
		or not has_horizontal_pan()
	):
		return false

	var direction_sign := (
		-1.0
		if direction < 0
		else 1.0
	)

	var distance := (
		_get_visible_world_width()
		* PAN_FRACTION
	)

	var target_x := clampf(
		_camera_target_x
			+ distance * direction_sign,
		_get_min_camera_x(),
		_get_max_camera_x()
	)

	if is_equal_approx(
		target_x,
		_camera_target_x
	):
		return false

	_set_camera_target_x(
		target_x,
		false
	)

	return true


func _ensure_viewport_scene() -> void:
	if _viewport != null:
		return

	_viewport = SubViewport.new()

	_viewport.name = "LocalLocationViewport"

	_viewport.transparent_bg = true
	_viewport.gui_disable_input = false

	_viewport.render_target_update_mode = (
		SubViewport.UPDATE_ALWAYS
	)

	add_child(
		_viewport
	)

	_world_root = Node2D.new()
	_world_root.name = "World"

	_viewport.add_child(
		_world_root
	)

	_content_root = Node2D.new()
	_content_root.name = "Content"

	_world_root.add_child(
		_content_root
	)

	_camera = Camera2D.new()
	_camera.name = "Camera"

	_camera.position_smoothing_enabled = true

	_camera.position_smoothing_speed = (
		CAMERA_SMOOTHING_SPEED
	)

	_world_root.add_child(
		_camera
	)

	_camera.make_current()


func _rebuild_world() -> void:
	if (
		_content_root == null
		or _camera == null
	):
		return

	for child in _content_root.get_children():
		_content_root.remove_child(
			child
		)

		child.queue_free()

	_buttons_by_interaction_id.clear()

	if _definition == null:
		return

	_create_debug_ground()
	_create_interaction_buttons()

	_refresh_button_texts()


func _create_debug_ground() -> void:
	if _definition == null:
		return

	var world_width := (
		_definition.reference_size.x
	)

	var world_height := (
		_definition.reference_size.y
	)

	var ground_start_y := (
		world_height * 0.58
	)

	var ground := Polygon2D.new()

	ground.name = "Ground"

	ground.polygon = PackedVector2Array(
		[
			Vector2(
				0.0,
				ground_start_y
			),
			Vector2(
				world_width,
				ground_start_y
			),
			Vector2(
				world_width,
				world_height
			),
			Vector2(
				0.0,
				world_height
			),
		]
	)

	ground.color = Color(
		0.09,
		0.085,
		0.075,
		1.0
	)

	_content_root.add_child(
		ground
	)

	var ground_line := Line2D.new()

	ground_line.name = "GroundLine"

	ground_line.points = PackedVector2Array(
		[
			Vector2(
				0.0,
				ground_start_y
			),
			Vector2(
				world_width,
				ground_start_y
			),
		]
	)

	ground_line.width = 2.0

	ground_line.default_color = Color(
		0.28,
		0.25,
		0.20,
		1.0
	)

	_content_root.add_child(
		ground_line
	)


func _create_interaction_buttons() -> void:
	if _definition == null:
		return

	for interaction in (
		_definition.interactions
	):
		if interaction == null:
			continue

		var button := Button.new()

		button.name = (
			"Interaction_%s"
			% interaction.interaction_id
		)

		button.size = INTERACTION_SIZE

		button.custom_minimum_size = (
			INTERACTION_SIZE
		)

		button.position = (
			interaction.local_position
			- INTERACTION_SIZE * 0.5
		)

		button.tooltip_text = (
			interaction.description
		)

		button.focus_mode = (
			Control.FOCUS_NONE
		)

		button.z_index = 10

		button.pressed.connect(
			_on_interaction_pressed.bind(
				interaction.interaction_id
			)
		)

		_content_root.add_child(
			button
		)

		_buttons_by_interaction_id[
			interaction.interaction_id
		] = button


func _refresh_button_texts() -> void:
	if _definition == null:
		return

	for interaction in (
		_definition.interactions
	):
		if (
			interaction == null
			or not _buttons_by_interaction_id.has(
				interaction.interaction_id
			)
		):
			continue

		var button := (
			_buttons_by_interaction_id[
				interaction.interaction_id
			] as Button
		)

		if button == null:
			continue

		var prefix := ""

		if (
			interaction.interaction_id
			== _selected_interaction_id
		):
			prefix = "→ "

		var display_text := (
			interaction.display_name
		)

		if _display_text_overrides.has(
			interaction.interaction_id
		):
			display_text = String(
				_display_text_overrides[
					interaction.interaction_id
				]
			)

		button.text = (
			prefix
			+ display_text
		)


func _sync_viewport_size() -> void:
	if (
		_viewport == null
		or _camera == null
		or _definition == null
	):
		return

	if (
		size.x <= 1.0
		or size.y <= 1.0
	):
		return

	_viewport.size = Vector2i(
		maxi(
			roundi(size.x),
			1
		),
		maxi(
			roundi(size.y),
			1
		)
	)

	_update_camera_zoom()

	if _needs_initial_camera_position:
		_needs_initial_camera_position = false

		_camera_target_x = (
			_get_min_camera_x()
		)

	else:
		_camera_target_x = clampf(
			_camera_target_x,
			_get_min_camera_x(),
			_get_max_camera_x()
		)

	_set_camera_target_x(
		_camera_target_x,
		true
	)


func _update_camera_zoom() -> void:
	if (
		_definition == null
		or _camera == null
		or _viewport == null
		or _definition.view_width <= 0.0
	):
		return

	## view_width — authored ширина кадра.
	## Например HOME имеет 3000 world units,
	## но камера одновременно показывает около 1000.
	var zoom_factor := (
		float(_viewport.size.x)
		/ _definition.view_width
	)

	zoom_factor = maxf(
		zoom_factor,
		0.01
	)

	_camera.zoom = Vector2(
		zoom_factor,
		zoom_factor
	)


func _get_visible_world_width() -> float:
	if (
		_viewport == null
		or _camera == null
		or _camera.zoom.x <= 0.0
	):
		return 1.0

	return (
		float(_viewport.size.x)
		/ _camera.zoom.x
	)


func _get_min_camera_x() -> float:
	if _definition == null:
		return 0.0

	var world_width := (
		_definition.reference_size.x
	)

	var visible_width := (
		_get_visible_world_width()
	)

	if world_width <= visible_width:
		return world_width * 0.5

	return visible_width * 0.5


func _get_max_camera_x() -> float:
	if _definition == null:
		return 0.0

	var world_width := (
		_definition.reference_size.x
	)

	var visible_width := (
		_get_visible_world_width()
	)

	if world_width <= visible_width:
		return world_width * 0.5

	return (
		world_width
		- visible_width * 0.5
	)


func _set_camera_target_x(
	target_x: float,
	snap: bool
) -> void:
	if (
		_definition == null
		or _camera == null
	):
		return

	_camera_target_x = clampf(
		target_x,
		_get_min_camera_x(),
		_get_max_camera_x()
	)

	_camera.position = Vector2(
		_camera_target_x,
		_definition.reference_size.y * 0.5
	)

	if snap:
		_camera.reset_smoothing()

	camera_target_changed.emit()


func _on_interaction_pressed(
	interaction_id: StringName
) -> void:
	set_selected_interaction(
		interaction_id
	)

	interaction_selected.emit(
		interaction_id
	)


func _on_resized() -> void:
	call_deferred(
		"_sync_viewport_size"
	)