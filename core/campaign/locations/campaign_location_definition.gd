@tool
class_name CampaignLocationDefinition
extends Resource


const PLAYER_TEAM_ID: StringName = &"team_player"
const MAX_PARTY_SIZE: int = 3


@export_group("Identity")

@export
var location_id: StringName = &""

@export
var display_name: String = "Unnamed Location"

@export_multiline
var description: String = ""


@export_group("Battle")

@export
var encounter_definition: BattleEncounterDefinition

## Упорядоченные placeholder-spawn ID.
## Первый герой отряда получает первый spawn,
## второй — второй, третий — третий.
@export
var party_spawn_instance_ids: Array[StringName] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if location_id == &"":
		errors.append(
			"Campaign location ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Campaign location display name is empty."
		)

	if encounter_definition == null:
		errors.append(
			"Campaign location encounter is not assigned."
		)

	elif not encounter_definition.is_valid_definition():
		errors.append(
			"Campaign location encounter is invalid."
		)

	if party_spawn_instance_ids.is_empty():
		errors.append(
			"Campaign location has no party spawn slots."
		)

	if party_spawn_instance_ids.size() > MAX_PARTY_SIZE:
		errors.append(
			"Campaign location cannot contain "
			+"more than three party spawn slots."
		)

	var used_spawn_ids: Dictionary = {}

	for spawn_id in party_spawn_instance_ids:
		if spawn_id == &"":
			errors.append(
				"Campaign party spawn ID is empty."
			)

			continue

		if used_spawn_ids.has(
			spawn_id
		):
			errors.append(
				"Duplicate campaign party spawn ID: %s."
				% spawn_id
			)

			continue

		used_spawn_ids[
			spawn_id
		] = true

		if encounter_definition == null:
			continue

		var found_spawn: CombatantSpawnDefinition

		for spawn in encounter_definition.combatant_spawns:
			if (
				spawn != null
				and spawn.instance_id == spawn_id
			):
				found_spawn = spawn
				break

		if found_spawn == null:
			errors.append(
				"Campaign party spawn '%s' "
				% spawn_id
				+"does not exist in the encounter."
			)

			continue

		if found_spawn.team_id != PLAYER_TEAM_ID:
			errors.append(
				"Campaign party spawn '%s' "
				% spawn_id
				+"does not belong to the player team."
			)

	return errors