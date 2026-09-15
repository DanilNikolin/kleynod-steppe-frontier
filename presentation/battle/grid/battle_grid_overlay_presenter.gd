class_name BattleGridOverlayPresenter
extends RefCounted


var overlay_state: BattleTacticalState

var movement_service: BattleMovementService
var action_service: BattleActionService
var targeting_service: BattleTargetingService

var show_targeting_debug: bool = true


func _init(
	p_overlay_state: BattleTacticalState,
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService,
	p_targeting_service: BattleTargetingService,
	p_show_targeting_debug: bool = true
) -> void:
	assert(
		p_overlay_state != null,
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

	overlay_state = p_overlay_state
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
		overlay_state.add_state(
			selected_combatant.grid_position, BattleTacticalState.Kind.SELECTED
		)


func clear() -> void:
	overlay_state.clear_tactical()


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
		overlay_state.clear_targeting_markers()
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
		!= BattleGrid.INVALID_COORDINATE
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

	overlay_state.set_targeting_markers(
		aim_coordinates,
		impact_coordinates
	)
	# Range markers used to be debug-only. Production's VALID_TARGET means
	# executable, so resolve the semantic state through the existing action service.
	for coordinate in aim_coordinates:
		var executable := action_service.can_execute(session, BattleActionCommand.new(actor, ability, coordinate))
		overlay_state.add_state(coordinate, BattleTacticalState.Kind.VALID_TARGET
			if executable else BattleTacticalState.Kind.INVALID_TARGET)


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
		overlay_state.add_state(
			coordinate,
			BattleTacticalState.Kind.REACHABLE
		)


func _draw_obstacles(
	grid: BattleGrid
) -> void:
	for coordinate in grid.get_all_coordinates():
		var cell := grid.get_cell(coordinate)

		if cell == null or not cell.has_obstacle():
			continue

		overlay_state.add_state(
			coordinate,
			BattleTacticalState.Kind.OBSTACLE
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

		overlay_state.add_state(
			ally.grid_position,
			BattleTacticalState.Kind.SWAP
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

		var slot_kind := (
			BattleTacticalState.Kind.INVALID_TARGET
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
				slot_kind = (
					BattleTacticalState.Kind.VALID_TARGET
				)

		overlay_state.add_state(
			target.grid_position,
			slot_kind
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
		== BattleGrid.INVALID_COORDINATE
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
		overlay_state.add_state(
			path_coordinate,
			BattleTacticalState.Kind.PATH
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
