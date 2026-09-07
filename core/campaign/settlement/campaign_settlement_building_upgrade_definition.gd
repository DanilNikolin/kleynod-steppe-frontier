@tool
class_name CampaignSettlementBuildingUpgradeDefinition
extends Resource


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

	return errors