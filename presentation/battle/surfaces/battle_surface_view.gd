@tool
class_name BattleSurfaceView
extends BattleSlotVisual

## Only the explicit unknown-ID fallback uses the definition's debug tint.
@export var use_definition_tint: bool = false
var surface_instance: BattleSurfaceEffectInstance


func bind_surface(value: BattleSurfaceEffectInstance, slot: BattleSlotAnchor) -> void:
	surface_instance = value
	bind_anchor(slot)
	if use_definition_tint:
		modulate = value.definition.presentation_color
