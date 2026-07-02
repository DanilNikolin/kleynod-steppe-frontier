class_name BattlePreviewCombatantState
extends RefCounted


var original_state: CombatantState

var instance_id: StringName = &""
var definition: CombatantDefinition
var team_id: StringName = &""

var grid_position: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var strength: int = 0
var agility: int = 0
var spirit: int = 0
var armor: int = 0

var max_health: int = 1
var current_health: int = 1
var current_guard: int = 0

var _statuses_by_id: Dictionary = {}


var is_alive: bool:
	get:
		return current_health > 0


func _init(
	p_original_state: CombatantState
) -> void:
	assert(
		p_original_state != null,
		"Preview combatant requires an original state."
	)

	original_state = p_original_state

	instance_id = original_state.instance_id
	definition = original_state.definition
	team_id = original_state.team_id
	grid_position = original_state.grid_position

	strength = original_state.strength
	agility = original_state.agility
	spirit = original_state.spirit
	armor = original_state.armor

	max_health = original_state.max_health
	current_health = original_state.current_health
	current_guard = original_state.current_guard

	for status in original_state.get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		_statuses_by_id[
			status.status_id
		] = {
			"definition": status.definition,
			"stack_count": status.stack_count,
			"remaining_turns": status.remaining_turns,
		}


func get_status_snapshot(
	status_id: StringName
) -> Dictionary:
	if not _statuses_by_id.has(
		status_id
	):
		return {}

	return _statuses_by_id[
		status_id
	]


func get_stat_modifier_total(
	stat: int
) -> int:
	var total: int = 0

	for value in _statuses_by_id.values():
		var snapshot: Dictionary = value

		var status_definition := (
			snapshot.get(
				"definition"
			) as BattleStatusDefinition
		)

		if status_definition == null:
			continue

		var stack_count := int(
			snapshot.get(
				"stack_count",
				0
			)
		)

		for modifier in (
			status_definition.stat_modifiers
		):
			if (
				modifier == null
				or modifier.stat != stat
			):
				continue

			total += modifier.get_total_amount(
				stack_count
			)

	return total


func get_effective_strength() -> int:
	return maxi(
		0,
		strength
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.STRENGTH
		)
	)


func get_effective_agility() -> int:
	return maxi(
		0,
		agility
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.AGILITY
		)
	)


func get_effective_spirit() -> int:
	return maxi(
		0,
		spirit
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.SPIRIT
		)
	)


func get_effective_armor() -> int:
	return maxi(
		0,
		armor
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

func has_status_id_immunity(
	status_id: StringName
) -> bool:
	return (
		definition != null
		and definition.has_status_id_immunity(
			status_id
		)
	)


func get_matching_status_immunity_tag(
	status_definition: BattleStatusDefinition
) -> StringName:
	if definition == null:
		return &""

	return (
		definition
		.get_matching_status_immunity_tag(
			status_definition
		)
	)


func is_immune_to_status(
	status_definition: BattleStatusDefinition
) -> bool:
	return (
		definition != null
		and definition.is_immune_to_status(
			status_definition
		)
	)

func apply_status_definition(
	status_definition: BattleStatusDefinition
) -> bool:
	if status_definition == null:
		return false

	if is_immune_to_status(
		status_definition
	):
		return false

	var existing_snapshot := get_status_snapshot(
		status_definition.status_id
	)

	if existing_snapshot.is_empty():
		_statuses_by_id[
			status_definition.status_id
		] = {
			"definition": status_definition,
			"stack_count": 1,
			"remaining_turns": (
				status_definition.duration_turns
			),
		}

		return true

	var stack_count := int(
		existing_snapshot.get(
			"stack_count",
			1
		)
	)

	var remaining_turns := int(
		existing_snapshot.get(
			"remaining_turns",
			status_definition.duration_turns
		)
	)

	match status_definition.reapply_rule:
		BattleStatusDefinition.ReapplyRule.REFRESH_DURATION:
			remaining_turns = (
				status_definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH:
			stack_count = mini(
				status_definition.max_stacks,
				stack_count + 1
			)

			remaining_turns = (
				status_definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.KEEP_EXISTING:
			pass

	existing_snapshot[
		"stack_count"
	] = stack_count

	existing_snapshot[
		"remaining_turns"
	] = remaining_turns

	_statuses_by_id[
		status_definition.status_id
	] = existing_snapshot

	return true