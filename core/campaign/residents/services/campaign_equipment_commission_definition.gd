@tool
class_name CampaignEquipmentCommissionDefinition
extends Resource


@export_group("Identity")

@export
var commission_id: StringName = &""

@export
var display_name: String = "Unnamed Commission"

@export_multiline
var description: String = ""


@export_group("Output")

@export
var output_item_definition: HeroEquipmentItemDefinition


@export_group("Cost")

@export_range(0, 999999999, 1)
var gold_cost: int = 0

@export_range(0, 999999999, 1)
var material_cost: int = 0

@export_range(1, 999999999, 1)
var duration_minutes: int = 60


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if commission_id == &"":
		errors.append(
			"Equipment commission ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Equipment commission display name is empty."
		)

	if output_item_definition == null:
		errors.append(
			"Equipment commission output item is missing."
		)

	elif not output_item_definition.is_valid_definition():
		errors.append(
			"Equipment commission output item is invalid."
		)

	if gold_cost < 0:
		errors.append(
			"Equipment commission gold cost cannot be negative."
		)

	if material_cost < 0:
		errors.append(
			"Equipment commission material cost cannot be negative."
		)

	if duration_minutes <= 0:
		errors.append(
			"Equipment commission duration must be positive."
		)

	return errors