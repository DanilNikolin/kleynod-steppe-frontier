class_name CombatantState
extends RefCounted


signal health_changed(previous_value: int, current_value: int)
signal stamina_changed(previous_value: int, current_value: int)
signal morale_changed(previous_value: int, current_value: int)
signal grid_position_changed(
	previous_position: Vector2i,
	current_position: Vector2i
)
signal died


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)


var instance_id: StringName
var definition: CombatantDefinition
var team_id: StringName

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


var is_alive: bool:
	get:
		return current_health > 0


func _init(
	p_instance_id: StringName,
	p_definition: CombatantDefinition,
	p_team_id: StringName,
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

	instance_id = p_instance_id
	definition = p_definition
	team_id = p_team_id
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