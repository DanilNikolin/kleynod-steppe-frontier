class_name BattleActionReactionResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var reactor_id: StringName = &""
var triggering_actor_id: StringName = &""

var status_id: StringName = &""
var status_display_name: String = ""

var effect_results: Array[BattleEffectResult] = []

var status_consumed: bool = false

func get_affected_target_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for effect_result in effect_results:
		if (
			effect_result == null
			or not effect_result.is_successful
			or effect_result.target_id == &""
		):
			continue

		if result.has(
			effect_result.target_id
		):
			continue

		result.append(
			effect_result.target_id
		)

	return result


func get_defeated_target_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for effect_result in effect_results:
		if effect_result == null:
			continue

		if (
			effect_result.target_died
			and effect_result.target_id != &""
			and not result.has(
				effect_result.target_id
			)
		):
			result.append(
				effect_result.target_id
			)

		for defeated_id in (
			effect_result.relocation_defeated_ids
		):
			if (
				defeated_id == &""
				or result.has(defeated_id)
			):
				continue

			result.append(
				defeated_id
			)

	return result