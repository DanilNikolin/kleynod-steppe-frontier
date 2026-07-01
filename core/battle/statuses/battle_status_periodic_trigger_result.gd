class_name BattleStatusPeriodicTriggerResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var timing: int = (
	BattleStatusPeriodicTrigger
	.Timing
	.OWNER_TURN_END
)

var owner_id: StringName = &""
var status_id: StringName = &""
var status_display_name: String = ""

var effect_results: Array[BattleEffectResult] = []


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

	for effect_result in effect_results:
		if (
			effect_result == null
			or not effect_result.target_died
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