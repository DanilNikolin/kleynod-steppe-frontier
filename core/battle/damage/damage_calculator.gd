class_name DamageCalculator
extends RefCounted


const BASE_CRIT_CHANCE_PERCENT: int = 5
const MAX_STANDARD_CRIT_CHANCE_PERCENT: int = 35


func calculate_raw_damage(
	attacker: CombatantState,
	effect: DamageEffect
) -> int:
	if attacker == null:
		return 0

	return calculate_raw_damage_from_effect(
		effect
	)


func calculate_raw_damage_from_effect(
	effect: DamageEffect
) -> int:
	if effect == null:
		return 0

	return maxi(
		0,
		effect.base_damage
	)


## Временный совместимый метод.
## Сила больше не влияет на урон напрямую.
func calculate_raw_damage_from_strength(
	_effective_strength: int,
	effect: DamageEffect
) -> int:
	return calculate_raw_damage_from_effect(
		effect
	)


func calculate_critical_chance_percent(
	attacker: CombatantState,
	effect: DamageEffect,
	allow_critical: bool = true
) -> int:
	var attacker_bonus: int = (
		attacker.crit_chance_bonus_percent
		if attacker != null
		else 0
	)

	return (
		calculate_critical_chance_percent_from_values(
			effect,
			attacker_bonus,
			allow_critical
		)
	)


func calculate_critical_chance_percent_from_values(
	effect: DamageEffect,
	attacker_crit_chance_bonus_percent: int = 0,
	allow_critical: bool = true
) -> int:
	if (
		effect == null
		or not allow_critical
	):
		return 0

	match effect.crit_mode:
		DamageEffect.CritMode.DISABLED:
			return 0

		DamageEffect.CritMode.GUARANTEED:
			return 100

		DamageEffect.CritMode.STANDARD:
			return clampi(
				BASE_CRIT_CHANCE_PERCENT
				+ attacker_crit_chance_bonus_percent
				+ effect.crit_chance_bonus_percent,
				0,
				MAX_STANDARD_CRIT_CHANCE_PERCENT
			)

	return 0


func calculate_critical_chance_percent_from_effect(
	effect: DamageEffect,
	allow_critical: bool = true
) -> int:
	return (
		calculate_critical_chance_percent_from_values(
			effect,
			0,
			allow_critical
		)
	)


## Временный совместимый метод.
## Ловкость больше не влияет на крит напрямую.
func calculate_critical_chance_percent_from_agility(
	_effective_agility: int,
	effect: DamageEffect,
	allow_critical: bool = true
) -> int:
	return (
		calculate_critical_chance_percent_from_effect(
			effect,
			allow_critical
		)
	)


func calculate_critical_multiplier(
	attacker: CombatantState,
	effect: DamageEffect
) -> float:
	var attacker_bonus: int = (
		attacker.crit_damage_bonus_percent
		if attacker != null
		else 0
	)

	return calculate_critical_multiplier_from_values(
		effect,
		attacker_bonus
	)


func calculate_critical_multiplier_from_values(
	effect: DamageEffect,
	attacker_crit_damage_bonus_percent: int = 0
) -> float:
	if effect == null:
		return 1.0

	var base_multiplier := (
		effect.critical_multiplier
	)

	var bonus_points := (
		float(attacker_crit_damage_bonus_percent)
		/ 100.0
	)

	return maxf(
		1.0,
		base_multiplier + bonus_points
	)


func apply_critical_multiplier(
	raw_damage: int,
	critical_multiplier: float
) -> int:
	if raw_damage <= 0:
		return 0

	return maxi(
		0,
		roundi(
			float(raw_damage)
			* critical_multiplier
		)
	)


func calculate_effective_armor(
	target: CombatantState,
	effect: DamageEffect
) -> int:
	if target == null:
		return 0

	return calculate_effective_armor_from_value(
		target.get_effective_armor(),
		effect
	)


func calculate_effective_armor_from_value(
	target_effective_armor: int,
	effect: DamageEffect
) -> int:
	if effect == null:
		return 0

	return maxi(
		0,
		target_effective_armor
		- effect.armor_piercing
	)


func calculate_resolved_damage_from_raw(
	target: CombatantState,
	effect: DamageEffect,
	raw_damage: int
) -> int:
	if target == null:
		return 0

	var effective_armor := (
		calculate_effective_armor(
			target,
			effect
		)
	)

	return calculate_resolved_damage_from_values(
		effective_armor,
		effect,
		raw_damage
	)


func calculate_resolved_damage_from_values(
	effective_armor: int,
	effect: DamageEffect,
	raw_damage: int
) -> int:
	if (
		effect == null
		or raw_damage <= 0
	):
		return 0

	var damage_after_armor := maxi(
		0,
		raw_damage
		- maxi(
			0,
			effective_armor
		)
	)

	var allowed_minimum := mini(
		effect.minimum_damage,
		raw_damage
	)

	return maxi(
		allowed_minimum,
		damage_after_armor
	)


func calculate_resolved_damage(
	attacker: CombatantState,
	target: CombatantState,
	effect: DamageEffect
) -> int:
	var raw_damage := calculate_raw_damage(
		attacker,
		effect
	)

	return calculate_resolved_damage_from_raw(
		target,
		effect,
		raw_damage
	)