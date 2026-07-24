class_name HeroBuildStatBonuses
extends RefCounted


## Ветки роста способностей.
var strength_rank_bonus: int = 0
var agility_rank_bonus: int = 0
var spirit_rank_bonus: int = 0

## Постоянные боевые параметры сборки.
var max_health_bonus: int = 0
var armor_bonus: int = 0
var max_stamina_bonus: int = 0
var start_stamina_bonus: int = 0

## Параметры личной сборки героя.
var active_slot_bonus: int = 0


func clear() -> void:
	strength_rank_bonus = 0
	agility_rank_bonus = 0
	spirit_rank_bonus = 0

	max_health_bonus = 0
	armor_bonus = 0
	max_stamina_bonus = 0
	start_stamina_bonus = 0

	active_slot_bonus = 0


func add_from(
	source: HeroBuildStatBonuses
) -> void:
	if source == null:
		return

	strength_rank_bonus += (
		source.strength_rank_bonus
	)

	agility_rank_bonus += (
		source.agility_rank_bonus
	)

	spirit_rank_bonus += (
		source.spirit_rank_bonus
	)

	max_health_bonus += (
		source.max_health_bonus
	)

	armor_bonus += (
		source.armor_bonus
	)

	max_stamina_bonus += (
		source.max_stamina_bonus
	)

	start_stamina_bonus += (
		source.start_stamina_bonus
	)

	active_slot_bonus += (
		source.active_slot_bonus
	)


func create_copy() -> HeroBuildStatBonuses:
	var result := HeroBuildStatBonuses.new()

	result.add_from(
		self
	)

	return result


func is_zero() -> bool:
	return (
		strength_rank_bonus == 0
		and agility_rank_bonus == 0
		and spirit_rank_bonus == 0
		and max_health_bonus == 0
		and armor_bonus == 0
		and max_stamina_bonus == 0
		and start_stamina_bonus == 0
		and active_slot_bonus == 0
	)