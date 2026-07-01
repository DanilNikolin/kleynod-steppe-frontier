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

	if ability.effects.is_empty():
		return "Эффекты отсутствуют."

	var lines := PackedStringArray()

	for effect in ability.effects:
		if effect == null:
			continue

		if effect is DamageEffect:
			lines.append(
				_build_damage_effect_text(
					effect as DamageEffect,
					actor
				)
			)

		elif effect is ApplyStatusEffect:
			lines.append(
				_build_status_effect_text(
					effect as ApplyStatusEffect
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


static func _build_damage_effect_text(
	effect: DamageEffect,
	actor: CombatantState
) -> String:
	var scaling_percent := roundi(
		effect.strength_scaling * 100.0
	)

	var damage_text: String

	if actor != null:
		var strength_damage := floori(
			float(actor.strength)
			* effect.strength_scaling
		)

		var predicted_raw_damage := maxi(
			0,
			effect.base_damage
			+ strength_damage
		)

		damage_text = (
			"• Урон: %d "
			% predicted_raw_damage
			+"(%d базового"
			% effect.base_damage
		)

		if effect.strength_scaling > 0.0:
			damage_text += (
				" + %d%% силы = %d"
				% [
					scaling_percent,
					strength_damage,
				]
			)

		damage_text += ")"

	else:
		damage_text = (
			"• Урон: %d базового"
			% effect.base_damage
		)

		if effect.strength_scaling > 0.0:
			damage_text += (
				" + %d%% силы"
				% scaling_percent
			)

	if effect.armor_piercing > 0:
		damage_text += (
			"\n  Пробитие брони: %d"
			% effect.armor_piercing
		)

	if effect.minimum_damage > 0:
		damage_text += (
			"\n  Минимальный урон: %d"
			% effect.minimum_damage
		)

	return damage_text


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

		BattleStatModifier.Stat.INITIATIVE:
			return "инициатива"

	return "характеристика"


static func _format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


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