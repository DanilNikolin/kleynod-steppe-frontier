# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['presentation/battle/ai/basic_melee_ai_turn_outcome.gd', 'presentation/battle/ai/basic_melee_ai_turn_runner.gd', 'scenes/debug/battle_grid_sandbox.gd']`
- Allow addons: `False`
- Included files planned: `4`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       └── debug_sabre_slash.tres
│   └── combatants
│       └── debug
│           ├── debug_sechevik.tres
│           └── debug_steppe_raider.tres
├── core
│   └── battle
│       ├── abilities
│       │   └── ability_definition.gd
│       ├── actions
│       │   ├── battle_action_command.gd
│       │   ├── battle_action_result.gd
│       │   ├── battle_action_service.gd
│       │   └── battle_effect_result.gd
│       ├── ai
│       │   ├── basic_melee_ai_controller.gd
│       │   └── basic_melee_ai_turn_plan.gd
│       ├── combatants
│       │   ├── combatant_definition.gd
│       │   └── combatant_state.gd
│       ├── damage
│       │   └── damage_calculator.gd
│       ├── effects
│       │   ├── battle_effect.gd
│       │   ├── damage_effect.gd
│       │   └── effect_resolver.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── movement
│       │   ├── battle_movement_plan.gd
│       │   └── battle_movement_service.gd
│       ├── session
│       │   └── battle_session.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   └── battle
│       ├── ai
│       │   ├── basic_melee_ai_turn_outcome.gd
│       │   └── basic_melee_ai_turn_runner.gd
│       ├── combatants
│       │   ├── battle_combatant_presenter.gd
│       │   ├── combatant_view.gd
│       │   ├── combatant_view.tscn
│       │   ├── combatant_visual.gd
│       │   └── placeholder_combatant_visual.tscn
│       ├── grid
│       │   ├── battle_grid_overlay_presenter.gd
│       │   ├── battle_grid_view.gd
│       │   └── battle_grid_view.tscn
│       └── movement
│           ├── battle_movement_outcome.gd
│           └── battle_movement_runner.gd
├── project.godot
└── scenes
    └── debug
        ├── battle_grid_sandbox.gd
        └── battle_grid_sandbox.tscn
```

---

## 📌 INCLUDED FILES

## FILE: `presentation/battle/ai/basic_melee_ai_turn_outcome.gd`
```gdscript
class_name BasicMeleeAITurnOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var target_id: StringName = &""

var movement_outcome: BattleMovementOutcome

var action_result: BattleActionResult
var action_presented: bool = false


func did_move() -> bool:
	return (
		movement_outcome != null
		and movement_outcome.did_move()
	)


func get_movement_step_count() -> int:
	if movement_outcome == null:
		return 0

	return movement_outcome.get_step_count()


func did_attack() -> bool:
	return (
		action_result != null
		and action_result.is_successful
	)


func get_damage_dealt() -> int:
	if action_result == null:
		return 0

	return action_result.get_total_applied_amount(
		&"damage"
	)


func did_target_die() -> bool:
	return (
		action_result != null
		and action_result.did_target_die()
	)
```

---

## FILE: `presentation/battle/ai/basic_melee_ai_turn_runner.gd`
```gdscript
class_name BasicMeleeAITurnRunner
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_PLAN: StringName = &"invalid_plan"
const FAILURE_ACTION_EXECUTION_FAILED: StringName = (
	&"action_execution_failed"
)
const FAILURE_ACTION_PRESENTATION_FAILED: StringName = (
	&"action_presentation_failed"
)


var movement_runner: BattleMovementRunner
var action_service: BattleActionService
var combatant_presenter: BattleCombatantPresenter


func _init(
	p_movement_runner: BattleMovementRunner,
	p_action_service: BattleActionService,
	p_combatant_presenter: BattleCombatantPresenter
) -> void:
	assert(
		p_movement_runner != null,
		"BasicMeleeAITurnRunner requires a movement runner."
	)

	assert(
		p_action_service != null,
		"BasicMeleeAITurnRunner requires an action service."
	)

	assert(
		p_combatant_presenter != null,
		"BasicMeleeAITurnRunner requires a combatant presenter."
	)

	movement_runner = p_movement_runner
	action_service = p_action_service
	combatant_presenter = p_combatant_presenter


func execute(
	grid: BattleGrid,
	plan: BasicMeleeAITurnPlan,
	animate_movement: bool = true,
	animate_action: bool = true
) -> BasicMeleeAITurnOutcome:
	var outcome := BasicMeleeAITurnOutcome.new()

	if grid == null:
		outcome.failure_code = FAILURE_INVALID_GRID
		return outcome

	if (
		plan == null
		or not plan.is_valid
		or plan.actor == null
		or plan.target == null
		or plan.ability == null
	):
		outcome.failure_code = FAILURE_INVALID_PLAN
		return outcome

	outcome.actor_id = plan.actor.instance_id
	outcome.target_id = plan.target.instance_id

	if plan.has_movement():
		outcome.movement_outcome = await (
			movement_runner.execute(
				grid,
				plan.actor,
				plan.movement_plan,
				animate_movement
			)
		)

		if not outcome.movement_outcome.is_successful:
			outcome.failure_code = (
				outcome.movement_outcome.failure_code
			)

			return outcome

	if not plan.target.is_alive:
		outcome.is_successful = true
		return outcome

	var command := BattleActionCommand.new(
		plan.actor,
		plan.target,
		plan.ability
	)

	if not action_service.can_execute(
		grid,
		command
	):
		outcome.is_successful = true
		return outcome

	outcome.action_result = action_service.execute(
		grid,
		command
	)

	if not outcome.action_result.is_successful:
		outcome.failure_code = (
			FAILURE_ACTION_EXECUTION_FAILED
		)

		return outcome

	outcome.action_presented = await (
		combatant_presenter.play_melee_feedback(
			plan.actor.instance_id,
			plan.target.instance_id,
			outcome.action_result.did_target_die(),
			animate_action
		)
	)

	if not outcome.action_presented:
		outcome.failure_code = (
			FAILURE_ACTION_PRESENTATION_FAILED
		)

		return outcome

	outcome.is_successful = true
	return outcome
```

---

## FILE: `project.godot`
```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="kleynod-steppe-frontier"
config/features=PackedStringArray("4.5", "Forward Plus")
config/icon="res://icon.svg"

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

---

## FILE: `scenes/debug/battle_grid_sandbox.gd`
```gdscript
extends Node2D


const HERO_ID: StringName = &"debug_hero"
const ENEMY_ID: StringName = &"debug_enemy"

const PLAYER_TEAM_ID: StringName = &"team_player"
const ENEMY_TEAM_ID: StringName = &"team_enemy"


@export_group("Combatants")

@export
var combatant_view_scene: PackedScene

@export
var hero_definition: CombatantDefinition

@export
var enemy_definition: CombatantDefinition


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

var hero_state: CombatantState
var enemy_state: CombatantState

var combatant_presenter: BattleCombatantPresenter
var grid_overlay_presenter: BattleGridOverlayPresenter

var movement_runner: BattleMovementRunner
var turn_controller: BattleTurnController

var ai_controller: BasicMeleeAIController
var ai_turn_runner: BasicMeleeAITurnRunner

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
		action_service,
		combatant_presenter
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
		hero_definition != null,
		"Hero definition is not assigned."
	)

	assert(
		enemy_definition != null,
		"Enemy definition is not assigned."
	)

	assert(
		sabre_slash_ability != null,
		"Sabre slash ability is not assigned."
	)

	var hero_errors := (
		hero_definition.get_validation_errors()
	)

	assert(
		hero_errors.is_empty(),
		"Invalid hero definition: %s"
		% hero_errors
	)

	var enemy_errors := (
		enemy_definition.get_validation_errors()
	)

	assert(
		enemy_errors.is_empty(),
		"Invalid enemy definition: %s"
		% enemy_errors
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
	session = BattleSession.new(
		grid_view.rows,
		grid_view.columns
	)

	grid = session.grid

	var hero_start := Vector2i(2, 1)
	var enemy_start := Vector2i(6, 1)

	hero_state = session.add_combatant(
		HERO_ID,
		hero_definition,
		PLAYER_TEAM_ID,
		hero_start
	)

	assert(
		hero_state != null,
		"Failed to create the debug hero."
	)

	enemy_state = session.add_combatant(
		ENEMY_ID,
		enemy_definition,
		ENEMY_TEAM_ID,
		enemy_start
	)

	assert(
		enemy_state != null,
		"Failed to create the debug enemy."
	)


func _create_combatant_presenter() -> void:
	combatant_presenter = BattleCombatantPresenter.new(
		grid_view,
		combatant_layer,
		combatant_view_scene
	)

	var created_hero_view := (
		combatant_presenter.add_combatant(
			hero_state,
			true
		)
	)

	assert(
		created_hero_view != null,
		"Failed to create the hero view."
	)

	var created_enemy_view := (
		combatant_presenter.add_combatant(
			enemy_state,
			false
		)
	)

	assert(
		created_enemy_view != null,
		"Failed to create the enemy view."
	)


func _create_movement_runner() -> void:
	movement_runner = BattleMovementRunner.new(
		movement_service,
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
		_set_status(
			"Сейчас ход %s. "
			% turn_controller.active_combatant.definition.display_name
			+"Нажми Space, чтобы завершить его "
			+"тестовый ход."
		)

		return

	match mouse_button:
		MOUSE_BUTTON_LEFT:
			if _is_living_enemy_coordinate(
				coordinate
			):
				_try_attack_enemy()
			else:
				_try_move_hero(
					coordinate
				)

		MOUSE_BUTTON_RIGHT:
			_toggle_obstacle(
				coordinate
			)


func _is_living_enemy_coordinate(
	coordinate: Vector2i
) -> bool:
	return (
		enemy_state != null
		and enemy_state.is_alive
		and enemy_state.grid_position == coordinate
	)

func _is_player_turn() -> bool:
	return (
		turn_controller != null
		and turn_controller.is_combatant_active(
			hero_state
		)
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

	if outcome.did_target_die():
		combatant_presenter.remove_view(
			outcome.target_id
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
	
func _try_move_hero(
	target_coordinate: Vector2i
) -> void:
	var plan := movement_service.create_plan(
		grid,
		hero_state,
		target_coordinate,
		stamina_cost_per_cell
	)

	if not plan.is_valid:
		_set_status(
			_get_movement_failure_message(
				plan.failure_code,
				plan
			)
		)

		_refresh_grid_overlays()
		return

	var previous_coordinate := (
		hero_state.grid_position
	)

	_interaction_in_progress = true

	grid_overlay_presenter.clear()

	_set_status(
		"%s движется к клетке %s..."
		% [
			hero_definition.display_name,
			plan.target_coordinate,
		]
	)

	var movement_outcome := await (
		movement_runner.execute(
			grid,
			hero_state,
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
			hero_definition.display_name,
			previous_coordinate,
			plan.target_coordinate,
			movement_outcome.get_step_count(),
		]
		+"Потрачено выносливости: %d. Осталось: %d/%d."
		% [
			plan.stamina_cost,
			hero_state.current_stamina,
			hero_state.max_stamina,
		]
	)

	_interaction_in_progress = false
	_refresh_grid_overlays()


func _try_attack_enemy() -> void:
	var command := BattleActionCommand.new(
		hero_state,
		enemy_state,
		sabre_slash_ability
	)

	var failure_code := (
		action_service.get_validation_failure(
			grid,
			command
		)
	)

	if failure_code != &"":
		_set_status(
			_get_action_failure_message(
				failure_code
			)
		)

		_refresh_grid_overlays()
		return

	_interaction_in_progress = true

	grid_overlay_presenter.clear()

	var result := action_service.execute(
		grid,
		command
	)

	if not result.is_successful:
		_interaction_in_progress = false

		_set_status(
			"Действие не выполнено: %s."
			% result.failure_code
		)

		_refresh_grid_overlays()
		return

	var action_presented: bool = await (
		combatant_presenter.play_melee_feedback(
			HERO_ID,
			ENEMY_ID,
			result.did_target_die(),
			animate_actions
		)
	)

	if not action_presented:
		push_error(
			"Failed to present melee action."
		)

	var damage_dealt := (
		result.get_total_applied_amount(
			&"damage"
		)
	)

	if result.did_target_die():
		_set_status(
			"%s использует «%s». Урон: %d. "
			% [
				hero_definition.display_name,
				sabre_slash_ability.display_name,
				damage_dealt,
			]
			+"%s погиб. Его клетка освобождена. "
			% enemy_definition.display_name
			+"Выносливость героя: %d/%d."
			% [
				hero_state.current_stamina,
				hero_state.max_stamina,
			]
		)

		combatant_presenter.remove_view(
			ENEMY_ID
		)
	else:
		_set_status(
			"%s использует «%s». Урон: %d. "
			% [
				hero_definition.display_name,
				sabre_slash_ability.display_name,
				damage_dealt,
			]
			+"Здоровье врага: %d/%d. "
			% [
				enemy_state.current_health,
				enemy_state.max_health,
			]
			+"Выносливость героя: %d/%d."
			% [
				hero_state.current_stamina,
				hero_state.max_stamina,
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
	failure_code: StringName
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
					hero_state.current_stamina,
				]
			)

		BattleActionService.FAILURE_TARGET_DEAD:
			return "Этот противник уже погиб."

		BattleActionService.FAILURE_ACTOR_DEAD:
			return "Погибший герой не может атаковать."

		BattleActionService.FAILURE_INVALID_TARGET_RELATION:
			return "Эту цель нельзя атаковать данным приёмом."

		_:
			return (
				"Действие невозможно: %s."
				% failure_code
			)


func _get_movement_failure_message(
	failure_code: StringName,
	plan: BattleMovementPlan
) -> String:
	match failure_code:
		BattleMovementService.FAILURE_TARGET_IS_START:
			return (
				"%s уже находится на выбранной клетке."
				% hero_definition.display_name
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
					hero_state.current_stamina,
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
```

---


## ✅ STATS
- Total files in tree: 41
- Readable files: 37
- Included files written: 4
- Trimmed files: 0
- Total lines written: 1168
