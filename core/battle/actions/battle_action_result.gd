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

var cooldown_started: bool = false
var cooldown_turns: int = 0

var effect_results: Array[BattleEffectResult] = []
var reaction_results: Array[BattleActionReactionResult] = []

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


func get_relocation_results() -> Array[BattleEffectResult]:
	var result: Array[BattleEffectResult] = []

	for effect_result in effect_results:
		if (
			effect_result == null
			or not effect_result.is_successful
		):
			continue

		if (
			effect_result.effect_kind
			!= &"swap_positions"
			and effect_result.effect_kind
			!= &"teleport"
		):
			continue

		result.append(
			effect_result
		)

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

		if target_id == &"":
			if (
				effect_result.target_died
				or not effect_result
					.relocation_defeated_ids
					.is_empty()
			):
				return true

			continue

		if (
			effect_result.target_id == target_id
			and effect_result.target_died
		):
			return true

		if effect_result.relocation_defeated_ids.has(
			target_id
		):
			return true

	return false

func get_defeated_target_ids() -> Array[StringName]:
	var candidate_ids: Array[StringName] = []

	for target_id in affected_target_ids:
		if (
			target_id != &""
			and not candidate_ids.has(
				target_id
			)
		):
			candidate_ids.append(
				target_id
			)

	for effect_result in effect_results:
		if effect_result == null:
			continue

		for defeated_id in (
			effect_result
			.relocation_defeated_ids
		):
			if (
				defeated_id != &""
				and not candidate_ids.has(
					defeated_id
				)
			):
				candidate_ids.append(
					defeated_id
				)

	var result: Array[StringName] = []

	for candidate_id in candidate_ids:
		if did_target_die(
			candidate_id
		):
			result.append(
				candidate_id
			)

	return result


func get_affected_target_count() -> int:
	return affected_target_ids.size()