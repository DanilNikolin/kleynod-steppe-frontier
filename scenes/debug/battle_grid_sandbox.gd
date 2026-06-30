extends Node2D


const PLAYER_TEAM_ID: StringName = &"team_player"
const ENEMY_TEAM_ID: StringName = &"team_enemy"


@export_group("Combatants")

@export
var combatant_view_scene: PackedScene

@export
var encounter_definition: BattleEncounterDefinition


@export_group("Abilities")

@export
var sabre_slash_ability: AbilityDefinition


@export_group("Presentation")

@export
var animate_movement: bool = true

@export
var animate_actions: bool = true

@export_range(0.0, 2.0, 0.05)
var ai_think_delay: float = 0.35


@export_group("Movement")

@export_range(1, 10, 1)
var stamina_cost_per_cell: int = 1


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


var session: BattleSession
var grid: BattleGrid


var combatant_presenter: BattleCombatantPresenter
var grid_overlay_presenter: BattleGridOverlayPresenter

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var turn_controller: BattleTurnController

var ai_controller: BasicMeleeAIController
var ai_turn_runner: BasicMeleeAITurnRunner

var session_factory := BattleSessionFactory.new()

var movement_service := BattleMovementService.new()
var action_service := BattleActionService.new()

var _obstacle_counter: int = 0
var _interaction_in_progress: bool = false

var _hovered_coordinate: Vector2i = (
	BattleGridView.INVALID_COORDINATE
)


func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_combatant_presenter()
	_create_movement_runner()
	_create_action_runner()
	_create_grid_overlay_presenter()
	_create_ai_system()
	_connect_grid_signals()
	_create_turn_controller()

func _create_ai_system() -> void:
	ai_controller = BasicMeleeAIController.new(
		movement_service,
		action_service
	)

	ai_turn_runner = BasicMeleeAITurnRunner.new(
		movement_runner,
		action_runner
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
		session
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

	assert(
		sabre_slash_ability != null,
		"Sabre slash ability is not assigned."
	)

	var ability_errors := (
		sabre_slash_ability.get_validation_errors()
	)

	assert(
		ability_errors.is_empty(),
		"Invalid sabre slash ability: %s"
		% ability_errors
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

	assert(
		grid.rows == grid_view.rows
		and grid.columns == grid_view.columns,
		"Encounter grid dimensions must match "
		+"the current BattleGridView dimensions."
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
			action_service
		)
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

	if (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_SPACE
		and _is_player_turn()
	):
		_end_active_turn()


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
			var target := (
				_get_combatant_at_coordinate(
					coordinate
				)
			)

			if target == null:
				_try_move_active_combatant(
					active_combatant,
					coordinate
				)

			elif target == active_combatant:
				_set_status(
					"%s уже находится на клетке %s."
					% [
						active_combatant.definition.display_name,
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
				_try_attack_target(
					active_combatant,
					target
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

	_refresh_grid_overlays()

	if combatant.team_id == PLAYER_TEAM_ID:
		_interaction_in_progress = false

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
			+"Space — завершить ход."
		)

		return

	_interaction_in_progress = true

	_set_status(
		"Раунд %d. Ход врага: %s."
		% [
			current_round,
			combatant.definition.display_name,
		]
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

	var plan := ai_controller.create_turn_plan(
		grid,
		session,
		combatant,
		sabre_slash_ability,
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
		grid,
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
			"%s атакует %s. Урон: %d. "
			% [
				combatant.definition.display_name,
				plan.target.definition.display_name,
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


func _try_attack_target(
	actor: CombatantState,
	target: CombatantState
) -> void:
	if actor == null or target == null:
		return

	if not turn_controller.is_combatant_active(
		actor
	):
		return

	var command := BattleActionCommand.new(
		actor,
		target,
		sabre_slash_ability
	)

	var failure_code := (
		action_runner.get_validation_failure(
			grid,
			command
		)
	)

	if failure_code != &"":
		_set_status(
			_get_action_failure_message(
				failure_code,
				actor
			)
		)

		_refresh_grid_overlays()
		return

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	var action_outcome := await (
		action_runner.execute_melee(
			grid,
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

	if turn_controller.is_finished:
		_interaction_in_progress = false
		return

	var damage_dealt := (
		action_outcome.get_total_applied_amount(
			&"damage"
		)
	)

	if action_outcome.did_target_die():
		_set_status(
			"%s использует «%s». Урон: %d. "
			% [
				actor.definition.display_name,
				sabre_slash_ability.display_name,
				damage_dealt,
			]
			+"%s погиб. Его клетка освобождена. "
			% target.definition.display_name
			+"Выносливость бойца: %d/%d."
			% [
				actor.current_stamina,
				actor.max_stamina,
			]
		)
	else:
		_set_status(
			"%s использует «%s». Урон: %d. "
			% [
				actor.definition.display_name,
				sabre_slash_ability.display_name,
				damage_dealt,
			]
			+"Здоровье цели: %d/%d. "
			% [
				target.current_health,
				target.max_health,
			]
			+"Выносливость бойца: %d/%d."
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

	grid_overlay_presenter.refresh(
		grid,
		active,
		target_candidates,
		sabre_slash_ability,
		_hovered_coordinate,
		stamina_cost_per_cell
	)


func _get_action_failure_message(
	failure_code: StringName,
	actor: CombatantState
) -> String:
	match failure_code:
		BattleActionService.FAILURE_TARGET_OUT_OF_RANGE:
			return (
				"Враг слишком далеко. "
				+"Для удара саблей нужно стоять "
				+"на соседней клетке."
			)

		BattleActionService.FAILURE_NOT_ENOUGH_STAMINA:
			return (
				"Недостаточно выносливости для удара. "
				+"Нужно: %d, доступно: %d."
				% [
					sabre_slash_ability.stamina_cost,
					actor.current_stamina,
				]
			)

		BattleActionService.FAILURE_TARGET_DEAD:
			return "Этот противник уже погиб."

		BattleActionService.FAILURE_ACTOR_DEAD:
			return "Погибший боец не может атаковать."

		BattleActionService.FAILURE_INVALID_TARGET_RELATION:
			return "Эту цель нельзя атаковать данным приёмом."

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


func _set_status(message: String) -> void:
	status_label.text = message