# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['presentation/battle/abilities/battle_ability_panel.gd', 'presentation/battle/abilities/battle_ability_panel.tscn', 'scenes/debug/battle_grid_sandbox.tscn', 'scenes/debug/battle_grid_sandbox.gd']`
- Allow addons: `False`
- Included files planned: `4`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_sabre_slash.tres
│   │       └── debug_sweeping_slash.tres
│   ├── combatants
│   │   └── debug
│   │       └── debug_steppe_raider.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   ├── loadouts
│   │   └── debug
│   │       ├── debug_sechevik_loadout.tres
│   │       ├── debug_steppe_raider_loadout.tres
│   │       └── debug_sweeping_sechevik_loadout.tres
│   └── statuses
│       └── debug
│           └── debug_cracked_defense.tres
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
│       │   ├── apply_status_effect.gd
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
│       ├── stats
│       │   └── battle_stat_modifier.gd
│       ├── statuses
│       │   ├── battle_status_definition.gd
│       │   └── battle_status_instance.gd
│       ├── targeting
│       │   ├── ability_targeting_definition.gd
│       │   ├── battle_targeting_result.gd
│       │   └── battle_targeting_service.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   └── battle
│       ├── abilities
│       │   ├── battle_ability_panel.gd
│       │   ├── battle_ability_panel.tscn
│       │   └── battle_ability_presentation_builder.gd
│       ├── actions
│       │   ├── battle_action_outcome.gd
│       │   └── battle_action_runner.gd
│       ├── ai
│       │   ├── basic_melee_ai_turn_outcome.gd
│       │   └── basic_melee_ai_turn_runner.gd
│       ├── combatants
│       │   ├── battle_combatant_hover_panel.gd
│       │   ├── battle_combatant_hover_panel.tscn
│       │   ├── battle_combatant_presenter.gd
│       │   ├── combatant_view.gd
│       │   ├── combatant_view.tscn
│       │   ├── combatant_visual.gd
│       │   ├── placeholder_combatant_visual.tscn
│       │   └── statuses
│       │       ├── battle_status_chip.gd
│       │       ├── battle_status_chip.tscn
│       │       ├── battle_status_strip.gd
│       │       └── battle_status_strip.tscn
│       ├── grid
│       │   ├── battle_grid_overlay_presenter.gd
│       │   ├── battle_grid_view.gd
│       │   └── battle_grid_view.tscn
│       └── movement
│           ├── battle_movement_outcome.gd
│           └── battle_movement_runner.gd
├── project.godot
└── scenes
	├── debug
	│   ├── battle_grid_sandbox.gd
	│   ├── battle_grid_sandbox.tscn
	│   ├── controllers
	│   │   └── battle_sandbox_interaction_controller.gd
	│   └── presentation
	│       └── battle_debug_log_presenter.gd
	└── debug_sechevik.tres
```

---

## 📌 INCLUDED FILES

## FILE: `presentation/battle/abilities/battle_ability_panel.gd`
```gdscript
class_name BattleAbilityPanel
extends PanelContainer


signal ability_selected(
	ability: AbilityDefinition
)


@onready
var actor_label: Label = (
	$ContentMargin/VBoxContainer/ActorLabel
)

@onready
var ability_grid: GridContainer = (
	$ContentMargin/VBoxContainer/AbilityGrid
)

@onready
var card_title_label: Label = (
	$ContentMargin/VBoxContainer/CardPanel /
	CardMargin / CardVBox / CardTitleLabel
)

@onready
var card_meta_label: Label = (
	$ContentMargin/VBoxContainer/CardPanel /
	CardMargin / CardVBox / CardMetaLabel
)

@onready
var card_description_label: Label = (
	$ContentMargin/VBoxContainer/CardPanel /
	CardMargin / CardVBox / CardDescriptionLabel
)

@onready
var card_effects_label: Label = (
	$ContentMargin/VBoxContainer/CardPanel /
	CardMargin / CardVBox / CardEffectsLabel
)


var _combatant: CombatantState

var _abilities: Array[AbilityDefinition] = []
var _buttons: Array[Button] = []

var _selected_ability_id: StringName = &""
var _interactable: bool = true

var _button_group: ButtonGroup

var _stamina_changed_callback: Callable


func _ready() -> void:
	_stamina_changed_callback = Callable(
		self,
		"_on_combatant_stamina_changed"
	)

	visible = false


func bind_combatant(
	combatant: CombatantState,
	selected_ability: AbilityDefinition = null
) -> void:
	_disconnect_combatant_signals()

	_combatant = combatant

	if (
		_combatant == null
		or not _combatant.is_alive
		or _combatant.loadout == null
	):
		clear_combatant()
		return

	_combatant.stamina_changed.connect(
		_stamina_changed_callback
	)

	_rebuild_buttons()

	if (
		selected_ability != null
		and _combatant.has_ability(
			selected_ability.ability_id
		)
	):
		_selected_ability_id = (
			selected_ability.ability_id
		)

	else:
		var default_ability := (
			_combatant.get_default_ability()
		)

		_selected_ability_id = (
			default_ability.ability_id
			if default_ability != null
			else &""
		)

	_refresh_visual_state()

	visible = true


func clear_combatant() -> void:
	_disconnect_combatant_signals()

	_combatant = null
	_selected_ability_id = &""

	_clear_buttons()

	actor_label.text = ""
	card_title_label.text = ""
	card_meta_label.text = ""
	card_description_label.text = ""
	card_effects_label.text = ""

	visible = false


func set_selected_ability(
	ability: AbilityDefinition
) -> bool:
	if _combatant == null:
		return false

	if ability == null:
		return false

	if not _combatant.has_ability(
		ability.ability_id
	):
		return false

	_selected_ability_id = (
		ability.ability_id
	)

	_refresh_visual_state()
	return true


func select_ability_by_index(
	ability_index: int,
	emit_selection_signal: bool = true
) -> bool:
	if not _interactable:
		return false

	if (
		ability_index < 0
		or ability_index >= _abilities.size()
	):
		return false

	if _combatant == null:
		return false

	var ability := _abilities[
		ability_index
	]

	if ability == null:
		return false

	if not _combatant.can_spend_stamina(
		ability.stamina_cost
	):
		return false

	_selected_ability_id = ability.ability_id

	_refresh_visual_state()

	if emit_selection_signal:
		ability_selected.emit(
			ability
		)

	return true


func set_interactable(
	interactable: bool
) -> void:
	_interactable = interactable
	_refresh_visual_state()


func get_selected_ability() -> AbilityDefinition:
	for ability in _abilities:
		if (
			ability != null
			and ability.ability_id
			== _selected_ability_id
		):
			return ability

	return null


func _rebuild_buttons() -> void:
	_clear_buttons()

	if _combatant == null:
		return

	var loadout_abilities := (
		_combatant.get_abilities()
	)

	for ability in loadout_abilities:
		if ability != null:
			_abilities.append(
				ability
			)

	_button_group = ButtonGroup.new()
	_button_group.allow_unpress = false

	for ability_index in range(
		_abilities.size()
	):
		var ability := _abilities[
			ability_index
		]

		var button := Button.new()

		button.custom_minimum_size = Vector2(
			230.0,
			68.0
		)

		button.toggle_mode = true
		button.button_group = _button_group

		button.text = (
			"%d. %s\n%d выносливости"
			% [
				ability_index + 1,
				ability.display_name,
				ability.stamina_cost,
			]
		)

		button.tooltip_text = (
			ability.description
		)

		button.pressed.connect(
			_on_ability_button_pressed.bind(
				ability_index
			)
		)

		ability_grid.add_child(
			button
		)

		_buttons.append(
			button
		)


func _clear_buttons() -> void:
	for child in ability_grid.get_children():
		ability_grid.remove_child(
			child
		)

		child.queue_free()

	_buttons.clear()
	_abilities.clear()

	_button_group = null


func _refresh_visual_state() -> void:
	if _combatant == null:
		return

	actor_label.text = (
		"%s  |  Выносливость: %d/%d"
		% [
			_combatant.definition.display_name,
			_combatant.current_stamina,
			_combatant.max_stamina,
		]
	)

	for ability_index in range(
		_buttons.size()
	):
		if ability_index >= _abilities.size():
			continue

		var button := _buttons[
			ability_index
		]

		var ability := _abilities[
			ability_index
		]

		if button == null or ability == null:
			continue

		var affordable := (
			_combatant.can_spend_stamina(
				ability.stamina_cost
			)
		)

		button.disabled = (
			not _interactable
			or not affordable
		)

		button.set_pressed_no_signal(
			ability.ability_id
			== _selected_ability_id
		)

	_refresh_card()


func _refresh_card() -> void:
	var selected_ability := (
		get_selected_ability()
	)

	if selected_ability == null:
		card_title_label.text = (
			"Способность не выбрана"
		)

		card_meta_label.text = ""
		card_description_label.text = ""
		card_effects_label.text = ""

		return

	var affordability_text := (
		"ДОСТУПНО"
		if (
			_combatant != null
			and _combatant.can_spend_stamina(
				selected_ability.stamina_cost
			)
		)
		else "НЕ ХВАТАЕТ ВЫНОСЛИВОСТИ"
	)

	card_title_label.text = (
		selected_ability.display_name
	)

	card_meta_label.text = (
		"%s  •  %s"
		% [
			BattleAbilityPresentationBuilder
			.build_meta_text(
				selected_ability
			),
			affordability_text,
		]
	)

	card_description_label.text = (
		selected_ability.description
	)

	card_effects_label.text = (
		BattleAbilityPresentationBuilder
		.build_effects_text(
			selected_ability,
			_combatant
		)
	)


func _disconnect_combatant_signals() -> void:
	if _combatant == null:
		return

	if not _stamina_changed_callback.is_valid():
		return

	if _combatant.is_connected(
		&"stamina_changed",
		_stamina_changed_callback
	):
		_combatant.disconnect(
			&"stamina_changed",
			_stamina_changed_callback
		)


func _on_ability_button_pressed(
	ability_index: int
) -> void:
	select_ability_by_index(
		ability_index,
		true
	)


func _on_combatant_stamina_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	_refresh_visual_state()
```

---

## FILE: `presentation/battle/abilities/battle_ability_panel.tscn`
```text
[gd_scene load_steps=2 format=3 uid="uid://bgg8ap77su8v1"]

[ext_resource type="Script" uid="uid://gy6q3opjvjqv" path="res://presentation/battle/abilities/battle_ability_panel.gd" id="1_panel"]

[node name="BattleAbilityPanel" type="PanelContainer"]
visible = false
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -550.0
offset_top = -300.0
offset_right = 550.0
offset_bottom = -24.0
grow_horizontal = 2
grow_vertical = 0
mouse_filter = 1
script = ExtResource("1_panel")

[node name="ContentMargin" type="MarginContainer" parent="."]
layout_mode = 2
theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 12
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 12

[node name="VBoxContainer" type="VBoxContainer" parent="ContentMargin"]
layout_mode = 2
theme_override_constants/separation = 8

[node name="ActorLabel" type="Label" parent="ContentMargin/VBoxContainer"]
layout_mode = 2
text = "Боец | Выносливость"
horizontal_alignment = 1

[node name="AbilityGrid" type="GridContainer" parent="ContentMargin/VBoxContainer"]
layout_mode = 2
theme_override_constants/h_separation = 8
theme_override_constants/v_separation = 8
columns = 4

[node name="CardPanel" type="PanelContainer" parent="ContentMargin/VBoxContainer"]
custom_minimum_size = Vector2(0, 150)
layout_mode = 2
size_flags_vertical = 3

[node name="CardMargin" type="MarginContainer" parent="ContentMargin/VBoxContainer/CardPanel"]
layout_mode = 2
theme_override_constants/margin_left = 14
theme_override_constants/margin_top = 10
theme_override_constants/margin_right = 14
theme_override_constants/margin_bottom = 10

[node name="CardVBox" type="VBoxContainer" parent="ContentMargin/VBoxContainer/CardPanel/CardMargin"]
layout_mode = 2
theme_override_constants/separation = 5

[node name="CardTitleLabel" type="Label" parent="ContentMargin/VBoxContainer/CardPanel/CardMargin/CardVBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "Название способности"

[node name="CardMetaLabel" type="Label" parent="ContentMargin/VBoxContainer/CardPanel/CardMargin/CardVBox"]
layout_mode = 2
text = "Цена • Цель • Дальность"
autowrap_mode = 2

[node name="Separator" type="HSeparator" parent="ContentMargin/VBoxContainer/CardPanel/CardMargin/CardVBox"]
layout_mode = 2

[node name="CardDescriptionLabel" type="Label" parent="ContentMargin/VBoxContainer/CardPanel/CardMargin/CardVBox"]
layout_mode = 2
text = "Описание способности."
autowrap_mode = 2

[node name="CardEffectsLabel" type="Label" parent="ContentMargin/VBoxContainer/CardPanel/CardMargin/CardVBox"]
layout_mode = 2
size_flags_vertical = 3
text = "Эффекты способности."
vertical_alignment = 1
autowrap_mode = 2
```

---

## FILE: `scenes/debug/battle_grid_sandbox.gd`
```gdscript
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

@onready
var combatant_hover_panel: BattleCombatantHoverPanel = (
	$CanvasLayer/CombatantHoverPanel
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

var debug_log_presenter: BattleDebugLogPresenter
var interaction_controller: BattleSandboxInteractionController

var session_factory := BattleSessionFactory.new()

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService


func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_action_services()
	_create_debug_log_presenter()
	_create_combatant_presenter()
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


func _create_interaction_controller() -> void:
	interaction_controller = (
		BattleSandboxInteractionController.new(
			PLAYER_TEAM_ID,
			session,
			turn_controller,
			ability_panel,
			combatant_hover_panel,
			movement_service,
			targeting_service,
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

	var ability := combatant.get_default_ability()

	if ability == null:
		debug_log_presenter.set_headline(
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
		debug_log_presenter.set_headline(
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
		interaction_controller.set_interaction_in_progress(
			false
		)
		return

	if not outcome.is_successful:
		debug_log_presenter.set_headline(
			"Ход ИИ выполнен не полностью: %s."
			% outcome.failure_code
		)

	elif outcome.did_attack():
		debug_log_presenter.set_headline(
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
		debug_log_presenter.set_headline(
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
		debug_log_presenter.set_headline(
			"%s не может действовать."
			% combatant.definition.display_name
		)

	interaction_controller.refresh_grid_overlays()

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
```

---

## FILE: `scenes/debug/battle_grid_sandbox.tscn`
```text
[gd_scene load_steps=8 format=3 uid="uid://bvvj4s6x1f4km"]

[ext_resource type="Script" uid="uid://dwtnlj74gi01o" path="res://scenes/debug/battle_grid_sandbox.gd" id="1_sandbox"]
[ext_resource type="PackedScene" uid="uid://cm5m1q7ed87gu" path="res://presentation/battle/grid/battle_grid_view.tscn" id="2_grid"]
[ext_resource type="PackedScene" uid="uid://dogan5u1eqtfl" path="res://presentation/battle/combatants/combatant_view.tscn" id="3_combatant_view"]
[ext_resource type="Resource" uid="uid://bcg0f3qjyahde" path="res://content/encounters/debug/debug_reinforcement_encounter.tres" id="4_encounter_definition"]
[ext_resource type="PackedScene" uid="uid://bgg8ap77su8v1" path="res://presentation/battle/abilities/battle_ability_panel.tscn" id="5_ability_panel"]
[ext_resource type="Resource" uid="uid://biy4yp5jjdsj0" path="res://content/statuses/debug/debug_cracked_defense.tres" id="6_debug_status"]
[ext_resource type="PackedScene" uid="uid://btsbnmv4wxefl" path="res://presentation/battle/combatants/battle_combatant_hover_panel.tscn" id="7_hover_panel"]

[node name="BattleGridSandbox" type="Node2D"]
script = ExtResource("1_sandbox")
combatant_view_scene = ExtResource("3_combatant_view")
encounter_definition = ExtResource("4_encounter_definition")
debug_status_definition = ExtResource("6_debug_status")

[node name="BattleGridView" parent="." instance=ExtResource("2_grid")]
position = Vector2(958.43, 498.68)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="InterfaceMargin" type="MarginContainer" parent="CanvasLayer"]
offset_left = 24.0
offset_top = 24.0
offset_right = 720.0
offset_bottom = 210.0

[node name="PanelContainer" type="PanelContainer" parent="CanvasLayer/InterfaceMargin"]
layout_mode = 2

[node name="ContentMargin" type="MarginContainer" parent="CanvasLayer/InterfaceMargin/PanelContainer"]
layout_mode = 2
theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 12
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 12

[node name="VBoxContainer" type="VBoxContainer" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin"]
layout_mode = 2
theme_override_constants/separation = 8

[node name="TitleLabel" type="Label" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin/VBoxContainer"]
layout_mode = 2
text = "Combat Action Sandbox"

[node name="InstructionsLabel" type="Label" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin/VBoxContainer"]
layout_mode = 2
text = "ЛКМ по пустой клетке: движение
ЛКМ по допустимой цели: применить выбранную способность
1–9: выбрать способность
ПКМ: поставить или удалить препятствие
T: наложить debug-статус на бойца под курсором
Space: завершить ход игрока"

[node name="StatusLabel" type="Label" parent="CanvasLayer/InterfaceMargin/PanelContainer/ContentMargin/VBoxContainer"]
layout_mode = 2
text = "Ожидание..."
autowrap_mode = 2

[node name="AbilityPanel" parent="CanvasLayer" instance=ExtResource("5_ability_panel")]

[node name="CombatantHoverPanel" parent="CanvasLayer" instance=ExtResource("7_hover_panel")]
```

---


## ✅ STATS
- Total files in tree: 78
- Readable files: 74
- Included files written: 4
- Trimmed files: 0
- Total lines written: 1249
