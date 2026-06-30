class_name DamageCalculator
extends RefCounted


func calculate_raw_damage(
	attacker: CombatantState,
	effect: DamageEffect
) -> int:
	if attacker == null or effect == null:
		return 0

	var attribute_damage := floori(
		float(attacker.strength)
		* effect.strength_scaling
	)

	return maxi(
		0,
		effect.base_damage + attribute_damage
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


func calculate_resolved_damage(
	attacker: CombatantState,
	target: CombatantState,
	effect: DamageEffect
) -> int:
	var raw_damage := calculate_raw_damage(
		attacker,
		effect
	)

	if raw_damage <= 0:
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