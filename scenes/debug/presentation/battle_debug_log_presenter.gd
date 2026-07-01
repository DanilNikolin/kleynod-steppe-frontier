class_name BattleDebugLogPresenter
extends RefCounted


var status_label: Label
var session: BattleSession
var debug_status_definition: BattleStatusDefinition
var max_battle_log_lines: int = 6

var _status_headline: String = ""
var _battle_log_lines := PackedStringArray()
var _status_signal_logging_suspended: bool = false


func _init(
	p_status_label: Label,
	p_session: BattleSession,
	p_debug_status_definition: BattleStatusDefinition = null,
	p_max_battle_log_lines: int = 6
) -> void:
	assert(
		p_status_label != null,
		"BattleDebugLogPresenter requires a status label."
	)
	assert(
		p_session != null,
		"BattleDebugLogPresenter requires a battle session."
	)

	status_label = p_status_label
	session = p_session
	debug_status_definition = p_debug_status_definition
	max_battle_log_lines = maxi(
		1,
		p_max_battle_log_lines
	)


func connect_combatant(
	combatant: CombatantState
) -> void:
	if combatant == null:
		return

	var added_callback := Callable(
		self,
		"_on_combatant_status_added"
	).bind(
		combatant
	)

	var updated_callback := Callable(
		self,
		"_on_combatant_status_updated"
	).bind(
		combatant
	)

	var removed_callback := Callable(
		self,
		"_on_combatant_status_removed"
	).bind(
		combatant
	)

	if not combatant.is_connected(
		&"status_added",
		added_callback
	):
		combatant.connect(
			&"status_added",
			added_callback
		)

	if not combatant.is_connected(
		&"status_updated",
		updated_callback
	):
		combatant.connect(
			&"status_updated",
			updated_callback
		)

	if not combatant.is_connected(
		&"status_removed",
		removed_callback
	):
		combatant.connect(
			&"status_removed",
			removed_callback
		)


func set_headline(
	message: String
) -> void:
	_status_headline = message
	_refresh_status_label()


func push_battle_log(
	message: String
) -> void:
	if message.strip_edges().is_empty():
		return

	_battle_log_lines.append(
		message
	)

	while (
		_battle_log_lines.size()
		> max_battle_log_lines
	):
		_battle_log_lines.remove_at(0)

	print(message)

	_refresh_status_label()

func suspend_status_signal_logging() -> void:
	_status_signal_logging_suspended = true


func resume_status_signal_logging() -> void:
	_status_signal_logging_suspended = false

func apply_debug_status(
	target: CombatantState,
	source: CombatantState = null
) -> bool:
	if debug_status_definition == null:
		set_headline(
			"Debug-статус не назначен в Inspector."
		)

		return false

	if not debug_status_definition.is_valid_definition():
		set_headline(
			"Назначен некорректный debug-статус."
		)

		return false

	if target == null:
		set_headline(
			"Наведи курсор на бойца и нажми T."
		)

		return false

	var source_instance_id: StringName = &""

	if source != null:
		source_instance_id = source.instance_id

	var applied_status := target.add_status(
		debug_status_definition,
		source_instance_id
	)

	if applied_status == null:
		set_headline(
			"Не удалось применить debug-статус."
		)

		return false

	set_headline(
		"%s: %s. Текущая броня: %d."
		% [
			target.definition.display_name,
			format_status_for_player(
				applied_status
			),
			target.get_effective_armor(),
		]
	)

	return true


func get_status_summary(
	combatant: CombatantState
) -> String:
	if combatant == null:
		return "нет"

	var statuses := combatant.get_active_statuses()

	if statuses.is_empty():
		return "нет"

	var parts := PackedStringArray()

	for status in statuses:
		if status == null:
			continue

		parts.append(
			format_status_for_player(
				status
			)
		)

	if parts.is_empty():
		return "нет"

	return "; ".join(parts)


func format_status_for_player(
	status: BattleStatusInstance
) -> String:
	if (
		status == null
		or status.definition == null
	):
		return "Неизвестный статус"

	var title := status.definition.display_name

	if status.stack_count > 1:
		title += " ×%d" % status.stack_count

	var effects := PackedStringArray()

	var armor_modifier := get_status_stat_modifier_amount(
		status,
		BattleStatModifier.Stat.ARMOR
	)

	if armor_modifier != 0:
		effects.append(
			"броня %s"
			% format_signed_integer(
				armor_modifier
			)
		)

	var has_turn_start_trigger := false
	var has_turn_end_trigger := false

	for trigger in (
		status.definition.periodic_triggers
	):
		if trigger == null:
			continue

		match trigger.timing:
			BattleStatusPeriodicTrigger.Timing.OWNER_TURN_START:
				has_turn_start_trigger = true

			BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END:
				has_turn_end_trigger = true

	if has_turn_start_trigger:
		effects.append(
			"эффект в начале хода"
		)

	if has_turn_end_trigger:
		effects.append(
			"эффект в конце хода"
		)

	var action_restriction := (
		status.definition.action_restriction
	)

	if action_restriction != null:
		if action_restriction.skip_owner_turn:
			effects.append(
				"пропуск хода"
			)

		else:
			if action_restriction.block_movement:
				effects.append(
					"запрет движения"
				)

			if action_restriction.block_all_abilities:
				effects.append(
					"запрет способностей"
				)

			elif not (
				action_restriction
				.blocked_ability_ids
				.is_empty()
			):
				effects.append(
					"запрещено способностей: %d"
					% action_restriction
					.blocked_ability_ids
					.size()
				)

	if effects.is_empty():
		effects.append(
			"без активных модификаторов"
		)

	return (
		"%s — %s, осталось %s"
		% [
			title,
			", ".join(effects),
			format_turn_count(
				status.remaining_turns
			),
		]
	)


func append_action_results(
	action_result: BattleActionResult
) -> void:
	if action_result == null:
		return

	for effect_result in (
		action_result.effect_results
	):
		if effect_result == null:
			continue

		if not effect_result.is_successful:
			continue

		match effect_result.effect_kind:
			&"damage":
				_append_damage_result(
					effect_result
				)

			&"heal":
				_append_heal_result(
					effect_result
				)

			&"grant_guard":
				_append_guard_result(
					effect_result
				)

			&"apply_status":
				_append_status_result(
					effect_result
				)

			&"forced_movement":
				_append_forced_movement_result(
					effect_result
				)


func append_periodic_trigger_results(
	combatant: CombatantState,
	timing: int,
	trigger_results: Array[
		BattleStatusPeriodicTriggerResult
	]
) -> void:
	if combatant == null:
		return

	for trigger_result in trigger_results:
		if trigger_result == null:
			continue

		var status_name := (
			trigger_result.status_display_name
		)

		if status_name.strip_edges().is_empty():
			status_name = String(
				trigger_result.status_id
			)

		push_battle_log(
			"«%s» срабатывает у %s %s."
			% [
				status_name,
				combatant.definition.display_name,
				format_periodic_timing(
					timing
				),
			]
		)

		for effect_result in (
			trigger_result.effect_results
		):
			if effect_result == null:
				continue

			if not effect_result.is_successful:
				push_battle_log(
					"Периодический эффект не выполнен: %s."
					% effect_result.failure_code
				)

				continue

			match effect_result.effect_kind:
				&"damage":
					_append_damage_result(
						effect_result
					)

				&"heal":
					_append_heal_result(
						effect_result
					)

				&"grant_guard":
					_append_guard_result(
						effect_result
					)

				# ApplyStatusEffect уже сообщает
				# об изменении через status-сигналы.
				&"apply_status":
					pass


func _append_damage_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var armor_text := (
		"%d"
		% effect_result.target_base_armor
	)

	if (
		effect_result
		.target_status_armor_modifier != 0
	):
		armor_text += (
			" %s от статусов = %d"
			% [
				format_signed_integer(
					effect_result
					.target_status_armor_modifier
				),
				effect_result
				.target_modified_armor,
			]
		)

	var guard_text: String

	if effect_result.guard_was_bypassed:
		guard_text = (
			"оборона проигнорирована "
			+"(было %d)"
			% effect_result.previous_guard
		)

	else:
		guard_text = (
			"оборона: %d → %d, поглощено %d"
			% [
				effect_result.previous_guard,
				effect_result.current_guard,
				effect_result
					.guard_absorbed_amount,
			]
		)

	var message := (
		"%s: сила удара — %d; "
		% [
			target_name,
			effect_result.raw_amount,
		]
		+"броня — %s; "
		% armor_text
		+"пробитие — %d; "
		% effect_result.armor_piercing
		+"итоговая броня — %d; "
		% effect_result.effective_armor
		+"урон после брони — %d; "
		% effect_result.resolved_amount
		+"%s; "
		% guard_text
		+"потеря HP — %d; "
		% effect_result.applied_amount
		+"overkill — %d."
		% effect_result.overkill_amount
	)

	if effect_result.target_died:
		message += " Цель погибает."

	push_battle_log(
		message
	)


func _append_heal_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s: расчётное лечение — %d; "
		% [
			target_name,
			effect_result.resolved_amount,
		]
		+"восстановлено HP — %d; "
		% effect_result.applied_amount
		+"overheal — %d. "
		% effect_result.overheal_amount
		+"Здоровье: %d → %d."
		% [
			effect_result.previous_value,
			effect_result.current_value,
		]
	)

	push_battle_log(
		message
	)


func _append_guard_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s получает оборону: +%d; "
		% [
			target_name,
			effect_result.applied_amount,
		]
		+"оборона %d → %d."
		% [
			effect_result.previous_guard,
			effect_result.current_guard,
		]
	)

	if effect_result.overguard_amount > 0:
		message += (
			" Сверх лимита потеряно: %d."
			% effect_result.overguard_amount
		)

	push_battle_log(
		message
	)
    
func _append_forced_movement_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s принудительно перемещается "
		% target_name
		+"на %d/%d клеток: %s → %s."
		% [
			effect_result
				.applied_movement_distance,
			effect_result
				.requested_movement_distance,
			effect_result.movement_origin,
			effect_result.movement_destination,
		]
	)

	if effect_result.movement_was_blocked:
		message += (
			" Дальнейшее движение остановлено: %s."
			% format_forced_movement_block_reason(
				effect_result
				.movement_block_reason
			)
		)

	push_battle_log(
		message
	)


func _append_status_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var status_name := String(
		effect_result.status_id
	)

	if target != null:
		var status := target.get_status(
			effect_result.status_id
		)

		if (
			status != null
			and status.definition != null
		):
			status_name = (
				status.definition.display_name
			)

	var message: String

	if effect_result.status_was_added:
		message = (
			"%s получает «%s»."
			% [
				target_name,
				status_name,
			]
		)
	else:
		message = (
			"«%s» у %s обновляется."
			% [
				status_name,
				target_name,
			]
		)

	if (
		effect_result
		.previous_target_effective_armor
		!= effect_result
		.current_target_effective_armor
	):
		message += (
			" Броня: %d → %d."
			% [
				effect_result
				.previous_target_effective_armor,
				effect_result
				.current_target_effective_armor,
			]
		)

	if (
		effect_result
		.previous_status_stack_count
		!= effect_result
		.current_status_stack_count
		and effect_result
		.current_status_stack_count > 1
	):
		message += (
			" Стаки: %d → %d."
			% [
				effect_result
				.previous_status_stack_count,
				effect_result
				.current_status_stack_count,
			]
		)

	if effect_result.status_was_added:
		message += (
			" Длительность: %s."
			% format_turn_count(
				effect_result
				.current_status_remaining_turns
			)
		)

	elif (
		effect_result
		.previous_status_remaining_turns
		!= effect_result
		.current_status_remaining_turns
	):
		message += (
			" Длительность: %s → %s."
			% [
				format_turn_count(
					effect_result
					.previous_status_remaining_turns
				),
				format_turn_count(
					effect_result
					.current_status_remaining_turns
				),
			]
		)

	push_battle_log(
		message
	)


func get_status_stat_modifier_amount(
	status: BattleStatusInstance,
	stat: int
) -> int:
	if (
		status == null
		or status.definition == null
	):
		return 0

	var total: int = 0

	for modifier in status.definition.stat_modifiers:
		if modifier == null:
			continue

		if modifier.stat != stat:
			continue

		total += modifier.get_total_amount(
			status.stack_count
		)

	return total


func format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


func format_turn_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d ходов" % value

	if last_digit == 1:
		return "%d ход" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d хода" % value

	return "%d ходов" % value


func format_periodic_timing(
	timing: int
) -> String:
	match timing:
		BattleStatusPeriodicTrigger.Timing.OWNER_TURN_START:
			return "в начале хода"

		BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END:
			return "в конце хода"

	return "в неизвестный момент"


func format_forced_movement_block_reason(
	reason: StringName
) -> String:
	match reason:
		BattleForcedMovementService.BLOCK_OUTSIDE_GRID:
			return "граница поля"

		BattleForcedMovementService.BLOCK_CELL_OCCUPIED_OR_OBSTRUCTED:
			return "клетка занята или заблокирована"

	return String(reason)


func _refresh_status_label() -> void:
	var text := _status_headline

	if not _battle_log_lines.is_empty():
		if not text.is_empty():
			text += "\n\n"

		text += "Журнал боя:\n• "
		text += "\n• ".join(
			_battle_log_lines
		)

	status_label.text = text


func _on_combatant_status_added(
	status: BattleStatusInstance,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var status_armor_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		- status_armor_modifier
	)

	var current_armor := combatant.get_effective_armor()

	var message := (
		"%s получает «%s»."
		% [
			combatant.definition.display_name,
			status.definition.display_name,
		]
	)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	message += (
		" Длительность: %s."
		% format_turn_count(
			status.remaining_turns
		)
	)

	push_battle_log(
		message
	)


func _on_combatant_status_updated(
	status: BattleStatusInstance,
	previous_stack_count: int,
	previous_remaining_turns: int,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var current_status_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_status_modifier: int = 0

	if (
		status != null
		and status.definition != null
	):
		for modifier in status.definition.stat_modifiers:
			if (
				modifier != null
				and modifier.stat
				== BattleStatModifier.Stat.ARMOR
			):
				previous_status_modifier += (
					modifier.get_total_amount(
						previous_stack_count
					)
				)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_modifier_total := (
		current_modifier_total
		- current_status_modifier
		+ previous_status_modifier
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ previous_modifier_total
	)

	var current_armor := combatant.get_effective_armor()

	var changes := PackedStringArray()

	if previous_stack_count != status.stack_count:
		changes.append(
			"стаки: %d → %d"
			% [
				previous_stack_count,
				status.stack_count,
			]
		)

	if previous_armor != current_armor:
		changes.append(
			"броня: %d → %d"
			% [
				previous_armor,
				current_armor,
			]
		)

	if previous_remaining_turns != status.remaining_turns:
		if status.remaining_turns > previous_remaining_turns:
			changes.append(
				"длительность обновлена: %s → %s"
				% [
					format_turn_count(
						previous_remaining_turns
					),
					format_turn_count(
						status.remaining_turns
					),
				]
			)
		else:
			changes.append(
				"осталось %s"
				% format_turn_count(
					status.remaining_turns
				)
			)

	if changes.is_empty():
		changes.append("обновлён")

	push_battle_log(
		"«%s» у %s: %s."
		% [
			status.definition.display_name,
			combatant.definition.display_name,
			", ".join(changes),
		]
	)


func _on_combatant_status_removed(
	status: BattleStatusInstance,
	reason: StringName,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var removed_armor_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		+ removed_armor_modifier
	)

	var current_armor := combatant.get_effective_armor()

	var message: String

	match reason:
		&"expired":
			message = (
				"«%s» у %s заканчивается."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		&"owner_defeated":
			message = (
				"«%s» снимается после гибели %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		_:
			message = (
				"«%s» снимается с %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	push_battle_log(
		message
	)