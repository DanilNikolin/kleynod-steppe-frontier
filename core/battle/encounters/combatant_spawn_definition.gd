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


@export_group("Loadout")

@export
var loadout_override: CombatantLoadoutDefinition


@export_group("Placement")

@export
var coordinate: Vector2i = Vector2i.ZERO

@export
var fallback_coordinates: Array[Vector2i] = []


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

	var effective_loadout := (
		get_effective_loadout()
	)

	if effective_loadout == null:
		errors.append(
			"Combatant loadout is not assigned."
		)

	elif not effective_loadout.is_valid_definition():
		errors.append(
			"Combatant loadout is invalid."
		)

	var used_coordinates: Dictionary = {
		coordinate: true,
	}

	for fallback_coordinate in fallback_coordinates:
		if used_coordinates.has(
			fallback_coordinate
		):
			errors.append(
				"Duplicate spawn candidate coordinate: %s."
				% fallback_coordinate
			)

			continue

		used_coordinates[
			fallback_coordinate
		] = true

	return errors
func get_effective_loadout() -> CombatantLoadoutDefinition:
	if loadout_override != null:
		return loadout_override

	if combatant_definition == null:
		return null

	return combatant_definition.default_loadout



func get_candidate_coordinates() -> Array[Vector2i]:
	var result: Array[Vector2i] = [
		coordinate,
	]

	for fallback_coordinate in fallback_coordinates:
		if result.has(
			fallback_coordinate
		):
			continue

		result.append(
			fallback_coordinate
		)

	return result