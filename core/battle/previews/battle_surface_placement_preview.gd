class_name BattleSurfacePlacementPreview
extends RefCounted


var coordinate: Vector2i = BattleGrid.INVALID_COORDINATE

var surface_effect_id: StringName = &""
var surface_display_name: String = ""

var can_place: bool = false
var failure_code: StringName = &""

var will_add: bool = false
var will_update: bool = false

var previous_is_permanent: bool = false
var previous_remaining_rounds: int = 0

var final_is_permanent: bool = false
var final_remaining_rounds: int = 0

var presentation_color: Color = Color.WHITE