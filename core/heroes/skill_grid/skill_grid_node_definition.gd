@tool
class_name SkillGridNodeDefinition
extends Resource


enum NodeType {
	BRANCH_RANK,
	LEARN_ABILITY,
	ACTIVE_SLOT,
	HERO_CORE,
	UTILITY,
	GEAR_SYNERGY,
	RARE_STAT,
}


enum Branch {
	NONE,
	STRENGTH,
	AGILITY,
	SPIRIT,
}


enum RareStat {
	NONE,
	MAX_HEALTH,
	MAX_STAMINA,
	START_STAMINA,
	ARMOR,
	STAMINA_REGENERATION,
	START_GUARD,
	CRIT_CHANCE_PERCENT,
	CRIT_DAMAGE_PERCENT,
	HEALTH_REGENERATION_EVERY_TWO_TURNS,
	GUARD_REGENERATION_EVERY_TWO_TURNS,
}


@export_group("Identity")

@export
var node_id: StringName = &""

@export
var display_name: String = "Unnamed Node"

@export_multiline
var description: String = ""

@export
var node_type: NodeType = NodeType.BRANCH_RANK

@export_range(1, 99, 1)
var skill_point_cost: int = 1


@export_group("Block")

@export
var block_id: StringName = &""

@export
var ui_position: Vector2 = Vector2.ZERO


@export_group("Dependencies")

@export
var prerequisite_node_ids: Array[StringName] = []

## Физические дорожки Skill Grid.
## Если массив содержит несколько нод,
## достаточно купить ЛЮБУЮ одну из них.
@export
var path_parent_node_ids: Array[StringName] = []


@export_group("Branch Rank")

@export
var branch: Branch = Branch.NONE

@export_range(1, 10, 1)
var branch_rank_amount: int = 1


@export_group("Ability")

@export
var granted_ability: AbilityDefinition


@export_group("Active Slots")

@export_range(1, 6, 1)
var active_slot_amount: int = 1


@export_group("Feature")

## Используется HERO_CORE, UTILITY и GEAR_SYNERGY.
##
## Пока это data-driven идентификатор открытого правила.
## Конкретное выполнение правила подключим позднее.
@export
var feature_id: StringName = &""


@export_group("Rare Stat")

@export
var rare_stat: RareStat = RareStat.NONE

@export_range(1, 999, 1)
var rare_stat_amount: int = 1


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if node_id == &"":
		errors.append(
			"Skill Grid node ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Skill Grid node display name is empty."
		)

	if skill_point_cost <= 0:
		errors.append(
			"Skill Point cost must be greater than zero."
		)

	var used_prerequisite_ids: Dictionary = {}

	for prerequisite_id in prerequisite_node_ids:
		if prerequisite_id == &"":
			errors.append(
				"Prerequisite node ID is empty."
			)

			continue

		if prerequisite_id == node_id:
			errors.append(
				"Node cannot require itself."
			)

		if used_prerequisite_ids.has(
			prerequisite_id
		):
			errors.append(
				"Duplicate prerequisite node ID: %s."
				% prerequisite_id
			)

			continue

		used_prerequisite_ids[
			prerequisite_id
		] = true

	var used_path_parent_ids: Dictionary = {}

	for path_parent_id in path_parent_node_ids:
		if path_parent_id == &"":
			errors.append(
				"Path parent node ID is empty."
			)

			continue

		if path_parent_id == node_id:
			errors.append(
				"Node cannot have itself as path parent."
			)

		if used_path_parent_ids.has(
			path_parent_id
		):
			errors.append(
				"Duplicate path parent node ID: %s."
				% path_parent_id
			)

			continue

		if used_prerequisite_ids.has(
			path_parent_id
		):
			errors.append(
				"Node ID '%s' cannot be both prerequisite and path parent."
				% path_parent_id
			)

		used_path_parent_ids[
			path_parent_id
		] = true

	match node_type:
		NodeType.BRANCH_RANK:
			if branch == Branch.NONE:
				errors.append(
					"Branch Rank node must select a branch."
				)

			if branch_rank_amount <= 0:
				errors.append(
					"Branch Rank amount must be positive."
				)

		NodeType.LEARN_ABILITY:
			if granted_ability == null:
				errors.append(
					"Learn Ability node has no ability."
				)

			elif not granted_ability.is_valid_definition():
				errors.append(
					"Learn Ability node contains "
					+"an invalid ability."
				)

		NodeType.ACTIVE_SLOT:
			if active_slot_amount <= 0:
				errors.append(
					"Active Slot amount must be positive."
				)

		NodeType.HERO_CORE, \
		NodeType.UTILITY, \
		NodeType.GEAR_SYNERGY:
			if feature_id == &"":
				errors.append(
					"Feature node requires a feature ID."
				)

		NodeType.RARE_STAT:
			if rare_stat == RareStat.NONE:
				errors.append(
					"Rare Stat node must select a stat."
				)

			if rare_stat_amount <= 0:
				errors.append(
					"Rare Stat amount must be positive."
				)

	return errors