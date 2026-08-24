class_name BattleActionSimulationResult
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""

## Полностью независимая копия боя после simulation.
var simulated_session: BattleSession

var initial_actor_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var final_actor_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

## Snapshot поверхностей на начальной клетке актёра
## ДО dry movement/action.
## Нужен AI evaluator-у, чтобы surface_escape не считал
## поверхность, созданную самим же действием в simulation.
var initial_actor_surface_definitions: Array[BattleSurfaceEffectDefinition] = []

var initial_actor_surface_source_team_ids: Array[StringName] = []

var initial_stamina: int = 0
var final_stamina: int = 0
var total_stamina_spent: int = 0


## Обычное перемещение.

var movement_was_requested: bool = false

var movement_origin: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var movement_requested_destination: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var movement_applied_path: Array[Vector2i] = []

var movement_stamina_spent: int = 0

var movement_completed: bool = false
var movement_interrupted: bool = false

var movement_interruption_reason: StringName = &""

var movement_surface_results: Array[BattleSurfaceTriggerResult] = []


## Обычный ally swap.

var ally_swap_result: BattleRelocationResult


## Способность.

var action_was_requested: bool = false
var action_was_attempted: bool = false
var action_was_skipped: bool = false

var action_skip_reason: StringName = &""

var action_result: BattleActionResult


func get_simulated_combatant(
	combatant_id: StringName
) -> CombatantState:
	if (
		simulated_session == null
		or combatant_id == &""
	):
		return null

	return simulated_session.get_combatant(
		combatant_id
	)


func get_simulated_actor() -> CombatantState:
	return get_simulated_combatant(
		actor_id
	)


func get_all_surface_trigger_results() -> Array[BattleSurfaceTriggerResult]:
	var result: Array[BattleSurfaceTriggerResult] = []

	for trigger_result in movement_surface_results:
		if trigger_result != null:
			result.append(
				trigger_result
			)

	if ally_swap_result != null:
		for trigger_result in (
			ally_swap_result
				.get_all_surface_results()
		):
			if trigger_result != null:
				result.append(
					trigger_result
				)

	return result


func get_all_effect_results() -> Array[BattleEffectResult]:
	var result: Array[BattleEffectResult] = []

	## Эффекты поверхностей, сработавших
	## во время обычного движения / swap.
	for trigger_result in (
		get_all_surface_trigger_results()
	):
		if trigger_result == null:
			continue

		for effect_result in (
			trigger_result.effect_results
		):
			_append_effect_result_tree(
				result,
				effect_result
			)

	if action_result == null:
		return result

	## Прямые эффекты выполненной способности.
	for effect_result in (
		action_result.effect_results
	):
		_append_effect_result_tree(
			result,
			effect_result
		)

	## Реакции, вызванные выполненным действием:
	## контратаки, восстановление Guard/Stamina,
	## debuff атакующего и любые будущие
	## универсальные реактивные эффекты.
	for reaction_result in (
		action_result.reaction_results
	):
		if (
			reaction_result == null
			or not reaction_result.is_successful
		):
			continue

		for effect_result in (
			reaction_result.effect_results
		):
			_append_effect_result_tree(
				result,
				effect_result
			)

	return result


func _append_effect_result_tree(
	result: Array[BattleEffectResult],
	effect_result: BattleEffectResult
) -> void:
	if effect_result == null:
		return

	result.append(
		effect_result
	)

	## Effect может сам вызвать поверхность,
	## а её эффект — следующую поверхность.
	## Собираем всё дерево последствий,
	## а не только один уровень.
	for trigger_result in (
		effect_result.surface_trigger_results
	):
		if trigger_result == null:
			continue

		for nested_effect_result in (
			trigger_result.effect_results
		):
			_append_effect_result_tree(
				result,
				nested_effect_result
			)