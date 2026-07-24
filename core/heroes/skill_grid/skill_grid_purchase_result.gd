class_name SkillGridPurchaseResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var node_id: StringName = &""

var spent_skill_points: int = 0
var previous_unspent_skill_points: int = 0
var current_unspent_skill_points: int = 0

var missing_prerequisite_node_ids: Array[StringName] = []
