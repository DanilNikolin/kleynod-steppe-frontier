class_name BattleHUD
extends Control

signal end_turn_pressed
const ENTRY_SCENE = preload("res://presentation/battle/ui/battle_turn_order_entry.tscn")

@onready var ability_panel: BattleAbilityPanel = $AbilityPanel
@onready var end_turn_button: TextureButton = $EndTurnArea/Button
@onready var top_menu: CommonTopMenu = $CommonTopMenu
## Campaign progression keyed by battle instance ID; standalone actors may have no level.
var progression_by_combatant_id: Dictionary[StringName, HeroProgressionState] = {}
var player_combatant: CombatantState
var player_team_id: StringName
var session: BattleSession
var turns: BattleTurnController
var reinforcements: BattleReinforcementController
var menu_panel: CampaignMenuPanel
var _was_paused: bool = false
var _warned_overflow: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	end_turn_button.pressed.connect(end_turn_pressed.emit)
	top_menu.menu_pressed.connect(open_menu)
	$ContextLayer.process_mode = Node.PROCESS_MODE_ALWAYS
	$ContextLayer.z_index = 100
	for row in $ReinforcementArea.get_children():
		row.hide()
	end_turn_button.disabled = true

func bind_battle(model: BattleSession, controller: BattleTurnController, waves: BattleReinforcementController, team: StringName) -> void:
	_disconnect_battle()
	session = model
	turns = controller
	reinforcements = waves
	player_team_id = team
	turns.turn_started.connect(refresh_turn_order)
	turns.round_started.connect(refresh_turn_order)
	session.combatant_defeated.connect(refresh_turn_order)
	reinforcements.wave_completed.connect(refresh_reinforcements)
	reinforcements.wave_deferred.connect(refresh_reinforcements)
	for actor in session.get_all_combatants():
		if actor.team_id == team and actor.is_alive:
			bind_player_combatant(actor)
			break
	refresh_reinforcements()

func bind_player_combatant(combatant: CombatantState) -> void:
	_disconnect_player()
	player_combatant = combatant
	if combatant == null:
		ability_panel.clear_combatant()
		$PortraitPanel/CharacterPortrait.texture = null
		$PortraitPanel/CharacterPortrait.hide()
		$PortraitPanel/LevelValue.text = ""
		BattleStatusStrip.render_into($PortraitPanel/BuffStrip, null)
		BattleStatusStrip.render_into($PortraitPanel/DebuffStrip, null)
		$PortraitPanel/NeutralStatuses.text = ""
		return
	for event in [&"health_changed", &"stamina_changed", &"max_stamina_changed", &"guard_changed", &"status_added", &"status_updated", &"status_removed"]:
		combatant.connect(event, _refresh_player)
	ability_panel.bind_combatant(combatant)
	_refresh_player()

func set_player_controls_enabled(enabled: bool) -> void:
	if player_combatant != null and ability_panel.hud_actor != player_combatant:
		ability_panel.bind_combatant(player_combatant)
	ability_panel.set_interactable(enabled)
	end_turn_button.disabled = not enabled

func _refresh_player(_a: Variant = null, _b: Variant = null, _c: Variant = null) -> void:
	if player_combatant == null:
		return
	var actor := player_combatant
	var progression := progression_by_combatant_id.get(actor.instance_id) as HeroProgressionState
	$PortraitPanel/LevelValue.text = str(progression.level) if progression != null else ""
	$PortraitPanel/CharacterPortrait.texture = actor.definition.portrait
	$PortraitPanel/CharacterPortrait.visible = actor.definition.portrait != null
	$PortraitPanel/Health/Bar.max_value = actor.max_health
	$PortraitPanel/Health/Bar.value = actor.current_health
	$PortraitPanel/Health/Value.text = "%d/%d" % [actor.current_health, actor.max_health]
	$PortraitPanel/Stamina/Bar.max_value = actor.max_stamina
	$PortraitPanel/Stamina/Bar.value = actor.current_stamina
	$PortraitPanel/Stamina/Value.text = "%d/%d" % [actor.current_stamina, actor.max_stamina]
	$PortraitPanel/Guard/Value.text = str(actor.current_guard)
	$PortraitPanel/Armor/Value.text = str(actor.get_effective_armor())
	$PortraitPanel/StaminaRegen/Value.text = "+%d" % actor.get_effective_stamina_regeneration()
	BattleStatusStrip.render_into($PortraitPanel/BuffStrip, actor, BattleStatusDefinition.Polarity.BENEFICIAL, 22, true)
	BattleStatusStrip.render_into($PortraitPanel/DebuffStrip, actor, BattleStatusDefinition.Polarity.HARMFUL, 22, true)
	var neutral := PackedStringArray()
	for status in actor.get_active_statuses():
		if status.definition.polarity == BattleStatusDefinition.Polarity.NEUTRAL:
			neutral.append(status.definition.display_name)
	$PortraitPanel/NeutralStatuses.text = ", ".join(neutral)

func refresh_turn_order(_a: Variant = null, _b: Variant = null, _c: Variant = null) -> void:
	if turns == null:
		return
	$EndTurnArea/RoundLabel.text = str(turns.round_number)
	for parent in [$TurnOrderArea/PastEntries, $TurnOrderArea/FutureEntries]:
		for child in parent.get_children():
			parent.remove_child(child)
			child.queue_free()
	var order := turns.get_turn_order()
	var current := turns.get_current_turn_index()
	$TurnOrderArea/CurrentEntry.hide()
	var past: Array[CombatantState] = []
	var future: Array[CombatantState] = []
	for i in range(order.size()):
		var actor := order[i]
		if not actor.is_alive:
			continue
		if i < current:
			past.append(actor)
		elif i > current:
			future.append(actor)
		else:
			$TurnOrderArea/CurrentEntry.show()
			$TurnOrderArea/CurrentEntry/Portrait.texture = actor.definition.portrait
			$TurnOrderArea/CurrentEntry/Portrait.visible = actor.definition.portrait != null
	# Three entries per side fit the exported 680px backing without overlap.
	if (past.size() > 3 or future.size() > 3) and not _warned_overflow:
		push_warning("Battle HUD turn strip shows the nearest 3 past and 3 future living actors.")
		_warned_overflow = true
	for i in range(mini(3, past.size())):
		_add_entry(past[past.size() - 1 - i], $TurnOrderArea/PastEntries, Vector2(824 - i * 83, 5))
	for i in range(mini(3, future.size())):
		_add_entry(future[i], $TurnOrderArea/FutureEntries, Vector2(1038 + i * 83, 5))
	refresh_reinforcements()

func _add_entry(actor: CombatantState, parent: Control, at: Vector2) -> void:
	var entry := ENTRY_SCENE.instantiate() as BattleTurnOrderEntry
	parent.add_child(entry)
	entry.position = at
	entry.bind_combatant(actor, actor.team_id == player_team_id)

func refresh_reinforcements(_a: Variant = null, _b: Variant = null, _c: Variant = null) -> void:
	var rows := reinforcements.get_pending_opposition_rows(player_team_id) if reinforcements != null else PackedInt32Array()
	for i in range(3):
		$ReinforcementArea.get_child(i).visible = rows.has(i)

## Keep the exported first flag position; align additional rows with authored slots.
## Called only when loading an arena, so camera impacts never displace the HUD.
func configure_arena_layout(layout: BattleArenaLayout, grid_size: Vector2i, zoom: Vector2) -> void:
	var first := layout.get_slot_position(Vector2i(grid_size.x - 1, 0))
	for row in range(mini(3, grid_size.y)):
		var slot := layout.get_slot_position(Vector2i(grid_size.x - 1, row))
		$ReinforcementArea.get_child(row).position.y = 380.0 + (slot.y - first.y) * zoom.y

func open_menu() -> void:
	if is_instance_valid(menu_panel):
		return
	_was_paused = get_tree().paused
	get_tree().paused = true
	menu_panel = CampaignMenuPanel.new()
	$ContextLayer.add_child(menu_panel)
	menu_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_panel.close_requested.connect(close_menu)
	menu_panel.save_requested.connect(_menu_unavailable.bind("Сохранение"))
	menu_panel.load_requested.connect(_menu_unavailable.bind("Загрузка"))
	menu_panel.save_slot_requested.connect(func(_slot: int): _menu_unavailable("Сохранение"))
	menu_panel.load_slot_requested.connect(func(_slot: int): _menu_unavailable("Загрузка"))
	menu_panel.new_debug_requested.connect(_menu_unavailable.bind("Начало новой кампании"))
	menu_panel.bind("Сохранение и загрузка во время боя пока недоступны.")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if is_instance_valid(menu_panel):
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()

func _menu_unavailable(action: String) -> void:
	menu_panel.set_status_message(action + " во время боя пока недоступна.")

func close_menu() -> void:
	if is_instance_valid(menu_panel):
		menu_panel.queue_free()
	menu_panel = null
	get_tree().paused = _was_paused

func _disconnect_player() -> void:
	if player_combatant == null:
		return
	for event in [&"health_changed", &"stamina_changed", &"max_stamina_changed", &"guard_changed", &"status_added", &"status_updated", &"status_removed"]:
		if player_combatant.is_connected(event, _refresh_player):
			player_combatant.disconnect(event, _refresh_player)
	player_combatant = null

func _disconnect_battle() -> void:
	if turns != null:
		turns.turn_started.disconnect(refresh_turn_order)
		turns.round_started.disconnect(refresh_turn_order)
	if session != null:
		session.combatant_defeated.disconnect(refresh_turn_order)
	if reinforcements != null:
		reinforcements.wave_completed.disconnect(refresh_reinforcements)
		reinforcements.wave_deferred.disconnect(refresh_reinforcements)
	turns = null
	session = null
	reinforcements = null

func _exit_tree() -> void:
	if is_instance_valid(menu_panel):
		close_menu()
	_disconnect_player()
	_disconnect_battle()
