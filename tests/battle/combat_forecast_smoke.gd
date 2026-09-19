extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	# 1. Instantiate CombatantView
	var view_scene := load("res://presentation/battle/combatants/combatant_view.tscn") as PackedScene
	var view := view_scene.instantiate() as CombatantView
	root.add_child(view)

	var def := load("res://content/combatants/debug/debug_steppe_raider.tres") as CombatantDefinition
	var loadout := load("res://content/loadouts/debug/debug_steppe_raider_loadout.tres") as CombatantLoadoutDefinition
	var state := CombatantState.new(&"test_raider", def, &"team_enemy", loadout, Vector2i(2, 1))
	state.max_health = 16
	state.current_health = 16

	view.bind_state(state)
	await process_frame
	await process_frame

	check(view.health_value_label.text == "16 / 16", "Health label initially displays 16 / 16 (got %s)" % view.health_value_label.text)
	check(not view.ghost_health_bar.visible, "Ghost health bar initially hidden")

	# 2. Test Primary Forecast: Normal hit with Guard Absorption & Bleeding
	var target_preview := BattleTargetPreview.new()
	target_preview.target_id = &"test_raider"
	target_preview.initial_health = 16
	target_preview.initial_guard = 3
	target_preview.initial_position = Vector2i(2, 1)
	target_preview.normal_final_health = 9
	target_preview.normal_final_guard = 0
	target_preview.critical_final_health = 5
	target_preview.critical_final_guard = 0

	var dmg_res := BattleEffectResult.new()
	dmg_res.effect_kind = &"damage"
	dmg_res.applied_amount = 7
	dmg_res.guard_absorbed_amount = 3
	dmg_res.critical_was_enabled = true
	dmg_res.critical_chance_percent = 18

	var status_res := BattleEffectResult.new()
	status_res.status_was_added = true
	status_res.status_display_name = "Кровотечение"
	status_res.current_status_stack_count = 2

	target_preview.normal_effect_results = [dmg_res, status_res]

	var crit_dmg_res := BattleEffectResult.new()
	crit_dmg_res.effect_kind = &"damage"
	crit_dmg_res.applied_amount = 11
	crit_dmg_res.guard_absorbed_amount = 3
	crit_dmg_res.was_critical = true

	target_preview.critical_effect_results = [crit_dmg_res]

	view.show_action_preview(target_preview, "Косая сечь", true)
	await process_frame
	await process_frame

	var badge := view.action_preview_badge
	check(badge.visible, "Preview badge is visible")
	check(badge.primary_forecast.visible, "Primary forecast is visible")
	check(not badge.secondary_badge.visible, "Secondary badge is hidden")
	check(badge.ability_title_label.text == "КОСАЯ СЕЧЬ", "Ability title matches (got %s)" % badge.ability_title_label.text)
	check(badge.damage_label.text == "−7 HP", "Normal damage label is −7 HP (got %s)" % badge.damage_label.text)
	check(badge.guard_absorption_label.visible and "3" in badge.guard_absorption_label.text, "Guard absorption displays 3")
	check(badge.critical_outcome_label.visible and "18%" in badge.critical_outcome_label.text and "11" in badge.critical_outcome_label.text, "Critical outcome shows 18% and 11 HP")
	check(badge.additional_effects_label.visible and "Кровотечение ×2" in badge.additional_effects_label.text, "Additional effects show Bleeding x2")
	check(not badge.lethal_banner_label.visible, "Not lethal yet")

	# Check ghost HP bar and label
	check(view.ghost_health_bar.visible, "Ghost health bar is visible during preview")
	check(view.ghost_health_bar.value == 16.0, "Ghost health bar holds original health 16")
	check(view.health_bar.value == 9.0, "Real health bar shows final health 9")
	check(view.health_value_label.text == "16 → 9", "Health value label displays 16 → 9 (got %s)" % view.health_value_label.text)

	# 3. Test Lethal Normal Hit
	target_preview.normal_final_health = 0
	view.show_action_preview(target_preview, "Косая сечь", true)
	await process_frame
	await process_frame

	check(badge.lethal_banner_label.visible and "СМЕРТЕЛЬНО" in badge.lethal_banner_label.text, "Lethal normal shows СМЕРТЕЛЬНО")

	# 4. Test Lethal only on Crit
	target_preview.normal_final_health = 3
	target_preview.critical_final_health = 0
	view.show_action_preview(target_preview, "Косая сечь", true)
	await process_frame
	await process_frame

	check(badge.lethal_banner_label.visible and "Критический удар смертелен" in badge.lethal_banner_label.text, "Lethal on crit banner shows correctly")

	# 5. Test Secondary AoE Badge
	view.show_action_preview(target_preview, "Косая сечь", false)
	await process_frame
	await process_frame

	check(not badge.primary_forecast.visible, "Primary forecast hidden in secondary mode")
	check(badge.secondary_badge.visible, "Secondary badge visible in secondary mode")
	check("HP" in badge.secondary_label.text or "−" in badge.secondary_label.text, "Secondary label has damage info")

	# 6. Test Clear Preview
	view.clear_action_preview()
	await process_frame
	await process_frame

	check(not badge.visible, "Preview badge hidden on clear")
	check(not view.ghost_health_bar.visible, "Ghost health bar hidden on clear")
	check(view.health_bar.value == 16.0, "Health bar reset to 16")
	check(view.health_value_label.text == "16 / 16", "Health value label restored to 16 / 16")

	view.queue_free()

	await process_frame
	print("COMBAT FORECAST SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
