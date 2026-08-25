@tool
class_name HeroBuildStatBonuses
extends Resource


@export_group("Ability Branches")

@export_range(-99, 99, 1)
var strength_rank_bonus: int = 0

@export_range(-99, 99, 1)
var agility_rank_bonus: int = 0

@export_range(-99, 99, 1)
var spirit_rank_bonus: int = 0


@export_group("Battle Stats")

@export_range(-999, 999, 1)
var max_health_bonus: int = 0

@export_range(-99, 99, 1)
var armor_bonus: int = 0

@export_range(-99, 99, 1)
var max_stamina_bonus: int = 0

@export_range(-99, 99, 1)
var start_stamina_bonus: int = 0

@export_range(-99, 99, 1)
var stamina_regeneration_bonus: int = 0

@export_range(-999, 999, 1)
var start_guard_bonus: int = 0

@export_range(-100, 100, 1)
var crit_chance_bonus_percent: int = 0

@export_range(-100, 999, 1)
var crit_damage_bonus_percent: int = 0

@export_range(-99, 99, 1)
var health_regeneration_every_two_turns_bonus: int = 0

@export_range(-99, 99, 1)
var guard_regeneration_every_two_turns_bonus: int = 0


@export_group("Hero Build")

@export_range(-6, 6, 1)
var active_slot_bonus: int = 0


func clear() -> void:
	strength_rank_bonus = 0
	agility_rank_bonus = 0
	spirit_rank_bonus = 0

	max_health_bonus = 0
	armor_bonus = 0
	max_stamina_bonus = 0
	start_stamina_bonus = 0
	stamina_regeneration_bonus = 0
	start_guard_bonus = 0
	crit_chance_bonus_percent = 0
	crit_damage_bonus_percent = 0
	health_regeneration_every_two_turns_bonus = 0
	guard_regeneration_every_two_turns_bonus = 0

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

	stamina_regeneration_bonus += (
		source.stamina_regeneration_bonus
	)

	start_guard_bonus += (
		source.start_guard_bonus
	)

	crit_chance_bonus_percent += (
		source.crit_chance_bonus_percent
	)

	crit_damage_bonus_percent += (
		source.crit_damage_bonus_percent
	)

	health_regeneration_every_two_turns_bonus += (
		source.health_regeneration_every_two_turns_bonus
	)

	guard_regeneration_every_two_turns_bonus += (
		source.guard_regeneration_every_two_turns_bonus
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
		and stamina_regeneration_bonus == 0
		and start_guard_bonus == 0
		and crit_chance_bonus_percent == 0
		and crit_damage_bonus_percent == 0
		and health_regeneration_every_two_turns_bonus == 0
		and guard_regeneration_every_two_turns_bonus == 0
		and active_slot_bonus == 0
	)