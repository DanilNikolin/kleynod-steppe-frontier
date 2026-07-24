class_name HeroPersonalLoadoutChangeResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var ability_id: StringName = &""

var active_slot_count: int = 0

var previous_selected_ability_ids: Array[StringName] = []
var current_selected_ability_ids: Array[StringName] = []
