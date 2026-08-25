@tool
class_name HeroEquipmentItemDefinition
extends Resource


enum Category {
	WEAPON,
	HEAD,
	ARMOR,
	GLOVES,
	BOOTS,
	CHARM,
	RING,
}


@export_group("Identity")

@export
var item_id: StringName = &""

@export
var display_name: String = "Unnamed Equipment"

@export_multiline
var description: String = ""


@export_group("Slot")

@export
var category: Category = Category.WEAPON

## Только оружие может быть двуручным.
## Двуручное оружие занимает Weapon 1 и Weapon 2.
@export
var is_two_handed: bool = false


@export_group("Stats")

@export
var stat_bonuses: HeroBuildStatBonuses


@export_group("Abilities")

## Основной приём оружия.
## Если оружие экипировано, он заменяет
## fallback-атаку героя.
##
## Не занимает личный активный слот.
@export
var primary_ability: AbilityDefinition

## Предмет может давать от нуля до двух активных способностей.
## Они не занимают личные активные слоты героя.
@export
var granted_abilities: Array[AbilityDefinition] = []


@export_group("Loot")

## Сколько reward budget поглощает предмет.
## 0 означает, что предмет не участвует
## в обычном random loot.
@export_range(0, 999999, 1)
var loot_value: int = 0

## Максимальный loot tier, необходимый
## для выпадения предмета.
@export_range(0, 99, 1)
var loot_tier: int = 0

## Относительный вес среди уже допустимых
## предметов.
@export_range(1, 100000, 1)
var loot_weight: int = 100

## Абсолютная редкость конкретного предмета.
## Проверяется ДО weighted selection.
@export_range(0, 100, 1)
var loot_drop_chance_percent: int = 100

## Тематические источники предмета.
## Пустой массив = generic loot.
@export
var loot_tags: Array[StringName] = []


func is_loot_enabled() -> bool:
	return (
		loot_value > 0
		and loot_tier > 0
	)
	
func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if item_id == &"":
		errors.append(
			"Equipment item ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Equipment display name is empty."
		)

	if (
		is_two_handed
		and category != Category.WEAPON
	):
		errors.append(
			"Only weapons can be two-handed."
		)

	if granted_abilities.size() > 2:
		errors.append(
			"Equipment item cannot grant "
			+"more than two abilities."
		)

	if stat_bonuses != null:
		if (
			stat_bonuses.strength_rank_bonus != 0
			or stat_bonuses.agility_rank_bonus != 0
			or stat_bonuses.spirit_rank_bonus != 0
		):
			errors.append(
				"Equipment cannot directly modify "
				+"ability branch ranks."
			)

		if stat_bonuses.active_slot_bonus != 0:
			errors.append(
				"Equipment cannot modify personal "
				+"active slot count."
			)

	var used_ability_ids: Dictionary = {}

	if primary_ability != null:
		if category != Category.WEAPON:
			errors.append(
				"Only weapons can define "
				+"a primary ability."
			)

		for ability_error in (
			primary_ability.get_validation_errors()
		):
			errors.append(
				"Primary ability: %s"
				% ability_error
			)

		if primary_ability.ability_id != &"":
			used_ability_ids[
				primary_ability.ability_id
			] = true

	for ability_index in range(
		granted_abilities.size()
	):
		var ability := granted_abilities[
			ability_index
		]

		if ability == null:
			errors.append(
				"Granted ability at index %d is null."
				% ability_index
			)

			continue

		for ability_error in (
			ability.get_validation_errors()
		):
			errors.append(
				"Granted ability %d: %s"
				% [
					ability_index,
					ability_error,
				]
			)

		if ability.ability_id == &"":
			continue

		if used_ability_ids.has(
			ability.ability_id
		):
			errors.append(
				"Duplicate granted ability ID: %s."
				% ability.ability_id
			)

			continue

		used_ability_ids[
			ability.ability_id
		] = true

	if (
		loot_value > 0
		and loot_tier <= 0
	):
		errors.append(
			"Loot-enabled equipment requires a positive loot tier."
		)

	if (
		loot_tier > 0
		and loot_value <= 0
	):
		errors.append(
			"Loot tier requires a positive loot value."
		)

	if loot_weight <= 0:
		errors.append(
			"Loot weight must be greater than zero."
		)

	if (
		loot_drop_chance_percent < 0
		or loot_drop_chance_percent > 100
	):
		errors.append(
			"Loot drop chance must be between 0 and 100."
		)

	var used_loot_tags: Dictionary = {}

	for tag in loot_tags:
		if tag == &"":
			errors.append(
				"Loot tag cannot be empty."
			)

			continue

		if used_loot_tags.has(
			tag
		):
			errors.append(
				"Duplicate loot tag: %s."
				% tag
			)

			continue

		used_loot_tags[
			tag
		] = true
		
	return errors