extends Node2D


const PLAYER_TEAM_ID: StringName = &"team_player"
const ENEMY_TEAM_ID: StringName = &"team_enemy"

const MAX_BATTLE_LOG_LINES: int = 6


const DEFEATED_VIEW_CLEANUP_DELAY: float = 0.35


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


@export_group("AI")


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
var debug_panel: Control = (
	$CanvasLayer/InterfaceMargin
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

@onready
var surface_hover_panel: BattleSurfaceHoverPanel = (
	$CanvasLayer/SurfaceHoverPanel
)

var active_encounter_definition: BattleEncounterDefinition

var session: BattleSession
var grid: BattleGrid

var combatant_presenter: BattleCombatantPresenter
var grid_overlay_presenter: BattleGridOverlayPresenter

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var turn_controller: BattleTurnController
var reinforcement_controller: BattleReinforcementController


var utility_plan_generator: BattleAIPlanGenerator
var utility_turn_runner: BattleUtilityAITurnRunner

var debug_log_presenter: BattleDebugLogPresenter
var interaction_controller: BattleSandboxInteractionController

var session_factory := BattleSessionFactory.new()
var experience_reward_service := (
	BattleExperienceRewardService.new()
)
var loot_reward_service := (
	BattleLootRewardService.new()
)

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService

var action_preview_service: BattleActionPreviewService
var action_preview_presenter: BattleActionPreviewPresenter

var _campaign_winning_team_id: StringName = &""
var _campaign_experience_reward_pool: int = 0
var _campaign_loot_reward_roll: BattleLootRewardRoll

func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_action_services()
	_create_debug_log_presenter()
	_connect_surface_effect_signals()
	_refresh_surface_effect_presentation()
	_create_combatant_presenter()
	_connect_defeated_view_cleanup()
	_create_action_preview_system()
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
	if _handle_debug_panel_toggle(
		event
	):
		get_viewport().set_input_as_handled()
		return

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


func _handle_debug_panel_toggle(
	event: InputEvent
) -> bool:
	var key_event := (
		event as InputEventKey
	)

	if key_event == null:
		return false

	if (
		not key_event.pressed
		or key_event.echo
	):
		return false

	if key_event.keycode != KEY_F1:
		return false

	if debug_panel == null:
		return false

	debug_panel.visible = (
		not debug_panel.visible
	)

	return true
	
func _validate_dependencies() -> void:
	assert(
		combatant_view_scene != null,
		"Combatant view scene is not assigned."
	)

	active_encounter_definition = (
		encounter_definition
	)

	if CampaignRuntime.has_pending_battle():
		active_encounter_definition = (
			CampaignRuntime
				.get_pending_battle_encounter()
		)

	assert(
		active_encounter_definition != null,
		"Battle encounter definition is not assigned."
	)

	var encounter_errors := (
		active_encounter_definition
			.get_validation_errors()
	)

	assert(
		encounter_errors.is_empty(),
		"Invalid encounter definition: %s"
		% encounter_errors
	)


func _create_battle_state() -> void:
	session = session_factory.create_from_encounter(
		active_encounter_definition
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
		session
			.side_rules
			.get_effective_divider_column(
				grid.columns
			)
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


func _connect_defeated_view_cleanup() -> void:
	assert(
		session != null,
		"Defeated view cleanup requires a battle session."
	)

	assert(
		combatant_presenter != null,
		"Defeated view cleanup requires "
		+"a combatant presenter."
	)

	var callback := Callable(
		self,
		"_on_combatant_defeated_for_presentation"
	)

	if session.is_connected(
		&"combatant_defeated",
		callback
	):
		return

	session.connect(
		&"combatant_defeated",
		callback
	)


func _on_combatant_defeated_for_presentation(
	combatant: CombatantState
) -> void:
	if combatant == null:
		return

	var cleanup_callback := Callable(
		self,
		"_remove_defeated_view_if_still_present"
	).bind(
		combatant.instance_id
	)

	get_tree().create_timer(
		DEFEATED_VIEW_CLEANUP_DELAY
	).timeout.connect(
		cleanup_callback
	)


func _remove_defeated_view_if_still_present(
	instance_id: StringName
) -> void:
	if combatant_presenter == null:
		return

	var view := combatant_presenter.get_view(
		instance_id
	)

	## Обычный BattleActionRunner уже мог удалить
	## фигурку после завершения анимации удара.
	if view == null:
		return

	## Дополнительная защита от ошибочного удаления
	## живого или восстановленного бойца.
	if (
		view.state != null
		and view.state.is_alive
	):
		return

	combatant_presenter.remove_view(
		instance_id
	)


func _connect_surface_effect_signals() -> void:
	assert(
		session.surface_effect_controller != null,
		"Battle session requires a surface controller."
	)

	session.surface_effect_controller.surface_effect_added.connect(
		_on_surface_effect_added
	)

	session.surface_effect_controller.surface_effect_updated.connect(
		_on_surface_effect_updated
	)

	session.surface_effect_controller.surface_effect_removed.connect(
		_on_surface_effect_removed
	)

	session.surface_effect_controller.surface_effect_triggered.connect(
		_on_surface_effect_triggered
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


func _create_action_preview_system() -> void:
	action_preview_service = (
		BattleActionPreviewService.new(
			action_service
		)
	)

	action_preview_presenter = (
		BattleActionPreviewPresenter.new(
			combatant_presenter,
			grid_view
		)
	)

func _create_movement_runner() -> void:
	movement_runner = BattleMovementRunner.new(
		session,
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
	utility_plan_generator = (
		BattleAIPlanGenerator.new(
			movement_service,
			action_service,
			targeting_service
		)
	)

	utility_turn_runner = (
		BattleUtilityAITurnRunner.new(
			utility_plan_generator,
			movement_runner,
			action_runner
		)
	)

func _create_reinforcement_system() -> void:
	reinforcement_controller = (
		BattleReinforcementController.new(
			session,
			active_encounter_definition
				.reinforcement_waves
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
			surface_hover_panel,
			movement_service,
			targeting_service,
			action_preview_service,
			action_preview_presenter,
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

	turn_controller.turn_skipped.connect(
		_on_turn_skipped
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


func _on_surface_effect_added(
	_instance: BattleSurfaceEffectInstance
) -> void:
	_refresh_surface_effect_presentation()
	_refresh_surface_hover_information()


func _on_surface_effect_updated(
	_instance: BattleSurfaceEffectInstance
) -> void:
	_refresh_surface_effect_presentation()
	_refresh_surface_hover_information()


func _on_surface_effect_removed(
	_coordinate: Vector2i,
	_surface_effect_id: StringName
) -> void:
	_refresh_surface_effect_presentation()
	_refresh_surface_hover_information()


func _on_surface_effect_triggered(
	trigger_result: BattleSurfaceTriggerResult
) -> void:
	debug_log_presenter.append_surface_trigger_result(
		trigger_result
	)

	if interaction_controller != null:
		interaction_controller.refresh_grid_overlays()


func _refresh_surface_hover_information() -> void:
	if interaction_controller == null:
		return

	interaction_controller.refresh_hover_panels()
	
func _refresh_surface_effect_presentation() -> void:
	grid_view.clear_surface_effect_colors()

	var surface_controller := (
		session.surface_effect_controller
	)

	for coordinate in (
		surface_controller
		.get_affected_coordinates()
	):
		var instances := (
			surface_controller.get_effects_at(
				coordinate
			)
		)

		if instances.is_empty():
			continue

		var resolved_color := (
			instances[0]
			.definition
			.presentation_color
		)

		## Если на клетке несколько поверхностей,
		## временно смешиваем их debug-цвета.
		for instance_index in range(
			1,
			instances.size()
		):
			var instance := instances[
				instance_index
			]

			if (
				instance == null
				or instance.definition == null
			):
				continue

			resolved_color = resolved_color.lerp(
				instance
					.definition
					.presentation_color,
				0.5
			)

		grid_view.set_surface_effect_color(
			coordinate,
			resolved_color
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
		
func _on_turn_skipped(
	combatant: CombatantState,
	current_round: int,
	_turn_index: int,
	restriction_status_ids: Array[StringName]
) -> void:
	_set_active_combatant_selection(
		combatant
	)

	interaction_controller.begin_skipped_turn()

	var status_names := PackedStringArray()

	for status_id in restriction_status_ids:
		var status := combatant.get_status(
			status_id
		)

		if (
			status != null
			and status.definition != null
		):
			status_names.append(
				status.definition.display_name
			)

		else:
			status_names.append(
				String(status_id)
			)

	debug_log_presenter.push_battle_log(
		"Раунд %d. %s пропускает ход. Причина: %s."
		% [
			current_round,
			combatant.definition.display_name,
			", ".join(status_names),
		]
	)


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

	_campaign_experience_reward_pool = (
		experience_reward_service
			.get_defeated_team_experience(
				session,
				ENEMY_TEAM_ID
			)
	)

	_campaign_loot_reward_roll = (
		loot_reward_service
			.roll_from_session(
				session,
				ENEMY_TEAM_ID,
				CampaignRuntime.get_loot_catalog(),
				winning_team_id
					== PLAYER_TEAM_ID
			)
	)

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
	if CampaignRuntime.has_pending_battle():
		_campaign_winning_team_id = (
			winning_team_id
		)

		_show_campaign_return_panel(
			winning_team_id
		)

func _show_campaign_return_panel(
	winning_team_id: StringName
) -> void:
	var canvas_layer := get_node_or_null(
		"CanvasLayer"
	) as CanvasLayer

	if canvas_layer == null:
		return

	var existing_panel := (
		canvas_layer.get_node_or_null(
			"CampaignBattleResultPanel"
		)
	)

	if existing_panel != null:
		return

	var panel := PanelContainer.new()

	panel.name = "CampaignBattleResultPanel"

	panel.set_anchors_preset(
		Control.PRESET_CENTER_BOTTOM
	)

	panel.offset_left = -230.0
	panel.offset_top = -220.0
	panel.offset_right = 230.0
	panel.offset_bottom = -40.0

	canvas_layer.add_child(
		panel
	)

	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		content
	)

	var result_label := Label.new()

	result_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	result_label.add_theme_font_size_override(
		"font_size",
		22
	)

	if winning_team_id == PLAYER_TEAM_ID:
		result_label.text = "ПОБЕДА"

	elif winning_team_id == ENEMY_TEAM_ID:
		result_label.text = "ПОРАЖЕНИЕ"

	else:
		result_label.text = "БОЙ ЗАВЕРШЁН"

	content.add_child(
		result_label
	)

	var experience_label := Label.new()

	experience_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	var party_size := (
		CampaignRuntime.get_pending_battle_party_size()
	)

	var experience_share: int = 0
	var experience_remainder: int = 0

	if party_size > 0:
		experience_share = floori(
			float(_campaign_experience_reward_pool)
			/ float(party_size)
		)

		experience_remainder = (
			_campaign_experience_reward_pool
			% party_size
		)

	experience_label.text = (
		"Опыт за побеждённых врагов: %d XP"
		% _campaign_experience_reward_pool
	)

	if party_size > 0:
		experience_label.text += (
			" · по %d каждому"
			% experience_share
		)

	if experience_remainder > 0:
		experience_label.text += (
			" · остаток %d"
			% experience_remainder
		)

	content.add_child(
		experience_label
	)

	var loot_label := Label.new()

	loot_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	loot_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	if winning_team_id != PLAYER_TEAM_ID:
		loot_label.text = (
			"Добыча: не получена — "
			+"для вывоза добычи нужна победа."
		)

	elif (
		_campaign_loot_reward_roll == null
		or _campaign_loot_reward_roll
			.total_budget <= 0
	):
		loot_label.text = "Добыча: ничего."

	else:
		var loot_names := (
			_campaign_loot_reward_roll
				.get_item_display_names()
		)

		var loot_parts := PackedStringArray()

		for loot_name in loot_names:
			loot_parts.append(
				loot_name
			)

		if (
			_campaign_loot_reward_roll
				.gold_reward > 0
		):
			loot_parts.append(
				"%d зол."
				% _campaign_loot_reward_roll
					.gold_reward
			)

		var reward_text := (
			"ничего"
			if loot_parts.is_empty()
			else " + ".join(
				loot_parts
			)
		)

		loot_label.text = (
			"Добыча: %s · бюджет %d · тир до %d"
			% [
				reward_text,
				_campaign_loot_reward_roll
					.total_budget,
				_campaign_loot_reward_roll
					.tier_cap,
			]
		)

	content.add_child(
		loot_label
	)

	var return_button := Button.new()

	return_button.text = "Вернуться в лагерь"

	return_button.pressed.connect(
		_on_campaign_return_pressed.bind(
			return_button
		)
	)

	content.add_child(
		return_button
	)


func _on_campaign_return_pressed(
	button: Button
) -> void:
	if button != null:
		button.disabled = true

	var completed := (
		CampaignRuntime
			.complete_pending_battle_and_return(
				_campaign_winning_team_id,
				_campaign_experience_reward_pool,
				_campaign_loot_reward_roll
			)
	)

	if not completed:
		if button != null:
			button.disabled = false

		push_warning(
			"Campaign battle result could not be completed."
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

	var utility_handled: bool = await (
		_try_run_utility_ai_turn(
			combatant
		)
	)

	if utility_handled:
		return

	debug_log_presenter.set_headline(
		"%s завершает ход: Utility AI не смог "
		% combatant.definition.display_name
		+"обработать ход."
	)

	_finish_ai_turn(
		combatant
	)


func _try_run_utility_ai_turn(
	combatant: CombatantState
) -> bool:
	if (
		utility_turn_runner == null
		or combatant == null
	):
		return false

	grid_overlay_presenter.clear()

	var outcome := await (
		utility_turn_runner.execute(
			session,
			combatant,
			stamina_cost_per_cell,
			animate_movement,
			animate_actions
		)
	)

	for report in outcome.planning_reports:
		debug_log_presenter.push_battle_log(
			BattleAIPlanningDebugFormatter
			.build_report_text(
				report,
				combatant,
				6
			)
		)

	_push_utility_ai_outcome_log(
		combatant,
		outcome
	)

	if turn_controller.is_finished:
		interaction_controller.set_interaction_in_progress(
			false
		)

		return true

	if not outcome.is_successful:
		if outcome.did_anything():
			debug_log_presenter.set_headline(
				"Utility AI: %s выполнил часть хода, "
				% combatant.definition.display_name
				+"но остановился с ошибкой: %s."
				% outcome.failure_code
			)

			interaction_controller.refresh_grid_overlays()

			_finish_ai_turn(
				combatant
			)

			return true

		## Если новый runner даже не начал действие,
		## просто завершаем ход (fallback отключен)
		debug_log_presenter.set_headline(
			"Utility AI не смог выполнить ход: %s."
			% outcome.failure_code
		)

		_finish_ai_turn(
			combatant
		)

		return true

	_set_utility_ai_headline(
		combatant,
		outcome
	)

	interaction_controller.refresh_grid_overlays()

	_finish_ai_turn(
		combatant
	)

	return true


func _push_utility_ai_outcome_log(
	combatant: CombatantState,
	outcome: BattleUtilityAITurnOutcome
) -> void:
	if (
		debug_log_presenter == null
		or combatant == null
		or outcome == null
	):
		return

	var actor_name := String(
		outcome.actor_id
	)

	if combatant.definition != null:
		actor_name = (
			combatant.definition.display_name
		)

	if not outcome.is_successful:
		debug_log_presenter.push_battle_log(
			"Utility AI outcome · %s · ошибка %s · "
			% [
				actor_name,
				outcome.failure_code,
			]
			+"выполнено планов %d."
			% outcome.executed_plans.size()
		)

		return

	debug_log_presenter.push_battle_log(
		"Utility AI stop · %s · %s · "
		% [
			actor_name,
			outcome.stop_reason,
		]
		+"планов %d · действий %d · шагов %d · "
		% [
			outcome.executed_plans.size(),
			outcome.get_action_count(),
			outcome.get_movement_step_count(),
		]
		+"урон %d · последний score %.1f."
		% [
			outcome.get_damage_dealt(),
			outcome.get_last_score(),
		]
	)

func _set_utility_ai_headline(
	combatant: CombatantState,
	outcome: BattleUtilityAITurnOutcome
) -> void:
	if combatant == null or outcome == null:
		return

	if outcome.did_act():
		var action_plan := (
			outcome.get_last_action_plan()
		)

		var ability_name := "способность"

		if (
			action_plan != null
			and action_plan.ability != null
		):
			ability_name = (
				action_plan.ability.display_name
			)

		debug_log_presenter.set_headline(
			"%s выбирает Utility AI: «%s». "
			% [
				combatant.definition.display_name,
				ability_name,
			]
			+"Действий: %d. Урон: %d. "
			% [
				outcome.get_action_count(),
				outcome.get_damage_dealt(),
			]
			+"Пройдено клеток: %d. "
			% outcome.get_movement_step_count()
			+"Выносливость: %d/%d."
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
		)

		return

	if outcome.did_move():
		debug_log_presenter.set_headline(
			"%s выбирает Utility AI: перемещение. "
			% combatant.definition.display_name
			+"Пройдено клеток: %d. "
			% outcome.get_movement_step_count()
			+"Выносливость: %d/%d. "
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
			+"Последний score: %.1f."
			% outcome.get_last_score()
		)

		return

	debug_log_presenter.set_headline(
		"%s выбирает Utility AI: завершает ход (%s)."
		% [
			combatant.definition.display_name,
			outcome.stop_reason,
		]
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
