class_name BattleTargetPreview
extends RefCounted


var target_id: StringName = &""
var display_name: String = ""

var initial_health: int = 0
var initial_guard: int = 0
var initial_position: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var normal_final_health: int = 0
var normal_final_guard: int = 0
var normal_final_position: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var critical_final_health: int = 0
var critical_final_guard: int = 0
var critical_final_position: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var normal_effect_results: Array[BattleEffectResult] = []

var critical_effect_results: Array[BattleEffectResult] = []


func has_damage_effect() -> bool:
	for effect_result in normal_effect_results:
		if (
			effect_result != null
			and effect_result.effect_kind
				== &"damage"
		):
			return true

	return false


func has_guaranteed_critical() -> bool:
	for effect_result in normal_effect_results:
		if (
			effect_result != null
			and effect_result
				.critical_was_guaranteed
		):
			return true

	return false


func get_standard_critical_chances() -> Array[int]:
	var result: Array[int] = []

	for effect_result in normal_effect_results:
		if effect_result == null:
			continue

		if (
			not effect_result
				.critical_was_enabled
			or effect_result
				.critical_was_guaranteed
			or effect_result
				.critical_chance_percent <= 0
		):
			continue

		var chance := (
			effect_result
			.critical_chance_percent
		)

		if not result.has(
			chance
		):
			result.append(
				chance
			)

	return result


func has_critical_alternative() -> bool:
	return (
		normal_final_health
			!= critical_final_health
		or normal_final_guard
			!= critical_final_guard
	)