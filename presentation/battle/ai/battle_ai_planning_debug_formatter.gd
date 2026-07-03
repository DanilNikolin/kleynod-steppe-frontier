class_name BattleAIPlanningDebugFormatter
extends RefCounted


static func build_report_text(
	report: BattleAIPlanningReport,
	actor: CombatantState,
	max_plan_lines: int = 6
) -> String:
	if report == null:
		return "Utility AI: planning report отсутствует."

	if not report.is_valid:
		return (
			"Utility AI: построение планов не удалось — %s."
			% report.failure_code
		)

	var actor_name := String(
		report.actor_id
	)

	if (
		actor != null
		and actor.definition != null
	):
		actor_name = (
			actor.definition.display_name
		)

	var lines := PackedStringArray()

	lines.append(
		"Utility AI scan · %s"
		% actor_name
	)

	lines.append(
		"Планов: %d · ожидание %d · действия %d · "
		% [
			report.plans.size(),
			report.get_wait_plan_count(),
			report.get_action_only_plan_count(),
		]
		+"движение %d · swap %d · комбинации %d · "
		% [
			report.get_movement_only_plan_count(),
			report.get_swap_only_plan_count(),
			report.get_combined_plan_count(),
		]
		+"отклонено %d"
		% report.rejected_candidate_count
	)

	if report.selected_plan != null:
		lines.append(
			"Лучший: %s"
			% _build_plan_text(
				report.selected_plan
			)
		)

		var score_text := (
			_build_score_breakdown_text(
				report.selected_plan
			)
		)

		if not score_text.is_empty():
			lines.append(
				"Score: %s"
				% score_text
			)

	var shown_count := mini(
		maxi(
			0,
			max_plan_lines
		),
		report.plans.size()
	)

	for plan_index in range(
		shown_count
	):
		var plan := report.plans[
			plan_index
		]

		lines.append(
			"%d. %s"
			% [
				plan_index + 1,
				_build_plan_text(
					plan
				),
			]
		)

	if report.plans.size() > shown_count:
		lines.append(
			"…ещё %d"
			% (
				report.plans.size()
				- shown_count
			)
		)

	var combined_plan := (
		_get_first_combined_plan(
			report
		)
	)

	if (
		combined_plan != null
		and not _is_plan_in_first_lines(
			report,
			combined_plan,
			shown_count
		)
	):
		lines.append(
			"Пример комбинации: %s"
			% _build_plan_text(
				combined_plan
			)
		)

	var rejection_text := (
		_build_rejection_text(
			report
		)
	)

	if not rejection_text.is_empty():
		lines.append(
			"Отказы: %s"
			% rejection_text
		)

	return "\n".join(
		lines
	)


static func _get_first_combined_plan(
	report: BattleAIPlanningReport
) -> BattleAIPlan:
	if report == null:
		return null

	for plan in report.plans:
		if (
			plan != null
			and plan.has_action()
			and (
				plan.has_movement()
				or plan.has_ally_swap()
			)
		):
			return plan

	return null


static func _is_plan_in_first_lines(
	report: BattleAIPlanningReport,
	target_plan: BattleAIPlan,
	shown_count: int
) -> bool:
	if (
		report == null
		or target_plan == null
	):
		return false

	var checked_count := mini(
		maxi(
			0,
			shown_count
		),
		report.plans.size()
	)

	for plan_index in range(
		checked_count
	):
		if (
			report.plans[plan_index]
			== target_plan
		):
			return true

	return false
    
static func _build_plan_text(
	plan: BattleAIPlan
) -> String:
	if plan == null:
		return "null plan"

	var parts := PackedStringArray()

	if plan.is_wait():
		parts.append(
			"ожидание"
		)

	if plan.has_movement():
		parts.append(
			"движение %s→%s"
			% [
				_format_coordinate(
					plan.origin_coordinate
				),
				_format_coordinate(
					plan.get_destination_coordinate()
				),
			]
		)

	if plan.has_ally_swap():
		parts.append(
			"swap с %s @ %s"
			% [
				plan.ally_swap_target_id,
				_format_coordinate(
					plan.ally_swap_target_coordinate
				),
			]
		)

	if plan.has_action():
		var ability_name := String(
			plan.ability.ability_id
		)

		if not plan.ability.display_name.is_empty():
			ability_name = (
				plan.ability.display_name
			)

		parts.append(
			"«%s» @ %s"
			% [
				ability_name,
				_format_coordinate(
					plan.aim_coordinate
				),
			]
		)

	var cost_parts := PackedStringArray()

	if plan.movement_stamina_cost > 0:
		cost_parts.append(
			"движение %d"
			% plan.movement_stamina_cost
		)

	if plan.ally_swap_stamina_cost > 0:
		cost_parts.append(
			"swap %d"
			% plan.ally_swap_stamina_cost
		)

	if plan.action_stamina_cost > 0:
		cost_parts.append(
			"действие %d"
			% plan.action_stamina_cost
		)

	if cost_parts.is_empty():
		cost_parts.append(
			"0"
		)

	parts.append(
		"цена %s = %d"
		% [
			" + ".join(cost_parts),
			plan.total_stamina_cost,
		]
	)

	parts.append(
		"остаток %d"
		% plan.remaining_stamina
	)

	_append_simulation_summary(
		parts,
		plan
	)

	_append_score_summary(
		parts,
		plan
	)

	return " · ".join(
		parts
	)


static func _build_rejection_text(
	report: BattleAIPlanningReport
) -> String:
	var parts := PackedStringArray()

	for reason in report.get_rejection_reasons():
		parts.append(
			"%s×%d"
			% [
				reason,
				int(
					report.rejection_counts[
						reason
					]
				),
			]
		)

	return ", ".join(
		parts
	)


static func _append_simulation_summary(
	parts: PackedStringArray,
	plan: BattleAIPlan
) -> void:
	if plan == null:
		return

	var simulation := (
		plan.simulation_result
	)

	if simulation == null:
		parts.append(
			"sim отсутствует"
		)

		return

	if not simulation.is_valid:
		parts.append(
			"sim отказ %s"
			% simulation.failure_code
		)

		return

	if simulation.movement_interrupted:
		parts.append(
			"движение прервано %s"
			% simulation
				.movement_interruption_reason
		)

		return

	if simulation.action_was_skipped:
		parts.append(
			"действие пропущено %s"
			% simulation.action_skip_reason
		)

		return

	if simulation.action_was_attempted:
		if simulation.action_result == null:
			parts.append(
				"действие без результата"
			)

			return

		if not simulation.action_result.is_successful:
			parts.append(
				"действие отказ %s"
				% simulation
					.action_result
					.failure_code
			)

			return

	parts.append(
		"sim ✓"
	)

static func _append_score_summary(
	parts: PackedStringArray,
	plan: BattleAIPlan
) -> void:
	if plan == null:
		return

	parts.append(
		"score %.1f"
		% plan.get_score()
	)


static func _build_score_breakdown_text(
	plan: BattleAIPlan
) -> String:
	if (
		plan == null
		or plan.score_breakdown == null
	):
		return ""

	var component_ids := (
		plan.score_breakdown
			.get_component_ids()
	)

	if component_ids.is_empty():
		return "0"

	var parts := PackedStringArray()

	for component_id in component_ids:
		var value := (
			plan.score_breakdown
				.get_score(
					component_id
				)
		)

		var sign := ""

		if value > 0.0:
			sign = "+"

		parts.append(
			"%s %s%.1f"
			% [
				String(component_id),
				sign,
				value,
			]
		)

	return ", ".join(
		parts
	)
	
static func _format_coordinate(
	coordinate: Vector2i
) -> String:
	return "(%d,%d)" % [
		coordinate.x,
		coordinate.y,
	]