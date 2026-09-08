@tool
class_name CampaignSettlementBuildingDefinition
extends Resource


@export_group("Identity")

@export
var building_id: StringName = &""

@export
var display_name: String = "Unnamed Building"

@export_multiline
var description: String = ""


@export_group("Construction")

## Пока false — здание существует в authored-зоопарке,
## но игрок ещё не может его строить.
@export
var construction_enabled: bool = false

@export_range(0, 999999999, 1)
var construction_gold_cost: int = 0

@export_range(0, 999999999, 1)
var construction_material_cost: int = 0

## Полная длительность строительства.
## Используем общий campaign clock.
@export_range(0, 999999999, 1)
var construction_minutes: int = 0

@export_group("Effects")

## Эффекты активны всё время,
## пока это здание физически существует.
##
## Они не сохраняются отдельно:
## активный набор всегда выводится
## из текущего SettlementState.
@export
var active_effects: Array[CampaignSettlementEffectDefinition] = []


@export_group("Economy")

## Пассивный Gold за одну пройденную границу сезона.
##
## Индекс 0 = уровень I,
## индекс 1 = уровень II и т.д.
##
## Пустой массив означает отсутствие
## пассивного дохода.
@export
var seasonal_gold_income_by_level: PackedInt32Array = (
	PackedInt32Array()
)


@export_group("Progression")

@export_range(1, 99, 1)
var max_level: int = 3

@export
var upgrades: Array[CampaignSettlementBuildingUpgradeDefinition] = []


func get_upgrade_to_level(
	target_level: int
) -> CampaignSettlementBuildingUpgradeDefinition:
	for upgrade in upgrades:
		if (
			upgrade != null
			and upgrade.target_level == target_level
		):
			return upgrade

	return null


func get_next_upgrade(
	current_level: int
) -> CampaignSettlementBuildingUpgradeDefinition:
	return get_upgrade_to_level(
		current_level + 1
	)


func get_seasonal_gold_income(
	building_level: int
) -> int:
	if building_level <= 0:
		return 0

	var index := building_level - 1

	if (
		index < 0
		or index
			>= seasonal_gold_income_by_level.size()
	):
		return 0

	return maxi(
		seasonal_gold_income_by_level[index],
		0
	)


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if building_id == &"":
		errors.append(
			"Settlement building ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Settlement building display name is empty."
		)

	if construction_gold_cost < 0:
		errors.append(
			"Settlement building gold cost cannot be negative."
		)

	if construction_material_cost < 0:
		errors.append(
			"Settlement building material cost cannot be negative."
		)

	if construction_minutes < 0:
		errors.append(
			"Settlement building construction time cannot be negative."
		)

	if (
		construction_enabled
		and construction_minutes <= 0
	):
		errors.append(
			"Enabled settlement construction requires positive time."
		)

	var used_effect_ids: Dictionary = {}

	for effect_index in range(
		active_effects.size()
	):
		var effect := active_effects[
			effect_index
		]

		if effect == null:
			errors.append(
				"Settlement effect at index %d is null."
				% effect_index
			)

			continue

		for effect_error in (
			effect.get_validation_errors()
		):
			errors.append(
				"Settlement effect %d: %s"
				% [
					effect_index,
					effect_error,
				]
			)

		if effect.effect_id == &"":
			continue

		if used_effect_ids.has(
			effect.effect_id
		):
			errors.append(
				"Duplicate settlement effect ID: %s."
				% effect.effect_id
			)

			continue

		used_effect_ids[
			effect.effect_id
		] = true

	if max_level <= 0:
		errors.append(
			"Settlement building max level must be positive."
		)

	var used_upgrade_levels: Dictionary = {}

	for upgrade_index in range(
		upgrades.size()
	):
		var upgrade := upgrades[
			upgrade_index
		]

		if upgrade == null:
			errors.append(
				"Building upgrade at index %d is null."
				% upgrade_index
			)

			continue

		for upgrade_error in (
			upgrade.get_validation_errors()
		):
			errors.append(
				"Building upgrade %d: %s"
				% [
					upgrade_index,
					upgrade_error,
				]
			)

		if upgrade.target_level > max_level:
			errors.append(
				"Building upgrade target level %d exceeds max level %d."
				% [
					upgrade.target_level,
					max_level,
				]
			)

		if used_upgrade_levels.has(
			upgrade.target_level
		):
			errors.append(
				"Duplicate building upgrade target level: %d."
				% upgrade.target_level
			)

			continue

		used_upgrade_levels[
			upgrade.target_level
		] = true

	if (
		seasonal_gold_income_by_level.size()
		> max_level
	):
		errors.append(
			"Seasonal income defines more levels "
			+ "than the building max level."
		)

	for income_index in range(
		seasonal_gold_income_by_level.size()
	):
		if (
			seasonal_gold_income_by_level[
				income_index
			]
			< 0
		):
			errors.append(
				"Seasonal income for building level %d "
				% (income_index + 1)
				+ "cannot be negative."
			)

	return errors