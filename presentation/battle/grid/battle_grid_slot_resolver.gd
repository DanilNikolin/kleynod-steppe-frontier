class_name BattleGridSlotResolver
extends BattleSlotResolver

## Compatibility adapter used only by the rectangular debug sandbox.
var grid_view: BattleGridView


func _init(p_grid_view: BattleGridView = null) -> void:
	grid_view = p_grid_view


func has_slot(coordinate: Vector2i) -> bool:
	return is_instance_valid(grid_view) and grid_view.is_valid_coordinate(coordinate)


func get_slot_position(coordinate: Vector2i) -> Vector2:
	return grid_view.to_global(grid_view.get_cell_center(coordinate))
