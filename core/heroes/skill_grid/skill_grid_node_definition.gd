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


@export_group("Dependencies")

@export
var prerequisite_node_ids: Array[StringName] = []


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