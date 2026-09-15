class_name BattleScreen
extends Node2D

signal slot_hovered(coordinate: Vector2i)
signal slot_clicked(coordinate: Vector2i, mouse_button: int)

## The caller selects presentation independently of encounter/gameplay data.
@export var environment_scene: PackedScene
## Optional encounter supplies bounds before an existing session is bound.
@export var encounter_definition: BattleEncounterDefinition
@export var combatant_view_scene: PackedScene = preload("res://presentation/battle/combatants/combatant_view.tscn")
@export var auto_start_battle: bool = true
@export var player_team_id: StringName = &"team_player"
@export var animate_movement: bool = true
@export var animate_actions: bool = true
@export_range(0.0, 2.0) var ai_think_delay: float = 0.3

var environment: BattleEnvironment
var session: BattleSession
var combatant_presenter: BattleCombatantPresenter
var tactical_state := BattleTacticalState.new()
var flow: BattleFlowController


func _ready() -> void:
	var interaction := get_node("BattleWorld/TacticalOverlay/SlotInteraction") as BattleSlotInteraction
	interaction.slot_hovered.connect(slot_hovered.emit)
	interaction.slot_clicked.connect(slot_clicked.emit)
	interaction.slot_hovered.connect(tactical_state.set_hover)
	if environment == null and environment_scene != null:
		load_environment(environment_scene)
	if auto_start_battle and encounter_definition != null:
		start_battle()


func start_battle() -> bool:
	if flow != null or encounter_definition == null or get_arena_layout() == null:
		return false
	var model := BattleSessionFactory.new().create_from_encounter(encounter_definition)
	if model == null:
		push_error("Cannot create battle: %s" % "; ".join(encounter_definition.get_validation_errors()))
		return false
	if not bind_session(model):
		model.clear()
		return false
	flow = BattleFlowController.new()
	flow.name = "BattleFlow"
	add_child(flow)
	return flow.start(self, encounter_definition)


## Validate before replacing, so an invalid scene leaves the current arena intact.
## Can also be called before adding BattleScreen to the scene tree.
func load_environment(scene: PackedScene) -> bool:
	if scene == null:
		push_error("BattleScreen requires an environment scene.")
		return false
	var candidate := scene.instantiate()
	var next_environment := candidate as BattleEnvironment
	if next_environment == null:
		candidate.free()
		push_error("Environment scene root must extend BattleEnvironment.")
		return false
	var errors := next_environment.get_validation_errors(_get_grid_size())
	if not errors.is_empty():
		next_environment.free()
		push_error("Invalid battle environment: %s" % "; ".join(errors))
		return false

	var host := get_node("BattleWorld/EnvironmentHost")
	if is_instance_valid(environment):
		host.remove_child(environment)
		environment.queue_free()
	environment = next_environment
	environment_scene = scene
	host.add_child(environment)
	var layout := get_arena_layout()
	var interaction := get_node("BattleWorld/TacticalOverlay/SlotInteraction") as BattleSlotInteraction
	interaction.set_layout(layout)
	(get_node("BattleWorld/TacticalOverlay") as BattleTacticalOverlay).bind(tactical_state, layout)
	if session != null:
		(get_node("BattleWorld/SurfaceLayer") as BattleSurfacePresenter).bind(session.surface_effect_controller, layout, tactical_state)
	_configure_preview(layout)
	if combatant_presenter != null:
		combatant_presenter.slot_resolver = layout
		for state in session.get_all_combatants():
			var view := combatant_presenter.get_view(state.instance_id)
			if view != null:
				view.snap_to_local_position(combatant_presenter.combatant_layer.to_local(
					layout.get_slot_position(state.grid_position)))
	return true


func get_arena_layout() -> BattleArenaLayout:
	if is_instance_valid(environment):
		return environment.get_arena_layout()
	return null


## Call after ready with the existing model; this never creates or changes gameplay state.
## Action/movement runners use combatant_presenter to animate committed results.
func bind_session(value: BattleSession) -> bool:
	if flow != null:
		push_error("Cannot replace a session while BattleFlow owns an active battle.")
		return false
	if not is_node_ready() or value == null or value.grid == null or get_arena_layout() == null:
		push_error("BattleScreen.bind_session requires a ready screen, environment and valid session.")
		return false
	var errors := get_arena_layout().get_validation_errors(Vector2i(value.grid.columns, value.grid.rows))
	if not errors.is_empty():
		push_error("Cannot bind battle session: %s" % "; ".join(errors))
		return false
	_disconnect_session()
	if combatant_presenter != null:
		combatant_presenter.clear()
	session = value
	combatant_presenter = BattleCombatantPresenter.new(
		get_arena_layout(), get_node("BattleWorld/CombatantLayer"), combatant_view_scene)
	combatant_presenter.default_impact_vfx_id = &"impact"
	(get_node("BattleWorld/BattleEffectsLayer") as BattleEffectsLayer).bind(combatant_presenter)
	(get_node("BattleWorld/SurfaceLayer") as BattleSurfacePresenter).bind(
		session.surface_effect_controller, get_arena_layout(), tactical_state)
	for state in session.get_all_combatants():
		combatant_presenter.add_combatant(state)
	session.combatant_added.connect(_on_combatant_added)
	session.combatant_removed.connect(_on_combatant_removed)
	_configure_preview(get_arena_layout())
	return true


func _on_combatant_added(state: CombatantState) -> void:
	combatant_presenter.add_combatant(state)


func _on_combatant_removed(instance_id: StringName) -> void:
	combatant_presenter.remove_view(instance_id)


func _disconnect_session() -> void:
	if session == null:
		return
	if session.combatant_added.is_connected(_on_combatant_added):
		session.combatant_added.disconnect(_on_combatant_added)
	if session.combatant_removed.is_connected(_on_combatant_removed):
		session.combatant_removed.disconnect(_on_combatant_removed)


func _exit_tree() -> void:
	_disconnect_session()


func _get_grid_size() -> Vector2i:
	if session != null:
		return Vector2i(session.grid.columns, session.grid.rows)
	if encounter_definition != null:
		return Vector2i(encounter_definition.columns, encounter_definition.rows)
	return Vector2i(6, 3)


func _configure_preview(layout: BattleArenaLayout) -> void:
	layout.preview_grid_size = _get_grid_size()
	if session != null:
		layout.preview_divider_column = session.side_rules.get_effective_divider_column(session.grid.columns)
	elif encounter_definition != null and encounter_definition.side_rules != null:
		layout.preview_divider_column = encounter_definition.side_rules.get_effective_divider_column(
			encounter_definition.columns)
