@tool
class_name BattleTooltipFrame
extends Control

@export_range(0.0, 1.0, 0.05)
var background_alpha: float = 0.82:
	set(value):
		background_alpha = value
		_update_background_alpha()

@export_range(0.25, 1.0, 0.05)
var frame_scale: float = 0.55:
	set(value):
		frame_scale = value
		queue_layout()

@onready var background: TextureRect = $Background
@onready var edge_top: TextureRect = $EdgeTop
@onready var edge_bottom: TextureRect = $EdgeBottom
@onready var edge_left: TextureRect = $EdgeLeft
@onready var edge_right: TextureRect = $EdgeRight
@onready var corner_top_left: TextureRect = $CornerTopLeft
@onready var corner_top_right: TextureRect = $CornerTopRight
@onready var corner_bottom_left: TextureRect = $CornerBottomLeft
@onready var corner_bottom_right: TextureRect = $CornerBottomRight

const OVERLAP: float = 2.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_background_alpha()
	queue_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_layout()

func _update_background_alpha() -> void:
	if background != null:
		background.modulate.a = background_alpha

func queue_layout() -> void:
	_layout_frame()

func _layout_frame() -> void:
	if not is_inside_tree() or corner_top_left == null or corner_top_left.texture == null:
		return

	var w: float = size.x
	var h: float = size.y

	# Background fills full rect
	if background != null:
		background.position = Vector2.ZERO
		background.size = Vector2(w, h)
		background.modulate.a = background_alpha

	# Corners size
	var c_tl_size: Vector2 = corner_top_left.texture.get_size() * frame_scale
	var c_tr_size: Vector2 = corner_top_right.texture.get_size() * frame_scale
	var c_bl_size: Vector2 = corner_bottom_left.texture.get_size() * frame_scale
	var c_br_size: Vector2 = corner_bottom_right.texture.get_size() * frame_scale

	corner_top_left.size = c_tl_size
	corner_top_left.position = Vector2.ZERO

	corner_top_right.size = c_tr_size
	corner_top_right.position = Vector2(w - c_tr_size.x, 0.0)

	corner_bottom_left.size = c_bl_size
	corner_bottom_left.position = Vector2(0.0, h - c_bl_size.y)

	corner_bottom_right.size = c_br_size
	corner_bottom_right.position = Vector2(w - c_br_size.x, h - c_br_size.y)

	# Horizontal edges: stretch between corners horizontally
	# thickness is texture height * frame_scale
	if edge_top != null and edge_top.texture != null:
		var top_thick: float = edge_top.texture.get_size().y * frame_scale
		var top_x_start: float = c_tl_size.x - OVERLAP
		var top_x_end: float = w - c_tr_size.x + OVERLAP
		edge_top.position = Vector2(top_x_start, 0.0)
		edge_top.size = Vector2(maxf(0.0, top_x_end - top_x_start), top_thick)

	if edge_bottom != null and edge_bottom.texture != null:
		var bottom_thick: float = edge_bottom.texture.get_size().y * frame_scale
		var bottom_x_start: float = c_bl_size.x - OVERLAP
		var bottom_x_end: float = w - c_br_size.x + OVERLAP
		edge_bottom.position = Vector2(bottom_x_start, h - bottom_thick)
		edge_bottom.size = Vector2(maxf(0.0, bottom_x_end - bottom_x_start), bottom_thick)

	# Vertical edges: stretch between corners vertically
	# thickness is texture width * frame_scale
	if edge_left != null and edge_left.texture != null:
		var left_thick: float = edge_left.texture.get_size().x * frame_scale
		var left_y_start: float = c_tl_size.y - OVERLAP
		var left_y_end: float = h - c_bl_size.y + OVERLAP
		edge_left.position = Vector2(0.0, left_y_start)
		edge_left.size = Vector2(left_thick, maxf(0.0, left_y_end - left_y_start))

	if edge_right != null and edge_right.texture != null:
		var right_thick: float = edge_right.texture.get_size().x * frame_scale
		var right_y_start: float = c_tr_size.y - OVERLAP
		var right_y_end: float = h - c_br_size.y + OVERLAP
		edge_right.position = Vector2(w - right_thick, right_y_start)
		edge_right.size = Vector2(right_thick, maxf(0.0, right_y_end - right_y_start))
