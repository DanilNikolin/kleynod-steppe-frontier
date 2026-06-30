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
	ContentMargin / VBoxContainer / StatusLabel
)

@onready
var ability_panel: BattleAbilityPanel = (
	$CanvasLayer/AbilityPanel
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

var session_factory := BattleSessionFactory.new()

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService

var _obstacle_counter: int = 0
var _interaction_in_progress: bool = false

var _selected_ability: AbilityDefinition

var _status_headline: String = ""

var _battle_log_lines := PackedStringArray()

var _hovered_coordinate: Vector2i = (
	BattleGridView.INVALID_COORDINATE
)


func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_action_services()
	_create_combatant_presenter()
	_create_movement_runner()
	_create_action_runner()
	_create_grid_overlay_presenter()
	_create_ai_system()
	_create_reinforcement_system()
	_connect_grid_signals()
	_connect_ability_panel()
	_create_turn_controller()

func _connect_ability_panel() -> void:
	assert(
		ability_panel != null,
		"Battle ability panel is required."
	)

	ability_panel.ability_selected.connect(
		_on_ability_selected
	)

func _on_ability_selected(
	ability: AbilityDefinition
) -> void:
	if ability == null:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	var active := (
		turn_controller.active_combatant
	)

	if (
		active == null
		or active.team_id != PLAYER_TEAM_ID
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if _interaction_in_progress:
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if not active.has_ability(
		ability.ability_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if not active.can_spend_stamina(
		ability.stamina_cost
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	_selected_ability = ability

	ability_panel.set_selected_ability(
		_selected_ability
	)

	_refresh_grid_overlays()

	_set_status(
		"%s выбирает «%s». "
		% [
			active.definition.display_name,
			ability.display_name,
		]
		+"Стоимость: %d выносливости."
		% ability.stamina_cost
	)

func _create_action_services() -> void:
	targeting_service = (
		BattleTargetingService.new()
	)

	action_service = BattleActionService.new(
		targeting_service
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

	turn_controller.turn_started.connect(
		_on_turn_started
	)

	turn_controller.battle_finished.connect(
		_on_battle_finished
	)

	var started := turn_controller.start(
		session,
		reinforcement_controller
	)

	assert(
		started,
		"Failed to start battle turn controller."
	)


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

		_connect_combatant_status_signals(
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

	_connect_combatant_status_signals(
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

func _connect_grid_signals() -> void:
	grid_view.cell_clicked.connect(
		_on_grid_cell_clicked
	)

	grid_view.cell_hovered.connect(
		_on_grid_cell_hovered
	)


func _unhandled_input(
	event: InputEvent
) -> void:
	if _interaction_in_progress:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	if not (
		event is InputEventKey
		and event.pressed
		and not event.echo
	):
		return

	if event.keycode == KEY_T:
		_apply_debug_status_to_hovered_combatant()

		get_viewport().set_input_as_handled()
		return

	if (
		event.keycode == KEY_SPACE
		and _is_player_turn()
	):
		_end_active_turn()

		get_viewport().set_input_as_handled()


func _on_grid_cell_hovered(
	coordinate: Vector2i
) -> void:
	_hovered_coordinate = coordinate

	if not _interaction_in_progress:
		_refresh_grid_overlays()


func _on_grid_cell_clicked(
	coordinate: Vector2i,
	mouse_button: int
) -> void:
	if _interaction_in_progress:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	if not _is_player_turn():
		return

	var active_combatant := (
		_get_active_combatant()
	)

	if active_combatant == null:
		return

	match mouse_button:
		MOUSE_BUTTON_LEFT:
			var ability := (
				_get_selected_ability(
					active_combatant
				)
			)


			var target := (
				_get_combatant_at_coordinate(
					coordinate
				)
			)

			# Это уже позволит следующим способностям
			# применяться по пустым клеткам.
			if (
				ability != null
				and targeting_service.can_target(
					session,
					active_combatant,
					ability,
					coordinate
				)
			):
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

			elif target == null:
				_try_move_active_combatant(
					active_combatant,
					coordinate
				)

			elif target == active_combatant:
				_set_status(
					"%s уже находится на клетке %s."
					% [
						active_combatant
						.definition.display_name,
						coordinate,
					]
				)

			elif (
				target.team_id
				== active_combatant.team_id
			):
				_set_status(
					"Клетка %s занята союзником %s."
					% [
						coordinate,
						target.definition.display_name,
					]
				)

			else:
				# Враг есть, но клетка может быть
				# вне маски. Показываем ошибку атаки,
				# а не ошибку движения.
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

		MOUSE_BUTTON_RIGHT:
			_toggle_obstacle(
				coordinate
			)


func _get_active_combatant() -> CombatantState:
	if turn_controller == null:
		return null

	if not turn_controller.is_running:
		return null

	return turn_controller.active_combatant

func _get_selected_ability(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	if (
		combatant.team_id == PLAYER_TEAM_ID
		and _selected_ability != null
		and combatant.has_ability(
			_selected_ability.ability_id
		)
	):
		return _selected_ability

	return _get_default_ability(
		combatant
	)
	
func _get_default_ability(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	return combatant.get_default_ability()


func _get_combatant_at_coordinate(
	coordinate: Vector2i
) -> CombatantState:
	if grid == null or session == null:
		return null

	var cell := grid.get_cell(
		coordinate
	)

	if cell == null or not cell.is_occupied():
		return null

	return session.get_combatant(
		cell.occupant_id
	)

func _is_player_turn() -> bool:
	var active_combatant := (
		_get_active_combatant()
	)

	return (
		active_combatant != null
		and active_combatant.team_id
		== PLAYER_TEAM_ID
	)


func _end_active_turn() -> void:
	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	turn_controller.end_current_turn()


func _on_turn_started(
	combatant: CombatantState,
	current_round: int,
	_turn_index: int
) -> void:
	_set_active_combatant_selection(
		combatant
	)

	if combatant.team_id == PLAYER_TEAM_ID:
		_interaction_in_progress = false

		_selected_ability = (
			_get_default_ability(
				combatant
			)
		)

		ability_panel.bind_combatant(
			combatant,
			_selected_ability
		)

		ability_panel.set_interactable(
			true
		)

		_refresh_grid_overlays()

		var ability_name := (
			_selected_ability.display_name
			if _selected_ability != null
			else "не выбрана"
		)

		_set_status(
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
			% _get_status_summary(
				combatant
			)
			+"Выбрано: %s. "
			% ability_name
			+"1–9 — способность, Space — завершить ход."
		)

		return

	_interaction_in_progress = true
	_selected_ability = null

	ability_panel.clear_combatant()

	_refresh_grid_overlays()

	_set_status(
		"Раунд %d. Ход врага: %s. "
		% [
			current_round,
			combatant.definition.display_name,
		]
		+"Статусы: %s."
		% _get_status_summary(
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
	_interaction_in_progress = false

	_set_active_combatant_selection(
		null
	)

	_selected_ability = null
	ability_panel.clear_combatant()

	grid_overlay_presenter.clear()

	if winning_team_id == PLAYER_TEAM_ID:
		_set_status(
			"Бой завершён. Победа!"
		)

	elif winning_team_id == ENEMY_TEAM_ID:
		_set_status(
			"Бой завершён. Поражение."
		)

	else:
		_set_status(
			"Бой завершён без победителя."
		)


func _input(
	event: InputEvent
) -> void:
	if not (event is InputEventKey):
		return

	var key_event := (
		event as InputEventKey
	)

	if (
		not key_event.pressed
		or key_event.echo
	):
		return

	var ability_index := (
		_get_ability_hotkey_index(
			key_event
		)
	)

	if ability_index < 0:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	var active := (
		turn_controller.active_combatant
	)

	if (
		active == null
		or active.team_id != PLAYER_TEAM_ID
		or _interaction_in_progress
	):
		return

	var selected := (
		ability_panel
		.select_ability_by_index(
			ability_index,
			true
		)
	)

	if selected:
		get_viewport().set_input_as_handled()


func _get_ability_hotkey_index(
	event: InputEventKey
) -> int:
	var keycodes: Array[int] = [
		event.keycode,
		event.physical_keycode,
	]

	for keycode in keycodes:
		match keycode:
			KEY_1:
				return 0

			KEY_2:
				return 1

			KEY_3:
				return 2

			KEY_4:
				return 3

			KEY_5:
				return 4

			KEY_6:
				return 5

			KEY_7:
				return 6

			KEY_8:
				return 7

			KEY_9:
				return 8

	return -1
	
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

	var ability := _get_default_ability(
		combatant
	)

	if ability == null:
		_set_status(
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
		_set_status(
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
		_interaction_in_progress = false
		return

	if not outcome.is_successful:
		_set_status(
			"Ход ИИ выполнен не полностью: %s."
			% outcome.failure_code
		)

	elif outcome.did_attack():
		_set_status(
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
		_set_status(
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
		_set_status(
			"%s не может действовать."
			% combatant.definition.display_name
		)

	_refresh_grid_overlays()

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
	
func _try_move_active_combatant(
	combatant: CombatantState,
	target_coordinate: Vector2i
) -> void:
	if combatant == null:
		return

	if not turn_controller.is_combatant_active(
		combatant
	):
		return

	var plan := movement_service.create_plan(
		grid,
		combatant,
		target_coordinate,
		stamina_cost_per_cell
	)

	if not plan.is_valid:
		_set_status(
			_get_movement_failure_message(
				plan.failure_code,
				plan,
				combatant
			)
		)

		_refresh_grid_overlays()
		return

	var previous_coordinate := (
		combatant.grid_position
	)

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	_set_status(
		"%s движется к клетке %s..."
		% [
			combatant.definition.display_name,
			plan.target_coordinate,
		]
	)

	var movement_outcome := await (
		movement_runner.execute(
			grid,
			combatant,
			plan,
			animate_movement
		)
	)

	if not movement_outcome.is_successful:
		_interaction_in_progress = false

		_set_status(
			"Не удалось выполнить перемещение: %s."
			% movement_outcome.failure_code
		)

		_refresh_grid_overlays()
		return

	_set_status(
		"%s идёт %s → %s. Шагов: %d. "
		% [
			combatant.definition.display_name,
			previous_coordinate,
			plan.target_coordinate,
			movement_outcome.get_step_count(),
		]
		+"Потрачено выносливости: %d. "
		% plan.stamina_cost
		+"Осталось: %d/%d."
		% [
			combatant.current_stamina,
			combatant.max_stamina,
		]
	)

	_interaction_in_progress = false
	_refresh_grid_overlays()


func _try_use_ability_at(
	actor: CombatantState,
	aim_coordinate: Vector2i
) -> void:
	if actor == null:
		return

	if not turn_controller.is_combatant_active(
		actor
	):
		return

	var ability := _get_selected_ability(
		actor
	)

	if ability == null:
		_set_status(
			"%s не имеет доступных способностей."
			% actor.definition.display_name
		)

		return

	var command := BattleActionCommand.new(
		actor,
		ability,
		aim_coordinate
	)

	var failure_code := (
		action_runner.get_validation_failure(
			session,
			command
		)
	)

	if failure_code != &"":
		_set_status(
			_get_action_failure_message(
				failure_code,
				actor,
				ability
			)
		)

		_refresh_grid_overlays()
		return

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	var action_outcome := await (
		action_runner.execute_action(
			session,
			command,
			animate_actions
		)
	)

	if not action_outcome.is_successful:
		_interaction_in_progress = false

		_set_status(
			"Действие не выполнено: %s."
			% action_outcome.failure_code
		)

		_refresh_grid_overlays()
		return

	_append_damage_results_to_log(
		action_outcome.action_result
	)

	if turn_controller.is_finished:
		_interaction_in_progress = false
		return

	var damage_dealt := (
		action_outcome.get_total_applied_amount(
			&"damage"
		)
	)

	var affected_count := (
		action_outcome
		.get_affected_target_count()
	)

	var defeated_count := (
		action_outcome
		.get_defeated_target_ids()
		.size()
	)

	_set_status(
		"%s использует «%s» по клетке %s. "
		% [
			actor.definition.display_name,
			ability.display_name,
			aim_coordinate,
		]
		+"Задето целей: %d. "
		% affected_count
		+"Общий урон: %d. "
		% damage_dealt
		+"Погибло целей: %d. "
		% defeated_count
		+"Выносливость: %d/%d."
		% [
			actor.current_stamina,
			actor.max_stamina,
		]
	)

	_interaction_in_progress = false
	_refresh_grid_overlays()

func _toggle_obstacle(
	coordinate: Vector2i
) -> void:
	var cell := grid.get_cell(coordinate)

	if cell == null:
		return

	if cell.is_occupied():
		_set_status(
			"Нельзя поставить препятствие под бойца."
		)
		return

	if cell.has_obstacle():
		var obstacle_id := cell.obstacle_id

		grid.remove_obstacle(
			obstacle_id
		)

		_set_status(
			"Препятствие удалено с клетки %s."
			% coordinate
		)

		_refresh_grid_overlays()
		return

	_obstacle_counter += 1

	var new_obstacle_id := StringName(
		"debug_obstacle_%d"
		% _obstacle_counter
	)

	if not grid.try_place_obstacle(
		new_obstacle_id,
		coordinate
	):
		_set_status(
			"Не удалось поставить препятствие."
		)
		return

	_set_status(
		"Препятствие установлено на клетку %s."
		% coordinate
	)

	_refresh_grid_overlays()


func _refresh_grid_overlays() -> void:
	if grid_overlay_presenter == null:
		return

	if turn_controller == null:
		grid_overlay_presenter.clear()
		return

	if not turn_controller.is_running:
		grid_overlay_presenter.clear()
		return

	var active := (
		turn_controller.active_combatant
	)

	if active == null:
		grid_overlay_presenter.clear()
		return

	var target_candidates: Array[CombatantState] = []

	for combatant in session.get_living_combatants():
		if combatant.team_id == active.team_id:
			continue

		target_candidates.append(
			combatant
		)

	var selected_ability := (
		_get_selected_ability(
			active
		)
	)

	grid_overlay_presenter.refresh(
		session,
		active,
		target_candidates,
		selected_ability,
		_hovered_coordinate,
		stamina_cost_per_cell
	)


func _get_action_failure_message(
	failure_code: StringName,
	actor: CombatantState,
	ability: AbilityDefinition
) -> String:
	match failure_code:
		BattleTargetingService.FAILURE_AIM_NOT_IN_PATTERN:
			return (
				"Выбранная клетка не входит в зону "
				+"досягаемости способности."
			)

		BattleTargetingService.FAILURE_AIM_OUTSIDE_GRID:
			return (
				"Выбранная клетка находится "
				+"за пределами поля."
			)

		BattleTargetingService.FAILURE_AIM_CELL_MUST_BE_OCCUPIED:
			return (
				"Для этой способности нужно выбрать "
				+"занятую клетку."
			)

		BattleTargetingService.FAILURE_AIM_CELL_MUST_BE_EMPTY:
			return (
				"Для этой способности нужно выбрать "
				+"пустую клетку."
			)

		BattleTargetingService.FAILURE_INVALID_AIM_RELATION:
			return (
				"Эта способность не может быть "
				+"применена к выбранному бойцу."
			)

		BattleActionService.FAILURE_NOT_ENOUGH_STAMINA:
			var cost := (
				ability.stamina_cost
				if ability != null
				else 0
			)

			return (
				"Недостаточно выносливости. "
				+"Нужно: %d, доступно: %d."
				% [
					cost,
					actor.current_stamina,
				]
			)

		BattleActionService.FAILURE_ABILITY_NOT_IN_LOADOUT:
			return (
				"Выбранная способность отсутствует "
				+"в loadout бойца."
			)

		BattleTargetingService.FAILURE_ACTOR_DEAD:
			return (
				"Погибший боец не может "
				+"использовать способности."
			)

		_:
			return (
				"Действие невозможно: %s."
				% failure_code
			)


func _get_movement_failure_message(
	failure_code: StringName,
	plan: BattleMovementPlan,
	combatant: CombatantState
) -> String:
	match failure_code:
		BattleMovementService.FAILURE_TARGET_IS_START:
			return (
				"%s уже находится на выбранной клетке."
				% combatant.definition.display_name
			)

		BattleMovementService.FAILURE_TARGET_OUTSIDE_TEAM_SIDE:
			return (
				"Обычным движением нельзя переходить "
				+"на сторону противника."
			)

		BattleMovementService.FAILURE_TARGET_BLOCKED:
			return (
				"Клетка %s занята или заблокирована."
				% plan.target_coordinate
			)

		BattleMovementService.FAILURE_NO_PATH:
			return (
				"До клетки %s невозможно построить маршрут."
				% plan.target_coordinate
			)

		BattleMovementService.FAILURE_NOT_ENOUGH_STAMINA:
			return (
				"Недостаточно выносливости. "
				+"Нужно: %d, доступно: %d."
				% [
					plan.stamina_cost,
					combatant.current_stamina,
				]
			)

		BattleMovementService.FAILURE_TARGET_OUTSIDE_GRID:
			return "Цель находится за пределами поля."

		BattleMovementService.FAILURE_DEAD_COMBATANT:
			return "Погибший боец не может двигаться."

		_:
			return (
				"Перемещение невозможно: %s."
				% failure_code
			)


func _set_status(
	message: String
) -> void:
	_status_headline = message
	_refresh_status_label()


func _push_battle_log(
	message: String
) -> void:
	if message.strip_edges().is_empty():
		return

	_battle_log_lines.append(
		message
	)

	while (
		_battle_log_lines.size()
		> MAX_BATTLE_LOG_LINES
	):
		_battle_log_lines.remove_at(0)

	print(message)

	_refresh_status_label()


func _refresh_status_label() -> void:
	var text := _status_headline

	if not _battle_log_lines.is_empty():
		if not text.is_empty():
			text += "\n\n"

		text += "Журнал боя:\n• "
		text += "\n• ".join(
			_battle_log_lines
		)

	status_label.text = text


func _connect_combatant_status_signals(
	combatant: CombatantState
) -> void:
	if combatant == null:
		return

	var added_callback := Callable(
		self,
		"_on_combatant_status_added"
	).bind(
		combatant
	)

	var updated_callback := Callable(
		self,
		"_on_combatant_status_updated"
	).bind(
		combatant
	)

	var removed_callback := Callable(
		self,
		"_on_combatant_status_removed"
	).bind(
		combatant
	)

	if not combatant.is_connected(
		&"status_added",
		added_callback
	):
		combatant.connect(
			&"status_added",
			added_callback
		)

	if not combatant.is_connected(
		&"status_updated",
		updated_callback
	):
		combatant.connect(
			&"status_updated",
			updated_callback
		)

	if not combatant.is_connected(
		&"status_removed",
		removed_callback
	):
		combatant.connect(
			&"status_removed",
			removed_callback
		)


func _on_combatant_status_added(
	status: BattleStatusInstance,
	combatant: CombatantState
) -> void:
	var status_armor_modifier := (
		_get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		- status_armor_modifier
	)

	var current_armor := (
		combatant.get_effective_armor()
	)

	var message := (
		"%s получает «%s»."
		% [
			combatant.definition.display_name,
			status.definition.display_name,
		]
	)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	message += (
		" Длительность: %s."
		% _format_turn_count(
			status.remaining_turns
		)
	)

	_push_battle_log(
		message
	)


func _on_combatant_status_updated(
	status: BattleStatusInstance,
	previous_stack_count: int,
	previous_remaining_turns: int,
	combatant: CombatantState
) -> void:
	var current_status_modifier := (
		_get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_status_modifier: int = 0

	if (
		status != null
		and status.definition != null
	):
		for modifier in (
			status.definition.stat_modifiers
		):
			if (
				modifier != null
				and modifier.stat
				== BattleStatModifier.Stat.ARMOR
			):
				previous_status_modifier += (
					modifier.get_total_amount(
						previous_stack_count
					)
				)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_modifier_total := (
		current_modifier_total
		- current_status_modifier
		+ previous_status_modifier
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ previous_modifier_total
	)

	var current_armor := (
		combatant.get_effective_armor()
	)

	var changes := PackedStringArray()

	if previous_stack_count != status.stack_count:
		changes.append(
			"стаки: %d → %d"
			% [
				previous_stack_count,
				status.stack_count,
			]
		)

	if previous_armor != current_armor:
		changes.append(
			"броня: %d → %d"
			% [
				previous_armor,
				current_armor,
			]
		)

	if (
		previous_remaining_turns
		!= status.remaining_turns
	):
		if (
			status.remaining_turns
			> previous_remaining_turns
		):
			changes.append(
				"длительность обновлена: %s → %s"
				% [
					_format_turn_count(
						previous_remaining_turns
					),
					_format_turn_count(
						status.remaining_turns
					),
				]
			)

		else:
			changes.append(
				"осталось %s"
				% _format_turn_count(
					status.remaining_turns
				)
			)

	if changes.is_empty():
		changes.append("обновлён")

	_push_battle_log(
		"«%s» у %s: %s."
		% [
			status.definition.display_name,
			combatant.definition.display_name,
			", ".join(changes),
		]
	)


func _on_combatant_status_removed(
	status: BattleStatusInstance,
	reason: StringName,
	combatant: CombatantState
) -> void:
	var removed_armor_modifier := (
		_get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		+ removed_armor_modifier
	)

	var current_armor := (
		combatant.get_effective_armor()
	)

	var message: String

	match reason:
		&"expired":
			message = (
				"«%s» у %s заканчивается."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		&"owner_defeated":
			message = (
				"«%s» снимается после гибели %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		_:
			message = (
				"«%s» снимается с %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	_push_battle_log(
		message
	)


func _apply_debug_status_to_hovered_combatant() -> void:
	if debug_status_definition == null:
		_set_status(
			"Debug-статус не назначен в Inspector."
		)

		return

	if not debug_status_definition.is_valid_definition():
		_set_status(
			"Назначен некорректный debug-статус."
		)

		return

	var target := _get_combatant_at_coordinate(
		_hovered_coordinate
	)

	if target == null:
		_set_status(
			"Наведи курсор на бойца и нажми T."
		)

		return

	var source := _get_active_combatant()

	var source_instance_id: StringName = &""

	if source != null:
		source_instance_id = (
			source.instance_id
		)

	var applied_status := target.add_status(
		debug_status_definition,
		source_instance_id
	)

	if applied_status == null:
		_set_status(
			"Не удалось применить debug-статус."
		)

		return

	_set_status(
		"%s: %s. Текущая броня: %d."
		% [
			target.definition.display_name,
			_format_status_for_player(
				applied_status
			),
			target.get_effective_armor(),
		]
	)


func _get_status_summary(
	combatant: CombatantState
) -> String:
	if combatant == null:
		return "нет"

	var statuses := (
		combatant.get_active_statuses()
	)

	if statuses.is_empty():
		return "нет"

	var parts := PackedStringArray()

	for status in statuses:
		if status == null:
			continue

		parts.append(
			_format_status_for_player(
				status
			)
		)

	if parts.is_empty():
		return "нет"

	return "; ".join(parts)

func _format_status_for_player(
	status: BattleStatusInstance
) -> String:
	if (
		status == null
		or status.definition == null
	):
		return "Неизвестный статус"

	var title := (
		status.definition.display_name
	)

	if status.stack_count > 1:
		title += " ×%d" % status.stack_count

	var effects := PackedStringArray()

	var armor_modifier := (
		_get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	if armor_modifier != 0:
		effects.append(
			"броня %s"
			% _format_signed_integer(
				armor_modifier
			)
		)

	if effects.is_empty():
		effects.append(
			"без активных модификаторов"
		)

	return (
		"%s — %s, осталось %s"
		% [
			title,
			", ".join(effects),
			_format_turn_count(
				status.remaining_turns
			),
		]
	)

func _get_status_stat_modifier_amount(
	status: BattleStatusInstance,
	stat: int
) -> int:
	if (
		status == null
		or status.definition == null
	):
		return 0

	var total: int = 0

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


func _format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


func _format_turn_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d ходов" % value

	if last_digit == 1:
		return "%d ход" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d хода" % value

	return "%d ходов" % value


func _append_damage_results_to_log(
	action_result: BattleActionResult
) -> void:
	if action_result == null:
		return

	for effect_result in (
		action_result.effect_results
	):
		if effect_result == null:
			continue

		if (
			not effect_result.is_successful
			or effect_result.effect_kind
			!= &"damage"
		):
			continue

		var target := session.get_combatant(
			effect_result.target_id
		)

		var target_name := String(
			effect_result.target_id
		)

		if (
			target != null
			and target.definition != null
		):
			target_name = (
				target.definition.display_name
			)

		var armor_text := (
			"%d"
			% effect_result.target_base_armor
		)

		if (
			effect_result
			.target_status_armor_modifier != 0
		):
			armor_text += (
				" %s от статусов = %d"
				% [
					_format_signed_integer(
						effect_result
						.target_status_armor_modifier
					),
					effect_result
					.target_modified_armor,
				]
			)

		var message := (
			"%s получает %d урона. "
			% [
				target_name,
				effect_result.applied_amount,
			]
			+"Сила удара: %d. "
			% effect_result.raw_amount
			+"Броня: %s. "
			% armor_text
			+"Пробитие: %d. "
			% effect_result.armor_piercing
			+"Защита после пробития: %d."
			% effect_result.effective_armor
		)

		if effect_result.target_died:
			message += " Цель погибает."

		_push_battle_log(
			message
		)
