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


@export_group("Progression")

@export_range(1, 99, 1)
var max_level: int = 3


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

	if max_level <= 0:
		errors.append(
			"Settlement building max level must be positive."
		)

	return errors