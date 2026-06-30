@tool
class_name BattleEffect
extends Resource


@export_group("Identity")

@export
var effect_id: StringName = &""


func is_valid_effect() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if effect_id == &"":
		errors.append("Effect ID is empty.")

	return errors