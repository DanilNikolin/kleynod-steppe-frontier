@tool
class_name CampaignSettlementEffectDefinition
extends Resource


@export_group("Identity")

@export
var effect_id: StringName = &""

@export
var display_name: String = "Unnamed Settlement Effect"

@export_multiline
var description: String = ""


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if effect_id == &"":
		errors.append(
			"Settlement effect ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Settlement effect display name is empty."
		)

	return errors