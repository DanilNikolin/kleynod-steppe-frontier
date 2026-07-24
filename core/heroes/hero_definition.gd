@tool
class_name HeroDefinition
extends Resource


@export_group("Identity")

@export
var hero_id: StringName = &""

@export
var display_name: String = "Unnamed Hero"

@export_multiline
var description: String = ""


@export_group("Battle")

@export
var base_combatant_definition: CombatantDefinition


@export_group("Skill Grid")

@export
var skill_grid: SkillGridDefinition


@export_group("Personal Abilities")

@export
var personal_abilities: Array[AbilityDefinition] = []

@export
var starting_known_ability_ids: Array[StringName] = []

@export
var default_ability_id: StringName = &""


@export_group("Active Slots")

@export_range(1, 6, 1)
var starting_active_slot_count: int = 1

@export_range(1, 6, 1)
var maximum_active_slot_count: int = 6


func get_personal_ability(
	ability_id: StringName
) -> AbilityDefinition:
	if ability_id == &"":
		return null

	for ability in personal_abilities:
		if (
			ability != null
			and ability.ability_id == ability_id
		):
			return ability

	return null


func has_personal_ability(
	ability_id: StringName
) -> bool:
	return get_personal_ability(
		ability_id
	) != null


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if hero_id == &"":
		errors.append(
			"Hero ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Hero display name is empty."
		)

	if base_combatant_definition == null:
		errors.append(
			"Base CombatantDefinition is not assigned."
		)

	elif not base_combatant_definition.is_valid_definition():
		errors.append(
			"Base CombatantDefinition is invalid."
		)

	if skill_grid == null:
		errors.append(
			"Hero Skill Grid is not assigned."
		)

	elif not skill_grid.is_valid_definition():
		errors.append(
			"Hero Skill Grid is invalid."
		)

	if personal_abilities.is_empty():
		errors.append(
			"Hero must contain personal abilities."
		)

	var personal_ability_ids: Dictionary = {}

	for ability_index in range(
		personal_abilities.size()
	):
		var ability := personal_abilities[
			ability_index
		]

		if ability == null:
			errors.append(
				"Personal ability at index %d is null."
				% ability_index
			)

			continue

		if not ability.is_valid_definition():
			errors.append(
				"Personal ability '%s' is invalid."
				% ability.ability_id
			)

		if personal_ability_ids.has(
			ability.ability_id
		):
			errors.append(
				"Duplicate personal ability ID: %s."
				% ability.ability_id
			)

			continue

		personal_ability_ids[
			ability.ability_id
		] = true

	var used_starting_ids: Dictionary = {}

	for ability_id in starting_known_ability_ids:
		if not personal_ability_ids.has(
			ability_id
		):
			errors.append(
				"Starting ability '%s' is not "
				% ability_id
				+"in the personal ability pool."
			)

		if used_starting_ids.has(
			ability_id
		):
			errors.append(
				"Duplicate starting ability ID: %s."
				% ability_id
			)

			continue

		used_starting_ids[
			ability_id
		] = true

	if default_ability_id == &"":
		errors.append(
			"Hero default ability ID is empty."
		)

	elif not used_starting_ids.has(
		default_ability_id
	):
		errors.append(
			"Hero default ability must be "
			+"known at the start."
		)

	if starting_active_slot_count <= 0:
		errors.append(
			"Starting active slot count "
			+"must be greater than zero."
		)

	if (
		maximum_active_slot_count
		< starting_active_slot_count
	):
		errors.append(
			"Maximum active slot count cannot "
			+"be lower than the starting count."
		)

	if skill_grid != null:
		for node in skill_grid.nodes:
			if (
				node == null
				or node.node_type
					!= SkillGridNodeDefinition
						.NodeType
						.LEARN_ABILITY
				or node.granted_ability == null
			):
				continue

			if not personal_ability_ids.has(
				node.granted_ability.ability_id
			):
				errors.append(
					"Skill Grid ability '%s' is not "
					% node.granted_ability.ability_id
					+"in the hero personal ability pool."
				)

	return errors