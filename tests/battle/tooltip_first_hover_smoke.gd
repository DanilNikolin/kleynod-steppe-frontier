extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	# 1. Test Compact HeroCoreHoverPanel on its very first hover
	var compact_scene := load("res://presentation/battle/ui/hero_core_hover_panel.tscn")
	var compact_panel := compact_scene.instantiate() as HeroCoreHoverPanel
	root.add_child(compact_panel)

	var dummy_source := Control.new()
	dummy_source.position = Vector2(200, 500)
	dummy_source.size = Vector2(40, 40)
	root.add_child(dummy_source)

	compact_panel.show_for_control(
		dummy_source,
		"Кровотечение",
		"В конце хода носителя наносит 1 урон за каждый стак кровотечения. Очень длинное описание для проверки правильности переноса текста и расчета высоты.",
		"Стаки: 3"
	)

	# Wait for the async layout frame pass
	await process_frame
	await process_frame

	check(compact_panel.visible, "Compact panel is visible after layout")
	check(is_equal_approx(compact_panel.size.x, HeroCoreHoverPanel.COMPACT_WIDTH), "Compact panel width equals 310 px (got %s)" % compact_panel.size.x)
	check(compact_panel.size.y >= 60.0 and compact_panel.size.y <= 350.0, "Compact panel first-hover height is within reasonable bounds (got %s)" % compact_panel.size.y)
	check(is_equal_approx(compact_panel.modulate.a, 1.0), "Compact panel modulate is 1.0 (got %s)" % compact_panel.modulate.a)

	dummy_source.queue_free()
	compact_panel.queue_free()

	# 2. Test CombatantHoverPanel first hover layout
	var combatant_scene := load("res://presentation/battle/combatants/battle_combatant_hover_panel.tscn")
	var combatant_panel := combatant_scene.instantiate() as BattleCombatantHoverPanel
	root.add_child(combatant_panel)

	# Create a dummy combatant state
	var def := load("res://content/combatants/debug/debug_steppe_raider.tres") as CombatantDefinition
	var loadout := load("res://content/loadouts/debug/debug_steppe_raider_loadout.tres") as CombatantLoadoutDefinition
	var state := CombatantState.new(&"test_raider", def, &"team_enemy", loadout, Vector2i(0, 0))

	combatant_panel.bind_combatant(state, &"team_player")

	await process_frame
	await process_frame

	check(combatant_panel.visible, "Combatant panel is visible after layout")
	check(is_equal_approx(combatant_panel.size.x, 380.0), "Combatant panel width equals 380 px (got %s)" % combatant_panel.size.x)
	check(combatant_panel.size.y > 80.0 and combatant_panel.size.y < 700.0, "Combatant panel height is reasonable and not entire viewport (got %s)" % combatant_panel.size.y)
	check(is_equal_approx(combatant_panel.modulate.a, 1.0), "Combatant panel modulate is 1.0 (got %s)" % combatant_panel.modulate.a)
	check(not combatant_panel.statuses_section.visible, "Statuses section is hidden when combatant has no statuses")
	check(not combatant_panel.hero_core_section.visible, "Hero Core section is hidden for regular raider")

	# 3. Test Combatant with Statuses
	var status_def := load("res://content/statuses/debug/debug_bleeding.tres") as BattleStatusDefinition
	state.add_status(status_def, &"test_source", 2)
	combatant_panel.refresh()
	await process_frame
	await process_frame

	check(combatant_panel.statuses_section.visible, "Statuses section is visible when combatant has statuses")
	check(combatant_panel.statuses_container.get_child_count() == 1, "Statuses container has 1 row")

	# 4. Test Bayda with Hero Core states
	var bayda_def := load("res://content/combatants/heroes/bayda/bayda_base_combatant.tres") as CombatantDefinition
	var bayda_core := load("res://content/heroes/bayda/bayda_core_module.tres") as HeroCoreModuleDefinition
	var bayda_state := CombatantState.new(&"bayda", bayda_def, &"team_player", loadout, Vector2i(0, 0), bayda_core)

	combatant_panel.bind_combatant(bayda_state, &"team_player")
	await process_frame
	await process_frame

	check(combatant_panel.hero_core_section.visible, "Hero Core section is visible for Bayda with unbroken ready")
	check(combatant_panel.hero_core_entries.get_child_count() == 1, "Hero Core has unbroken ready row")

	# Test Bayda with exhaustion debt and fracture
	var bayda_runtime := bayda_state.hero_core_runtime_state as BaydaCoreRuntimeState
	bayda_runtime.unbroken_available = false
	bayda_runtime.is_fractured = true
	bayda_runtime.exhaustion_debt = 3
	bayda_runtime.grit_teeth_max_stamina_penalty = 2
	combatant_panel.refresh()
	await process_frame
	await process_frame

	check(combatant_panel.hero_core_section.visible, "Hero Core section visible with fractured, debt, and penalty")
	check(combatant_panel.hero_core_entries.get_child_count() == 3, "Hero Core has 3 rows (fractured, debt, penalty)")

	combatant_panel.queue_free()

	await process_frame
	print("TOOLTIP FIRST HOVER SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
