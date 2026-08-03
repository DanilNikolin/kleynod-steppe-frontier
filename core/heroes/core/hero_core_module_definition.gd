@tool
class_name HeroCoreModuleDefinition
extends Resource


@export_group("Identity")

@export
var core_id: StringName = &""

@export
var display_name: String = "Unnamed Hero Core"

@export_multiline
var description: String = ""


func create_runtime_state(
	owner
) -> HeroCoreRuntimeState:
	if owner == null:
		return null

	if not is_valid_definition():
		return null

	var result := HeroCoreRuntimeState.new()

	result.initialize(
		self,
		owner
	)

	return result


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if core_id == &"":
		errors.append(
			"Hero Core ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Hero Core display name is empty."
		)

	return errors
