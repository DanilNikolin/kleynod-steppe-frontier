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

const SWAPPABLE_ALLY_OVERLAY_COLOR := Color(
	0.28,
	0.92,
	0.48,
	0.58
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
var targeting_service: BattleTargetingService

var show_targeting_debug: bool = true


func _init(
	p_grid_view: BattleGridView,
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService,
	p_targeting_service: BattleTargetingService,
	p_show_targeting_debug: bool = true
) -> void:
	assert(
		p_grid_view != null,
		"BattleGridOverlayPresenter requires a grid view."
	)

	assert(
		p_movement_service != null,
		"BattleGridOverlayPresenter requires "
		+"a movement service."
	)

	assert(
		p_action_service != null,
		"BattleGridOverlayPresenter requires "
		+"an action service."
	)

	assert(
		p_targeting_service != null,
		"BattleGridOverlayPresenter requires "
		+"a targeting service."
	)

	grid_view = p_grid_view
	movement_service = p_movement_service
	action_service = p_action_service
	targeting_service = p_targeting_service

	show_targeting_debug = (
		p_show_targeting_debug
	)


func refresh(
	session: BattleSession,
	selected_combatant: CombatantState,
	target_candidates: Array[CombatantState],
	selected_ability: AbilityDefinition,
	hovered_coordinate: Vector2i,
	stamina_cost_per_cell: int
) -> void:
	clear()

	if session == null or session.grid == null:
		return

	var grid := session.grid

	if selected_combatant == null:
		return

	if not selected_combatant.is_alive:
		return

	var movement_restricted := (
		selected_combatant
		.is_movement_restricted()
	)

	var ability_restricted := (
		selected_ability != null
		and selected_combatant
		.is_ability_restricted(
			selected_ability.ability_id
		)
	)

	if not movement_restricted:
		_draw_reachable_coordinates(
			grid,
			selected_combatant,
			stamina_cost_per_cell
		)

	_draw_obstacles(grid)

	if not movement_restricted:
		_draw_swappable_allies(
			session,
			selected_combatant,
			stamina_cost_per_cell
		)

	_draw_target_candidates(
		session,
		selected_combatant,
		target_candidates,
		selected_ability
	)

	if (
		show_targeting_debug
		and not ability_restricted
	):
		_draw_targeting_debug(
			session,
			selected_combatant,
			selected_ability,
			hovered_coordinate
		)

	if not movement_restricted:
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
	grid_view.clear_targeting_debug_markers()


func _draw_targeting_debug(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	hovered_coordinate: Vector2i
) -> void:
	if (
		session == null
		or actor == null
		or ability == null
		or ability.targeting == null
	):
		grid_view.clear_targeting_debug_markers()
		return

	var aim_coordinates := (
		targeting_service.get_aim_coordinates(
			session,
			actor,
			ability
		)
	)

	if _has_teleport_effect(
		ability
	):
		aim_coordinates = (
			_filter_executable_teleport_coordinates(
				session,
				actor,
				ability,
				aim_coordinates
			)
		)

	var impact_coordinates: Array[Vector2i] = []

	if (
		hovered_coordinate
		!= BattleGridView.INVALID_COORDINATE
		and aim_coordinates.has(
			hovered_coordinate
		)
	):
		impact_coordinates = (
			targeting_service
			.get_impact_coordinates(
				session,
				actor,
				ability,
				hovered_coordinate
			)
		)

	grid_view.set_targeting_debug_markers(
		aim_coordinates,
		impact_coordinates
	)


func _filter_executable_teleport_coordinates(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	coordinates: Array[Vector2i]
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if (
		session == null
		or actor == null
		or ability == null
	):
		return result

	for coordinate in coordinates:
		var command := BattleActionCommand.new(
			actor,
			ability,
			coordinate
		)

		if not action_service.can_execute(
			session,
			command
		):
			continue

		result.append(
			coordinate
		)

	return result


func _has_teleport_effect(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	for effect in ability.effects:
		if effect is TeleportEffect:
			return true

	return false

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
			maximum_steps,
			combatant.team_id
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


func _draw_swappable_allies(
	session: BattleSession,
	active: CombatantState,
	stamina_cost: int
) -> void:
	if session == null or active == null:
		return

	for ally in session.get_team_combatants(
		active.team_id,
		true
	):
		if ally == null or ally == active:
			continue

		if not movement_service.can_swap_with_ally(
			session,
			active,
			ally,
			stamina_cost
		):
			continue

		grid_view.set_cell_overlay(
			ally.grid_position,
			SWAPPABLE_ALLY_OVERLAY_COLOR
		)


func _draw_target_candidates(
	session: BattleSession,
	actor: CombatantState,
	target_candidates: Array[CombatantState],
	ability: AbilityDefinition
) -> void:
	if session == null or session.grid == null:
		return

	var grid := session.grid

	for target in target_candidates:
		if target == null or not target.is_alive:
			continue

		if not grid.is_inside(
			target.grid_position
		):
			continue

		var overlay_color := (
			ENEMY_OVERLAY_COLOR
		)

		if ability != null:
			var command := BattleActionCommand.new(
				actor,
				ability,
				target.grid_position
			)

			if action_service.can_execute(
				session,
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