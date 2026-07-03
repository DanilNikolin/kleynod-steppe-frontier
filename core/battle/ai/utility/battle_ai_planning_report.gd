class_name BattleAIPlanningReport
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""

var plans: Array[BattleAIPlan] = []

var rejected_candidate_count: int = 0
var rejection_counts: Dictionary = {}

## Начнёт использоваться после появления evaluator.
var selected_plan: BattleAIPlan


func add_plan(
	plan: BattleAIPlan
) -> bool:
	if plan == null or not plan.is_valid:
		return false

	plans.append(
		plan
	)

	return true


func add_rejection(
	reason: StringName
) -> void:
	var resolved_reason := reason

	if resolved_reason == &"":
		resolved_reason = &"unknown_rejection"

	rejected_candidate_count += 1

	var previous_count := int(
		rejection_counts.get(
			resolved_reason,
			0
		)
	)

	rejection_counts[
		resolved_reason
	] = previous_count + 1


func sort_plans() -> void:
	plans.sort_custom(
		Callable(
			self,
			"_is_plan_before"
		)
	)


func select_best_plan() -> void:
	selected_plan = null

	for plan in plans:
		if plan == null or not plan.is_valid:
			continue

		if (
			selected_plan == null
			or _is_plan_before(
				plan,
				selected_plan
			)
		):
			selected_plan = plan

func get_wait_plan_count() -> int:
	var result := 0

	for plan in plans:
		if plan != null and plan.is_wait():
			result += 1

	return result


func get_action_only_plan_count() -> int:
	var result := 0

	for plan in plans:
		if (
			plan != null
			and plan.has_action()
			and not plan.has_movement()
			and not plan.has_ally_swap()
		):
			result += 1

	return result


func get_movement_only_plan_count() -> int:
	var result := 0

	for plan in plans:
		if (
			plan != null
			and plan.has_movement()
			and not plan.has_action()
		):
			result += 1

	return result


func get_swap_only_plan_count() -> int:
	var result := 0

	for plan in plans:
		if (
			plan != null
			and plan.has_ally_swap()
			and not plan.has_action()
		):
			result += 1

	return result


func get_combined_plan_count() -> int:
	var result := 0

	for plan in plans:
		if (
			plan != null
			and plan.has_action()
			and (
				plan.has_movement()
				or plan.has_ally_swap()
			)
		):
			result += 1

	return result


func get_rejection_reasons() -> Array[StringName]:
	var result: Array[StringName] = []

	for value in rejection_counts.keys():
		var reason: StringName = value

		result.append(
			reason
		)

	result.sort_custom(
		Callable(
			self,
			"_is_rejection_reason_before"
		)
	)

	return result


func _is_plan_before(
	first: BattleAIPlan,
	second: BattleAIPlan
) -> bool:
	if first == null:
		return false

	if second == null:
		return true

	var first_score := first.get_score()
	var second_score := second.get_score()

	if not is_equal_approx(
		first_score,
		second_score
	):
		return first_score > second_score

	return (
		first.get_stable_sort_key()
		< second.get_stable_sort_key()
	)


func _is_rejection_reason_before(
	first: StringName,
	second: StringName
) -> bool:
	return String(first) < String(second)