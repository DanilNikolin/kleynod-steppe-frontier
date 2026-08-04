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

var max_stamina: int = 1
var current_stamina: int = 0

var stamina_restoration_debt: int = 0

## Независимая runtime-копия настоящего бойца.
## Используется для Core-aware изменений HP и Stamina.
var _runtime_state

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

	max_stamina = original_state.max_stamina
	current_stamina = original_state.current_stamina

	stamina_restoration_debt = (
		original_state
			.get_stamina_restoration_debt()
	)

	_runtime_state = (
		original_state.create_runtime_copy()
	)

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


func can_pay_health_cost(
	amount: int,
	minimum_remaining_health: int = 1
) -> bool:
	if _runtime_state == null:
		return false

	_sync_runtime_state_from_preview()

	return _runtime_state.can_pay_health_cost(
		amount,
		minimum_remaining_health
	)


func pay_health_cost(
	amount: int,
	minimum_remaining_health: int = 1
) -> int:
	if _runtime_state == null:
		return 0

	_sync_runtime_state_from_preview()

	var paid_amount: int = (
		_runtime_state.pay_health_cost(
			amount,
			minimum_remaining_health
		)
	)

	_sync_preview_from_runtime_state()

	return paid_amount


func restore_stamina(
	amount: int,
	reason: StringName = &"preview"
) -> int:
	if _runtime_state == null:
		return 0

	_sync_runtime_state_from_preview()

	var restored_amount: int = (
		_runtime_state.restore_stamina(
			amount,
			reason
		)
	)

	_sync_preview_from_runtime_state()

	return restored_amount


func get_stamina_restoration_debt() -> int:
	return maxi(
		0,
		stamina_restoration_debt
	)


func _sync_runtime_state_from_preview() -> void:
	if _runtime_state == null:
		return

	_runtime_state.current_health = (
		current_health
	)

	_runtime_state.current_guard = (
		current_guard
	)

	_runtime_state.max_stamina = (
		max_stamina
	)

	_runtime_state.current_stamina = (
		current_stamina
	)

	_runtime_state.grid_position = (
		grid_position
	)


func _sync_preview_from_runtime_state() -> void:
	if _runtime_state == null:
		return

	current_health = (
		_runtime_state.current_health
	)

	current_guard = (
		_runtime_state.current_guard
	)

	max_stamina = (
		_runtime_state.max_stamina
	)

	current_stamina = (
		_runtime_state.current_stamina
	)

	stamina_restoration_debt = (
		_runtime_state
			.get_stamina_restoration_debt()
	)

	grid_position = (
		_runtime_state.grid_position
	)


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

func get_status_ids_matching_removal(
	effect: RemoveStatusEffect
) -> Array[StringName]:
	var result: Array[StringName] = []

	if effect == null:
		return result

	for value in _statuses_by_id.keys():
		var status_id: StringName = value

		var snapshot := get_status_snapshot(
			status_id
		)

		var status_definition := (
			snapshot.get(
				"definition"
			) as BattleStatusDefinition
		)

		if status_definition == null:
			continue

		if not effect.matches_status_definition(
			status_definition
		):
			continue

		result.append(
			status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func remove_status_snapshot(
	status_id: StringName
) -> bool:
	if not _statuses_by_id.has(
		status_id
	):
		return false

	_statuses_by_id.erase(
		status_id
	)

	return true


func _is_status_id_before(
	first: StringName,
	second: StringName
) -> bool:
	return String(first) < String(second)
    
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