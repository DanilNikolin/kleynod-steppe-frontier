class_name BattleSession
extends RefCounted


signal combatant_added(combatant: CombatantState)
signal combatant_removed(instance_id: StringName)
signal combatant_defeated(combatant: CombatantState)


var grid: BattleGrid
var side_rules: BattleSideRules
var surface_effect_controller: BattleSurfaceEffectController

var _combatants: Dictionary = {}
var _death_callbacks: Dictionary = {}


func _init(
	p_rows: int = 5,
	p_columns: int = 10,
	p_side_rules: BattleSideRules = null
) -> void:
	side_rules = (
		p_side_rules
		if p_side_rules != null
		else BattleSideRules.new()
	)

	var side_errors := (
		side_rules.get_validation_errors(
			p_columns
		)
	)

	assert(
		side_errors.is_empty(),
		"Invalid battle side rules: %s"
		% side_errors
	)

	surface_effect_controller = (
		BattleSurfaceEffectController.new()
	)

	grid = BattleGrid.new(
		p_rows,
		p_columns
	)


func add_combatant(
	instance_id: StringName,
	definition: CombatantDefinition,
	team_id: StringName,
	coordinate: Vector2i,
	loadout_override: CombatantLoadoutDefinition = null
) -> CombatantState:
	if instance_id == &"":
		return null

	if definition == null:
		return null

	var resolved_loadout := (
		loadout_override
		if loadout_override != null
		else definition.default_loadout
	)

	if resolved_loadout == null:
		return null

	if not resolved_loadout.is_valid_definition():
		return null

	if team_id == &"":
		return null

	if not is_coordinate_allowed_for_team(
		team_id,
		coordinate
	):
		return null

	if _combatants.has(instance_id):
		return null

	if not grid.try_place_occupant(
		instance_id,
		coordinate
	):
		return null

	var combatant := CombatantState.new(
		instance_id,
		definition,
		team_id,
		resolved_loadout,
		coordinate
	)

	_combatants[instance_id] = combatant

	var death_callback := Callable(
		self,
		"_on_combatant_died"
	).bind(combatant)

	_death_callbacks[instance_id] = death_callback

	combatant.died.connect(
		death_callback
	)

	combatant_added.emit(
		combatant
	)

	return combatant


func has_combatant(
	instance_id: StringName
) -> bool:
	return _combatants.has(instance_id)


func get_combatant(
	instance_id: StringName
) -> CombatantState:
	return (
		_combatants.get(instance_id)
		as CombatantState
	)


func get_all_combatants() -> Array[CombatantState]:
	var result: Array[CombatantState] = []

	for value in _combatants.values():
		var combatant := value as CombatantState

		if combatant != null:
			result.append(combatant)

	return result


func get_living_combatants() -> Array[CombatantState]:
	var result: Array[CombatantState] = []

	for combatant in get_all_combatants():
		if combatant.is_alive:
			result.append(combatant)

	return result


func get_team_combatants(
	team_id: StringName,
	living_only: bool = false
) -> Array[CombatantState]:
	var result: Array[CombatantState] = []

	for combatant in get_all_combatants():
		if combatant.team_id != team_id:
			continue

		if living_only and not combatant.is_alive:
			continue

		result.append(combatant)

	return result


func is_team_supported(
	team_id: StringName
) -> bool:
	return (
		side_rules != null
		and side_rules.is_team_supported(
			team_id
		)
	)


func is_coordinate_allowed_for_team(
	team_id: StringName,
	coordinate: Vector2i
) -> bool:
	if side_rules == null or grid == null:
		return false

	return side_rules.is_coordinate_allowed(
		team_id,
		coordinate,
		grid.rows,
		grid.columns
	)


func get_team_forward_direction(
	team_id: StringName
) -> int:
	if side_rules == null:
		return 0

	return side_rules.get_forward_direction(
		team_id
	)

func remove_combatant(
	instance_id: StringName
) -> bool:
	var combatant := get_combatant(
		instance_id
	)

	if combatant == null:
		return false

	var death_callback: Callable = (
		_death_callbacks.get(
			instance_id,
			Callable()
		)
	)

	if (
		death_callback.is_valid()
		and combatant.is_connected(
			&"died",
			death_callback
		)
	):
		combatant.disconnect(
			&"died",
			death_callback
		)

	grid.remove_occupant(
		instance_id
	)

	_death_callbacks.erase(
		instance_id
	)

	_combatants.erase(
		instance_id
	)

	combatant_removed.emit(
		instance_id
	)

	return true


func clear() -> void:
	if surface_effect_controller != null:
		surface_effect_controller.clear(
			self
		)

	var combatant_ids := _combatants.keys()

	for value in combatant_ids:
		var instance_id: StringName = value

		remove_combatant(
			instance_id
		)

	grid.clear()


func _on_combatant_died(
	combatant: CombatantState
) -> void:
	if combatant == null:
		return

	if not has_combatant(
		combatant.instance_id
	):
		return

	grid.remove_occupant(
		combatant.instance_id
	)

	combatant_defeated.emit(
		combatant
	)