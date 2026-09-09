@tool
class_name CampaignSettlementBuildingUpgradeDefinition
extends Resource


@export_group("Identity")

## Конкретное физическое состояние после улучшения.
##
## Может быть пустым для старого/debug-контента:
## тогда UI использует обычный номер уровня.
@export
var display_name: String = ""

## Описание конкретной стадии.
##
## Пока HOME находится в design-production,
## здесь также можно явно оставлять DEV-note
## о временных стоимости/requirements.
@export_multiline
var description: String = ""


@export_group("Progression")

## Уровень здания ПОСЛЕ применения этого улучшения.
## Например 2 означает переход I -> II.
@export_range(2, 99, 1)
var target_level: int = 2

@export
var upgrade_enabled: bool = false


@export_group("Cost")

@export_range(0, 999999999, 1)
var gold_cost: int = 0

@export_range(0, 999999999, 1)
var material_cost: int = 0

@export_range(0, 999999999, 1)
var duration_minutes: int = 0


@export_group("Effects")

## Derived effects, которые начинают действовать
## после достижения target_level.
##
## Они не сохраняются отдельно:
## активность всегда выводится из building_level.
@export
var active_effects: Array[CampaignSettlementEffectDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if target_level < 2:
		errors.append(
			"Building upgrade target level must be at least 2."
		)

	if gold_cost < 0:
		errors.append(
			"Building upgrade gold cost cannot be negative."
		)

	if material_cost < 0:
		errors.append(
			"Building upgrade material cost cannot be negative."
		)

	if duration_minutes < 0:
		errors.append(
			"Building upgrade duration cannot be negative."
		)

	if (
		upgrade_enabled
		and duration_minutes <= 0
	):
		errors.append(
			"Enabled building upgrade requires positive duration."
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
				"Building upgrade effect at index %d is null."
				% effect_index
			)

			continue

		for effect_error in (
			effect.get_validation_errors()
		):
			errors.append(
				"Building upgrade effect %d: %s"
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
				"Duplicate building upgrade effect ID: %s."
				% effect.effect_id
			)

			continue

		used_effect_ids[
			effect.effect_id
		] = true

	return errors