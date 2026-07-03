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


static func _build_plan_text(
	plan: BattleAIPlan
) -> String:
	if plan == null:
		return "null plan"

	var parts := PackedStringArray()

	if plan.is_wait():
		return (
			"ожидание · остаток %d"
			% plan.remaining_stamina
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

	parts.append(
		"цена %d"
		% plan.total_stamina_cost
	)

	parts.append(
		"остаток %d"
		% plan.remaining_stamina
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


static func _format_coordinate(
	coordinate: Vector2i
) -> String:
	return "(%d,%d)" % [
		coordinate.x,
		coordinate.y,
	]