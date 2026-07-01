extends Node2D


const PLAYER_TEAM_ID: StringName = &"team_player"
const ENEMY_TEAM_ID: StringName = &"team_enemy"

const MAX_BATTLE_LOG_LINES: int = 6


@export_group("Combatants")

@export
var combatant_view_scene: PackedScene

@export
var encounter_definition: BattleEncounterDefinition


@export_group("Presentation")

@export
var animate_movement: bool = true

@export
var animate_actions: bool = true

@export
var show_targeting_debug: bool = true

@export_range(0.0, 2.0, 0.05)
var ai_think_delay: float = 0.35


@export_group("Movement")

@export_range(1, 10, 1)
var stamina_cost_per_cell: int = 1


@export_group("Status Debug")

@export
var debug_status_definition: BattleStatusDefinition


@onready
var grid_view: BattleGridView = $BattleGridView

@onready
var combatant_layer: Node2D = (
	$BattleGridView/CombatantLayer
)

@onready
var status_label: Label = (
	$CanvasLayer/InterfaceMargin/PanelContainer /
	ContentMargin / VBoxContainer /
	CollapsibleContent / StatusLabel
)

@onready
var ability_panel: BattleAbilityPanel = (
	$CanvasLayer/AbilityPanel
)

@onready
var combatant_hover_panel: BattleCombatantHoverPanel = (
	$CanvasLayer/CombatantHoverPanel
)


var session: BattleSession
var grid: BattleGrid

var combatant_presenter: BattleCombatantPresenter
var grid_overlay_presenter: BattleGridOverlayPresenter

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var turn_controller: BattleTurnController
var reinforcement_controller: BattleReinforcementController

var ai_controller: BasicMeleeAIController
var ai_turn_runner: BasicMeleeAITurnRunner

var debug_log_presenter: BattleDebugLogPresenter
var interaction_controller: BattleSandboxInteractionController

var session_factory := BattleSessionFactory.new()

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService


func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_action_services()
	_create_debug_log_presenter()
	_create_combatant_presenter()
	_create_movement_runner()
	_create_action_runner()
	_create_grid_overlay_presenter()
	_create_ai_system()
	_create_reinforcement_system()
	_create_turn_controller()
	_create_interaction_controller()
	_connect_grid_signals()
	_connect_ability_panel()
	_connect_turn_signals()
	_start_battle()


func _input(
	event: InputEvent
) -> void:
	if interaction_controller == null:
		return

	if interaction_controller.handle_input(
		event
	):
		get_viewport().set_input_as_handled()


func _unhandled_input(
	event: InputEvent
) -> void:
	if interaction_controller == null:
		return

	if interaction_controller.handle_unhandled_input(
		event
	):
		get_viewport().set_input_as_handled()


func _validate_dependencies() -> void:
	assert(
		combatant_view_scene != null,
		"Combatant view scene is not assigned."
	)

	assert(
		encounter_definition != null,
		"Encounter definition is not assigned."
	)

	var encounter_errors := (
		encounter_definition.get_validation_errors()
	)

	assert(
		encounter_errors.is_empty(),
		"Invalid encounter definition: %s"
		% encounter_errors
	)


func _create_battle_state() -> void:
	session = session_factory.create_from_encounter(
		encounter_definition
	)

	assert(
		session != null,
		"Failed to create battle session "
		+"from encounter definition."
	)

	grid = session.grid

	movement_service = BattleMovementService.new(
		session.side_rules
	)

	grid_view.rows = grid.rows
	grid_view.columns = grid.columns
	grid_view.divider_column = (
		session.side_rules.divider_column
	)


func _create_action_services() -> void:
	targeting_service = BattleTargetingService.new()

	action_service = BattleActionService.new(
		targeting_service
	)


func _create_debug_log_presenter() -> void:
	debug_log_presenter = BattleDebugLogPresenter.new(
		status_label,
		session,
		debug_status_definition,
		MAX_BATTLE_LOG_LINES
	)


func _create_combatant_presenter() -> void:
	combatant_presenter = BattleCombatantPresenter.new(
		grid_view,
		combatant_layer,
		combatant_view_scene
	)

	for combatant in session.get_all_combatants():
		var created_view := (
			combatant_presenter.add_combatant(
				combatant,
				false
			)
		)

		assert(
			created_view != null,
			"Failed to create view for combatant '%s'."
			% combatant.instance_id
		)

		debug_log_presenter.connect_combatant(
			combatant
		)


func _create_movement_runner() -> void:
	movement_runner = BattleMovementRunner.new(
		movement_service,
		combatant_presenter
	)


func _create_action_runner() -> void:
	action_runner = BattleActionRunner.new(
		action_service,
		combatant_presenter
	)


func _create_grid_overlay_presenter() -> void:
	grid_overlay_presenter = (
		BattleGridOverlayPresenter.new(
			grid_view,
			movement_service,
			action_service,
			targeting_service,
			show_targeting_debug
		)
	)


func _create_ai_system() -> void:
	ai_controller = BasicMeleeAIController.new(
		movement_service,
		action_service,
		targeting_service
	)

	ai_turn_runner = BasicMeleeAITurnRunner.new(
		movement_runner,
		action_runner
	)


func _create_reinforcement_system() -> void:
	reinforcement_controller = (
		BattleReinforcementController.new(
			session,
			encounter_definition.reinforcement_waves
		)
	)

	reinforcement_controller.combatant_spawned.connect(
		_on_reinforcement_combatant_spawned
	)

	reinforcement_controller.wave_completed.connect(
		_on_reinforcement_wave_completed
	)

	reinforcement_controller.wave_deferred.connect(
		_on_reinforcement_wave_deferred
	)


func _create_turn_controller() -> void:
	turn_controller = BattleTurnController.new()


func _create_interaction_controller() -> void:
	interaction_controller = (
		BattleSandboxInteractionController.new(
			PLAYER_TEAM_ID,
			session,
			turn_controller,
			ability_panel,
			combatant_hover_panel,
			movement_service,
			targeting_service,
			movement_runner,
			action_runner,
			grid_overlay_presenter,
			debug_log_presenter,
			stamina_cost_per_cell,
			animate_movement,
			animate_actions
		)
	)


func _connect_grid_signals() -> void:
	grid_view.cell_clicked.connect(
		interaction_controller.on_grid_cell_clicked
	)

	grid_view.cell_hovered.connect(
		interaction_controller.on_grid_cell_hovered
	)


func _connect_ability_panel() -> void:
	assert(
		ability_panel != null,
		"Battle ability panel is required."
	)

	ability_panel.ability_selected.connect(
		interaction_controller.on_ability_selected
	)


func _connect_turn_signals() -> void:
	turn_controller.turn_started.connect(
		_on_turn_started
	)

	turn_controller.periodic_status_effects_resolved.connect(
		_on_periodic_status_effects_resolved
	)

	turn_controller.battle_finished.connect(
		_on_battle_finished
	)


func _start_battle() -> void:
	var started := turn_controller.start(
		session,
		reinforcement_controller
	)

	assert(
		started,
		"Failed to start battle turn controller."
	)


func _on_reinforcement_combatant_spawned(
	combatant: CombatantState,
	wave_id: StringName,
	scheduled_round: int,
	actual_round: int,
	coordinate: Vector2i
) -> void:
	var created_view := (
		combatant_presenter.add_combatant(
			combatant,
			false
		)
	)

	assert(
		created_view != null,
		"Failed to create reinforcement view "
		+"for combatant '%s'."
		% combatant.instance_id
	)

	debug_log_presenter.connect_combatant(
		combatant
	)

	print(
		"Reinforcement '%s' from wave '%s' "
		% [
			combatant.instance_id,
			wave_id,
		]
		+"spawned at %s. Scheduled round: %d, "
		% [
			coordinate,
			scheduled_round,
		]
		+"actual round: %d."
		% actual_round
	)


func _on_reinforcement_wave_completed(
	wave_id: StringName,
	actual_round: int
) -> void:
	print(
		"Reinforcement wave '%s' completed "
		% wave_id
		+"on round %d."
		% actual_round
	)


func _on_reinforcement_wave_deferred(
	wave_id: StringName,
	pending_combatant_count: int,
	actual_round: int
) -> void:
	print(
		"Reinforcement wave '%s' deferred "
		% wave_id
		+"on round %d. Pending combatants: %d."
		% [
			actual_round,
			pending_combatant_count,
		]
	)


func _on_periodic_status_effects_resolved(
	combatant: CombatantState,
	timing: int,
	trigger_results: Array[
		BattleStatusPeriodicTriggerResult
	]
) -> void:
	debug_log_presenter.append_periodic_trigger_results(
		combatant,
		timing,
		trigger_results
	)

	var removed_view_ids: Dictionary = {}

	for trigger_result in trigger_results:
		if trigger_result == null:
			continue

		for target_id in (
			trigger_result
			.get_defeated_target_ids()
		):
			if removed_view_ids.has(
				target_id
			):
				continue

			removed_view_ids[
				target_id
			] = true

			if combatant_presenter.has_view(
				target_id
			):
				combatant_presenter.remove_view(
					target_id
				)

	if interaction_controller != null:
		interaction_controller.refresh_grid_overlays()
		
func _on_turn_started(
	combatant: CombatantState,
	current_round: int,
	_turn_index: int
) -> void:
	_set_active_combatant_selection(
		combatant
	)

	if combatant.team_id == PLAYER_TEAM_ID:
		interaction_controller.begin_player_turn(
			combatant
		)

		var selected_ability := (
			interaction_controller.get_selected_ability()
		)

		var ability_name := (
			selected_ability.display_name
			if selected_ability != null
			else "не выбрана"
		)

		debug_log_presenter.set_headline(
			"Раунд %d. Твой ход: %s. "
			% [
				current_round,
				combatant.definition.display_name,
			]
			+"Выносливость: %d/%d. "
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
			+"Статусы: %s. "
			% debug_log_presenter.get_status_summary(
				combatant
			)
			+"Выбрано: %s. "
			% ability_name
			+"1–9 — способность, Space — завершить ход."
		)

		return

	interaction_controller.begin_enemy_turn()

	debug_log_presenter.set_headline(
		"Раунд %d. Ход врага: %s. "
		% [
			current_round,
			combatant.definition.display_name,
		]
		+"Статусы: %s."
		% debug_log_presenter.get_status_summary(
			combatant
		)
	)

	call_deferred(
		"_run_ai_turn",
		combatant
	)


func _on_battle_finished(
	winning_team_id: StringName
) -> void:
	_set_active_combatant_selection(
		null
	)

	interaction_controller.finish_battle()

	if winning_team_id == PLAYER_TEAM_ID:
		debug_log_presenter.set_headline(
			"Бой завершён. Победа!"
		)

	elif winning_team_id == ENEMY_TEAM_ID:
		debug_log_presenter.set_headline(
			"Бой завершён. Поражение."
		)

	else:
		debug_log_presenter.set_headline(
			"Бой завершён без победителя."
		)


func _set_active_combatant_selection(
	active: CombatantState
) -> void:
	for combatant in session.get_all_combatants():
		var view := combatant_presenter.get_view(
			combatant.instance_id
		)

		if view == null:
			continue

		view.set_selected_state(
			combatant == active
		)


func _run_ai_turn(
	combatant: CombatantState
) -> void:
	if not _is_combatant_still_active(
		combatant
	):
		return

	if ai_think_delay > 0.0:
		await get_tree().create_timer(
			ai_think_delay
		).timeout

	if not _is_combatant_still_active(
		combatant
	):
		return

	var ability := combatant.get_default_ability()

	if ability == null:
		debug_log_presenter.set_headline(
			"%s не имеет доступных способностей."
			% combatant.definition.display_name
		)

		_finish_ai_turn(
			combatant
		)
		return

	var plan := ai_controller.create_turn_plan(
		grid,
		session,
		combatant,
		ability,
		stamina_cost_per_cell
	)

	if not plan.is_valid:
		debug_log_presenter.set_headline(
			"%s завершает ход: %s."
			% [
				combatant.definition.display_name,
				plan.failure_code,
			]
		)

		_finish_ai_turn(
			combatant
		)
		return

	grid_overlay_presenter.clear()

	var outcome := await ai_turn_runner.execute(
		session,
		plan,
		animate_movement,
		animate_actions
	)

	if turn_controller.is_finished:
		interaction_controller.set_interaction_in_progress(
			false
		)
		return

	if not outcome.is_successful:
		debug_log_presenter.set_headline(
			"Ход ИИ выполнен не полностью: %s."
			% outcome.failure_code
		)

	elif outcome.did_attack():
		debug_log_presenter.set_headline(
			"%s использует «%s» против %s. "
			% [
				combatant.definition.display_name,
				ability.display_name,
				plan.target.definition.display_name,
			]
			+"Ударов: %d. Общий урон: %d. "
			% [
				outcome.get_attack_count(),
				outcome.get_damage_dealt(),
			]
			+"Здоровье цели: %d/%d. "
			% [
				plan.target.current_health,
				plan.target.max_health,
			]
			+"Выносливость врага: %d/%d."
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
		)

	elif outcome.did_move():
		debug_log_presenter.set_headline(
			"%s приближается к %s. "
			% [
				combatant.definition.display_name,
				plan.target.definition.display_name,
			]
			+"Пройдено клеток: %d. "
			% outcome.get_movement_step_count()
			+"Осталось выносливости: %d/%d."
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
		)

	else:
		debug_log_presenter.set_headline(
			"%s не может действовать."
			% combatant.definition.display_name
		)

	interaction_controller.refresh_grid_overlays()

	_finish_ai_turn(
		combatant
	)


func _is_combatant_still_active(
	combatant: CombatantState
) -> bool:
	return (
		turn_controller != null
		and turn_controller.is_running
		and turn_controller.is_combatant_active(
			combatant
		)
	)


func _finish_ai_turn(
	combatant: CombatantState
) -> void:
	if not _is_combatant_still_active(
		combatant
	):
		return

	turn_controller.end_current_turn()
