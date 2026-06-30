class_name BattleReinforcementController
extends RefCounted


signal combatant_spawned(
	combatant: CombatantState,
	wave_id: StringName,
	scheduled_round: int,
	actual_round: int,
	coordinate: Vector2i
)

signal wave_completed(
	wave_id: StringName,
	actual_round: int
)

signal wave_deferred(
	wave_id: StringName,
	pending_combatant_count: int,
	actual_round: int
)


var session: BattleSession

var _waves: Array[BattleReinforcementWaveDefinition] = []

var _pending_spawn_indices: Dictionary = {}
var _completed_wave_ids: Dictionary = {}


func _init(
	p_session: BattleSession,
	p_waves: Array[BattleReinforcementWaveDefinition] = []
) -> void:
	assert(
		p_session != null,
		"BattleReinforcementController requires "
		+"a battle session."
	)

	session = p_session
	_waves = p_waves.duplicate()

	_waves.sort_custom(
		Callable(
			self,
			"_has_earlier_schedule"
		)
	)

	for wave in _waves:
		if wave == null:
			continue

		var pending_indices: Array[int] = []

		for spawn_index in range(
			wave.combatant_spawns.size()
		):
			pending_indices.append(
				spawn_index
			)

		_pending_spawn_indices[
			wave.wave_id
		] = pending_indices


func process_round(
	current_round: int
) -> Array[CombatantState]:
	var spawned_combatants: Array[CombatantState] = []

	if current_round <= 0:
		return spawned_combatants

	for wave in _waves:
		if wave == null:
			continue

		if wave.round_number > current_round:
			continue

		if _completed_wave_ids.has(
			wave.wave_id
		):
			continue

		var pending_values: Array = (
			_pending_spawn_indices.get(
				wave.wave_id,
				[]
			)
		)

		var remaining_indices: Array[int] = []

		for value in pending_values:
			var spawn_index := int(value)

			if (
				spawn_index < 0
				or spawn_index
				>= wave.combatant_spawns.size()
			):
				continue

			var spawn := (
				wave.combatant_spawns[
					spawn_index
				]
			)

			if spawn == null:
				continue

			if session.has_combatant(
				spawn.instance_id
			):
				continue

			var spawn_coordinate := (
				_find_available_coordinate(
					spawn
				)
			)

			if (
				spawn_coordinate
				== BattleGrid.INVALID_COORDINATE
			):
				remaining_indices.append(
					spawn_index
				)

				continue

			var combatant := session.add_combatant(
				spawn.instance_id,
				spawn.combatant_definition,
				spawn.team_id,
				spawn_coordinate,
				spawn.get_effective_loadout()
			)

			if combatant == null:
				remaining_indices.append(
					spawn_index
				)

				continue

			spawned_combatants.append(
				combatant
			)

			combatant_spawned.emit(
				combatant,
				wave.wave_id,
				wave.round_number,
				current_round,
				spawn_coordinate
			)

		_pending_spawn_indices[
			wave.wave_id
		] = remaining_indices

		if remaining_indices.is_empty():
			_completed_wave_ids[
				wave.wave_id
			] = true

			wave_completed.emit(
				wave.wave_id,
				current_round
			)
		else:
			wave_deferred.emit(
				wave.wave_id,
				remaining_indices.size(),
				current_round
			)

	return spawned_combatants


func has_pending_reinforcements() -> bool:
	for value in _pending_spawn_indices.values():
		var pending_values := value as Array

		if (
			pending_values != null
			and not pending_values.is_empty()
		):
			return true

	return false


func has_pending_reinforcements_for_team(
	team_id: StringName
) -> bool:
	for wave in _waves:
		if wave == null:
			continue

		var pending_values: Array = (
			_pending_spawn_indices.get(
				wave.wave_id,
				[]
			)
		)

		for value in pending_values:
			var spawn_index := int(value)

			if (
				spawn_index < 0
				or spawn_index
				>= wave.combatant_spawns.size()
			):
				continue

			var spawn := (
				wave.combatant_spawns[
					spawn_index
				]
			)

			if (
				spawn != null
				and spawn.team_id == team_id
			):
				return true

	return false


func has_pending_opposition_to(
	team_id: StringName
) -> bool:
	for wave in _waves:
		if wave == null:
			continue

		var pending_values: Array = (
			_pending_spawn_indices.get(
				wave.wave_id,
				[]
			)
		)

		for value in pending_values:
			var spawn_index := int(value)

			if (
				spawn_index < 0
				or spawn_index
				>= wave.combatant_spawns.size()
			):
				continue

			var spawn := (
				wave.combatant_spawns[
					spawn_index
				]
			)

			if (
				spawn != null
				and spawn.team_id != team_id
			):
				return true

	return false


func get_pending_combatant_count() -> int:
	var result: int = 0

	for value in _pending_spawn_indices.values():
		var pending_values := value as Array

		if pending_values == null:
			continue

		result += pending_values.size()

	return result


func _find_available_coordinate(
	spawn: CombatantSpawnDefinition
) -> Vector2i:
	for coordinate in spawn.get_candidate_coordinates():
		var cell := session.grid.get_cell(
			coordinate
		)

		if cell == null:
			continue

		if cell.is_walkable():
			return coordinate

	return BattleGrid.INVALID_COORDINATE


func _has_earlier_schedule(
	first: BattleReinforcementWaveDefinition,
	second: BattleReinforcementWaveDefinition
) -> bool:
	if first.round_number != second.round_number:
		return (
			first.round_number
			< second.round_number
		)

	return (
		String(first.wave_id)
		< String(second.wave_id)
	)