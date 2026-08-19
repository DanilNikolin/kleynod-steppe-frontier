class_name BattleAbilityPresentationBuilder
extends RefCounted


static func build_meta_text(
	ability: AbilityDefinition
) -> String:
	if ability == null:
		return ""

	var parts := PackedStringArray()

	parts.append(
		"Цена: %d выносливости"
		% ability.stamina_cost
	)

	if ability.initial_lock_turns > 0:
		parts.append(
			"Стартовая задержка: %s"
			% format_turn_count(
				ability.initial_lock_turns
			)
		)

	if ability.cooldown_turns > 0:
		parts.append(
			"Кулдаун: %s"
			% format_turn_count(
				ability.cooldown_turns
			)
		)

	if ability.targeting != null:
		parts.append(
			"Цель: %s"
			% _build_aim_target_text(
				ability.targeting
			)
		)

		var range_text := _build_range_text(
			ability.targeting
		)

		if not range_text.is_empty():
			parts.append(
				range_text
			)

		if (
			ability.targeting
			.impact_offsets.size() > 1
		):
			parts.append(
				"Область: %d клеток"
				% ability.targeting
				.impact_offsets.size()
			)

	return "  •  ".join(parts)


static func build_effects_text(
	ability: AbilityDefinition,
	actor: CombatantState = null
) -> String:
	if ability == null:
		return "Нет данных о способности."

	return build_effect_list_text(
		ability.effects,
		actor
	)


static func build_effect_list_text(
	effects: Array[BattleEffect],
	actor: CombatantState = null
) -> String:
	if effects.is_empty():
		return "Эффекты отсутствуют."

	var lines := PackedStringArray()

	for effect in effects:
		if effect == null:
			continue

		if effect is DamageEffect:
			lines.append(
				_build_damage_effect_text(
					effect as DamageEffect,
					actor
				)
			)

		elif effect is HealEffect:
			lines.append(
				_build_heal_effect_text(
					effect as HealEffect,
					actor
				)
			)

		elif effect is HealthCostEffect:
			lines.append(
				_build_health_cost_effect_text(
					effect as HealthCostEffect
				)
			)

		elif effect is RestoreStaminaEffect:
			lines.append(
				_build_restore_stamina_effect_text(
					effect as RestoreStaminaEffect
				)
			)

		elif effect is HeroCoreEffect:
			lines.append(
				(
					effect as HeroCoreEffect
				).get_presentation_text()
			)
			
		elif effect is GrantGuardEffect:
			lines.append(
				_build_guard_effect_text(
					effect as GrantGuardEffect
				)
			)

		elif effect is ApplyStatusEffect:
			lines.append(
				_build_status_effect_text(
					effect as ApplyStatusEffect
				)
			)

		elif effect is RemoveStatusEffect:
			lines.append(
				_build_remove_status_effect_text(
					effect as RemoveStatusEffect
				)
			)

		elif effect is SwapPositionsEffect:
			lines.append(
				"• Обмен позициями с бойцом "
				+"той же команды"
			)

		elif effect is TeleportEffect:
			lines.append(
				"• Телепорт в выбранную "
				+"свободную клетку"
			)
			
		elif effect is PlaceSurfaceEffect:
			lines.append(
				_build_place_surface_effect_text(
					effect as PlaceSurfaceEffect
				)
			)

		else:
			lines.append(
				"• Эффект: %s"
				% effect.effect_id
			)

	if lines.is_empty():
		return "Эффекты отсутствуют."

	return "\n".join(lines)


static func _build_place_surface_effect_text(
	effect: PlaceSurfaceEffect
) -> String:
	if (
		effect == null
		or effect.surface_definition == null
	):
		return "• Создаёт неизвестную поверхность."

	var definition := effect.surface_definition

	var duration_text := (
		"постоянно"
		if definition.duration_rounds == 0
		else format_round_count(
			definition.duration_rounds
		)
	)

	var result := (
		"• Создаёт поверхность: «%s»"
		% definition.display_name
		+"\n  Длительность: %s"
		% duration_text
	)

	var description := (
		definition.description.strip_edges()
	)

	if not description.is_empty():
		result += (
			"\n  %s"
			% description
		)

	return result

static func _build_damage_effect_text(
	effect: DamageEffect,
	_actor: CombatantState
) -> String:
	var damage_text := (
		"• Урон: %d"
		% effect.base_damage
	)

	if effect.armor_piercing >= 999:
		damage_text += (
			"\n  Броня: полностью игнорируется"
		)

	elif effect.armor_piercing > 0:
		damage_text += (
			"\n  Пробитие брони: %d"
			% effect.armor_piercing
		)

	if effect.minimum_damage > 0:
		damage_text += (
			"\n  Минимальный урон: %d"
			% effect.minimum_damage
		)

	damage_text += (
		"\n  %s"
		% _build_critical_effect_text(
			effect,
			_actor
		)
	)

	return damage_text

static func _build_critical_effect_text(
	effect: DamageEffect,
	_actor: CombatantState
) -> String:
	match effect.crit_mode:
		DamageEffect.CritMode.DISABLED:
			return "Крит: нет"

		DamageEffect.CritMode.GUARANTEED:
			return (
				"Крит: гарантирован"
				+"  •  Множитель: ×%s"
				% _format_multiplier(
					effect.critical_multiplier
				)
			)

		DamageEffect.CritMode.STANDARD:
			var calculator := (
				DamageCalculator.new()
			)

			var chance := (
				calculator
				.calculate_critical_chance_percent_from_effect(
					effect,
					true
				)
			)

			return (
				"Крит: %d%%"
				% chance
				+"  •  Множитель: ×%s"
				% _format_multiplier(
					effect.critical_multiplier
				)
			)

	return "Крит: нет"


static func _format_multiplier(
	value: float
) -> String:
	return str(
		snappedf(
			value,
			0.01
		)
	)

static func _build_health_cost_effect_text(
	effect: HealthCostEffect
) -> String:
	return (
		"• Цена здоровьем: -%d HP"
		% effect.health_cost
		+"\n  После оплаты останется "
		+"не меньше %d HP"
		% effect.minimum_remaining_health
	)


static func _build_restore_stamina_effect_text(
	effect: RestoreStaminaEffect
) -> String:
	var recipient_text := (
		"себе"
		if effect.targets_source()
		else "цели"
	)

	var repeat_text := ""

	if effect.repeats_for_affected_targets():
		repeat_text = (
			"\n  За каждую поражённую цель"
		)

	return (
		"• Выносливость: +%d (%s)"
		% [
			effect.stamina_amount,
			recipient_text,
		]
		+ repeat_text
		+"\n  Сначала погашает "
		+"долг восстановления"
	)


static func _build_heal_effect_text(
	effect: HealEffect,
	_actor: CombatantState
) -> String:
	return (
		"• Лечение: %d"
		% effect.base_healing
	)

static func _build_guard_effect_text(
	effect: GrantGuardEffect
) -> String:
	var repeat_text := ""

	if effect.repeats_for_affected_targets():
		repeat_text = (
			"\n  За каждую поражённую цель"
		)

	return (
		"• Оборона: +%d"
		% effect.guard_amount
		+ repeat_text
		+"\n  Максимум: здоровье бойца"
	)

static func _build_status_effect_text(
	effect: ApplyStatusEffect
) -> String:
	if effect.status_definition == null:
		return "• Накладывает неизвестный статус."

	var status := effect.status_definition

	var text := (
		"• Статус: «%s»"
		% status.display_name
	)

	text += (
		"\n  Длительность: %s"
		% format_turn_count(
			status.duration_turns
		)
	)

	var modifier_parts := PackedStringArray()

	for modifier in status.stat_modifiers:
		if modifier == null:
			continue

		modifier_parts.append(
			"%s %s"
			% [
				_get_stat_name(
					modifier.stat
				),
				_format_signed_integer(
					modifier.amount_per_stack
				),
			]
		)

	if not modifier_parts.is_empty():
		text += (
			"\n  Изменяет: %s"
			% ", ".join(
				modifier_parts
			)
		)

	if status.max_stacks > 1:
		text += (
			"\n  Максимум стаков: %d"
			% status.max_stacks
		)

	return text


static func _build_remove_status_effect_text(
	effect: RemoveStatusEffect
) -> String:
	match effect.filter_mode:
		RemoveStatusEffect.FilterMode.SPECIFIC_STATUSES:
			var status_parts := PackedStringArray()

			for status_definition in (
				effect.specific_statuses
			):
				if status_definition == null:
					continue

				status_parts.append(
					"«%s»"
					% status_definition.display_name
				)

			if status_parts.is_empty():
				return (
					"• Снимает конкретные статусы"
				)

			return (
				"• Снимает: %s"
				% ", ".join(
					status_parts
				)
			)

		RemoveStatusEffect.FilterMode.STATUS_TAG:
			return (
				"• Снимает все статусы "
				+"категории «%s»"
				% effect.status_tag
			)

		RemoveStatusEffect.FilterMode.ALL_HARMFUL:
			return "• Снимает все вредные статусы"

		RemoveStatusEffect.FilterMode.ALL_BENEFICIAL:
			return "• Снимает все полезные статусы"

	return "• Снимает статусы"

static func _build_aim_target_text(
	targeting: AbilityTargetingDefinition
) -> String:
	match targeting.aim_requirement:
		AbilityTargetingDefinition.AimRequirement.EMPTY_CELL:
			return "пустая клетка"

		AbilityTargetingDefinition.AimRequirement.ANY_CELL:
			return "любая клетка"

		AbilityTargetingDefinition.AimRequirement.OCCUPIED_CELL:
			return _relation_mask_to_text(
				targeting.aim_relation_mask
			)

	return "неизвестно"


static func _build_range_text(
	targeting: AbilityTargetingDefinition
) -> String:
	if targeting.aim_offsets.is_empty():
		return ""

	var minimum_distance := 999999
	var maximum_distance := 0
	var maximum_row_offset := 0

	for offset in targeting.aim_offsets:
		var distance := absi(
			offset.x
		)

		minimum_distance = mini(
			minimum_distance,
			distance
		)

		maximum_distance = maxi(
			maximum_distance,
			distance
		)

		maximum_row_offset = maxi(
			maximum_row_offset,
			absi(offset.y)
		)

	var range_text: String

	if minimum_distance == maximum_distance:
		if maximum_distance == 0:
			range_text = "Дальность: на себе"
		else:
			range_text = (
				"Дальность: %d"
				% maximum_distance
			)

	else:
		range_text = (
			"Дальность: %d–%d"
			% [
				minimum_distance,
				maximum_distance,
			]
		)

	if maximum_row_offset > 0:
		range_text += (
			", ряды ±%d"
			% maximum_row_offset
		)

	return range_text


static func _relation_mask_to_text(
	relation_mask: int
) -> String:
	var relations := PackedStringArray()

	if (
		relation_mask
		& AbilityTargetingDefinition.RelationMask.SELF
	):
		relations.append("себя")

	if (
		relation_mask
		& AbilityTargetingDefinition.RelationMask.ALLY
	):
		relations.append("союзника")

	if (
		relation_mask
		& AbilityTargetingDefinition.RelationMask.ENEMY
	):
		relations.append("врага")

	if relations.is_empty():
		return "никого"

	return " или ".join(relations)


static func _get_stat_name(
	stat: int
) -> String:
	match stat:
		BattleStatModifier.Stat.ARMOR:
			return "броня"

		BattleStatModifier.Stat.STRENGTH:
			return "сила"

		BattleStatModifier.Stat.AGILITY:
			return "ловкость"

		BattleStatModifier.Stat.SPIRIT:
			return "дух"


	return "характеристика"


static func _format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


static func format_round_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d раундов" % value

	if last_digit == 1:
		return "%d раунд" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d раунда" % value

	return "%d раундов" % value

	
static func format_turn_count(
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
