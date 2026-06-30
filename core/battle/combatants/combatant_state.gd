class_name CombatantState
extends RefCounted


signal health_changed(previous_value: int, current_value: int)
signal stamina_changed(previous_value: int, current_value: int)
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

var armor: int

var max_stamina: int
var current_stamina: int
var stamina_regeneration: int

var initiative: int

var max_morale: int
var current_morale: int

var _statuses_by_id: Dictionary = {}


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

	armor = definition.base_armor

	max_stamina = definition.max_stamina
	current_stamina = max_stamina
	stamina_regeneration = definition.stamina_regeneration

	initiative = definition.base_initiative

	max_morale = definition.base_morale
	current_morale = max_morale


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


func apply_resolved_damage(amount: int) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var previous_value := current_health

	current_health = maxi(
		0,
		current_health - amount
	)

	var received_damage := previous_value - current_health

	if received_damage > 0:
		health_changed.emit(
			previous_value,
			current_health
		)

	if previous_value > 0 and current_health == 0:
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

func get_status_modifier_total(
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


func get_effective_armor() -> int:
	var status_modifier := (
		get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	return maxi(
		0,
		armor + status_modifier
	)