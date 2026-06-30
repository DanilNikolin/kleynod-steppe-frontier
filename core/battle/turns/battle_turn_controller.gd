class_name BattleTurnController
extends RefCounted


signal battle_started
signal round_started(round_number: int)

signal turn_started(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_ended(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal battle_finished(
	winning_team_id: StringName
)


var session: BattleSession

var round_number: int = 0
var active_combatant: CombatantState
var winning_team_id: StringName = &""

var is_running: bool:
	get:
		return _started and not _finished

var is_finished: bool:
	get:
		return _finished


var _turn_order: Array[CombatantState] = []
var _current_turn_index: int = -1

var _started: bool = false
var _finished: bool = false


func start(
	p_session: BattleSession
) -> bool:
	if _started:
		return false

	if p_session == null:
		return false

	session = p_session

	_started = true
	_finished = false

	round_number = 1
	winning_team_id = &""

	_connect_session_signals()
	_rebuild_turn_order()

	if _turn_order.is_empty():
		_finish_battle(&"")
		return false

	battle_started.emit()

	if evaluate_battle_state():
		return true

	round_started.emit(
		round_number
	)

	_current_turn_index = 0

	_begin_turn(
		_turn_order[_current_turn_index]
	)

	return true


func end_current_turn() -> bool:
	if not is_running:
		return false

	if active_combatant == null:
		return false

	var ended_combatant := active_combatant
	var ended_index := _current_turn_index

	turn_ended.emit(
		ended_combatant,
		round_number,
		ended_index
	)

	active_combatant = null

	if evaluate_battle_state():
		return true

	return _advance_to_next_turn()


func evaluate_battle_state() -> bool:
	if not _started:
		return false

	if _finished:
		return true

	var living_combatants := (
		session.get_living_combatants()
	)

	if living_combatants.is_empty():
		_finish_battle(&"")
		return true

	var possible_winner := (
		living_combatants[0].team_id
	)

	for combatant in living_combatants:
		if combatant.team_id != possible_winner:
			return false

	_finish_battle(
		possible_winner
	)

	return true


func is_combatant_active(
	combatant: CombatantState
) -> bool:
	return (
		is_running
		and combatant != null
		and combatant == active_combatant
	)


func get_turn_order() -> Array[CombatantState]:
	return _turn_order.duplicate()


func get_current_turn_index() -> int:
	return _current_turn_index


func _advance_to_next_turn() -> bool:
	var next_index := (
		_current_turn_index + 1
	)

	while next_index < _turn_order.size():
		var candidate := _turn_order[next_index]

		if candidate != null and candidate.is_alive:
			_current_turn_index = next_index

			_begin_turn(
				candidate
			)

			return true

		next_index += 1

	return _start_next_round()


func _start_next_round() -> bool:
	if evaluate_battle_state():
		return true

	round_number += 1

	_rebuild_turn_order()

	if _turn_order.is_empty():
		_finish_battle(&"")
		return false

	_current_turn_index = 0

	round_started.emit(
		round_number
	)

	_begin_turn(
		_turn_order[_current_turn_index]
	)

	return true


func _begin_turn(
	combatant: CombatantState
) -> void:
	if combatant == null or not combatant.is_alive:
		return

	active_combatant = combatant

	combatant.restore_round_stamina()

	turn_started.emit(
		combatant,
		round_number,
		_current_turn_index
	)


func _rebuild_turn_order() -> void:
	_turn_order = (
		session.get_living_combatants()
	)

	_turn_order.sort_custom(
		Callable(
			self,
			"_has_higher_turn_priority"
		)
	)


func _has_higher_turn_priority(
	first: CombatantState,
	second: CombatantState
) -> bool:
	if first.initiative != second.initiative:
		return first.initiative > second.initiative

	return (
		String(first.instance_id)
		< String(second.instance_id)
	)


func _connect_session_signals() -> void:
	var callback := Callable(
		self,
		"_on_combatant_defeated"
	)

	if not session.is_connected(
		&"combatant_defeated",
		callback
	):
		session.connect(
			&"combatant_defeated",
			callback
		)


func _on_combatant_defeated(
	_combatant: CombatantState
) -> void:
	evaluate_battle_state()


func _finish_battle(
	p_winning_team_id: StringName
) -> void:
	if _finished:
		return

	_finished = true
	winning_team_id = p_winning_team_id
	active_combatant = null

	battle_finished.emit(
		winning_team_id
	)