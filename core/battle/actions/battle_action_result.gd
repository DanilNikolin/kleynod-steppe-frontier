class_name BattleActionResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var target_id: StringName = &""
var ability_id: StringName = &""

var stamina_cost: int = 0
var stamina_spent: int = 0

var effect_results: Array[BattleEffectResult] = []


func get_total_applied_amount(
	effect_kind: StringName = &""
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if effect_result == null:
			continue

		if (
			effect_kind != &""
			and effect_result.effect_kind != effect_kind
		):
			continue

		total += effect_result.applied_amount

	return total


func did_target_die() -> bool:
	for effect_result in effect_results:
		if (
			effect_result != null
			and effect_result.target_died
		):
			return true

	return false