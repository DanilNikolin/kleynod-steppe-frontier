@tool
class_name CombatantSpawnDefinition
extends Resource


@export_group("Identity")

@export
var instance_id: StringName = &""

@export
var combatant_definition: CombatantDefinition

@export
var team_id: StringName = &""


@export_group("Placement")

@export
var coordinate: Vector2i = Vector2i.ZERO


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if instance_id == &"":
		errors.append(
			"Combatant instance ID is empty."
		)

	if combatant_definition == null:
		errors.append(
			"Combatant definition is not assigned."
		)

	elif not combatant_definition.is_valid_definition():
		errors.append(
			"Combatant definition is invalid."
		)

	if team_id == &"":
		errors.append(
			"Team ID is empty."
		)

	return errors