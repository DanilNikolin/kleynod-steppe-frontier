class_name BattleAIScoreBreakdown
extends RefCounted


var _scores_by_id: Dictionary = {}


func clear() -> void:
	_scores_by_id.clear()


func set_score(
	component_id: StringName,
	value: float
) -> void:
	if component_id == &"":
		return

	if is_zero_approx(value):
		_scores_by_id.erase(
			component_id
		)

		return

	_scores_by_id[
		component_id
	] = value


func add_score(
	component_id: StringName,
	value: float
) -> void:
	if (
		component_id == &""
		or is_zero_approx(value)
	):
		return

	set_score(
		component_id,
		get_score(component_id) + value
	)


func get_score(
	component_id: StringName
) -> float:
	if not _scores_by_id.has(
		component_id
	):
		return 0.0

	return float(
		_scores_by_id[
			component_id
		]
	)


func has_score(
	component_id: StringName
) -> bool:
	return _scores_by_id.has(
		component_id
	)


func get_total_score() -> float:
	var result := 0.0

	for value in _scores_by_id.values():
		result += float(value)

	return result


func get_component_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for value in _scores_by_id.keys():
		var component_id: StringName = value

		result.append(
			component_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_component_id_before"
		)
	)

	return result


func duplicate_breakdown() -> BattleAIScoreBreakdown:
	var result := BattleAIScoreBreakdown.new()

	for component_id in get_component_ids():
		result.set_score(
			component_id,
			get_score(component_id)
		)

	return result


func _is_component_id_before(
	first: StringName,
	second: StringName
) -> bool:
	return String(first) < String(second)