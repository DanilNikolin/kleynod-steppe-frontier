class_name BattleFlowController
extends Node

## Scene orchestration only. Decisions and commits stay in the existing services.
signal completed(winning_team_id: StringName)

var screen: BattleScreen
var session: BattleSession
var turn_controller: BattleTurnController
var reinforcement_controller: BattleReinforcementController
var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService
var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner
var ai_runner: BattleUtilityAITurnRunner
var interaction: BattleInteractionController
var overlay_presenter: BattleGridOverlayPresenter
var preview_presenter: BattleActionPreviewPresenter
var log_presenter: BattleLogPresenter
var ai_turns_completed: int = 0
var _closing: bool = false
var _combatants: Array[CombatantState] = []


func start(value: BattleScreen, encounter: BattleEncounterDefinition) -> bool:
	screen = value
	session = screen.session
	var presenter := screen.combatant_presenter
	turn_controller = BattleTurnController.new()
	reinforcement_controller = BattleReinforcementController.new(session, encounter.reinforcement_waves)
	movement_service = BattleMovementService.new(session.side_rules)
	targeting_service = BattleTargetingService.new()
	action_service = BattleActionService.new(targeting_service)
	movement_runner = BattleMovementRunner.new(session, movement_service, presenter)
	action_runner = BattleActionRunner.new(action_service, presenter)
	ai_runner = BattleUtilityAITurnRunner.new(
		BattleAIPlanGenerator.new(movement_service, action_service, targeting_service), movement_runner, action_runner)
	overlay_presenter = BattleGridOverlayPresenter.new(
		screen.tactical_state, movement_service, action_service, targeting_service)
	preview_presenter = BattleActionPreviewPresenter.new(presenter, screen.tactical_state)
	log_presenter = BattleLogPresenter.new(screen.get_node("BattleUI/Root/StatusLabel"), session, null, 2)
	interaction = BattleInteractionController.new(
		screen.player_team_id, session, turn_controller,
		screen.get_node("BattleUI/Root/AbilityPanel"),
		screen.get_node("BattleUI/Root/CombatantHoverPanel"),
		screen.get_node("BattleUI/Root/SurfaceHoverPanel"),
		movement_service, targeting_service, BattleActionPreviewService.new(action_service),
		preview_presenter, movement_runner, action_runner, overlay_presenter, log_presenter,
		1, screen.animate_movement, screen.animate_actions)
	screen.slot_clicked.connect(interaction.on_grid_cell_clicked)
	screen.slot_hovered.connect(_on_hover)
	screen.get_node("BattleUI/Root/AbilityPanel").ability_selected.connect(interaction.on_ability_selected)
	screen.get_node("BattleUI/Root/EndTurn").pressed.connect(_end_turn)
	screen.get_node("BattleUI/Root/TestShake").pressed.connect(screen.get_node("CameraDirector").impact_shake)
	turn_controller.turn_started.connect(_on_turn_started)
	turn_controller.turn_skipped.connect(_on_turn_skipped)
	turn_controller.periodic_status_effects_resolved.connect(_on_periodic)
	turn_controller.battle_finished.connect(_on_finished)
	session.combatant_added.connect(_on_added)
	session.combatant_defeated.connect(_on_defeated)
	for state in session.get_all_combatants():
		_on_added(state)
	return turn_controller.start(session, reinforcement_controller)


func _unhandled_input(event: InputEvent) -> void:
	if interaction == null:
		return
	if interaction.handle_input(event) or interaction.handle_unhandled_input(event):
		get_viewport().set_input_as_handled()


func _end_turn() -> void:
	if interaction.is_player_turn() and not interaction.is_interaction_in_progress():
		interaction.end_active_turn()


func _on_hover(coordinate: Vector2i) -> void:
	interaction.on_grid_cell_hovered(coordinate)
	for state in session.get_all_combatants():
		var view := screen.combatant_presenter.get_view(state.instance_id)
		if view != null:
			view.set_hovered_state(state.grid_position == coordinate)


func _on_turn_started(actor: CombatantState, round_number: int, _index: int) -> void:
	for state in session.get_all_combatants():
		var view := screen.combatant_presenter.get_view(state.instance_id)
		if view != null:
			view.set_selected_state(state == actor)
	var player_turn := actor.team_id == screen.player_team_id
	screen.get_node("BattleUI/Root/EndTurn").disabled = not player_turn
	log_presenter.set_headline("Раунд %d · %s · %s" % [
		round_number, actor.definition.display_name, "Ваш ход" if player_turn else "Ход противника"])
	if player_turn:
		interaction.begin_player_turn(actor)
	else:
		interaction.begin_enemy_turn()
		_run_ai.call_deferred(actor)


func _on_turn_skipped(_actor: CombatantState, _round: int, _index: int, _statuses: Array[StringName]) -> void:
	interaction.begin_skipped_turn()


func _run_ai(actor: CombatantState) -> void:
	if _closing or not turn_controller.is_combatant_active(actor):
		return
	if screen.ai_think_delay > 0:
		await get_tree().create_timer(screen.ai_think_delay).timeout
	if _closing or not is_inside_tree() or not turn_controller.is_running or not turn_controller.is_combatant_active(actor):
		return
	overlay_presenter.clear()
	preview_presenter.clear()
	var outcome := await ai_runner.execute(session, actor, 1, screen.animate_movement, screen.animate_actions)
	if _closing or not is_inside_tree():
		return
	ai_turns_completed += 1
	if not outcome.is_successful:
		log_presenter.set_headline("AI завершает ход: %s" % outcome.failure_code)
	if turn_controller.is_running and turn_controller.is_combatant_active(actor):
		turn_controller.end_current_turn()


func _on_periodic(actor: CombatantState, timing: int, results: Array[BattleStatusPeriodicTriggerResult]) -> void:
	log_presenter.append_periodic_trigger_results(actor, timing, results)


func _on_finished(winner: StringName) -> void:
	interaction.finish_battle()
	screen.tactical_state.set_hover(BattleGrid.INVALID_COORDINATE)
	screen.get_node("BattleUI/Root/EndTurn").disabled = true
	log_presenter.set_headline("Победа!" if winner == screen.player_team_id else "Бой завершён · поражение")
	for state in session.get_all_combatants():
		var view := screen.combatant_presenter.get_view(state.instance_id)
		if view != null:
			view.set_selected_state(false)
	completed.emit(winner)


func _on_added(state: CombatantState) -> void:
	_combatants.append(state)
	state.health_changed.connect(_on_health_changed.bind(state))


func _on_health_changed(before: int, after: int, state: CombatantState) -> void:
	if after >= before:
		return
	(screen.get_node("CameraDirector") as BattleCameraDirector).impact_shake()
	if state.team_id == screen.player_team_id:
		(screen.get_node("BattleUI/ScreenFeedback") as BattleScreenFeedback).damage_flash()


func _on_defeated(state: CombatantState) -> void:
	# ActionRunner normally removes defeated views; also cover surfaces/periodic damage.
	var id := state.instance_id
	await get_tree().create_timer(0.5).timeout
	if _closing or not is_inside_tree():
		return
	if not state.is_alive:
		screen.combatant_presenter.remove_view(id)


func _exit_tree() -> void:
	_closing = true
	for state in _combatants:
		var callback := _on_health_changed.bind(state)
		if state.health_changed.is_connected(callback):
			state.health_changed.disconnect(callback)
	_combatants.clear()
	if session != null and turn_controller != null:
		# Core currently has no public stop/dispose method; detach its session callback
		# when disposing this presentation-owned turn controller.
		for connection in session.combatant_defeated.get_connections():
			var callback: Callable = connection.callable
			if callback.get_object() == turn_controller:
				session.combatant_defeated.disconnect(callback)
