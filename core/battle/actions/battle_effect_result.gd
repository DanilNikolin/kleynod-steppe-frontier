class_name BattleEffectResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var effect_id: StringName = &""
var effect_kind: StringName = &""

var source_id: StringName = &""
var target_id: StringName = &""

var raw_amount: int = 0
var mitigated_amount: int = 0
var resolved_amount: int = 0
var applied_amount: int = 0

var previous_value: int = 0
var current_value: int = 0

var target_died: bool = false