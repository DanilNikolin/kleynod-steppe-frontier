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

	if max_level <= 0:
		errors.append(
			"Settlement building max level must be positive."
		)

	return errors