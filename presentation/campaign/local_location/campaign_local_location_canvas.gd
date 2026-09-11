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
const KEYBOARD_PAN_SPEED: float = 700.0


var _definition: CampaignLocalLocationDefinition

var _selected_interaction_id: StringName = &""

var _camera_target_x: float = 0.0
var _needs_initial_camera_position: bool = true
var _is_camera_dragging: bool = false

var _viewport: SubViewport
var _world_root: Node2D

var _far_background: Parallax2D
var _mid_background: Parallax2D
var _content_root: Node2D
var _foreground: Parallax2D
var _interactions_root: Node2D

var _camera: Camera2D

var _buttons_by_interaction_id: Dictionary = {}
var _display_text_overrides: Dictionary = {}
var _visibility_overrides: Dictionary = {}
var _anchors_by_interaction_id: Dictionary = {}


func _ready() -> void:
	stretch = true

	_ensure_viewport_scene()
	_activate_camera_if_ready()

	resized.connect(
		_on_resized
	)


func _process(delta: float) -> void:
	if (
		_definition == null
		or _camera == null
		or _is_camera_dragging
		or not has_horizontal_pan()
	):
		return

	var direction := Input.get_axis(
		"ui_left",
		"ui_right"
	)

	if is_zero_approx(direction):
		return

	_set_camera_target_x(
		_camera_target_x
			+ direction
			* KEYBOARD_PAN_SPEED
			* delta,
		false
	)


func _gui_input(event: InputEvent) -> void:
	if (
		_definition == null
		or _camera == null
		or not has_horizontal_pan()
	):
		return

	if not event is InputEventMouseButton:
		return

	var mouse_button := (
		event as InputEventMouseButton
	)

	if (
		mouse_button.button_index
		!= MOUSE_BUTTON_LEFT
	):
		return

	if not mouse_button.pressed:
		return

	## Interaction buttons rendered inside the SubViewport
	## must keep their normal GUI click behaviour.
	if _is_pointer_over_subviewport_control():
		return

	_begin_camera_drag()

	accept_event()


func _input(event: InputEvent) -> void:
	if (
		not _is_camera_dragging
		or _camera == null
	):
		return

	if event is InputEventMouseMotion:
		var mouse_motion := (
			event as InputEventMouseMotion
		)

		var world_delta_x := (
			mouse_motion.relative.x
			/ maxf(
				_camera.zoom.x,
				0.01
			)
		)

		_set_camera_target_x(
			_camera_target_x
				- world_delta_x,
			true
		)

		get_viewport().set_input_as_handled()

		return

	if event is InputEventMouseButton:
		var mouse_button := (
			event as InputEventMouseButton
		)

		if (
			mouse_button.button_index
			== MOUSE_BUTTON_LEFT
			and not mouse_button.pressed
		):
			_end_camera_drag()

			get_viewport().set_input_as_handled()


func _is_pointer_over_subviewport_control() -> bool:
	if _viewport == null:
		return false

	return (
		_viewport.gui_get_hovered_control()
		!= null
	)


func _begin_camera_drag() -> void:
	if _camera == null:
		return

	_is_camera_dragging = true

	_camera.position_smoothing_enabled = false


func _end_camera_drag() -> void:
	if _camera == null:
		_is_camera_dragging = false

		return

	_is_camera_dragging = false

	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = (
		CAMERA_SMOOTHING_SPEED
	)


func bind(
	definition: CampaignLocalLocationDefinition
) -> void:
	_definition = definition

	_selected_interaction_id = &""
	_display_text_overrides.clear()
	_visibility_overrides.clear()

	_camera_target_x = 0.0
	_needs_initial_camera_position = true
	_is_camera_dragging = false

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


func set_interaction_visibility_overrides(
	overrides: Dictionary
) -> void:
	_visibility_overrides = (
		overrides.duplicate()
	)

	_refresh_button_texts()


func set_build_site_built_states(
	states: Dictionary
) -> void:
	for interaction_id in states:
		if not _anchors_by_interaction_id.has(
			interaction_id
		):
			continue

		var site := (
			_anchors_by_interaction_id[interaction_id]
			as LocalBuildSiteView
		)

		if site == null:
			continue

		site.set_built(
			bool(states[interaction_id])
		)


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


func _rebuild_world() -> void:
	if _viewport == null:
		return

	_clear_visual_stage()

	_buttons_by_interaction_id.clear()

	if _definition == null:
		return

	var has_authored_visual_stage := (
		_instantiate_authored_visual_stage()
	)

	if not has_authored_visual_stage:
		_create_fallback_visual_stage()

	if (
		_content_root == null
		or _interactions_root == null
		or _camera == null
	):
		push_error(
			"Local location visual stage is incomplete."
		)

		return

	## Authored visual scenes own their placeholder/art content.
	## Old locations without a scene keep the legacy debug ground.
	if not has_authored_visual_stage:
		_create_debug_ground()

	_create_interaction_buttons()

	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = (
		CAMERA_SMOOTHING_SPEED
	)

	_activate_camera_if_ready()

	_refresh_button_texts()


func _activate_camera_if_ready() -> void:
	if (
		_camera == null
		or not _camera.is_inside_tree()
	):
		return

	_camera.enabled = true
	_camera.make_current()

func _clear_visual_stage() -> void:
	if (
		_world_root != null
		and is_instance_valid(_world_root)
	):
		var parent := _world_root.get_parent()

		if parent != null:
			parent.remove_child(
				_world_root
			)

		_world_root.queue_free()

	_reset_visual_stage_references()


func _reset_visual_stage_references() -> void:
	_world_root = null
	_far_background = null
	_mid_background = null
	_content_root = null
	_foreground = null
	_interactions_root = null
	_camera = null
	_anchors_by_interaction_id.clear()


func _instantiate_authored_visual_stage() -> bool:
	if (
		_definition == null
		or _definition
			.visual_scene_path
			.strip_edges()
			.is_empty()
	):
		return false

	var visual_scene := load(
		_definition.visual_scene_path
	) as PackedScene

	if visual_scene == null:
		push_error(
			"Failed to load local location visual scene: %s"
			% _definition.visual_scene_path
		)

		return false

	var instance := visual_scene.instantiate()

	if not instance is Node2D:
		push_error(
			"Local location visual scene root must be Node2D: %s"
			% _definition.visual_scene_path
		)

		instance.queue_free()

		return false

	_world_root = instance as Node2D

	_viewport.add_child(
		_world_root
	)

	if _bind_visual_stage_nodes():
		return true

	_viewport.remove_child(
		_world_root
	)

	_world_root.queue_free()

	_reset_visual_stage_references()

	return false


func _bind_visual_stage_nodes() -> bool:
	if _world_root == null:
		return false

	_far_background = (
		_world_root.get_node_or_null(
			"FarBackground"
		) as Parallax2D
	)

	_mid_background = (
		_world_root.get_node_or_null(
			"MidBackground"
		) as Parallax2D
	)

	_content_root = (
		_world_root.get_node_or_null(
			"WorldContent"
		) as Node2D
	)

	_foreground = (
		_world_root.get_node_or_null(
			"Foreground"
		) as Parallax2D
	)

	_interactions_root = (
		_world_root.get_node_or_null(
			"Interactions"
		) as Node2D
	)

	_camera = (
		_world_root.get_node_or_null(
			"Camera"
		) as Camera2D
	)

	if (
		_content_root == null
		or _interactions_root == null
		or _camera == null
	):
		push_error(
			"Local location visual scene is missing required nodes (WorldContent, Interactions, Camera): %s"
			% _definition.visual_scene_path
		)

		return false

	_discover_interaction_anchors()

	return true


func _discover_interaction_anchors() -> void:
	_anchors_by_interaction_id.clear()

	if _world_root == null:
		return

	var stack: Array[Node] = [_world_root]

	while not stack.is_empty():
		var current := stack.pop_back() as Node

		if current == null:
			continue

		if (
			current is Node2D
			and "interaction_id" in current
		):
			var id_value = current.get("interaction_id")

			if id_value is StringName and not (id_value as StringName).is_empty():
				_anchors_by_interaction_id[id_value] = current as Node2D

		for child in current.get_children():
			stack.push_back(child)


func _create_fallback_visual_stage() -> void:
	_world_root = Node2D.new()
	_world_root.name = "World"

	_viewport.add_child(
		_world_root
	)

	_far_background = Parallax2D.new()
	_far_background.name = "FarBackground"
	_far_background.scroll_scale = Vector2.ONE
	_far_background.z_index = -30

	_world_root.add_child(
		_far_background
	)

	_mid_background = Parallax2D.new()
	_mid_background.name = "MidBackground"
	_mid_background.scroll_scale = Vector2.ONE
	_mid_background.z_index = -20

	_world_root.add_child(
		_mid_background
	)

	_content_root = Node2D.new()
	_content_root.name = "WorldContent"
	_content_root.z_index = 0

	_world_root.add_child(
		_content_root
	)

	_foreground = Parallax2D.new()
	_foreground.name = "Foreground"
	_foreground.scroll_scale = Vector2.ONE
	_foreground.z_index = 20

	_world_root.add_child(
		_foreground
	)

	_interactions_root = Node2D.new()
	_interactions_root.name = "Interactions"
	_interactions_root.z_index = 100

	_world_root.add_child(
		_interactions_root
	)

	_camera = Camera2D.new()
	_camera.name = "Camera"

	_world_root.add_child(
		_camera
	)
	
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

		var authored_button := _get_authored_interaction_button(
			interaction.interaction_id
		)

		if authored_button != null:
			authored_button.tooltip_text = (
				interaction.description
			)

			authored_button.focus_mode = (
				Control.FOCUS_NONE
			)

			var pressed_callable := _on_interaction_pressed.bind(
				interaction.interaction_id
			)

			if not authored_button.pressed.is_connected(pressed_callable):
				authored_button.pressed.connect(pressed_callable)

			_buttons_by_interaction_id[
				interaction.interaction_id
			] = authored_button

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

		var target_pos := interaction.local_position

		if _anchors_by_interaction_id.has(interaction.interaction_id):
			var anchor := _anchors_by_interaction_id[interaction.interaction_id] as Node2D

			if anchor != null and is_instance_valid(anchor):
				target_pos = _interactions_root.to_local(anchor.global_position)

		button.position = (
			target_pos
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

		_interactions_root.add_child(
			button
		)

		_buttons_by_interaction_id[
			interaction.interaction_id
		] = button


func _get_authored_interaction_button(
	interaction_id: StringName
) -> Button:
	if not _anchors_by_interaction_id.has(interaction_id):
		return null

	var anchor := (
		_anchors_by_interaction_id[interaction_id]
		as Node2D
	)

	if anchor is LocalBuildSiteView:
		return (
			anchor as LocalBuildSiteView
		).get_interaction_button()

	return null


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

		var interaction_visible := true

		if _visibility_overrides.has(
			interaction.interaction_id
		):
			interaction_visible = bool(
				_visibility_overrides[
					interaction.interaction_id
				]
			)

		button.visible = interaction_visible

		if not interaction_visible:
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

	# With stretch enabled the container owns the viewport size.
	if not stretch:
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
	if _camera == null:
		return

	_camera.zoom = Vector2.ONE


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