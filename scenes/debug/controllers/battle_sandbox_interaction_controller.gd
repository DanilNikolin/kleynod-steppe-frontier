class_name BattleSandboxInteractionController
extends RefCounted


var player_team_id: StringName

var session: BattleSession
var grid: BattleGrid
var turn_controller: BattleTurnController

var ability_panel: BattleAbilityPanel
var combatant_hover_panel: BattleCombatantHoverPanel

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var grid_overlay_presenter: BattleGridOverlayPresenter
var debug_log_presenter: BattleDebugLogPresenter

var stamina_cost_per_cell: int = 1
var animate_movement: bool = true
var animate_actions: bool = true

var _obstacle_counter: int = 0
var _interaction_in_progress: bool = false

var _selected_ability: AbilityDefinition

var _hovered_coordinate: Vector2i = (
	BattleGridView.INVALID_COORDINATE
)


func _init(
	p_player_team_id: StringName,
	p_session: BattleSession,
	p_turn_controller: BattleTurnController,
	p_ability_panel: BattleAbilityPanel,
	p_combatant_hover_panel: BattleCombatantHoverPanel,
	p_movement_service: BattleMovementService,
	p_targeting_service: BattleTargetingService,
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner,
	p_grid_overlay_presenter: BattleGridOverlayPresenter,
	p_debug_log_presenter: BattleDebugLogPresenter,
	p_stamina_cost_per_cell: int = 1,
	p_animate_movement: bool = true,
	p_animate_actions: bool = true
) -> void:
	assert(
		p_player_team_id != &"",
		"Interaction controller requires a player team ID."
	)

	assert(
		p_session != null,
		"Interaction controller requires a battle session."
	)

	assert(
		p_turn_controller != null,
		"Interaction controller requires a turn controller."
	)

	assert(
		p_ability_panel != null,
		"Interaction controller requires an ability panel."
	)

	assert(
		p_combatant_hover_panel != null,
		"Interaction controller requires "
		+"a combatant hover panel."
	)

	assert(
		p_movement_service != null,
		"Interaction controller requires a movement service."
	)

	assert(
		p_targeting_service != null,
		"Interaction controller requires a targeting service."
	)

	assert(
		p_movement_runner != null,
		"Interaction controller requires a movement runner."
	)

	assert(
		p_action_runner != null,
		"Interaction controller requires an action runner."
	)

	assert(
		p_grid_overlay_presenter != null,
		"Interaction controller requires an overlay presenter."
	)

	assert(
		p_debug_log_presenter != null,
		"Interaction controller requires a debug log presenter."
	)

	player_team_id = p_player_team_id

	session = p_session
	grid = session.grid
	turn_controller = p_turn_controller

	ability_panel = p_ability_panel
	combatant_hover_panel = (
		p_combatant_hover_panel
	)

	movement_service = p_movement_service
	targeting_service = p_targeting_service

	movement_runner = p_movement_runner
	action_runner = p_action_runner

	grid_overlay_presenter = p_grid_overlay_presenter
	debug_log_presenter = p_debug_log_presenter

	stamina_cost_per_cell = maxi(
		1,
		p_stamina_cost_per_cell
	)

	animate_movement = p_animate_movement
	animate_actions = p_animate_actions


func begin_player_turn(
	combatant: CombatantState
) -> void:
	_interaction_in_progress = false

	_selected_ability = get_default_ability(
		combatant
	)

	ability_panel.bind_combatant(
		combatant,
		_selected_ability
	)

	ability_panel.set_interactable(
		true
	)

	refresh_grid_overlays()


func begin_enemy_turn() -> void:
	_interaction_in_progress = true
	_selected_ability = null

	ability_panel.clear_combatant()

	refresh_grid_overlays()

func begin_skipped_turn() -> void:
	_interaction_in_progress = true
	_selected_ability = null

	ability_panel.clear_combatant()
	grid_overlay_presenter.clear()

func finish_battle() -> void:
	_interaction_in_progress = false
	_selected_ability = null

	ability_panel.clear_combatant()
	combatant_hover_panel.clear_combatant()
	grid_overlay_presenter.clear()


func set_interaction_in_progress(
	value: bool
) -> void:
	_interaction_in_progress = value

	if value:
		grid_overlay_presenter.clear()
	else:
		refresh_grid_overlays()


func is_interaction_in_progress() -> bool:
	return _interaction_in_progress


func get_selected_ability() -> AbilityDefinition:
	return _selected_ability


func get_selected_ability_for(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	if (
		combatant.team_id == player_team_id
		and _selected_ability != null
		and combatant.has_ability(
			_selected_ability.ability_id
		)
		and not combatant.is_ability_locked(
			_selected_ability.ability_id
		)
		and not combatant.is_ability_restricted(
			_selected_ability.ability_id
		)
	):
		return _selected_ability

	return get_default_ability(
		combatant
	)


func get_default_ability(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	var default_ability := (
		combatant.get_default_ability()
	)

	if (
		default_ability != null
		and not combatant.is_ability_locked(
			default_ability.ability_id
		)
		and not combatant
		.is_ability_restricted(
			default_ability.ability_id
		)
	):
		return default_ability

	for ability in combatant.get_abilities():
		if ability == null:
			continue

		if combatant.is_ability_locked(
			ability.ability_id
		):
			continue

		if combatant.is_ability_restricted(
			ability.ability_id
		):
			continue

		return ability

	return null


func get_active_combatant() -> CombatantState:
	if turn_controller == null:
		return null

	if not turn_controller.is_running:
		return null

	return turn_controller.active_combatant


func is_player_turn() -> bool:
	var active_combatant := get_active_combatant()

	return (
		active_combatant != null
		and active_combatant.team_id
		== player_team_id
	)


func end_active_turn() -> void:
	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	turn_controller.end_current_turn()


func handle_unhandled_input(
	event: InputEvent
) -> bool:
	if _interaction_in_progress:
		return false

	if turn_controller == null:
		return false

	if not turn_controller.is_running:
		return false

	if not (event is InputEventKey):
		return false

	var key_event := event as InputEventKey

	if (
		not key_event.pressed
		or key_event.echo
	):
		return false

	if key_event.keycode == KEY_T:
		_apply_debug_status_to_hovered_combatant()
		return true

	if (
		key_event.keycode == KEY_SPACE
		and is_player_turn()
	):
		end_active_turn()
		return true

	return false


func handle_input(
	event: InputEvent
) -> bool:
	if not (event is InputEventKey):
		return false

	var key_event := event as InputEventKey

	if (
		not key_event.pressed
		or key_event.echo
	):
		return false

	var ability_index := _get_ability_hotkey_index(
		key_event
	)

	if ability_index < 0:
		return false

	if turn_controller == null:
		return false

	if not turn_controller.is_running:
		return false

	var active := turn_controller.active_combatant

	if (
		active == null
		or active.team_id != player_team_id
		or _interaction_in_progress
	):
		return false

	return ability_panel.select_ability_by_index(
		ability_index,
		true
	)


func on_ability_selected(
	ability: AbilityDefinition
) -> void:
	if ability == null:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	var active := turn_controller.active_combatant

	if (
		active == null
		or active.team_id != player_team_id
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

	if active.is_ability_locked(
		ability.ability_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		debug_log_presenter.set_headline(
			_get_ability_lock_message(
				active,
				ability
			)
		)

		return

	if active.is_ability_restricted(
		ability.ability_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		debug_log_presenter.set_headline(
			"«%s» сейчас запрещена активным статусом."
			% ability.display_name
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

	refresh_grid_overlays()

	debug_log_presenter.set_headline(
		"%s выбирает «%s». "
		% [
			active.definition.display_name,
			ability.display_name,
		]
		+"Стоимость: %d выносливости."
		% ability.stamina_cost
	)


func on_grid_cell_hovered(
	coordinate: Vector2i
) -> void:
	_hovered_coordinate = coordinate

	_refresh_hover_panel()

	if not _interaction_in_progress:
		refresh_grid_overlays()


func on_grid_cell_clicked(
	coordinate: Vector2i,
	mouse_button: int
) -> void:
	if _interaction_in_progress:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	if not is_player_turn():
		return

	var active_combatant := get_active_combatant()

	if active_combatant == null:
		return

	match mouse_button:
		MOUSE_BUTTON_LEFT:
			var ability := get_selected_ability_for(
				active_combatant
			)

			var target := _get_combatant_at_coordinate(
				coordinate
			)

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
				debug_log_presenter.set_headline(
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
				debug_log_presenter.set_headline(
					"Клетка %s занята союзником %s."
					% [
						coordinate,
						target.definition.display_name,
					]
				)

			else:
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

		MOUSE_BUTTON_RIGHT:
			_toggle_obstacle(
				coordinate
			)


func refresh_grid_overlays() -> void:
	if grid_overlay_presenter == null:
		return

	if turn_controller == null:
		grid_overlay_presenter.clear()
		return

	if not turn_controller.is_running:
		grid_overlay_presenter.clear()
		return

	var active := turn_controller.active_combatant

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

	var selected_ability := get_selected_ability_for(
		active
	)

	grid_overlay_presenter.refresh(
		session,
		active,
		target_candidates,
		selected_ability,
		_hovered_coordinate,
		stamina_cost_per_cell
	)

	_refresh_hover_panel()


func _refresh_hover_panel() -> void:
	if combatant_hover_panel == null:
		return

	var hovered_combatant := (
		_get_combatant_at_coordinate(
			_hovered_coordinate
		)
	)

	if (
		hovered_combatant == null
		or not hovered_combatant.is_alive
	):
		combatant_hover_panel.clear_combatant()
		return

	combatant_hover_panel.bind_combatant(
		hovered_combatant,
		player_team_id
	)

func _apply_debug_status_to_hovered_combatant() -> void:
	var target := _get_combatant_at_coordinate(
		_hovered_coordinate
	)

	debug_log_presenter.apply_debug_status(
		target,
		get_active_combatant()
	)


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
		debug_log_presenter.set_headline(
			_get_movement_failure_message(
				plan.failure_code,
				plan,
				combatant
			)
		)

		refresh_grid_overlays()
		return

	var previous_coordinate := combatant.grid_position

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	debug_log_presenter.set_headline(
		"%s движется к клетке %s..."
		% [
			combatant.definition.display_name,
			plan.target_coordinate,
		]
	)

	var movement_outcome := await movement_runner.execute(
		grid,
		combatant,
		plan,
		animate_movement
	)

	if not movement_outcome.is_successful:
		_interaction_in_progress = false

		debug_log_presenter.set_headline(
			"Не удалось выполнить перемещение: %s."
			% movement_outcome.failure_code
		)

		refresh_grid_overlays()
		return

	debug_log_presenter.set_headline(
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
	refresh_grid_overlays()


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

	var ability := get_selected_ability_for(
		actor
	)

	if ability == null:
		debug_log_presenter.set_headline(
			"%s не имеет доступных способностей."
			% actor.definition.display_name
		)

		return

	var command := BattleActionCommand.new(
		actor,
		ability,
		aim_coordinate
	)

	var failure_code := action_runner.get_validation_failure(
		session,
		command
	)

	if failure_code != &"":
		debug_log_presenter.set_headline(
			_get_action_failure_message(
				failure_code,
				actor,
				ability
			)
		)

		refresh_grid_overlays()
		return

	_interaction_in_progress = true
	grid_overlay_presenter.clear()

	debug_log_presenter.suspend_status_signal_logging()

	var action_outcome := await action_runner.execute_action(
		session,
		command,
		animate_actions
	)

	debug_log_presenter.resume_status_signal_logging()

	if not action_outcome.is_successful:
		_interaction_in_progress = false

		debug_log_presenter.set_headline(
			"Действие не выполнено: %s."
			% action_outcome.failure_code
		)

		refresh_grid_overlays()
		return

	debug_log_presenter.append_action_results(
		action_outcome.action_result
	)

	if (
		action_outcome
		.action_result
		.cooldown_started
	):
		_selected_ability = get_default_ability(
			actor
		)

		ability_panel.set_selected_ability(
			_selected_ability
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
		action_outcome.get_affected_target_count()
	)

	var defeated_count := (
		action_outcome
		.get_defeated_target_ids()
		.size()
	)

	debug_log_presenter.set_headline(
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
	refresh_grid_overlays()


func _toggle_obstacle(
	coordinate: Vector2i
) -> void:
	var cell := grid.get_cell(
		coordinate
	)

	if cell == null:
		return

	if cell.is_occupied():
		debug_log_presenter.set_headline(
			"Нельзя поставить препятствие под бойца."
		)
		return

	if cell.has_obstacle():
		var obstacle_id := cell.obstacle_id

		grid.remove_obstacle(
			obstacle_id
		)

		debug_log_presenter.set_headline(
			"Препятствие удалено с клетки %s."
			% coordinate
		)

		refresh_grid_overlays()
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
		debug_log_presenter.set_headline(
			"Не удалось поставить препятствие."
		)
		return

	debug_log_presenter.set_headline(
		"Препятствие установлено на клетку %s."
		% coordinate
	)

	refresh_grid_overlays()


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

		BattleTargetingService.FAILURE_TARGET_PROTECTED_BY_BLOCKER:
			return (
				"Цель защищена боевым объектом, "
				+"стоящим перед ней."
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

		BattleActionService.FAILURE_ABILITY_ON_COOLDOWN:
			return _get_ability_lock_message(
				actor,
				ability
			)

		BattleActionService.FAILURE_ABILITY_RESTRICTED:
			return (
				"Боец не может использовать "
				+"эту способность из-за статуса."
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


func _get_ability_lock_message(
	actor: CombatantState,
	ability: AbilityDefinition
) -> String:
	if actor == null or ability == null:
		return "Способность временно недоступна."

	var remaining_turns := (
		actor.get_ability_lock_remaining_turns(
			ability.ability_id
		)
	)

	var formatted_turns := (
		BattleAbilityPresentationBuilder
		.format_turn_count(
			remaining_turns
		)
	)

	if (
		actor.get_ability_lock_kind(
			ability.ability_id
		)
		== CombatantState
		.AbilityLockKind
		.INITIAL
	):
		return (
			"«%s» ещё закрыта стартовой задержкой. "
			% ability.display_name
			+"Осталось: %s."
			% formatted_turns
		)

	return (
		"«%s» восстанавливается. "
		% ability.display_name
		+"Осталось: %s."
		% formatted_turns
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

		BattleMovementService.FAILURE_MOVEMENT_RESTRICTED:
			return (
				"Боец не может двигаться "
				+"из-за активного статуса."
			)

		BattleMovementService.FAILURE_DEAD_COMBATANT:
			return "Погибший боец не может двигаться."

		_:
			return (
				"Перемещение невозможно: %s."
				% failure_code
			)