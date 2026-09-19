extends SceneTree

var failures: int = 0
var selections: int = 0
var end_turns: int = 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.environment_scene = load("res://scenes/battle/environments/deep_forest_environment.tscn")
	screen.ai_think_delay = 0
	root.add_child(screen)
	var hud := screen.battle_hud
	var actor := hud.player_combatant
	var enemy := screen.session.get_combatant(&"debug_enemy")
	check(hud != null and actor != null and screen.environment != null, "Deep Forest and bound HUD load.")
	check(hud.ability_panel.hud_slots.size() == 6, "Exactly six slots.")
	for i in range(6):
		var slot := hud.ability_panel.hud_slots[i]
		check(slot.get_node("HotkeyLabel").text == str(i + 1), "Hotkey numbering.")
		if slot.ability == null:
			check(slot.disabled and slot.get_node("Backing").texture == BattleAbilitySlot.INACTIVE and not slot.get_node("CostBadge").visible, "Empty slot inactive.")
		else:
			check(slot.get_node("CostLabel").text == str(slot.ability.stamina_cost), "Stamina cost bound.")
	var portrait := hud.get_node("PortraitPanel/CharacterPortrait") as TextureRect
	check(portrait.texture == actor.definition.portrait, "Portrait comes from model definition.")
	check(hud.get_node("PortraitPanel/PortraitBackground").get_index() < portrait.get_index() and portrait.get_index() < hud.get_node("PortraitPanel/PortraitFrame").get_index(), "Portrait draw order.")
	actor.pay_health_cost(1)
	actor.spend_stamina(1)
	actor.grant_guard(3)
	actor.set_max_stamina(actor.max_stamina + 2)
	check(hud.get_node("PortraitPanel/Health/Bar").value == actor.current_health, "HP signal updates bar.")
	check(hud.get_node("PortraitPanel/Stamina/Bar").value == actor.current_stamina and hud.get_node("PortraitPanel/Stamina/Bar").max_value == actor.max_stamina, "Stamina signals update bar.")
	check(hud.get_node("PortraitPanel/Guard/Value").text == str(actor.current_guard), "Guard signal updates label.")
	hud.ability_panel.ability_selected.connect(func(_ability): selections += 1)
	actor.restore_stamina(actor.max_stamina)
	check(hud.ability_panel.select_ability_by_index(0) and selections == 1, "Selection contract.")
	# Drive real mouse down/up: emitting pressed alone misses a latched draw state.
	await process_frame
	var clicked_slot := hud.ability_panel.hud_slots[1]
	var mouse_at := clicked_slot.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = mouse_at
	root.push_input(motion, true)
	for click_index in range(3):
		for down in [true, false]:
			var click := InputEventMouseButton.new()
			click.position = mouse_at
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = down
			root.push_input(click, true)
			await process_frame
			if down:
				check(clicked_slot.get_draw_mode() in [BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED], "Mouse hold shows pressed art.")
			else:
				check(hud.ability_panel.get_selected_ability() == clicked_slot.ability, "First and repeated clicks retain the selected ability.")
				check(clicked_slot.get_draw_mode() not in [BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED], "Mouse release never leaves pressed art latched.")
				check(clicked_slot.texture_hover == BattleAbilitySlot.SELECTED and clicked_slot.texture_normal == BattleAbilitySlot.SELECTED, "Released selection is visible under the cursor and outside it.")
	hud.end_turn_pressed.connect(func(): end_turns += 1)
	hud.end_turn_pressed.disconnect(screen.flow._end_turn)
	hud.end_turn_button.pressed.emit()
	check(end_turns == 1, "End turn button forwards the public signal exactly once.")
	hud.end_turn_pressed.connect(screen.flow._end_turn)
	check(hud.get_node("TurnOrderArea/CurrentEntry/Frame").texture.resource_path.ends_with("turn_current_frame.png"), "Current actor uses the large current frame.")
	for item in hud.get_node("TurnOrderArea/PastEntries").get_children():
		check(item.position.x < 918, "Past entries are left of current.")
	for item in hud.get_node("TurnOrderArea/FutureEntries").get_children():
		check(item.position.x > 1023, "Future entries are right of current.")
	# Keep this test deterministic; directly enter enemy presentation without scheduling AI.
	screen.flow.interaction.begin_enemy_turn()
	hud.set_player_controls_enabled(false)
	check(hud.player_combatant == actor and hud.ability_panel.hud_actor == actor, "Enemy turn keeps player panel bound.")
	check(hud.end_turn_button.disabled and not hud.ability_panel.select_ability_by_index(0), "Enemy turn blocks player actions.")
	for slot in hud.ability_panel.hud_slots:
		check(slot.disabled, "Enemy turn disables slots.")
	check(hud.get_node("EndTurnArea/RoundLabel").text == str(screen.flow.turn_controller.round_number), "Round displayed numerically.")
	var waves := BattleReinforcementWaveDefinition.new()
	waves.wave_id = &"hud_rows"
	var spawn := CombatantSpawnDefinition.new()
	spawn.instance_id = &"incoming"
	spawn.team_id = &"team_enemy"
	spawn.combatant_definition = enemy.definition
	spawn.coordinate = Vector2i(5, 0)
	spawn.fallback_coordinates = [Vector2i(4, 0), Vector2i(5, 2)]
	waves.combatant_spawns = [spawn]
	var query := BattleReinforcementController.new(screen.session, [waves])
	check(query.get_pending_opposition_rows(&"team_player") == PackedInt32Array([0, 2]), "Unique rows include all spawn candidates.")
	check(query.get_pending_opposition_rows(&"team_enemy").is_empty(), "Own reinforcement excluded.")
	# Rebind also tests cleanup of old battle signal connections.
	hud.bind_battle(screen.session, screen.flow.turn_controller, query, &"team_player")
	check(hud.get_node("ReinforcementArea/Row0").visible and hud.get_node("ReinforcementArea/Row2").visible and not hud.get_node("ReinforcementArea/Row1").visible, "Multiple row flags simultaneously visible.")
	query.process_round(99)
	hud.refresh_reinforcements()
	check(not hud.get_node("ReinforcementArea/Row0").visible and not hud.get_node("ReinforcementArea/Row2").visible, "Completed spawns remove flags.")
	var entry := load("res://presentation/battle/ui/battle_turn_order_entry.tscn").instantiate() as BattleTurnOrderEntry
	root.add_child(entry)
	entry.bind_combatant(actor, true)
	check(entry.get_node("Frame").texture == BattleTurnOrderEntry.FRIENDLY, "Friendly frame.")
	entry.bind_combatant(enemy, false)
	check(entry.get_node("Frame").texture == BattleTurnOrderEntry.ENEMY, "Enemy frame.")
	entry.queue_free()
	var transform := hud.get_global_transform_with_canvas()
	var director := screen.get_node("CameraDirector") as BattleCameraDirector
	director.impact_shake_strong()
	director._process(0.03)
	check(hud.get_global_transform_with_canvas() == transform, "World effects do not move HUD.")
	director.reset()
	hud.open_menu()
	check(paused and is_instance_valid(hud.menu_panel), "Menu opens and pauses battle.")
	check(hud.get_node("ContextLayer").size == hud.size and hud.menu_panel.size == hud.size, "Menu context fills the HUD viewport.")
	hud.menu_panel.save_requested.emit()
	check(hud.menu_panel.get("_status_message").contains("во время боя"), "Save limitation explained.")
	hud.close_menu()
	check(not paused, "Menu close resumes battle.")
	# Root and all decorative textures ignore mouse; only buttons/card interactions consume it.
	check(hud.mouse_filter == Control.MOUSE_FILTER_IGNORE, "HUD passes battlefield clicks.")
	for node in hud.find_children("*", "TextureRect", true, false):
		check(node.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Art does not intercept battlefield clicks.")
	# ==========================================================
	# Bayda Hero Core Portrait Indicators Test Suite
	# ==========================================================
	var core_panel := hud.get_node("PortraitPanel/HeroCoreIndicators") as Control
	check(core_panel != null, "HeroCoreIndicators exists under PortraitPanel.")
	# Default duel encounter uses debug_sechevik (no hero core module), so panel is initially hidden
	check(not core_panel.visible, "HeroCoreIndicators is hidden for non-Bayda actor.")

	# Create real Bayda combatant and bind to HUD
	var bayda_hero := load("res://content/heroes/bayda/bayda_hero.tres") as HeroDefinition
	var bayda_combatant := CombatantState.new(&"bayda_test", bayda_hero.base_combatant_definition,
		&"team_player", CombatantLoadoutDefinition.new(), Vector2i.ZERO, bayda_hero.core_module)
	hud.bind_player_combatant(bayda_combatant)
	check(core_panel.visible, "HeroCoreIndicators is visible for Bayda.")

	var unbroken_icon := hud.get_node("PortraitPanel/HeroCoreIndicators/Unbroken/Icon") as TextureRect
	var fractured_icon := hud.get_node("PortraitPanel/HeroCoreIndicators/Fractured/Icon") as TextureRect
	var debt_icon := hud.get_node("PortraitPanel/HeroCoreIndicators/ExhaustionDebt/Icon") as TextureRect
	var debt_label := hud.get_node("PortraitPanel/HeroCoreIndicators/ExhaustionDebt/MagnitudeLabel") as Label
	var penalty_icon := hud.get_node("PortraitPanel/HeroCoreIndicators/MaxStaminaPenalty/Icon") as TextureRect
	var penalty_label := hud.get_node("PortraitPanel/HeroCoreIndicators/MaxStaminaPenalty/MagnitudeLabel") as Label

	const HeroCoreIndicatorType = preload("res://presentation/battle/ui/hero_core_indicator.gd")
	var unbroken_ind: HeroCoreIndicatorType = hud.get_node("PortraitPanel/HeroCoreIndicators/Unbroken")
	var fractured_ind: HeroCoreIndicatorType = hud.get_node("PortraitPanel/HeroCoreIndicators/Fractured")
	var debt_ind: HeroCoreIndicatorType = hud.get_node("PortraitPanel/HeroCoreIndicators/ExhaustionDebt")
	var penalty_ind: HeroCoreIndicatorType = hud.get_node("PortraitPanel/HeroCoreIndicators/MaxStaminaPenalty")

	var bayda_core := bayda_combatant.hero_core_runtime_state as BaydaCoreRuntimeState
	check(bayda_core != null, "Bayda combatant has BaydaCoreRuntimeState.")

	# 1. Initial State: Unbroken active, Fractured inactive, Debt inactive (no label), Penalty inactive (no label)
	check(unbroken_icon.texture == unbroken_ind.active_texture, "Initial Unbroken is ACTIVE.")
	check(fractured_icon.texture == fractured_ind.inactive_texture, "Initial Fractured is INACTIVE.")
	check(debt_icon.texture == debt_ind.inactive_texture, "Initial ExhaustionDebt is INACTIVE.")
	check(not debt_label.visible, "Initial ExhaustionDebt MagnitudeLabel is hidden.")
	check(penalty_icon.texture == penalty_ind.inactive_texture, "Initial MaxStaminaPenalty is INACTIVE.")
	check(not penalty_label.visible, "Initial MaxStaminaPenalty MagnitudeLabel is hidden.")

	# 2. Trigger Unbroken: unbroken_available = false, is_fractured = true
	bayda_core.unbroken_available = false
	bayda_core.is_fractured = true
	bayda_core.state_changed.emit()

	check(unbroken_icon.texture == unbroken_ind.inactive_texture, "After trigger: Unbroken is INACTIVE.")
	check(fractured_icon.texture == fractured_ind.active_texture, "After trigger: Fractured is ACTIVE.")

	# 3. Exhaustion Debt: exhaustion_debt = 4
	bayda_core.exhaustion_debt = 4
	bayda_core.state_changed.emit()

	check(debt_icon.texture == debt_ind.active_texture, "Debt > 0: ExhaustionDebt is ACTIVE.")
	check(debt_label.visible and debt_label.text == "4", "Debt > 0: MagnitudeLabel is '4'.")

	# 4. Max Stamina Penalty: grit_teeth_max_stamina_penalty = 3
	bayda_core.grit_teeth_max_stamina_penalty = 3
	bayda_core.state_changed.emit()

	check(penalty_icon.texture == penalty_ind.active_texture, "Penalty > 0: MaxStaminaPenalty is ACTIVE.")
	check(penalty_label.visible and penalty_label.text == "3", "Penalty > 0: MagnitudeLabel is '3'.")

	# 5. Reset back to 0
	bayda_core.unbroken_available = true
	bayda_core.is_fractured = false
	bayda_core.exhaustion_debt = 0
	bayda_core.grit_teeth_max_stamina_penalty = 0
	bayda_core.state_changed.emit()

	check(unbroken_icon.texture == unbroken_ind.active_texture, "Reset: Unbroken back to ACTIVE.")
	check(fractured_icon.texture == fractured_ind.inactive_texture, "Reset: Fractured back to INACTIVE.")
	check(debt_icon.texture == debt_ind.inactive_texture, "Reset: Debt back to INACTIVE.")
	check(not debt_label.visible, "Reset: Debt MagnitudeLabel hidden.")
	check(penalty_icon.texture == penalty_ind.inactive_texture, "Reset: Penalty back to INACTIVE.")
	check(not penalty_label.visible, "Reset: Penalty MagnitudeLabel hidden.")

	# 6. Check HeroCoreHoverPanel instant hover behavior
	const HeroCoreHoverPanelType = preload("res://presentation/battle/ui/hero_core_hover_panel.gd")
	var hover_panel: HeroCoreHoverPanelType = hud.hero_core_hover_panel
	check(hover_panel != null, "HeroCoreHoverPanel exists in BattleHUD.")
	check(not hover_panel.visible, "1. HeroCoreHoverPanel starts hidden.")
	check(hover_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE, "9. Custom panel uses MOUSE_FILTER_IGNORE.")
	check(unbroken_ind.mouse_filter == Control.MOUSE_FILTER_STOP, "Unbroken has MOUSE_FILTER_STOP.")
	check(unbroken_icon.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Unbroken icon has MOUSE_FILTER_IGNORE.")
	check(unbroken_ind.tooltip_text.is_empty(), "10. No standard tooltip_text on Unbroken.")

	# 2. Hover Unbroken
	unbroken_ind._on_mouse_entered()
	check(hover_panel.visible, "2. Hover Unbroken: panel becomes visible immediately.")
	check(hover_panel.title_label.text == "Несломленность", "2. Title is 'Несломленность'.")
	check(not hover_panel.description_label.text.is_empty(), "2. Description is non-empty.")
	check(not hover_panel.value_label.visible, "2. ValueLabel hidden.")
	unbroken_ind._on_mouse_exited()
	check(not hover_panel.visible, "7. Mouse exit: panel immediately hidden.")

	# 3. Hover Fractured (inactive icon remains hoverable)
	fractured_ind._on_mouse_entered()
	check(hover_panel.visible, "3. Hover Fractured: panel becomes visible immediately.")
	check(hover_panel.title_label.text == "Надлом", "3. Title is 'Надлом'.")
	check(not hover_panel.value_label.visible, "3. ValueLabel hidden.")
	fractured_ind._on_mouse_exited()
	check(not hover_panel.visible, "Mouse exit Fractured hides panel.")

	# 4. Hover ExhaustionDebt with value 4
	debt_ind.set_magnitude(4)
	debt_ind._on_mouse_entered()
	check(hover_panel.visible, "4. Hover ExhaustionDebt: panel visible.")
	check(hover_panel.title_label.text == "Долг истощения", "4. Title is 'Долг истощения'.")
	check(hover_panel.value_label.visible and hover_panel.value_label.text == "Текущий долг: 4", "4. ValueLabel is 'Текущий долг: 4'.")

	# 5. Live value refresh while hovered (4 -> 2)
	debt_ind.set_magnitude(2)
	check(hover_panel.value_label.text == "Текущий долг: 2", "5. Live update while hovered: 'Текущий долг: 2'.")
	debt_ind._on_mouse_exited()
	check(not hover_panel.visible, "Mouse exit Debt hides panel.")

	# 6. Hover MaxStaminaPenalty with value 3
	penalty_ind.set_magnitude(3)
	penalty_ind._on_mouse_entered()
	check(hover_panel.visible, "6. Hover MaxStaminaPenalty: panel visible.")
	check(hover_panel.value_label.visible and hover_panel.value_label.text == "Текущий штраф: 3", "6. ValueLabel is 'Текущий штраф: 3'.")
	penalty_ind._on_mouse_exited()
	check(not hover_panel.visible, "Mouse exit Penalty hides panel.")

	# 7. Non-Bayda combatant hides HeroCoreIndicators
	hud.bind_player_combatant(enemy)
	check(not core_panel.visible, "Non-Bayda combatant hides HeroCoreIndicators.")

	# Rebind Bayda to restore
	hud.bind_player_combatant(bayda_combatant)
	check(core_panel.visible, "Rebinding Bayda restores HeroCoreIndicators.")

	screen.queue_free()
	await process_frame
	print("BATTLE HUD SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
