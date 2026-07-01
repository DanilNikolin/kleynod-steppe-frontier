class_name CombatantState
extends RefCounted


signal health_changed(previous_value: int, current_value: int)
signal guard_changed(previous_value: int, current_value: int)
signal stamina_changed(previous_value: int, current_value: int)
signal ability_lock_changed(
	ability_id: StringName,
	previous_remaining_turns: int,
	current_remaining_turns: int
)
signal morale_changed(previous_value: int, current_value: int)
signal status_added(
	status: BattleStatusInstance
)

signal status_updated(
	status: BattleStatusInstance,
	previous_stack_count: int,
	previous_remaining_turns: int
)

signal status_removed(
	status: BattleStatusInstance,
	reason: StringName
)
signal grid_position_changed(
	previous_position: Vector2i,
	current_position: Vector2i
)
signal died


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)

enum AbilityLockKind {
	NONE,
	INITIAL,
	COOLDOWN,
}
var instance_id: StringName
var definition: CombatantDefinition
var team_id: StringName
var loadout: CombatantLoadoutDefinition

var grid_position: Vector2i = INVALID_COORDINATE

var strength: int
var agility: int
var spirit: int

var max_health: int
var current_health: int

var current_guard: int

var armor: int

var max_stamina: int
var current_stamina: int
var stamina_regeneration: int

var initiative: int

var max_morale: int
var current_morale: int

var _statuses_by_id: Dictionary = {}
var _ability_lock_turns_by_id: Dictionary = {}
var _initially_locked_ability_ids: Dictionary = {}
var _cooldowns_started_this_turn: Dictionary = {}

var is_alive: bool:
	get:
		return current_health > 0


func _init(
	p_instance_id: StringName,
	p_definition: CombatantDefinition,
	p_team_id: StringName,
	p_loadout: CombatantLoadoutDefinition,
	p_grid_position: Vector2i = INVALID_COORDINATE
) -> void:
	assert(
		p_instance_id != &"",
		"CombatantState requires a non-empty instance ID."
	)

	assert(
		p_definition != null,
		"CombatantState requires a CombatantDefinition."
	)

	assert(
		p_loadout != null,
		"CombatantState requires a CombatantLoadoutDefinition."
	)

	instance_id = p_instance_id
	definition = p_definition
	team_id = p_team_id
	loadout = p_loadout
	grid_position = p_grid_position

	_initialize_runtime_attributes()


func _initialize_runtime_attributes() -> void:
	strength = definition.base_strength
	agility = definition.base_agility
	spirit = definition.base_spirit

	max_health = definition.max_health
	current_health = max_health

	current_guard = 0

	armor = definition.base_armor

	max_stamina = definition.max_stamina
	current_stamina = max_stamina
	stamina_regeneration = definition.stamina_regeneration

	initiative = definition.base_initiative

	max_morale = definition.base_morale
	current_morale = max_morale

	_initialize_ability_locks()


func set_grid_position(new_position: Vector2i) -> void:
	if grid_position == new_position:
		return

	var previous_position := grid_position
	grid_position = new_position

	grid_position_changed.emit(
		previous_position,
		grid_position
	)


func can_spend_stamina(amount: int) -> bool:
	return amount >= 0 and current_stamina >= amount


func spend_stamina(amount: int) -> bool:
	if amount < 0:
		return false

	if current_stamina < amount:
		return false

	var previous_value := current_stamina
	current_stamina -= amount

	stamina_changed.emit(
		previous_value,
		current_stamina
	)

	return true


func restore_stamina(amount: int) -> int:
	if amount <= 0:
		return 0

	var previous_value := current_stamina

	current_stamina = mini(
		max_stamina,
		current_stamina + amount
	)

	var restored_amount := current_stamina - previous_value

	if restored_amount > 0:
		stamina_changed.emit(
			previous_value,
			current_stamina
		)

	return restored_amount


func restore_round_stamina() -> int:
	return restore_stamina(stamina_regeneration)

func grant_guard(amount: int) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var previous_value := current_guard

	current_guard = mini(
		max_health,
		current_guard + amount
	)

	var granted_amount := (
		current_guard - previous_value
	)

	if granted_amount > 0:
		guard_changed.emit(
			previous_value,
			current_guard
		)

	return granted_amount


func absorb_damage_with_guard(
	amount: int
) -> int:
	if amount <= 0 or current_guard <= 0:
		return 0

	var previous_value := current_guard

	var absorbed_amount := mini(
		amount,
		current_guard
	)

	current_guard -= absorbed_amount

	guard_changed.emit(
		previous_value,
		current_guard
	)

	return absorbed_amount


func clear_guard() -> int:
	if current_guard <= 0:
		return 0

	var previous_value := current_guard
	current_guard = 0

	guard_changed.emit(
		previous_value,
		current_guard
	)

	return previous_value

func apply_resolved_damage(
	amount: int,
	bypass_guard: bool = false
) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var remaining_damage := amount

	if not bypass_guard:
		remaining_damage -= (
			absorb_damage_with_guard(
				remaining_damage
			)
		)

	if remaining_damage <= 0:
		return 0

	var previous_value := current_health

	current_health = maxi(
		0,
		current_health - remaining_damage
	)

	var received_damage := (
		previous_value - current_health
	)

	if received_damage > 0:
		health_changed.emit(
			previous_value,
			current_health
		)

	if previous_value > 0 and current_health == 0:
		clear_guard()

		clear_statuses(
			&"owner_defeated"
		)

		died.emit()

	return received_damage


func heal(amount: int) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var previous_value := current_health

	current_health = mini(
		max_health,
		current_health + amount
	)

	var healed_amount := current_health - previous_value

	if healed_amount > 0:
		health_changed.emit(
			previous_value,
			current_health
		)

	return healed_amount


func set_morale(new_value: int) -> void:
	var clamped_value := clampi(
		new_value,
		0,
		max_morale
	)

	if current_morale == clamped_value:
		return

	var previous_value := current_morale
	current_morale = clamped_value

	morale_changed.emit(
		previous_value,
		current_morale
	)


func change_morale(amount: int) -> int:
	var previous_value := current_morale

	set_morale(current_morale + amount)

	return current_morale - previous_value


func get_abilities() -> Array[AbilityDefinition]:
	if loadout == null:
		return []

	return loadout.get_abilities()


func has_ability(
	ability_id: StringName
) -> bool:
	return (
		loadout != null
		and loadout.has_ability(
			ability_id
		)
	)


func get_ability(
	ability_id: StringName
) -> AbilityDefinition:
	if loadout == null:
		return null

	return loadout.get_ability(
		ability_id
	)


func get_default_ability() -> AbilityDefinition:
	if loadout == null:
		return null

	return loadout.get_default_ability()

func get_ability_lock_remaining_turns(
	ability_id: StringName
) -> int:
	if ability_id == &"":
		return 0

	if not _ability_lock_turns_by_id.has(
		ability_id
	):
		return 0

	return maxi(
		0,
		int(
			_ability_lock_turns_by_id[
				ability_id
			]
		)
	)


func get_ability_lock_kind(
	ability_id: StringName
) -> int:
	if (
		get_ability_lock_remaining_turns(
			ability_id
		) <= 0
	):
		return AbilityLockKind.NONE

	if _initially_locked_ability_ids.has(
		ability_id
	):
		return AbilityLockKind.INITIAL

	return AbilityLockKind.COOLDOWN


func is_ability_locked(
	ability_id: StringName
) -> bool:
	return (
		get_ability_lock_remaining_turns(
			ability_id
		) > 0
	)


func start_ability_cooldown(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	if ability.ability_id == &"":
		return false

	if not has_ability(
		ability.ability_id
	):
		return false

	var cooldown_turns := maxi(
		0,
		ability.cooldown_turns
	)

	if cooldown_turns <= 0:
		return false

	var previous_remaining_turns := (
		get_ability_lock_remaining_turns(
			ability.ability_id
		)
	)

	_ability_lock_turns_by_id[
		ability.ability_id
	] = cooldown_turns

	_initially_locked_ability_ids.erase(
		ability.ability_id
	)

	_cooldowns_started_this_turn[
		ability.ability_id
	] = true

	ability_lock_changed.emit(
		ability.ability_id,
		previous_remaining_turns,
		cooldown_turns
	)

	return true


func advance_ability_cooldowns_after_owner_turn() -> void:
	var ability_ids: Array = (
		_ability_lock_turns_by_id.keys()
	)

	for value in ability_ids:
		var ability_id: StringName = value

		if _cooldowns_started_this_turn.has(
			ability_id
		):
			continue

		var previous_remaining_turns := (
			get_ability_lock_remaining_turns(
				ability_id
			)
		)

		if previous_remaining_turns <= 0:
			_ability_lock_turns_by_id.erase(
				ability_id
			)

			_initially_locked_ability_ids.erase(
				ability_id
			)

			continue

		var current_remaining_turns := maxi(
			0,
			previous_remaining_turns - 1
		)

		if current_remaining_turns <= 0:
			_ability_lock_turns_by_id.erase(
				ability_id
			)

			_initially_locked_ability_ids.erase(
				ability_id
			)

		else:
			_ability_lock_turns_by_id[
				ability_id
			] = current_remaining_turns

		ability_lock_changed.emit(
			ability_id,
			previous_remaining_turns,
			current_remaining_turns
		)

	_cooldowns_started_this_turn.clear()


func _initialize_ability_locks() -> void:
	_ability_lock_turns_by_id.clear()
	_initially_locked_ability_ids.clear()
	_cooldowns_started_this_turn.clear()

	if loadout == null:
		return

	for ability in loadout.get_abilities():
		if ability == null:
			continue

		if ability.initial_lock_turns <= 0:
			continue

		_ability_lock_turns_by_id[
			ability.ability_id
		] = ability.initial_lock_turns

		_initially_locked_ability_ids[
			ability.ability_id
		] = true

func get_active_statuses() -> Array[BattleStatusInstance]:
	var result: Array[BattleStatusInstance] = []

	for value in _statuses_by_id.values():
		var status := (
			value as BattleStatusInstance
		)

		if status == null:
			continue

		result.append(
			status
		)

	return result


func get_status(
	status_id: StringName
) -> BattleStatusInstance:
	if status_id == &"":
		return null

	if not _statuses_by_id.has(
		status_id
	):
		return null

	return (
		_statuses_by_id[status_id]
		as BattleStatusInstance
	)


func has_status(
	status_id: StringName
) -> bool:
	return get_status(
		status_id
	) != null


func add_status(
	status_definition: BattleStatusDefinition,
	source_instance_id: StringName = &""
) -> BattleStatusInstance:
	if status_definition == null:
		return null

	if not status_definition.is_valid_definition():
		return null

	var existing_status := get_status(
		status_definition.status_id
	)

	if existing_status != null:
		var previous_stack_count := (
			existing_status.stack_count
		)

		var previous_remaining_turns := (
			existing_status.remaining_turns
		)

		existing_status.reapply(
			source_instance_id
		)

		status_updated.emit(
			existing_status,
			previous_stack_count,
			previous_remaining_turns
		)

		return existing_status

	var new_status := BattleStatusInstance.new(
		status_definition,
		source_instance_id
	)

	_statuses_by_id[
		status_definition.status_id
	] = new_status

	status_added.emit(
		new_status
	)

	return new_status


func remove_status(
	status_id: StringName,
	reason: StringName = &"removed"
) -> bool:
	var status := get_status(
		status_id
	)

	if status == null:
		return false

	_statuses_by_id.erase(
		status_id
	)

	status_removed.emit(
		status,
		reason
	)

	return true


func clear_statuses(
	reason: StringName = &"cleared"
) -> void:
	var status_ids: Array = (
		_statuses_by_id.keys()
	)

	for value in status_ids:
		var status_id: StringName = value

		remove_status(
			status_id,
			reason
		)


func advance_statuses_after_owner_turn() -> Array[StringName]:
	var expired_status_ids: Array[StringName] = []

	var statuses := get_active_statuses()

	for status in statuses:
		if status == null:
			continue

		var previous_stack_count := (
			status.stack_count
		)

		var previous_remaining_turns := (
			status.remaining_turns
		)

		status.advance_owner_turn()

		if status.is_expired:
			expired_status_ids.append(
				status.status_id
			)

			remove_status(
				status.status_id,
				&"expired"
			)

			continue

		status_updated.emit(
			status,
			previous_stack_count,
			previous_remaining_turns
		)

	return expired_status_ids

func must_skip_turn() -> bool:
	return not get_turn_skip_status_ids().is_empty()


func is_movement_restricted() -> bool:
	return not (
		get_movement_restriction_status_ids()
		.is_empty()
	)


func is_ability_restricted(
	ability_id: StringName
) -> bool:
	return not (
		get_ability_restriction_status_ids(
			ability_id
		).is_empty()
	)


func get_turn_skip_status_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction.skip_owner_turn
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func get_movement_restriction_status_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction
			.prevents_movement()
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func get_ability_restriction_status_ids(
	ability_id: StringName
) -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction
			.prevents_ability(
				ability_id
			)
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func _is_status_id_before(
	first: StringName,
	second: StringName
) -> bool:
	return String(first) < String(second)

func get_stat_base_value(
	stat: int
) -> int:
	match stat:
		BattleStatModifier.Stat.ARMOR:
			return armor

		BattleStatModifier.Stat.STRENGTH:
			return strength

		BattleStatModifier.Stat.AGILITY:
			return agility

		BattleStatModifier.Stat.SPIRIT:
			return spirit

	return 0


func get_stat_modifier_total(
	stat: int
) -> int:
	var total: int = 0

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		for modifier in (
			status.definition.stat_modifiers
		):
			if modifier == null:
				continue

			if modifier.stat != stat:
				continue

			total += modifier.get_total_amount(
				status.stack_count
			)

	return total


# Оставляем старое имя как совместимый переходный метод,
# чтобы уже существующий код не сломался.
func get_status_modifier_total(
	stat: int
) -> int:
	return get_stat_modifier_total(
		stat
	)


func get_effective_stat(
	stat: int
) -> int:
	return maxi(
		0,
		get_stat_base_value(stat)
		+ get_stat_modifier_total(stat)
	)


func get_effective_strength() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.STRENGTH
	)


func get_effective_agility() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.AGILITY
	)


func get_effective_spirit() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.SPIRIT
	)


func get_effective_armor() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.ARMOR
	)