class_name BattleGridOverlayPresenter
extends RefCounted


var overlay_state: BattleTacticalState

var movement_service: BattleMovementService
var action_service: BattleActionService
var targeting_service: BattleTargetingService

var show_targeting_debug: bool = false


func _init(
	p_overlay_state: BattleTacticalState,
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService,
	p_targeting_service: BattleTargetingService,
	p_show_targeting_debug: bool = false
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
		selected_combatant.is_movement_restricted()
	)

	var ability_restricted := (
		selected_ability != null
		and selected_combatant.is_ability_restricted(
			selected_ability.ability_id
		)
	)

	_draw_obstacles(grid)

	if not movement_restricted:
		_draw_hovered_swap(
			session,
			selected_combatant,
			hovered_coordinate,
			stamina_cost_per_cell
		)

	_draw_target_candidates(
		session,
		selected_combatant,
		target_candidates,
		selected_ability,
		hovered_coordinate
	)

	if not ability_restricted:
		if show_targeting_debug:
			_draw_targeting_debug(
				session,
				selected_combatant,
				selected_ability,
				hovered_coordinate
			)
		else:
			_draw_hovered_ability_preview(
				session,
				selected_combatant,
				selected_ability,
				hovered_coordinate
			)

	if not movement_restricted:
		_draw_hovered_path(
			session,
			grid,
			selected_combatant,
			selected_ability,
			target_candidates,
			hovered_coordinate,
			stamina_cost_per_cell
		)

	if grid.is_inside(
		selected_combatant.grid_position
	):
		overlay_state.add_state(
			selected_combatant.grid_position,
			BattleTacticalState.Kind.SELECTED
		)


func clear() -> void:
	overlay_state.clear_tactical()


func _draw_hovered_ability_preview(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	hovered_coordinate: Vector2i
) -> void:
	overlay_state.clear_targeting_markers()

	if (
		session == null
		or actor == null
		or ability == null
		or hovered_coordinate
			== BattleGrid.INVALID_COORDINATE
	):
		return

	var command := BattleActionCommand.new(
		actor,
		ability,
		hovered_coordinate
	)

	if not action_service.can_execute(
		session,
		command
	):
		return

	overlay_state.add_state(
		hovered_coordinate,
		BattleTacticalState.Kind.VALID_TARGET
	)

	overlay_state.add_state(
		hovered_coordinate,
		BattleTacticalState.Kind.HOVER
	)

	var impact_coordinates := (
		targeting_service.get_impact_coordinates(
			session,
			actor,
			ability,
			hovered_coordinate
		)
	)

	# Single-target attacks should not suddenly look like AoE.
	# AOE layer is reserved for a real multi-cell impact preview.
	if impact_coordinates.size() > 1:
		overlay_state.set_targeting_markers(
			[],
			impact_coordinates
		)


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


func _draw_hovered_swap(
	session: BattleSession,
	active: CombatantState,
	hovered_coordinate: Vector2i,
	stamina_cost: int
) -> void:
	if session == null or active == null:
		return

	if hovered_coordinate == BattleGrid.INVALID_COORDINATE:
		return

	for ally in session.get_team_combatants(
		active.team_id,
		true
	):
		if ally == null or ally == active:
			continue

		if ally.grid_position != hovered_coordinate:
			continue

		if not movement_service.can_swap_with_ally(
			session,
			active,
			ally,
			stamina_cost
		):
			return

		overlay_state.add_state(
			ally.grid_position,
			BattleTacticalState.Kind.SWAP
		)

		overlay_state.add_state(
			ally.grid_position,
			BattleTacticalState.Kind.HOVER
		)

		return


func _draw_target_candidates(
	session: BattleSession,
	actor: CombatantState,
	target_candidates: Array[CombatantState],
	ability: AbilityDefinition,
	hovered_coordinate: Vector2i
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

		var executable := false

		if ability != null:
			var command := BattleActionCommand.new(
				actor,
				ability,
				target.grid_position
			)

			executable = action_service.can_execute(
				session,
				command
			)

		if executable:
			overlay_state.add_state(
				target.grid_position,
				BattleTacticalState.Kind.VALID_TARGET
			)

		if target.grid_position != hovered_coordinate:
			continue

		if not executable:
			overlay_state.add_state(
				target.grid_position,
				BattleTacticalState.Kind.INVALID_TARGET
			)

		overlay_state.add_state(
			target.grid_position,
			BattleTacticalState.Kind.HOVER
		)


func _draw_hovered_path(
	session: BattleSession,
	grid: BattleGrid,
	combatant: CombatantState,
	ability: AbilityDefinition,
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

	# Ability interaction has priority over movement.
	if ability != null:
		var command := BattleActionCommand.new(
			combatant,
			ability,
			hovered_coordinate
		)

		if action_service.can_execute(
			session,
			command
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

	overlay_state.add_state(
		hovered_coordinate,
		BattleTacticalState.Kind.HOVER
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
