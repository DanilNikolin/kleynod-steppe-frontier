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


@export_group("Hero Build")

## Если HeroDefinition задан, боец собирается
## через HeroBattleBuildResolver.
##
## Обычные враги продолжают использовать
## combatant_definition и loadout_override.
@export
var hero_definition: HeroDefinition

@export
var hero_progression_state: HeroProgressionState


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

	if team_id == &"":
		errors.append(
			"Team ID is empty."
		)

	if hero_definition != null:
		if not hero_definition.is_valid_definition():
			errors.append(
				"Hero definition is invalid."
			)

		if hero_progression_state == null:
			errors.append(
				"Hero progression state is not assigned."
			)

		elif not hero_progression_state.is_valid_state():
			errors.append(
				"Hero progression state is invalid."
			)

	else:
		if combatant_definition == null:
			errors.append(
				"Combatant definition is not assigned."
			)

		elif not combatant_definition.is_valid_definition():
			errors.append(
				"Combatant definition is invalid."
			)

	var battle_build := create_battle_build()

	if battle_build == null:
		errors.append(
			"Combatant battle build could not be created."
		)

	elif not battle_build.is_valid():
		errors.append(
			"Combatant battle build is invalid."
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


func create_battle_build() -> HeroBattleBuild:
	if hero_definition != null:
		if hero_progression_state == null:
			return null

		var hero_resolver := (
			HeroBattleBuildResolver.new()
		)

		return hero_resolver.resolve(
			hero_definition,
			hero_progression_state
		)

	if combatant_definition == null:
		return null

	var source_loadout := (
		loadout_override
		if loadout_override != null
		else combatant_definition.default_loadout
	)

	if source_loadout == null:
		return null

	var loadout_resolver := (
		CombatantLoadoutRuntimeResolver.new()
	)

	var resolved_loadout := (
		loadout_resolver.resolve(
			source_loadout,
			combatant_definition.base_strength,
			combatant_definition.base_agility,
			combatant_definition.base_spirit
		)
	)

	if resolved_loadout == null:
		return null

	var result := HeroBattleBuild.new()

	result.combatant_definition = (
		combatant_definition
	)

	result.loadout = resolved_loadout

	result.strength_rank = (
		combatant_definition.base_strength
	)

	result.agility_rank = (
		combatant_definition.base_agility
	)

	result.spirit_rank = (
		combatant_definition.base_spirit
	)

	result.active_slot_count = (
		resolved_loadout.abilities.size()
	)

	for ability in resolved_loadout.get_abilities():
		result.known_personal_ability_ids.append(
			ability.ability_id
		)

		result.selected_personal_ability_ids.append(
			ability.ability_id
		)

	return result


func get_effective_combatant_definition() -> CombatantDefinition:
	var battle_build := create_battle_build()

	if battle_build == null:
		return null

	return battle_build.combatant_definition


func get_effective_loadout() -> CombatantLoadoutDefinition:
	var battle_build := create_battle_build()

	if battle_build == null:
		return null

	return battle_build.loadout


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