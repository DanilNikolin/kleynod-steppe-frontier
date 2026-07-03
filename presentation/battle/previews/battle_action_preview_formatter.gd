class_name BattleActionPreviewFormatter
extends RefCounted


static func build_surface_placement_text(
	preview: BattleSurfacePlacementPreview
) -> String:
	if preview == null:
		return ""

	if not preview.can_place:
		return (
			"НЕЛЬЗЯ · %s"
			% _format_surface_failure_short(
				preview.failure_code
			)
		)

	var final_duration := (
		_format_surface_duration_short(
			preview.final_is_permanent,
			preview.final_remaining_rounds
		)
	)

	if preview.will_add:
		return (
			"СОЗДАТЬ · %s"
			% final_duration
		)

	if preview.will_update:
		var previous_duration := (
			_format_surface_duration_short(
				preview.previous_is_permanent,
				preview.previous_remaining_rounds
			)
		)

		if previous_duration == final_duration:
			return (
				"ОБНОВИТЬ · %s"
				% final_duration
			)

		return (
			"ОБНОВИТЬ · %s→%s"
			% [
				previous_duration,
				final_duration,
			]
		)

	return final_duration


static func _format_surface_duration_short(
	is_permanent: bool,
	remaining_rounds: int
) -> String:
	if is_permanent:
		return "∞"

	return "%dр" % remaining_rounds


static func _format_surface_failure_short(
	failure_code: StringName
) -> String:
	match failure_code:
		BattleSurfaceEffectController.FAILURE_SURFACE_CELL_HAS_OBSTACLE:
			return "блок"

		BattleSurfaceEffectController.FAILURE_INVALID_SURFACE_COORDINATE:
			return "вне поля"

		BattleSurfaceEffectController.FAILURE_INVALID_SURFACE_DEFINITION:
			return "ошибка"

	return "нельзя"


static func build_target_text(
	preview: BattleTargetPreview
) -> String:
	if preview == null:
		return ""

	var lines := PackedStringArray()

	if preview.has_damage_effect():
		_append_damage_lines(
			lines,
			preview
		)

	_append_healing_lines(
		lines,
		preview.normal_effect_results
	)

	_append_guard_lines(
		lines,
		preview.normal_effect_results
	)

	_append_status_lines(
		lines,
		preview.normal_effect_results
	)

	_append_removed_status_lines(
		lines,
		preview.normal_effect_results
	)

	_append_movement_lines(
		lines,
		preview.normal_effect_results
	)

	_append_relocation_lines(
		lines,
		preview
	)

	if preview.normal_final_health <= 0:
		lines.append(
			"ПОГИБНЕТ"
		)

	elif (
		preview.critical_final_health <= 0
		and preview.has_critical_alternative()
	):
		lines.append(
			"При крите погибнет"
		)

	return "\n".join(
		lines
	)


static func _append_damage_lines(
	lines: PackedStringArray,
	preview: BattleTargetPreview
) -> void:
	var normal_guard_damage := (
		_sum_guard_absorption(
			preview.normal_effect_results
		)
	)

	var normal_health_damage := (
		_sum_applied_amount(
			preview.normal_effect_results,
			&"damage"
		)
	)

	if preview.has_guaranteed_critical():
		lines.append(
			"КРИТ гарантирован"
		)

		lines.append(
			_format_damage(
				normal_guard_damage,
				normal_health_damage
			)
		)

		return

	var critical_chances := (
		preview
		.get_standard_critical_chances()
	)

	if critical_chances.is_empty():
		lines.append(
			_format_damage(
				normal_guard_damage,
				normal_health_damage
			)
		)

		return

	var critical_guard_damage := (
		_sum_guard_absorption(
			preview.critical_effect_results
		)
	)

	var critical_health_damage := (
		_sum_applied_amount(
			preview.critical_effect_results,
			&"damage"
		)
	)

	lines.append(
		"Обычно: %s"
		% _format_damage(
			normal_guard_damage,
			normal_health_damage
		)
	)

	lines.append(
		"При крите: %s"
		% _format_damage(
			critical_guard_damage,
			critical_health_damage
		)
	)

	var chance_parts := PackedStringArray()

	for chance in critical_chances:
		chance_parts.append(
			"%d%%"
			% chance
		)

	lines.append(
		"Шанс крита: %s"
		% " / ".join(
			chance_parts
		)
	)


static func _append_healing_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"heal"
		):
			continue

		var text := (
			"HP +%d"
			% effect_result.applied_amount
		)

		if effect_result.overheal_amount > 0:
			text += (
				"  (избыток %d)"
				% effect_result.overheal_amount
			)

		lines.append(
			text
		)


static func _append_guard_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"grant_guard"
		):
			continue

		var text := (
			"Оборона +%d"
			% effect_result.applied_amount
		)

		if effect_result.overguard_amount > 0:
			text += (
				"  (потеряно %d)"
				% effect_result.overguard_amount
			)

		lines.append(
			text
		)


static func _append_status_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"apply_status"
		):
			continue

		var status_name := (
			effect_result.status_display_name
		)

		if status_name.is_empty():
			status_name = String(
				effect_result.status_id
			)

		if (
			effect_result
			.status_application_blocked_by_immunity
		):
			lines.append(
				"ИММУНИТЕТ: «%s»"
				% status_name
			)

			continue

		if effect_result.status_was_added:
			lines.append(
				"+ «%s» (%d х.)"
				% [
					status_name,
					effect_result
						.current_status_remaining_turns,
				]
			)

		else:
			lines.append(
				"«%s» обновится (%d х.)"
				% [
					status_name,
					effect_result
						.current_status_remaining_turns,
				]
			)


static func _append_removed_status_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"remove_status"
		):
			continue

		if (
			effect_result
			.removed_status_display_names
			.is_empty()
		):
			lines.append(
				"Снятие: подходящих статусов нет"
			)

			continue

		var status_parts := PackedStringArray()

		for status_name in (
			effect_result
			.removed_status_display_names
		):
			status_parts.append(
				"«%s»"
				% status_name
			)

		lines.append(
			"Снимет: %s"
			% ", ".join(
				status_parts
			)
		)

static func _append_relocation_lines(
	lines: PackedStringArray,
	preview: BattleTargetPreview
) -> void:
	for effect_result in (
		preview.normal_effect_results
	):
		if effect_result == null:
			continue

		if (
			effect_result.effect_kind
			== &"teleport"
		):
			lines.append(
				"Телепорт: %s → %s"
				% [
					preview.initial_position,
					preview.normal_final_position,
				]
			)

			return

		if (
			effect_result.effect_kind
			== &"swap_positions"
		):
			lines.append(
				"Обмен: %s → %s"
				% [
					preview.initial_position,
					preview.normal_final_position,
				]
			)

			return
			        
static func _append_movement_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"forced_movement"
		):
			continue

		var text := (
			"Сдвиг: %d/%d → %s"
			% [
				effect_result
					.applied_movement_distance,
				effect_result
					.requested_movement_distance,
				effect_result
					.movement_destination,
			]
		)

		if effect_result.movement_was_blocked:
			text += (
				"\nОстановка: %s"
				% _format_block_reason(
					effect_result
						.movement_block_reason
				)
			)

		lines.append(
			text
		)


static func _format_damage(
	guard_damage: int,
	health_damage: int
) -> String:
	var parts := PackedStringArray()

	if guard_damage > 0:
		parts.append(
			"ОБ −%d"
			% guard_damage
		)

	if health_damage > 0:
		parts.append(
			"HP −%d"
			% health_damage
		)

	if parts.is_empty():
		return "урон 0"

	return ", ".join(
		parts
	)


static func _sum_guard_absorption(
	effect_results: Array[BattleEffectResult]
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if (
			effect_result != null
			and effect_result.effect_kind
				== &"damage"
		):
			total += (
				effect_result
				.guard_absorbed_amount
			)

	return total


static func _sum_applied_amount(
	effect_results: Array[BattleEffectResult],
	effect_kind: StringName
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if (
			effect_result != null
			and effect_result.effect_kind
				== effect_kind
		):
			total += (
				effect_result.applied_amount
			)

	return total


static func _format_block_reason(
	reason: StringName
) -> String:
	match reason:
		BattleForcedMovementService.BLOCK_OUTSIDE_GRID:
			return "граница поля"

		BattleForcedMovementService.BLOCK_CELL_OCCUPIED_OR_OBSTRUCTED:
			return "клетка занята"

	return String(reason)