class_name SkillGridGraphView
extends Control


signal node_selected(node_id: StringName)


const NODE_SIZE := Vector2(
	150.0,
	64.0
)

const MINIMUM_CANVAS_SIZE := Vector2(
	850.0,
	760.0
)

const STATE_PURCHASED: StringName = &"purchased"
const STATE_AVAILABLE: StringName = &"available"
const STATE_LOCKED: StringName = &"locked"
const STATE_PREVIEW: StringName = &"preview"


var grid: SkillGridDefinition
var block: SkillGridBlockDefinition
var progression: HeroProgressionState

var selected_node_id: StringName = &""
var preview_mode: bool = false

var purchase_service := (
	SkillGridPurchaseService.new()
)


func bind(
	p_grid: SkillGridDefinition,
	p_block: SkillGridBlockDefinition,
	p_progression: HeroProgressionState,
	p_preview_mode: bool = false
) -> void:
	grid = p_grid
	block = p_block
	progression = p_progression
	preview_mode = p_preview_mode

	custom_minimum_size = MINIMUM_CANVAS_SIZE

	_rebuild_nodes()


func set_selected_node_id(
	node_id: StringName
) -> void:
	selected_node_id = node_id

	_refresh_button_styles()

	queue_redraw()


func _rebuild_nodes() -> void:
	_clear_children()

	if (
		grid == null
		or block == null
		or progression == null
	):
		queue_redraw()
		return

	for node in grid.get_nodes_for_block(
		block.block_id
	):
		if node == null:
			continue

		var button := _create_node_button(
			node
		)

		button.position = (
			node.ui_position
			- NODE_SIZE * 0.5
		)

		add_child(
			button
		)

	queue_redraw()


func _create_node_button(
	node: SkillGridNodeDefinition
) -> Button:
	var button := Button.new()

	button.name = (
		"Node_%s"
		% String(node.node_id)
	)

	button.custom_minimum_size = NODE_SIZE
	button.size = NODE_SIZE

	button.text = node.display_name

	button.tooltip_text = node.description

	button.focus_mode = (
		Control.FOCUS_ALL
	)

	button.disabled = preview_mode

	if preview_mode:
		button.focus_mode = Control.FOCUS_NONE

	button.pressed.connect(
		_on_node_button_pressed.bind(
			node.node_id
		)
	)

	button.set_meta(
		"skill_grid_node_id",
		node.node_id
	)

	_apply_node_button_style(
		button,
		node
	)

	return button


func _apply_node_button_style(
	button: Button,
	node: SkillGridNodeDefinition
) -> void:
	var state := _get_node_state(
		node
	)

	var background_color := Color(
		0.12,
		0.13,
		0.15,
		1.0
	)

	var border_color := Color(
		0.31,
		0.33,
		0.36,
		1.0
	)

	var font_color := Color(
		0.62,
		0.64,
		0.67,
		1.0
	)

	match state:
		STATE_PURCHASED:
			background_color = Color(
				0.24,
				0.20,
				0.09,
				1.0
			)

			border_color = Color(
				0.93,
				0.73,
				0.24,
				1.0
			)

			font_color = Color(
				1.0,
				0.93,
				0.70,
				1.0
			)

		STATE_AVAILABLE:
			background_color = Color(
				0.12,
				0.23,
				0.16,
				1.0
			)

			border_color = Color(
				0.34,
				0.78,
				0.47,
				1.0
			)

			font_color = Color(
				0.86,
				1.0,
				0.89,
				1.0
			)

		STATE_PREVIEW:
			background_color = Color(
				0.10,
				0.13,
				0.18,
				1.0
			)

			border_color = Color(
				0.35,
				0.48,
				0.65,
				1.0
			)

			font_color = Color(
				0.72,
				0.80,
				0.90,
				1.0
			)

		STATE_LOCKED:
			pass

	var border_width := 2

	if (
		not preview_mode
		and node.node_id == selected_node_id
	):
		border_color = Color(
			0.92,
			0.92,
			0.92,
			1.0
		)

		border_width = 4

	var normal_style := _create_button_style(
		background_color,
		border_color,
		border_width
	)

	var hover_style := _create_button_style(
		background_color.lightened(
			0.08
		),
		border_color.lightened(
			0.08
		),
		border_width
	)

	var pressed_style := _create_button_style(
		background_color.darkened(
			0.08
		),
		border_color,
		border_width
	)

	button.add_theme_stylebox_override(
		"normal",
		normal_style
	)

	button.add_theme_stylebox_override(
		"hover",
		hover_style
	)

	button.add_theme_stylebox_override(
		"pressed",
		pressed_style
	)

	button.add_theme_stylebox_override(
		"focus",
		normal_style
	)

	button.add_theme_stylebox_override(
		"disabled",
		normal_style
	)

	button.add_theme_color_override(
		"font_color",
		font_color
	)

	button.add_theme_color_override(
		"font_hover_color",
		font_color
	)

	button.add_theme_color_override(
		"font_pressed_color",
		font_color
	)

	button.add_theme_color_override(
		"font_disabled_color",
		font_color
	)

	button.add_theme_font_size_override(
		"font_size",
		14
	)


func _create_button_style(
	background_color: Color,
	border_color: Color,
	border_width: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()

	style.bg_color = background_color

	style.border_color = border_color

	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width

	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10

	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0

	return style


func _get_node_state(
	node: SkillGridNodeDefinition
) -> StringName:
	if preview_mode:
		return STATE_PREVIEW

	if (
		progression != null
		and progression.purchased_node_ids.has(
			node.node_id
		)
	):
		return STATE_PURCHASED

	if (
		grid != null
		and progression != null
		and purchase_service.can_purchase(
			grid,
			progression,
			node.node_id
		)
	):
		return STATE_AVAILABLE

	return STATE_LOCKED


func _refresh_button_styles() -> void:
	if grid == null:
		return

	for child in get_children():
		var button := child as Button

		if button == null:
			continue

		if not button.has_meta(
			"skill_grid_node_id"
		):
			continue

		var node_id: StringName = (
			button.get_meta(
				"skill_grid_node_id"
			)
		)

		var node := grid.get_node_definition(
			node_id
		)

		if node == null:
			continue

		_apply_node_button_style(
			button,
			node
		)


func _draw() -> void:
	if (
		grid == null
		or block == null
		or progression == null
	):
		return

	for node in grid.get_nodes_for_block(
		block.block_id
	):
		if node == null:
			continue

		for parent_id in (
			node.path_parent_node_ids
		):
			var parent := (
				grid.get_node_definition(
					parent_id
				)
			)

			if parent == null:
				continue

			draw_line(
				parent.ui_position,
				node.ui_position,
				_get_path_color(
					parent.node_id,
					node.node_id
				),
				4.0,
				true
			)

	for entry_id in block.entry_node_ids:
		var entry_node := (
			grid.get_node_definition(
				entry_id
			)
		)

		if entry_node == null:
			continue

		draw_line(
			Vector2(
				24.0,
				entry_node.ui_position.y
			),
			entry_node.ui_position,
			_get_entry_path_color(
				entry_node
			),
			4.0,
			true
		)

	for exit_id in block.exit_anchor_node_ids:
		var exit_node := (
			grid.get_node_definition(
				exit_id
			)
		)

		if exit_node == null:
			continue

		draw_line(
			exit_node.ui_position,
			Vector2(
				size.x - 24.0,
				exit_node.ui_position.y
			),
			_get_exit_path_color(
				exit_node
			),
			4.0,
			true
		)


func _get_path_color(
	parent_id: StringName,
	child_id: StringName
) -> Color:
	if preview_mode:
		return Color(
			0.35,
			0.48,
			0.65,
			0.75
		)

	if progression.purchased_node_ids.has(
		child_id
	):
		return Color(
			0.93,
			0.73,
			0.24,
			1.0
		)

	if progression.purchased_node_ids.has(
		parent_id
	):
		return Color(
			0.34,
			0.78,
			0.47,
			1.0
		)

	return Color(
		0.25,
		0.27,
		0.30,
		1.0
	)


func _get_entry_path_color(
	entry_node: SkillGridNodeDefinition
) -> Color:
	if preview_mode:
		return Color(
			0.35,
			0.48,
			0.65,
			0.75
		)

	if progression.purchased_node_ids.has(
		entry_node.node_id
	):
		return Color(
			0.93,
			0.73,
			0.24,
			1.0
		)

	if purchase_service.can_purchase(
		grid,
		progression,
		entry_node.node_id
	):
		return Color(
			0.34,
			0.78,
			0.47,
			1.0
		)

	return Color(
		0.25,
		0.27,
		0.30,
		1.0
	)


func _get_exit_path_color(
	exit_node: SkillGridNodeDefinition
) -> Color:
	if preview_mode:
		return Color(
			0.35,
			0.48,
			0.65,
			0.75
		)

	if progression.purchased_node_ids.has(
		exit_node.node_id
	):
		return Color(
			0.93,
			0.73,
			0.24,
			1.0
		)

	return Color(
		0.25,
		0.27,
		0.30,
		1.0
	)


func _on_node_button_pressed(
	node_id: StringName
) -> void:
	if preview_mode:
		return

	node_selected.emit(
		node_id
	)


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()