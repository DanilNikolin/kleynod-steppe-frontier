class_name BattleActionResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var ability_id: StringName = &""

var aim_coordinate: Vector2i = BattleGrid.INVALID_COORDINATE

var affected_coordinates: Array[Vector2i] = []
var affected_target_ids: Array[StringName] = []

var stamina_cost: int = 0
var stamina_spent: int = 0

var effect_results: Array[BattleEffectResult] = []


func get_primary_target_id() -> StringName:
	if affected_target_ids.is_empty():
		return &""

	return affected_target_ids[0]


func get_total_applied_amount(
	effect_kind: StringName = &""
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if effect_result == null:
			continue

		if (
			effect_kind != &""
			and effect_result.effect_kind
			!= effect_kind
		):
			continue

		total += effect_result.applied_amount

	return total

func get_forced_movement_results() -> Array[BattleEffectResult]:
	var result: Array[BattleEffectResult] = []

	for effect_result in effect_results:
		if (
			effect_result == null
			or not effect_result.is_successful
			or effect_result.effect_kind
			!= &"forced_movement"
		):
			continue

		result.append(effect_result)

	return result


func get_total_forced_movement_distance() -> int:
	var total: int = 0

	for effect_result in get_forced_movement_results():
		total += effect_result.applied_movement_distance

	return total


func did_target_die(
	target_id: StringName = &""
) -> bool:
	for effect_result in effect_results:
		if effect_result == null:
			continue

		if (
			target_id != &""
			and effect_result.target_id
			!= target_id
		):
			continue

		if effect_result.target_died:
			return true

	return false

func get_defeated_target_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for target_id in affected_target_ids:
		if target_id == &"":
			continue

		if did_target_die(target_id):
			result.append(target_id)

	return result


func get_affected_target_count() -> int:
	return affected_target_ids.size()