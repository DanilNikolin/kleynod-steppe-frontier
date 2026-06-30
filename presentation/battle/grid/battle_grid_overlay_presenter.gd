class_name BattleGridOverlayPresenter
extends RefCounted


const REACHABLE_OVERLAY_COLOR := Color(
	0.20,
	0.72,
	0.88,
	0.28
)

const PATH_OVERLAY_COLOR := Color(
	1.0,
	0.82,
	0.24,
	0.52
)

const OBSTACLE_OVERLAY_COLOR := Color(
	0.82,
	0.26,
	0.18,
	0.62
)

const ENEMY_OVERLAY_COLOR := Color(
	0.82,
	0.18,
	0.14,
	0.30
)

const ATTACKABLE_OVERLAY_COLOR := Color(
	1.0,
	0.46,
	0.12,
	0.70
)


var grid_view: BattleGridView

var movement_service: BattleMovementService
var action_service: BattleActionService


func _init(
	p_grid_view: BattleGridView,
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService
) -> void:
	assert(
		p_grid_view != null,
		"BattleGridOverlayPresenter requires a grid view."
	)

	assert(
		p_movement_service != null,
		"BattleGridOverlayPresenter requires a movement service."
	)

	assert(
		p_action_service != null,
		"BattleGridOverlayPresenter requires an action service."
	)

	grid_view = p_grid_view
	movement_service = p_movement_service
	action_service = p_action_service


func refresh(
	grid: BattleGrid,
	selected_combatant: CombatantState,
	target_candidates: Array[CombatantState],
	selected_ability: AbilityDefinition,
	hovered_coordinate: Vector2i,
	stamina_cost_per_cell: int
) -> void:
	clear()

	if grid == null or selected_combatant == null:
		return

	if not selected_combatant.is_alive:
		return

	_draw_reachable_coordinates(
		grid,
		selected_combatant,
		stamina_cost_per_cell
	)

	_draw_obstacles(grid)

	_draw_target_candidates(
		grid,
		selected_combatant,
		target_candidates,
		selected_ability
	)

	_draw_hovered_path(
		grid,
		selected_combatant,
		target_candidates,
		hovered_coordinate,
		stamina_cost_per_cell
	)

	if grid.is_inside(
		selected_combatant.grid_position
	):
		grid_view.set_selected_cell(
			selected_combatant.grid_position
		)


func clear() -> void:
	grid_view.clear_cell_overlays()
	grid_view.clear_selected_cell()


func _draw_reachable_coordinates(
	grid: BattleGrid,
	combatant: CombatantState,
	stamina_cost_per_cell: int
) -> void:
	if stamina_cost_per_cell <= 0:
		return

	var maximum_steps := floori(
		float(combatant.current_stamina)
		/ float(stamina_cost_per_cell)
	)

	var reachable_coordinates := (
		movement_service.get_reachable_coordinates(
			grid,
			combatant.grid_position,
			maximum_steps
		)
	)

	for coordinate in reachable_coordinates:
		grid_view.set_cell_overlay(
			coordinate,
			REACHABLE_OVERLAY_COLOR
		)


func _draw_obstacles(
	grid: BattleGrid
) -> void:
	for coordinate in grid.get_all_coordinates():
		var cell := grid.get_cell(coordinate)

		if cell == null or not cell.has_obstacle():
			continue

		grid_view.set_cell_overlay(
			coordinate,
			OBSTACLE_OVERLAY_COLOR
		)


func _draw_target_candidates(
	grid: BattleGrid,
	actor: CombatantState,
	target_candidates: Array[CombatantState],
	ability: AbilityDefinition
) -> void:
	for target in target_candidates:
		if target == null or not target.is_alive:
			continue

		if not grid.is_inside(target.grid_position):
			continue

		var overlay_color := ENEMY_OVERLAY_COLOR

		if ability != null:
			var command := BattleActionCommand.new(
				actor,
				target,
				ability
			)

			if action_service.can_execute(
				grid,
				command
			):
				overlay_color = (
					ATTACKABLE_OVERLAY_COLOR
				)

		grid_view.set_cell_overlay(
			target.grid_position,
			overlay_color
		)


func _draw_hovered_path(
	grid: BattleGrid,
	combatant: CombatantState,
	target_candidates: Array[CombatantState],
	hovered_coordinate: Vector2i,
	stamina_cost_per_cell: int
) -> void:
	if (
		hovered_coordinate
		== BattleGridView.INVALID_COORDINATE
	):
		return

	if _is_living_target_coordinate(
		target_candidates,
		hovered_coordinate
	):
		return

	var hover_plan := movement_service.create_plan(
		grid,
		combatant,
		hovered_coordinate,
		stamina_cost_per_cell
	)

	if not hover_plan.is_valid:
		return

	for path_coordinate in hover_plan.path:
		grid_view.set_cell_overlay(
			path_coordinate,
			PATH_OVERLAY_COLOR
		)


func _is_living_target_coordinate(
	target_candidates: Array[CombatantState],
	coordinate: Vector2i
) -> bool:
	for target in target_candidates:
		if (
			target != null
			and target.is_alive
			and target.grid_position == coordinate
		):
			return true

	return false