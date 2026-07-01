class_name DamageCalculator
extends RefCounted


const BASE_CRIT_CHANCE_PERCENT: int = 5
const AGILITY_CRIT_CHANCE_PER_POINT: int = 1
const MAX_STANDARD_CRIT_CHANCE_PERCENT: int = 35


func calculate_raw_damage(
	attacker: CombatantState,
	effect: DamageEffect
) -> int:
	if attacker == null or effect == null:
		return 0

	var attribute_damage := floori(
		float(
			attacker.get_effective_strength()
		)
		* effect.strength_scaling
	)

	return maxi(
		0,
		effect.base_damage + attribute_damage
	)


func calculate_critical_chance_percent(
	attacker: CombatantState,
	effect: DamageEffect,
	allow_critical: bool = true
) -> int:
	if (
		attacker == null
		or effect == null
		or not allow_critical
	):
		return 0

	match effect.crit_mode:
		DamageEffect.CritMode.DISABLED:
			return 0

		DamageEffect.CritMode.GUARANTEED:
			return 100

		DamageEffect.CritMode.STANDARD:
			var agility_bonus := (
				attacker.get_effective_agility()
				* AGILITY_CRIT_CHANCE_PER_POINT
			)

			return clampi(
				BASE_CRIT_CHANCE_PERCENT
				+ agility_bonus
				+ effect
					.crit_chance_bonus_percent,
				0,
				MAX_STANDARD_CRIT_CHANCE_PERCENT
			)

	return 0


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
	if target == null or effect == null:
		return 0

	return maxi(
		0,
		target.get_effective_armor()
		- effect.armor_piercing
	)


func calculate_resolved_damage_from_raw(
	target: CombatantState,
	effect: DamageEffect,
	raw_damage: int
) -> int:
	if (
		target == null
		or effect == null
		or raw_damage <= 0
	):
		return 0

	var effective_armor := calculate_effective_armor(
		target,
		effect
	)

	var damage_after_armor := maxi(
		0,
		raw_damage - effective_armor
	)

	var allowed_minimum := mini(
		effect.minimum_damage,
		raw_damage
	)

	return maxi(
		allowed_minimum,
		damage_after_armor
	)


## Совместимый метод для старого кода.
## Критический бросок здесь не выполняется.
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