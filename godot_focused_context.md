# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/actions/battle_action_command.gd', 'core/battle/actions/battle_action_result.gd', 'core/battle/actions/battle_effect_result.gd', 'core/battle/grid/battle_grid.gd', 'core/battle/ai/basic_melee_ai_turn_plan.gd', 'presentation/battle/actions/battle_action_runner.gd', 'presentation/battle/actions/battle_action_outcome.gd', 'presentation/battle/ai/basic_melee_ai_turn_runner.gd', 'presentation/battle/combatants/battle_combatant_presenter.gd']`
- Allow addons: `False`
- Included files planned: `10`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_raider_chop.tres
│   │       └── debug_sabre_slash.tres
│   ├── combatants
│   │   └── debug
│   │       ├── debug_sechevik.tres
│   │       └── debug_steppe_raider.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   └── loadouts
│       └── debug
│           ├── debug_sechevik_loadout.tres
│           └── debug_steppe_raider_loadout.tres
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
│       ├── encounters
│       │   ├── battle_encounter_definition.gd
│       │   ├── battle_reinforcement_wave_definition.gd
│       │   └── combatant_spawn_definition.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── loadouts
│       │   └── combatant_loadout_definition.gd
│       ├── movement
│       │   ├── battle_movement_plan.gd
│       │   └── battle_movement_service.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
│       ├── session
│       │   ├── battle_session.gd
│       │   └── battle_session_factory.gd
│       ├── sides
│       │   └── battle_side_rules.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   └── battle
│       ├── actions
│       │   ├── battle_action_outcome.gd
│       │   └── battle_action_runner.gd
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

## FILE: `core/battle/actions/battle_action_command.gd`
```gdscript
class_name BattleActionCommand
extends RefCounted


var actor: CombatantState
var target: CombatantState
var ability: AbilityDefinition


func _init(
	p_actor: CombatantState = null,
	p_target: CombatantState = null,
	p_ability: AbilityDefinition = null
) -> void:
	actor = p_actor
	target = p_target
	ability = p_ability
```

---

## FILE: `core/battle/actions/battle_action_result.gd`
```gdscript
class_name BattleActionResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var target_id: StringName = &""
var ability_id: StringName = &""

var stamina_cost: int = 0
var stamina_spent: int = 0

var effect_results: Array[BattleEffectResult] = []


func get_total_applied_amount(
	effect_kind: StringName = &""
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if effect_result == null:
			continue

		if (
			effect_kind != &""
			and effect_result.effect_kind != effect_kind
		):
			continue

		total += effect_result.applied_amount

	return total


func did_target_die() -> bool:
	for effect_result in effect_results:
		if (
			effect_result != null
			and effect_result.target_died
		):
			return true

	return false
```

---

## FILE: `core/battle/actions/battle_effect_result.gd`
```gdscript
class_name BattleEffectResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var effect_id: StringName = &""
var effect_kind: StringName = &""

var source_id: StringName = &""
var target_id: StringName = &""

var raw_amount: int = 0
var mitigated_amount: int = 0
var resolved_amount: int = 0
var applied_amount: int = 0

var previous_value: int = 0
var current_value: int = 0

var target_died: bool = false
```

---

## FILE: `core/battle/ai/basic_melee_ai_turn_plan.gd`
```gdscript
class_name BasicMeleeAITurnPlan
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor: CombatantState
var target: CombatantState
var ability: AbilityDefinition

var movement_plan: BattleMovementPlan
var expects_attack_after_movement: bool = false


func has_movement() -> bool:
	return (
		movement_plan != null
		and movement_plan.is_valid
		and movement_plan.has_path()
	)
```

---

## FILE: `core/battle/grid/battle_grid.gd`
```gdscript
class_name BattleGrid
extends RefCounted


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)
const EMPTY_ID: StringName = &""


var rows: int
var columns: int

var _cells: Array[BattleGridCell] = []
var _occupant_positions: Dictionary = {}
var _obstacle_positions: Dictionary = {}


func _init(p_rows: int = 3, p_columns: int = 10) -> void:
	assert(p_rows > 0, "BattleGrid requires at least one row.")
	assert(p_columns > 0, "BattleGrid requires at least one column.")

	rows = p_rows
	columns = p_columns

	_build_cells()


func _build_cells() -> void:
	_cells.clear()
	_cells.resize(rows * columns)

	for row in range(rows):
		for column in range(columns):
			var coordinate := Vector2i(column, row)
			_cells[_coordinate_to_index(coordinate)] = BattleGridCell.new(coordinate)


func _coordinate_to_index(coordinate: Vector2i) -> int:
	return coordinate.y * columns + coordinate.x


func is_inside(coordinate: Vector2i) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)


func get_cell(coordinate: Vector2i) -> BattleGridCell:
	if not is_inside(coordinate):
		return null

	return _cells[_coordinate_to_index(coordinate)]


func get_all_coordinates() -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for row in range(rows):
		for column in range(columns):
			result.append(Vector2i(column, row))

	return result


func get_cells_in_row(row: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if row < 0 or row >= rows:
		return result

	for column in range(columns):
		result.append(Vector2i(column, row))

	return result


func get_cells_in_column(column: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if column < 0 or column >= columns:
		return result

	for row in range(rows):
		result.append(Vector2i(column, row))

	return result


func get_orthogonal_neighbors(
	coordinate: Vector2i,
	walkable_only: bool = false
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]

	for direction in directions:
		var neighbor := coordinate + direction

		if not is_inside(neighbor):
			continue

		if walkable_only:
			var neighbor_cell := get_cell(neighbor)

			if neighbor_cell == null or not neighbor_cell.is_walkable():
				continue

		result.append(neighbor)

	return result


func get_manhattan_distance(
	first_coordinate: Vector2i,
	second_coordinate: Vector2i
) -> int:
	return (
		absi(first_coordinate.x - second_coordinate.x)
		+ absi(first_coordinate.y - second_coordinate.y)
	)


func are_orthogonally_adjacent(
	first_coordinate: Vector2i,
	second_coordinate: Vector2i
) -> bool:
	return get_manhattan_distance(first_coordinate, second_coordinate) == 1


func has_occupant(occupant_id: StringName) -> bool:
	return _occupant_positions.has(occupant_id)


func get_occupant_position(occupant_id: StringName) -> Vector2i:
	return _occupant_positions.get(occupant_id, INVALID_COORDINATE)


func try_place_occupant(
	occupant_id: StringName,
	coordinate: Vector2i
) -> bool:
	if occupant_id == EMPTY_ID:
		return false

	if _occupant_positions.has(occupant_id):
		return false

	var cell := get_cell(coordinate)

	if cell == null or not cell.is_walkable():
		return false

	cell.occupant_id = occupant_id
	_occupant_positions[occupant_id] = coordinate

	return true


func try_move_occupant(
	occupant_id: StringName,
	target_coordinate: Vector2i
) -> bool:
	if not _occupant_positions.has(occupant_id):
		return false

	var source_coordinate: Vector2i = _occupant_positions[occupant_id]

	if source_coordinate == target_coordinate:
		return false

	var source_cell := get_cell(source_coordinate)
	var target_cell := get_cell(target_coordinate)

	if source_cell == null or target_cell == null:
		return false

	if not target_cell.is_walkable():
		return false

	source_cell.occupant_id = EMPTY_ID
	target_cell.occupant_id = occupant_id
	_occupant_positions[occupant_id] = target_coordinate

	return true


func remove_occupant(occupant_id: StringName) -> bool:
	if not _occupant_positions.has(occupant_id):
		return false

	var coordinate: Vector2i = _occupant_positions[occupant_id]
	var cell := get_cell(coordinate)

	if cell != null and cell.occupant_id == occupant_id:
		cell.occupant_id = EMPTY_ID

	_occupant_positions.erase(occupant_id)
	return true


func has_obstacle(obstacle_id: StringName) -> bool:
	return _obstacle_positions.has(obstacle_id)


func get_obstacle_position(obstacle_id: StringName) -> Vector2i:
	return _obstacle_positions.get(obstacle_id, INVALID_COORDINATE)


func try_place_obstacle(
	obstacle_id: StringName,
	coordinate: Vector2i
) -> bool:
	if obstacle_id == EMPTY_ID:
		return false

	if _obstacle_positions.has(obstacle_id):
		return false

	var cell := get_cell(coordinate)

	if cell == null or not cell.is_walkable():
		return false

	cell.obstacle_id = obstacle_id
	_obstacle_positions[obstacle_id] = coordinate

	return true


func remove_obstacle(obstacle_id: StringName) -> bool:
	if not _obstacle_positions.has(obstacle_id):
		return false

	var coordinate: Vector2i = _obstacle_positions[obstacle_id]
	var cell := get_cell(coordinate)

	if cell != null and cell.obstacle_id == obstacle_id:
		cell.obstacle_id = EMPTY_ID

	_obstacle_positions.erase(obstacle_id)
	return true


func clear() -> void:
	for cell in _cells:
		cell.clear()

	_occupant_positions.clear()
	_obstacle_positions.clear()
```

---

## FILE: `presentation/battle/actions/battle_action_outcome.gd`
```gdscript
class_name BattleActionOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var command: BattleActionCommand
var action_result: BattleActionResult

var action_presented: bool = false
var defeated_view_removed: bool = false


func did_execute() -> bool:
	return (
		action_result != null
		and action_result.is_successful
	)


func get_total_applied_amount(
	effect_kind: StringName = &""
) -> int:
	if action_result == null:
		return 0

	return action_result.get_total_applied_amount(
		effect_kind
	)


func did_target_die() -> bool:
	return (
		action_result != null
		and action_result.did_target_die()
	)
```

---

## FILE: `presentation/battle/actions/battle_action_runner.gd`
```gdscript
class_name BattleActionRunner
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_COMMAND: StringName = &"invalid_command"

const FAILURE_EXECUTION_FAILED: StringName = (
	&"execution_failed"
)

const FAILURE_PRESENTATION_FAILED: StringName = (
	&"presentation_failed"
)

const FAILURE_DEFEATED_VIEW_REMOVAL_FAILED: StringName = (
	&"defeated_view_removal_failed"
)


var action_service: BattleActionService
var combatant_presenter: BattleCombatantPresenter


func _init(
	p_action_service: BattleActionService,
	p_combatant_presenter: BattleCombatantPresenter
) -> void:
	assert(
		p_action_service != null,
		"BattleActionRunner requires an action service."
	)

	assert(
		p_combatant_presenter != null,
		"BattleActionRunner requires a combatant presenter."
	)

	action_service = p_action_service
	combatant_presenter = p_combatant_presenter


func can_execute(
	grid: BattleGrid,
	command: BattleActionCommand
) -> bool:
	return get_validation_failure(
		grid,
		command
	) == &""


func get_validation_failure(
	grid: BattleGrid,
	command: BattleActionCommand
) -> StringName:
	if grid == null:
		return FAILURE_INVALID_GRID

	if command == null:
		return FAILURE_INVALID_COMMAND

	return action_service.get_validation_failure(
		grid,
		command
	)


func execute_melee(
	grid: BattleGrid,
	command: BattleActionCommand,
	animated: bool = true,
	remove_defeated_view: bool = true
) -> BattleActionOutcome:
	var outcome := BattleActionOutcome.new()

	outcome.command = command

	var validation_failure := get_validation_failure(
		grid,
		command
	)

	if validation_failure != &"":
		outcome.failure_code = validation_failure
		return outcome

	outcome.action_result = action_service.execute(
		grid,
		command
	)

	if not outcome.action_result.is_successful:
		outcome.failure_code = (
			outcome.action_result.failure_code
			if outcome.action_result.failure_code != &""
			else FAILURE_EXECUTION_FAILED
		)

		return outcome

	outcome.action_presented = await (
		combatant_presenter.play_melee_feedback(
			command.actor.instance_id,
			command.target.instance_id,
			outcome.action_result.did_target_die(),
			animated
		)
	)

	if not outcome.action_presented:
		outcome.failure_code = (
			FAILURE_PRESENTATION_FAILED
		)

		return outcome

	if (
		remove_defeated_view
		and outcome.action_result.did_target_die()
	):
		outcome.defeated_view_removed = (
			combatant_presenter.remove_view(
				command.target.instance_id
			)
		)

		if not outcome.defeated_view_removed:
			outcome.failure_code = (
				FAILURE_DEFEATED_VIEW_REMOVAL_FAILED
			)

			return outcome

	outcome.is_successful = true
	return outcome
```

---

## FILE: `presentation/battle/ai/basic_melee_ai_turn_runner.gd`
```gdscript
class_name BasicMeleeAITurnRunner
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_PLAN: StringName = &"invalid_plan"
const FAILURE_ACTION_LIMIT_REACHED: StringName = (
	&"action_limit_reached"
)

# Защита от бесконечного цикла для будущих
# бесплатных способностей, лечения и прочих эффектов.
const MAX_ACTIONS_PER_TURN: int = 64


var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner


func _init(
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner
) -> void:
	assert(
		p_movement_runner != null,
		"BasicMeleeAITurnRunner requires a movement runner."
	)

	assert(
		p_action_runner != null,
		"BasicMeleeAITurnRunner requires an action runner."
	)

	movement_runner = p_movement_runner
	action_runner = p_action_runner


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

	if not plan.actor.is_alive:
		outcome.is_successful = true
		return outcome

	if not plan.target.is_alive:
		outcome.is_successful = true
		return outcome

	var executed_action_count: int = 0

	while (
		plan.actor.is_alive
		and plan.target.is_alive
	):
		if executed_action_count >= MAX_ACTIONS_PER_TURN:
			outcome.failure_code = (
				FAILURE_ACTION_LIMIT_REACHED
			)

			return outcome

		var command := BattleActionCommand.new(
			plan.actor,
			plan.target,
			plan.ability
		)

		# Обычно цикл закончится здесь,
		# когда не хватит выносливости.
		if not action_runner.can_execute(
			grid,
			command
		):
			break

		var previous_actor_stamina := (
			plan.actor.current_stamina
		)

		var previous_target_health := (
			plan.target.current_health
		)

		var current_action_outcome := await (
			action_runner.execute_melee(
				grid,
				command,
				animate_action
			)
		)

		if not current_action_outcome.is_successful:
			outcome.failure_code = (
				current_action_outcome.failure_code
			)

			return outcome

		outcome.add_action_outcome(
			current_action_outcome
		)

		executed_action_count += 1

		# Дополнительная страховка от способности,
		# которая не тратит ресурс и ничего не меняет.
		var stamina_changed := (
			plan.actor.current_stamina
			!= previous_actor_stamina
		)

		var health_changed := (
			plan.target.current_health
			!= previous_target_health
		)

		if not stamina_changed and not health_changed:
			break

	outcome.is_successful = true
	return outcome
```

---

## FILE: `presentation/battle/combatants/battle_combatant_presenter.gd`
```gdscript
class_name BattleCombatantPresenter
extends RefCounted


var grid_view: BattleGridView
var combatant_layer: Node2D
var combatant_view_scene: PackedScene

var _views: Dictionary = {}


func _init(
	p_grid_view: BattleGridView,
	p_combatant_layer: Node2D,
	p_combatant_view_scene: PackedScene
) -> void:
	assert(p_grid_view != null, "Grid view is required.")
	assert(p_combatant_layer != null, "Combatant layer is required.")
	assert(p_combatant_view_scene != null, "Combatant view scene is required.")

	grid_view = p_grid_view
	combatant_layer = p_combatant_layer
	combatant_view_scene = p_combatant_view_scene


func add_combatant(
	state: CombatantState,
	selected: bool = false
) -> CombatantView:
	if state == null or state.instance_id == &"":
		return null

	if has_view(state.instance_id):
		return null

	var instance := combatant_view_scene.instantiate()

	if not (instance is CombatantView):
		push_error(
			"Combatant view scene must inherit CombatantView."
		)
		instance.queue_free()
		return null

	var view := instance as CombatantView

	combatant_layer.add_child(view)
	view.bind_state(state)
	view.set_selected_state(selected)
	view.snap_to_local_position(
		grid_view.get_cell_center(state.grid_position)
	)

	_views[state.instance_id] = view
	return view


func has_view(instance_id: StringName) -> bool:
	return get_view(instance_id) != null


func get_view(instance_id: StringName) -> CombatantView:
	if not _views.has(instance_id):
		return null

	var value: Variant = _views[instance_id]

	if not is_instance_valid(value):
		_views.erase(instance_id)
		return null

	return value as CombatantView


func move_along_grid_path(
	instance_id: StringName,
	grid_path: Array[Vector2i],
	animated: bool = true
) -> bool:
	var view := get_view(instance_id)

	if view == null or grid_path.is_empty():
		return false

	var local_path: Array[Vector2] = []

	for coordinate in grid_path:
		if not grid_view.is_valid_coordinate(coordinate):
			return false

		local_path.append(
			grid_view.get_cell_center(coordinate)
		)

	view.move_along_local_path(local_path, animated)

	if animated:
		await view.movement_finished

	return true


func face_toward(
	actor_id: StringName,
	target_id: StringName
) -> bool:
	var actor_view := get_view(actor_id)
	var target_view := get_view(target_id)

	if actor_view == null or target_view == null:
		return false

	var horizontal_distance := (
		target_view.position.x - actor_view.position.x
	)

	if not is_zero_approx(horizontal_distance):
		actor_view.set_facing_direction(
			1 if horizontal_distance > 0.0 else -1
		)

	return true


func play_melee_feedback(
	actor_id: StringName,
	target_id: StringName,
	target_died: bool = false,
	animated: bool = true
) -> bool:
	var actor_view := get_view(actor_id)
	var target_view := get_view(target_id)

	if actor_view == null or target_view == null:
		return false

	face_toward(actor_id, target_id)

	actor_view.play_visual_animation(&"attack", &"idle")
	target_view.play_visual_animation(&"hit", &"idle")

	if not animated:
		_finish_melee_feedback(
			actor_view,
			target_view,
			target_died
		)
		return true

	var actor_start := actor_view.position
	var target_original_modulate := target_view.modulate
	var direction := (
		target_view.position - actor_view.position
	).normalized()

	var tween := combatant_layer.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		actor_view,
		"position",
		actor_start + direction * 22.0,
		0.08
	)

	tween.parallel().tween_property(
		target_view,
		"modulate",
		Color(1.0, 0.28, 0.22, 1.0),
		0.06
	)

	tween.tween_property(
		actor_view,
		"position",
		actor_start,
		0.11
	)

	tween.parallel().tween_property(
		target_view,
		"modulate",
		target_original_modulate,
		0.11
	)

	await tween.finished

	_finish_melee_feedback(
		actor_view,
		target_view,
		target_died
	)

	return true


func remove_view(instance_id: StringName) -> bool:
	var view := get_view(instance_id)

	if view == null:
		return false

	_views.erase(instance_id)
	view.queue_free()
	return true


func clear() -> void:
	for value in _views.keys():
		var instance_id: StringName = value
		remove_view(instance_id)


func _finish_melee_feedback(
	actor_view: CombatantView,
	target_view: CombatantView,
	target_died: bool
) -> void:
	if is_instance_valid(actor_view):
		actor_view.play_visual_animation(&"idle", &"")

	if not is_instance_valid(target_view):
		return

	if target_died:
		target_view.play_visual_animation(&"death", &"")
	else:
		target_view.play_visual_animation(&"idle", &"")
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


## ✅ STATS
- Total files in tree: 56
- Readable files: 52
- Included files written: 10
- Trimmed files: 0
- Total lines written: 948
