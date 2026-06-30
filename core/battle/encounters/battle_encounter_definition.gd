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
var rows: int = 5

@export_range(1, 100, 1)
var columns: int = 10

@export_group("Sides")

@export
var side_rules: BattleSideRules = BattleSideRules.new()

@export_group("Initial Combatants")

@export
var combatant_spawns: Array[CombatantSpawnDefinition] = []


@export
var reinforcement_waves: Array[BattleReinforcementWaveDefinition] = []


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

	if side_rules == null:
		errors.append(
			"Battle side rules are not assigned."
		)

	else:
		for side_error in (
			side_rules.get_validation_errors(
				columns
			)
		):
			errors.append(
				"Battle sides: %s"
				% side_error
			)
	if combatant_spawns.is_empty():
		errors.append(
			"Encounter must contain at least one "
			+"initial combatant."
		)

	var used_instance_ids: Dictionary = {}
	var used_initial_coordinates: Dictionary = {}
	var used_team_ids: Dictionary = {}
	var used_wave_ids: Dictionary = {}

	for spawn_index in range(
		combatant_spawns.size()
	):
		var spawn := combatant_spawns[spawn_index]

		if spawn == null:
			errors.append(
				"Initial combatant spawn at index %d is null."
				% spawn_index
			)

			continue

		for spawn_error in spawn.get_validation_errors():
			errors.append(
				"Initial combatant spawn %d: %s"
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
				"Initial combatant '%s' has an invalid "
				% spawn.instance_id
				+"start coordinate: %s."
				% spawn.coordinate
			)

		elif used_initial_coordinates.has(
			spawn.coordinate
		):
			errors.append(
				"Multiple initial combatants use "
				+"coordinate %s."
				% spawn.coordinate
			)

		else:
			used_initial_coordinates[
				spawn.coordinate
			] = true

		if spawn.team_id != &"":
			used_team_ids[
				spawn.team_id
			] = true

		if (
			side_rules != null
			and spawn.team_id != &""
		):
			if not side_rules.is_team_supported(
				spawn.team_id
			):
				errors.append(
					"Initial combatant '%s' uses "
					% spawn.instance_id
					+"unsupported team ID: %s."
					% spawn.team_id
				)

			elif (
				is_coordinate_inside(
					spawn.coordinate
				)
				and not side_rules.is_coordinate_allowed(
					spawn.team_id,
					spawn.coordinate,
					rows,
					columns
				)
			):
				errors.append(
					"Initial combatant '%s' starts "
					% spawn.instance_id
					+"outside its team side: %s."
					% spawn.coordinate
				)

	for wave_index in range(
		reinforcement_waves.size()
	):
		var wave := reinforcement_waves[wave_index]

		if wave == null:
			errors.append(
				"Reinforcement wave at index %d is null."
				% wave_index
			)

			continue

		for wave_error in wave.get_validation_errors():
			errors.append(
				"Reinforcement wave %d: %s"
				% [
					wave_index,
					wave_error,
				]
			)

		if wave.wave_id != &"":
			if used_wave_ids.has(
				wave.wave_id
			):
				errors.append(
					"Duplicate reinforcement wave ID: %s."
					% wave.wave_id
				)
			else:
				used_wave_ids[
					wave.wave_id
				] = true

		for spawn_index in range(
			wave.combatant_spawns.size()
		):
			var spawn := (
				wave.combatant_spawns[
					spawn_index
				]
			)

			if spawn == null:
				continue

			if spawn.instance_id != &"":
				if used_instance_ids.has(
					spawn.instance_id
				):
					errors.append(
						"Duplicate combatant instance ID "
						+"across encounter: %s."
						% spawn.instance_id
					)
				else:
					used_instance_ids[
						spawn.instance_id
					] = true

			if spawn.team_id != &"":
				used_team_ids[
					spawn.team_id
				] = true

			if (
				side_rules != null
				and spawn.team_id != &""
				and not side_rules.is_team_supported(
					spawn.team_id
				)
			):
				errors.append(
					"Reinforcement combatant '%s' uses "
					% spawn.instance_id
					+"unsupported team ID: %s."
					% spawn.team_id
				)

			for candidate_coordinate in (
				spawn.get_candidate_coordinates()
			):
				if not is_coordinate_inside(
					candidate_coordinate
				):
					errors.append(
						"Reinforcement combatant '%s' "
						% spawn.instance_id
						+"has an invalid candidate "
						+"coordinate: %s."
						% candidate_coordinate
					)

					continue

				if (
					side_rules != null
					and side_rules.is_team_supported(
						spawn.team_id
					)
					and not side_rules.is_coordinate_allowed(
						spawn.team_id,
						candidate_coordinate,
						rows,
						columns
					)
				):
					errors.append(
						"Reinforcement combatant '%s' "
						% spawn.instance_id
						+"has a candidate outside "
						+"its team side: %s."
						% candidate_coordinate
					)

	if used_team_ids.size() < 2:
		errors.append(
			"Encounter must contain combatants "
			+"from at least two teams, including "
			+"reinforcement waves."
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