class_name CollapsiblePanelController
extends Node


signal collapsed_changed(
	is_collapsed: bool
)


enum FixedEdge {
	TOP,
	BOTTOM,
}


@export_group("Nodes")

@export
var target_control_path: NodePath

@export
var content_control_path: NodePath

@export
var toggle_button_path: NodePath


@export_group("Collapse")

@export
var fixed_edge: FixedEdge = FixedEdge.TOP

@export_range(24.0, 200.0, 1.0)
var collapsed_height: float = 48.0

@export
var starts_collapsed: bool = false


@export_group("Button")

@export
var expanded_button_text: String = "−"

@export
var collapsed_button_text: String = "+"


var is_collapsed: bool = false


var _target_control: Control
var _content_control: CanvasItem
var _toggle_button: Button

var _expanded_offset_top: float = 0.0
var _expanded_offset_bottom: float = 0.0

var _is_initialized: bool = false


func _ready() -> void:
	_target_control = get_node_or_null(
		target_control_path
	) as Control

	_content_control = get_node_or_null(
		content_control_path
	) as CanvasItem

	_toggle_button = get_node_or_null(
		toggle_button_path
	) as Button

	if not _validate_nodes():
		return

	_expanded_offset_top = (
		_target_control.offset_top
	)

	_expanded_offset_bottom = (
		_target_control.offset_bottom
	)

	var toggle_callback := Callable(
		self,
		"_on_toggle_button_pressed"
	)

	if not _toggle_button.pressed.is_connected(
		toggle_callback
	):
		_toggle_button.pressed.connect(
			toggle_callback
		)

	_is_initialized = true

	set_collapsed(
		starts_collapsed,
		true
	)


func set_collapsed(
	collapsed: bool,
	force_refresh: bool = false
) -> void:
	if not _is_initialized:
		return

	if (
		is_collapsed == collapsed
		and not force_refresh
	):
		return

	is_collapsed = collapsed

	_content_control.visible = (
		not is_collapsed
	)

	if is_collapsed:
		_apply_collapsed_size()

	else:
		_restore_expanded_size()

	_refresh_toggle_button()

	collapsed_changed.emit(
		is_collapsed
	)


func toggle_collapsed() -> void:
	set_collapsed(
		not is_collapsed
	)


func _apply_collapsed_size() -> void:
	match fixed_edge:
		FixedEdge.TOP:
			_target_control.offset_top = (
				_expanded_offset_top
			)

			_target_control.offset_bottom = (
				_expanded_offset_top
				+ collapsed_height
			)

		FixedEdge.BOTTOM:
			_target_control.offset_top = (
				_expanded_offset_bottom
				- collapsed_height
			)

			_target_control.offset_bottom = (
				_expanded_offset_bottom
			)


func _restore_expanded_size() -> void:
	_target_control.offset_top = (
		_expanded_offset_top
	)

	_target_control.offset_bottom = (
		_expanded_offset_bottom
	)


func _refresh_toggle_button() -> void:
	_toggle_button.text = (
		collapsed_button_text
		if is_collapsed
		else expanded_button_text
	)

	_toggle_button.tooltip_text = (
		"Развернуть"
		if is_collapsed
		else "Свернуть"
	)


func _validate_nodes() -> bool:
	if _target_control == null:
		push_error(
			"CollapsiblePanelController could not "
			+"find its target Control."
		)

		return false

	if _content_control == null:
		push_error(
			"CollapsiblePanelController could not "
			+"find its content CanvasItem."
		)

		return false

	if _toggle_button == null:
		push_error(
			"CollapsiblePanelController could not "
			+"find its toggle Button."
		)

		return false

	return true


func _on_toggle_button_pressed() -> void:
	toggle_collapsed()