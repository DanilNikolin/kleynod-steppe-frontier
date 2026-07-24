@tool
class_name HeroEquipmentItemInstance
extends Resource


@export_group("Identity")

@export
var instance_id: StringName = &""


@export_group("Definition")

@export
var definition: HeroEquipmentItemDefinition


func is_valid_instance() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if instance_id == &"":
		errors.append(
			"Equipment instance ID is empty."
		)

	if definition == null:
		errors.append(
			"Equipment definition is not assigned."
		)

	elif not definition.is_valid_definition():
		errors.append(
			"Equipment definition is invalid."
		)

	return errors