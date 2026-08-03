@tool
class_name CampaignLocationDefinition
extends Resource


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

## Instance ID игрока внутри encounter.
## При запуске кампании его HeroDefinition и
## HeroProgressionState заменяются состоянием кампании.
@export
var player_spawn_instance_id: StringName = &"debug_hero"


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

	if player_spawn_instance_id == &"":
		errors.append(
			"Campaign location player spawn ID is empty."
		)

	elif encounter_definition != null:
		var has_player_spawn := false

		for spawn in encounter_definition.combatant_spawns:
			if (
				spawn != null
				and spawn.instance_id
					== player_spawn_instance_id
			):
				has_player_spawn = true
				break

		if not has_player_spawn:
			errors.append(
				"Campaign location player spawn '%s' "
				% player_spawn_instance_id
				+"does not exist in the encounter."
			)

	return errors