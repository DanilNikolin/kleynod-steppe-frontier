@tool
class_name BattleEncounterDefinition
extends Resource


@export_group("Identity")

@export
var encounter_id: StringName = &""

@export
var display_name: String = "Unnamed Encounter"

@export_multiline
var description: String = ""


@export_group("Grid")

@export_range(1, 100, 1)
var rows: int = 3

@export_range(1, 100, 1)
var columns: int = 10


@export_group("Combatants")

@export
var combatant_spawns: Array[CombatantSpawnDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if encounter_id == &"":
		errors.append(
			"Encounter ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Encounter display name is empty."
		)

	if rows <= 0:
		errors.append(
			"Encounter must contain at least one row."
		)

	if columns <= 0:
		errors.append(
			"Encounter must contain at least one column."
		)

	if combatant_spawns.is_empty():
		errors.append(
			"Encounter must contain at least one combatant."
		)

	var used_instance_ids: Dictionary = {}
	var used_coordinates: Dictionary = {}
	var used_team_ids: Dictionary = {}

	for spawn_index in range(
		combatant_spawns.size()
	):
		var spawn := combatant_spawns[spawn_index]

		if spawn == null:
			errors.append(
				"Combatant spawn at index %d is null."
				% spawn_index
			)

			continue

		var spawn_errors := (
			spawn.get_validation_errors()
		)

		for spawn_error in spawn_errors:
			errors.append(
				"Combatant spawn %d: %s"
				% [
					spawn_index,
					spawn_error,
				]
			)

		if spawn.instance_id != &"":
			if used_instance_ids.has(
				spawn.instance_id
			):
				errors.append(
					"Duplicate combatant instance ID: %s."
					% spawn.instance_id
				)
			else:
				used_instance_ids[
					spawn.instance_id
				] = true

		if not is_coordinate_inside(
			spawn.coordinate
		):
			errors.append(
				"Combatant '%s' has an invalid "
				% spawn.instance_id
				+"start coordinate: %s."
				% spawn.coordinate
			)

		elif used_coordinates.has(
			spawn.coordinate
		):
			errors.append(
				"Multiple combatants use start "
				+"coordinate %s."
				% spawn.coordinate
			)

		else:
			used_coordinates[
				spawn.coordinate
			] = true

		if spawn.team_id != &"":
			used_team_ids[
				spawn.team_id
			] = true

	if used_team_ids.size() < 2:
		errors.append(
			"Encounter must contain combatants "
			+"from at least two teams."
		)

	return errors


func is_coordinate_inside(
	coordinate: Vector2i
) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)