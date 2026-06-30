@tool
class_name ApplyStatusEffect
extends BattleEffect


@export_group("Status")

@export
var status_definition: BattleStatusDefinition


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if status_definition == null:
		errors.append(
			"Status definition is not assigned."
		)

		return errors

	for status_error in (
		status_definition.get_validation_errors()
	):
		errors.append(
			"Status: %s"
			% status_error
		)

	return errors