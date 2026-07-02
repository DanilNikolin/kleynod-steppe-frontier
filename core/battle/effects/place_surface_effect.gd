@tool
class_name PlaceSurfaceEffect
extends BattleEffect


@export_group("Surface")

@export
var surface_definition: BattleSurfaceEffectDefinition


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if surface_definition == null:
		errors.append(
			"Surface definition is not assigned."
		)

		return errors

	for definition_error in (
		surface_definition.get_validation_errors()
	):
		errors.append(
			"Surface: %s"
			% definition_error
		)

	return errors