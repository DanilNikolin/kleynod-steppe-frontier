@tool
class_name BattleSlotResolver
extends Node2D

## Presentation contract: positions are always global world coordinates.
func has_slot(_coordinate: Vector2i) -> bool:
	return false


func get_slot_position(_coordinate: Vector2i) -> Vector2:
	push_error("BattleSlotResolver.get_slot_position must be implemented.")
	return Vector2.INF
