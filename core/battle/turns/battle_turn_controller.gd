class_name BattleTurnController
extends RefCounted


signal battle_started
signal round_started(round_number: int)

signal turn_starting(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_started(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_skipped(
	combatant: CombatantState,
	round_number: int,
	turn_index: int,
	restriction_status_ids: Array[StringName]
)

signal turn_ending(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_ended(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal periodic_status_effects_resolved(
	combatant: CombatantState,
	timing: int,
	results: Array[BattleStatusPeriodicTriggerResult]
)

signal battle_finished(
	winning_team_id: StringName
)


var session: BattleSession
var reinforcement_controller: BattleReinforcementController

var periodic_status_processor: BattleStatusPeriodicProcessor

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

var _is_processing_periodic_statuses: bool = false


func _init(
	p_periodic_status_processor: BattleStatusPeriodicProcessor = null
) -> void:
	periodic_status_processor = (
		p_periodic_status_processor
		if p_periodic_status_processor != null
		else BattleStatusPeriodicProcessor.new()
	)


func start(
	p_session: BattleSession,
	p_reinforcement_controller: BattleReinforcementController = null
) -> bool:
	if _started:
		return false

	if p_session == null:
		return false

	session = p_session
	reinforcement_controller = (
		p_reinforcement_controller
	)

	_started = true
	_finished = false

	round_number = 0
	winning_team_id = &""

	_connect_session_signals()

	battle_started.emit()

	return _start_round(1)


func end_current_turn() -> bool:
	if not is_running:
		return false

	if active_combatant == null:
		return false

	var ended_combatant := active_combatant
	var ended_index := _current_turn_index

	turn_ending.emit(
		ended_combatant,
		round_number,
		ended_index
	)

	_process_periodic_status_effects(
		ended_combatant,
		BattleStatusPeriodicTrigger
		.Timing
		.OWNER_TURN_END
	)

	if ended_combatant.is_alive:
		ended_combatant.advance_statuses_after_owner_turn()

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
		if (
			reinforcement_controller != null
			and reinforcement_controller
			.has_pending_reinforcements()
		):
			return false

		_finish_battle(&"")
		return true

	var living_team_ids: Dictionary = {}

	for combatant in living_combatants:
		living_team_ids[
			combatant.team_id
		] = true

	if living_team_ids.size() > 1:
		return false

	var possible_winner: StringName = (
		living_team_ids.keys()[0]
	)

	if (
		reinforcement_controller != null
		and reinforcement_controller
		.has_pending_opposition_to(
			possible_winner
		)
	):
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


func _start_round(
	new_round_number: int
) -> bool:
	if not is_running:
		return false

	round_number = new_round_number
	active_combatant = null
	_current_turn_index = -1

	if reinforcement_controller != null:
		reinforcement_controller.process_round(
			round_number
		)

	_rebuild_turn_order()

	if evaluate_battle_state():
		return true

	if _turn_order.is_empty():
		return false

	round_started.emit(
		round_number
	)

	_current_turn_index = 0

	_begin_turn(
		_turn_order[_current_turn_index]
	)

	return true


func _advance_to_next_turn() -> bool:
	var next_index := (
		_current_turn_index + 1
	)

	while next_index < _turn_order.size():
		var candidate := _turn_order[next_index]

		if (
			candidate != null
			and candidate.is_alive
		):
			_current_turn_index = next_index

			_begin_turn(
				candidate
			)

			return true

		next_index += 1

	return _start_next_round()


func _start_next_round() -> bool:
	return _start_round(
		round_number + 1
	)


func _begin_turn(
	combatant: CombatantState
) -> void:
	if (
		combatant == null
		or not combatant.is_alive
	):
		return

	active_combatant = combatant

	turn_starting.emit(
		combatant,
		round_number,
		_current_turn_index
	)

	_process_periodic_status_effects(
		combatant,
		BattleStatusPeriodicTrigger
		.Timing
		.OWNER_TURN_START
	)

	if not combatant.is_alive:
		active_combatant = null

		if evaluate_battle_state():
			return

		_advance_to_next_turn()
		return

	combatant.restore_round_stamina()

	var skip_status_ids := (
		combatant.get_turn_skip_status_ids()
	)

	if not skip_status_ids.is_empty():
		turn_skipped.emit(
			combatant,
			round_number,
			_current_turn_index,
			skip_status_ids
		)

		end_current_turn()
		return

	turn_started.emit(
		combatant,
		round_number,
		_current_turn_index
	)


func _process_periodic_status_effects(
	combatant: CombatantState,
	timing: int
) -> Array[BattleStatusPeriodicTriggerResult]:
	var results: Array[BattleStatusPeriodicTriggerResult] = []

	if periodic_status_processor == null:
		return results

	_is_processing_periodic_statuses = true

	results = (
		periodic_status_processor
		.process_owner_timing(
			session,
			combatant,
			timing
		)
	)

	_is_processing_periodic_statuses = false

	if not results.is_empty():
		periodic_status_effects_resolved.emit(
			combatant,
			timing,
			results
		)

	return results


func _rebuild_turn_order() -> void:
	_turn_order.clear()

	for combatant in (
		session.get_living_combatants()
	):
		if (
			combatant == null
			or combatant.definition == null
		):
			continue

		if not (
			combatant
			.definition
			.participates_in_turn_order
		):
			continue

		_turn_order.append(
			combatant
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
	if _is_processing_periodic_statuses:
		return

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