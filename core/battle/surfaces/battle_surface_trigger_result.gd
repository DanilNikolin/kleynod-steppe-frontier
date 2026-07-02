class_name BattleSurfaceTriggerResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var surface_effect_id: StringName = &""
var surface_display_name: String = ""

var coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var timing: int = 0

var source_id: StringName = &""
var target_id: StringName = &""

var effect_results: Array[BattleEffectResult] = []

var stops_movement: bool = false
var was_consumed: bool = false
var target_died: bool = false