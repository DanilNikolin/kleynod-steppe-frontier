@tool
class_name CombatantView
extends Node2D


signal movement_finished


@export_group("Movement")

@export_range(0.01, 2.0, 0.01)
var movement_duration: float = 0.16


@export_group("Footprint")

@export
var show_footprint: bool = true:
	set(value):
		show_footprint = value
		queue_redraw()

@export_range(4.0, 100.0, 1.0)
var footprint_radius: float = 28.0:
	set(value):
		footprint_radius = maxf(4.0, value)
		queue_redraw()

@export
var footprint_color: Color = Color(0.0, 0.0, 0.0, 0.22):
	set(value):
		footprint_color = value
		queue_redraw()


@export_group("Selection")

@export
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()

@export
var hovered: bool = false:
	set(value):
		hovered = value
		queue_redraw()

@export
var selected_color: Color = Color(1.0, 0.84, 0.25, 0.95):
	set(value):
		selected_color = value
		queue_redraw()

@export
var hovered_color: Color = Color(0.75, 0.9, 1.0, 0.85):
	set(value):
		hovered_color = value
		queue_redraw()

@export_range(1.0, 12.0, 0.5)
var outline_width: float = 3.0:
	set(value):
		outline_width = maxf(1.0, value)
		queue_redraw()


@onready
var visual_container: Node2D = $VisualContainer

@onready
var status_strip: BattleStatusStrip = (
	$StatusAnchor/BattleStatusStrip
)

@onready
var hero_core_indicator_label: Label = (
	$HeroCoreAnchor/HeroCoreIndicatorLabel
)

@onready
var action_preview_badge: BattleActionPreviewBadge = (
	$IntentAnchor/BattleActionPreviewBadge
)

@onready
var name_label: Label = (
	$InterfaceRoot/VBoxContainer/NameLabel
)

@onready
var health_bar: ProgressBar = (
	$InterfaceRoot/VBoxContainer/HealthRow/HealthBar
)

@onready
var health_value_label: Label = (
	$InterfaceRoot/VBoxContainer/HealthRow/HealthValueLabel
)

@onready
var guard_bar: ProgressBar = (
	$InterfaceRoot/VBoxContainer/GuardRow/GuardBar
)

@onready
var guard_value_label: Label = (
	$InterfaceRoot/VBoxContainer/GuardRow/GuardValueLabel
)

@onready
var stamina_bar: ProgressBar = (
	$InterfaceRoot/VBoxContainer/StaminaRow/StaminaBar
)

@onready
var stamina_value_label: Label = (
	$InterfaceRoot/VBoxContainer/StaminaRow/StaminaValueLabel
)


var state: CombatantState
var visual: CombatantVisual

var _movement_tween: Tween


func _ready() -> void:
	if not Engine.is_editor_hint():
		status_strip.bind_state(
			state
		)

	queue_redraw()


func _draw() -> void:
	if show_footprint:
		draw_circle(
			Vector2.ZERO,
			footprint_radius,
			footprint_color,
			true
		)

	if hovered:
		draw_circle(
			Vector2.ZERO,
			footprint_radius,
			hovered_color,
			false,
			outline_width,
			true
		)

	if selected:
		draw_circle(
			Vector2.ZERO,
			footprint_radius + 3.0,
			selected_color,
			false,
			outline_width,
			true
		)


func bind_state(
	new_state: CombatantState
) -> void:
	if state == new_state:
		if is_node_ready() and not Engine.is_editor_hint():
			status_strip.bind_state(
				state
			)

		refresh_from_state()
		return

	_disconnect_state_signals()

	state = new_state

	_connect_state_signals()

	if is_node_ready() and not Engine.is_editor_hint():
		status_strip.bind_state(
			state
		)

	_rebuild_visual()
	refresh_from_state()


func _connect_state_signals() -> void:
	if state == null:
		return

	state.health_changed.connect(_on_health_changed)
	state.guard_changed.connect(_on_guard_changed)
	state.stamina_changed.connect(_on_stamina_changed)
	state.max_stamina_changed.connect(_on_max_stamina_changed)
	state.morale_changed.connect(_on_morale_changed)
	state.died.connect(_on_died)

	_connect_hero_core_signal()


func _disconnect_state_signals() -> void:
	if state == null:
		return

	if state.health_changed.is_connected(_on_health_changed):
		state.health_changed.disconnect(_on_health_changed)
	if state.guard_changed.is_connected(_on_guard_changed):
		state.guard_changed.disconnect(_on_guard_changed)
	if state.stamina_changed.is_connected(_on_stamina_changed):
		state.stamina_changed.disconnect(_on_stamina_changed)
	if state.max_stamina_changed.is_connected(_on_max_stamina_changed):
		state.max_stamina_changed.disconnect(_on_max_stamina_changed)
	if state.morale_changed.is_connected(_on_morale_changed):
		state.morale_changed.disconnect(_on_morale_changed)
	if state.died.is_connected(_on_died):
		state.died.disconnect(_on_died)

	_disconnect_hero_core_signal()

func _connect_hero_core_signal() -> void:
	if (
		state == null
		or state.hero_core_runtime_state == null
	):
		return

	var core: HeroCoreRuntimeState = (
		state.hero_core_runtime_state
	)

	var callback := Callable(
		self,
		"_on_hero_core_state_changed"
	)

	if core.is_connected(
		&"state_changed",
		callback
	):
		return

	core.connect(
		&"state_changed",
		callback
	)


func _disconnect_hero_core_signal() -> void:
	if (
		state == null
		or state.hero_core_runtime_state == null
	):
		return

	var core: HeroCoreRuntimeState = (
		state.hero_core_runtime_state
	)

	var callback := Callable(
		self,
		"_on_hero_core_state_changed"
	)

	if core.is_connected(
		&"state_changed",
		callback
	):
		core.disconnect(
			&"state_changed",
			callback
		)

func _rebuild_visual() -> void:
	if visual != null:
		visual.queue_free()
		visual = null

	if state == null:
		return

	var definition := state.definition

	if definition == null:
		return

	if definition.visual_scene == null:
		push_error(
			"Combatant '%s' has no visual scene."
			% state.instance_id
		)
		return

	var visual_instance := (
		definition.visual_scene.instantiate()
	)

	if not (visual_instance is CombatantVisual):
		push_error(
			"Visual scene for '%s' must inherit CombatantVisual."
			% state.instance_id
		)

		visual_instance.queue_free()
		return

	visual = visual_instance as CombatantVisual
	visual_container.add_child(visual)

	visual.modulate = definition.visual_tint
	visual.play_idle()


func refresh_from_state() -> void:
	if not is_node_ready():
		return

	if state == null:
		name_label.text = "No Combatant"
		hero_core_indicator_label.text = ""
		hero_core_indicator_label.visible = false

		health_bar.max_value = 1
		health_bar.value = 0
		health_value_label.text = "0 / 0"

		guard_bar.max_value = 1
		guard_bar.value = 0
		guard_value_label.text = "0 / 0"

		stamina_bar.max_value = 1
		stamina_bar.value = 0
		stamina_value_label.text = "0 / 0"

		return

	name_label.text = state.definition.display_name

	health_bar.max_value = state.max_health
	health_bar.value = state.current_health

	health_value_label.text = "%d / %d" % [
		state.current_health,
		state.max_health,
	]

	guard_bar.max_value = state.max_health
	guard_bar.value = state.current_guard

	guard_value_label.text = "%d / %d" % [
		state.current_guard,
		state.max_health,
	]

	stamina_bar.max_value = state.max_stamina
	stamina_bar.value = state.current_stamina

	stamina_value_label.text = "%d / %d" % [
		state.current_stamina,
		state.max_stamina,
	]
	_refresh_hero_core_indicator()

func _refresh_hero_core_indicator() -> void:
	if (
		state == null
		or state.hero_core_runtime_state == null
	):
		hero_core_indicator_label.text = ""
		hero_core_indicator_label.visible = false
		return

	var core: HeroCoreRuntimeState = (
		state.hero_core_runtime_state
	)

	var indicator_text := (
		core.get_battle_indicator_text()
	)

	hero_core_indicator_label.text = (
		indicator_text
	)

	hero_core_indicator_label.visible = (
		not indicator_text.is_empty()
	)

	hero_core_indicator_label.add_theme_color_override(
		"font_color",
		core.get_battle_indicator_color()
	)

func show_action_preview(
	text: String
) -> void:
	if action_preview_badge == null:
		return

	action_preview_badge.show_preview(
		text
	)


func clear_action_preview() -> void:
	if action_preview_badge == null:
		return

	action_preview_badge.clear_preview()


func set_selected_state(value: bool) -> void:
	selected = value


func set_hovered_state(value: bool) -> void:
	hovered = value


func set_facing_direction(direction: int) -> void:
	if visual != null:
		visual.set_facing_direction(direction)


func play_visual_animation(
	animation_key: StringName,
	fallback_key: StringName = &"idle",
	restart_if_same: bool = false
) -> bool:
	if visual == null:
		return false

	return visual.play_animation(
		animation_key,
		fallback_key,
		restart_if_same
	)


func snap_to_local_position(
	target_position: Vector2
) -> void:
	_stop_movement_tween()
	position = target_position


func move_to_local_position(
	target_position: Vector2,
	animated: bool = true
) -> void:
	var local_path: Array[Vector2] = [
		target_position
	]

	move_along_local_path(
		local_path,
		animated
	)


func move_along_local_path(
	local_path: Array[Vector2],
	animated: bool = true
) -> void:
	_stop_movement_tween()

	if local_path.is_empty():
		movement_finished.emit()
		return

	if not animated:
		for target_position in local_path:
			_face_toward_position(
				target_position
			)

			position = target_position

		movement_finished.emit()
		return

	if visual != null:
		visual.play_move()

	_movement_tween = create_tween()

	_movement_tween.set_trans(
		Tween.TRANS_QUAD
	)

	_movement_tween.set_ease(
		Tween.EASE_IN_OUT
	)

	for target_position in local_path:
		_movement_tween.tween_callback(
			Callable(
				self,
				"_face_toward_position"
			).bind(target_position)
		)

		_movement_tween.tween_property(
			self,
			"position",
			target_position,
			movement_duration
		)

	_movement_tween.finished.connect(
		_on_movement_tween_finished
	)


func _face_toward_position(
	target_position: Vector2
) -> void:
	var horizontal_distance := (
		target_position.x - position.x
	)

	if is_zero_approx(horizontal_distance):
		return

	set_facing_direction(
		1 if horizontal_distance > 0.0 else -1
	)


func _stop_movement_tween() -> void:
	if _movement_tween == null:
		return

	if _movement_tween.is_valid():
		_movement_tween.kill()

	_movement_tween = null


func _on_movement_tween_finished() -> void:
	_movement_tween = null

	if visual != null:
		visual.play_idle()

	movement_finished.emit()


func _on_health_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_guard_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_stamina_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_max_stamina_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_hero_core_state_changed() -> void:
	refresh_from_state()
	
func _on_morale_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh_from_state()


func _on_died() -> void:
	clear_action_preview()

	if visual != null:
		visual.play_death()

	refresh_from_state()