@tool
class_name BattleArenaLayout
extends BattleSlotResolver

## Editor validation defaults only. Runtime validation receives the actual model grid.
@export var preview_grid_size: Vector2i = Vector2i(6, 3):
	set(value):
		preview_grid_size = value
		update_configuration_warnings()

## Preview coloring only, not a gameplay side rule.
@export var preview_divider_column: int = 3:
	set(value):
		preview_divider_column = value
		_redraw_anchors()

@export var debug_preview: bool = false:
	set(value):
		debug_preview = value
		_redraw_anchors()


func _ready() -> void:
	child_entered_tree.connect(_on_child_changed)
	child_exiting_tree.connect(_on_child_changed)
	update_configuration_warnings()


func _on_child_changed(_child: Node) -> void:
	update_configuration_warnings.call_deferred()


func _redraw_anchors() -> void:
	for anchor in get_anchors():
		anchor.queue_redraw()


func get_anchors() -> Array[BattleSlotAnchor]:
	var anchors: Array[BattleSlotAnchor] = []
	for child in get_children():
		if child is BattleSlotAnchor:
			anchors.append(child)
	return anchors


## No position cache: dragging an anchor immediately affects resolution and picking.
func get_slot_anchor(coordinate: Vector2i) -> BattleSlotAnchor:
	var result: BattleSlotAnchor
	for anchor in get_anchors():
		if anchor.coordinate == coordinate:
			if result != null:
				return null
			result = anchor
	return result


func has_slot(coordinate: Vector2i) -> bool:
	return get_slot_anchor(coordinate) != null


func get_slot_position(coordinate: Vector2i) -> Vector2:
	var anchor := get_slot_anchor(coordinate)
	if anchor == null:
		push_error("ArenaLayout '%s': missing or duplicated slot %s." % [name, coordinate])
		return Vector2.INF
	return anchor.global_position


func get_validation_errors(grid_size: Vector2i) -> PackedStringArray:
	var errors := PackedStringArray()
	if grid_size.x <= 0 or grid_size.y <= 0:
		errors.append("ArenaLayout '%s': invalid encounter grid size %s." % [name, grid_size])
		return errors
	var seen: Dictionary = {}
	for anchor in get_anchors():
		var coordinate := anchor.coordinate
		if seen.has(coordinate):
			errors.append("ArenaLayout '%s': duplicate coordinate %s on '%s' and '%s'." %
				[name, coordinate, seen[coordinate], anchor.name])
		else:
			seen[coordinate] = anchor.name
		if coordinate.x < 0 or coordinate.y < 0 or coordinate.x >= grid_size.x or coordinate.y >= grid_size.y:
			errors.append("ArenaLayout '%s': anchor '%s' coordinate %s outside encounter bounds %s." %
				[name, anchor.name, coordinate, grid_size])
	for row in range(grid_size.y):
		for column in range(grid_size.x):
			var coordinate := Vector2i(column, row)
			if not seen.has(coordinate):
				errors.append("ArenaLayout '%s': missing required coordinate %s." % [name, coordinate])
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return get_validation_errors(preview_grid_size)


## Overlap policy: nearest ground contact; equal distances prefer the deeper slot.
func pick_slot(world_position: Vector2) -> BattleSlotAnchor:
	var picked: BattleSlotAnchor
	var best_distance := INF
	for anchor in get_anchors():
		if not anchor.is_visible_in_tree() or not anchor.contains_world_position(world_position):
			continue
		var distance := anchor.global_position.distance_squared_to(world_position)
		if distance < best_distance or (is_equal_approx(distance, best_distance)
				and picked != null and anchor.global_position.y > picked.global_position.y):
			picked = anchor
			best_distance = distance
	return picked
