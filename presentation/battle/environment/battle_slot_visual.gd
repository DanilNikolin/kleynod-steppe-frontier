@tool
class_name BattleSlotVisual
extends Node2D

## Artwork is authored around the ground origin using these reference radii.
## The view follows the full anchor transform and its current interaction radii.
@export var design_radii: Vector2 = Vector2(60, 32)
var anchor: BattleSlotAnchor


func bind_anchor(value: BattleSlotAnchor) -> void:
	anchor = value
	sync_anchor()


func sync_anchor() -> void:
	if not is_instance_valid(anchor):
		return
	var ratio := anchor.interaction_radii / design_radii.max(Vector2.ONE)
	global_transform = anchor.global_transform * Transform2D(0, ratio, 0, Vector2.ZERO)


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		sync_anchor()
