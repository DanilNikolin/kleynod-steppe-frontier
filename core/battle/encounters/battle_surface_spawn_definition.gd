@tool
class_name BattleSurfaceSpawnDefinition
extends Resource


@export_group("Surface")

@export
var surface_definition: BattleSurfaceEffectDefinition


@export_group("Placement")

@export
var coordinate: Vector2i = Vector2i.ZERO


@export_group("Source")

## Необязательный конкретный автор поверхности.
## Должен ссылаться на стартового бойца encounter.
@export
var source_instance_id: StringName = &""

## Необязательная команда-владелец.
## Позволяет создавать командные поверхности
## без конкретного бойца-источника.
@export
var source_team_id: StringName = &""


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

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