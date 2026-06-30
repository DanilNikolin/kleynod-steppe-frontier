@tool
class_name BattleReinforcementWaveDefinition
extends Resource


@export_group("Identity")

@export
var wave_id: StringName = &""

@export
var display_name: String = "Reinforcement Wave"


@export_group("Schedule")

@export_range(1, 1000, 1)
var round_number: int = 2


@export_group("Combatants")

@export
var combatant_spawns: Array[CombatantSpawnDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if wave_id == &"":
		errors.append(
			"Reinforcement wave ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Reinforcement wave display name is empty."
		)

	if round_number <= 0:
		errors.append(
			"Reinforcement wave round must be positive."
		)

	if combatant_spawns.is_empty():
		errors.append(
			"Reinforcement wave has no combatants."
		)

	var used_instance_ids: Dictionary = {}

	for spawn_index in range(
		combatant_spawns.size()
	):
		var spawn := combatant_spawns[spawn_index]

		if spawn == null:
			errors.append(
				"Reinforcement spawn at index %d is null."
				% spawn_index
			)

			continue

		for spawn_error in spawn.get_validation_errors():
			errors.append(
				"Reinforcement spawn %d: %s"
				% [
					spawn_index,
					spawn_error,
				]
			)

		if spawn.instance_id == &"":
			continue

		if used_instance_ids.has(
			spawn.instance_id
		):
			errors.append(
				"Duplicate reinforcement instance ID: %s."
				% spawn.instance_id
			)
		else:
			used_instance_ids[
				spawn.instance_id
			] = true

	return errors