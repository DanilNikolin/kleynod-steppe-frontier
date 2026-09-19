extends SceneTree

var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func definition(id: StringName, tags: Array[StringName], polarity: int = 2) -> BattleStatusDefinition:
	var result := BattleStatusDefinition.new()
	result.status_id = id
	result.display_name = String(id)
	result.tags = tags
	result.polarity = polarity
	result.duration_turns = 3
	return result
func modifier(stat: int, amount: int) -> BattleStatModifier:
	var result := BattleStatModifier.new()
	result.stat = stat
	result.amount_per_stack = amount
	return result
func run() -> void:
	var cases := {"bleeding":"bleeding", "armor_debuff":"armor_down", "immobilized":"immobilized", "stun":"stun", "counterattack":"counterattack", "armor_buff":"armor_up", "stamina_reaction":"reactive_stamina", "burning":"burning", "poison":"poison", "stamina_regeneration_buff":"stamina_regen_up"}
	for tag in cases:
		var tags: Array[StringName] = [StringName(tag)]
		check(BattleStatusVisualResolver.resolve(definition(&"mapping", tags)) == [cases[tag]], "Mapping: " + tag)
	check(BattleStatusVisualResolver.resolve(definition(&"guard", [&"reaction", &"guard"])) == ["reactive_guard"], "Reactive guard requires both tags.")
	check(BattleStatusVisualResolver.resolve(definition(&"guard_only", [&"guard"])).is_empty(), "Guard alone is not a reaction.")
	check(BattleStatModifier.Stat.ARMOR == 0 and BattleStatModifier.Stat.STRENGTH == 1 and BattleStatModifier.Stat.AGILITY == 2 and BattleStatModifier.Stat.SPIRIT == 3 and BattleStatModifier.Stat.STAMINA_REGENERATION == 4, "Stable enum ordinals.")
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	root.add_child(screen)
	var hud := screen.battle_hud
	var actor := hud.player_combatant
	var enemy := screen.session.get_combatant(&"debug_enemy")
	actor.clear_statuses()
	var buff := definition(&"armor_up_test", [&"armor_buff"], 1)
	buff.stat_modifiers = [modifier(BattleStatModifier.Stat.ARMOR, 4)]
	actor.add_status(buff)
	check(hud.get_node("PortraitPanel/Armor/Value").text == str(actor.armor + 4), "Armor Up updates effective HUD armor.")
	var composite := definition(&"composite", [&"immobilized", &"armor_debuff"])
	composite.stat_modifiers = [modifier(BattleStatModifier.Stat.ARMOR, -2)]
	check(BattleStatusVisualResolver.resolve(composite) == ["immobilized", "armor_down"], "Composite emits two ordered semantics.")
	actor.add_status(composite)
	enemy.add_status(composite)
	check(hud.get_node("PortraitPanel/Armor/Value").text == str(actor.get_effective_armor()) and actor.get_effective_armor() == actor.armor + 2, "Armor Down updates effective HUD armor.")
	var buffs := hud.get_node("PortraitPanel/BuffStrip")
	var debuffs := hud.get_node("PortraitPanel/DebuffStrip")
	check(buffs.get_child_count() == 1 and debuffs.get_child_count() == 2, "HUD polarity filters and composite icons.")
	var bleed := definition(&"bleed", [&"bleeding"])
	bleed.max_stacks = 3
	bleed.reapply_rule = BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH
	actor.add_status(bleed)
	check(not debuffs.get_child(1).get_node("StackLabel").visible, "Single stack has no count.")
	actor.add_status(bleed)
	check(debuffs.get_child(1).get_node("StackLabel").visible and debuffs.get_child(1).get_node("StackLabel").text == "2", "Stack count updates via signal.")
	var regen := definition(&"regen", [&"stamina_regeneration_buff"], 1)
	regen.stat_modifiers = [modifier(BattleStatModifier.Stat.STAMINA_REGENERATION, 2)]
	actor.add_status(regen)
	check(hud.get_node("PortraitPanel/StaminaRegen/Value").text == "+%d" % (actor.stamina_regeneration + 2), "Effective stamina regeneration in HUD.")
	actor.spend_stamina(actor.current_stamina)
	check(actor.restore_round_stamina() == mini(actor.max_stamina, actor.stamina_regeneration + 2), "Round regeneration uses modifier pipeline.")
	actor.add_status(definition(&"reactive", [&"stamina_reaction"], 1))
	check(actor.get_effective_stamina_regeneration() == actor.stamina_regeneration + 2, "Reactive gain does not change normal regen.")
	actor.grant_guard(5)
	check(hud.get_node("PortraitPanel/Guard/Value").text == str(actor.current_guard), "Guard still updates.")
	actor.add_status(definition(&"unknown", [&"unknown_tag"], 1))
	check(buffs.get_child(buffs.get_child_count()-1) is BattleStatusChip, "Unmapped status has visible text fallback.")
	var world_count := 0
	for view in screen.get_node("BattleWorld/CombatantLayer").get_children():
		var strip := view.get_node("StatusAnchor/BattleStatusStrip") as BattleStatusStrip
		for icon in strip.chip_container.get_children():
			check(icon.mouse_filter == Control.MOUSE_FILTER_IGNORE, "World entries pass tactical clicks.")
		if strip.state == actor:
			check(strip.chip_container.get_child_count() == 7, "World player shows both polarities plus fallback.")
		if strip.state == enemy:
			check(strip.chip_container.get_child_count() == 2, "World enemy composite icons.")
		world_count += 1
		check(view.get_node("InterfaceRoot/HealthBar") != null and view.get_node("InterfaceRoot/StaminaBar") != null, "World bars retained.")
	check(world_count == 2, "Both combatants have world strips.")
	actor.remove_status(composite.status_id)
	check(debuffs.get_child_count() == 1, "Removal immediately removes both composite icons.")
	actor.remove_status(bleed.status_id)
	actor.add_status(bleed)
	check(not debuffs.get_child(0).get_node("StackLabel").visible, "Re-added single stack hides number.")
	actor.remove_status(bleed.status_id)
	actor.add_status(bleed)
	check(not debuffs.get_child(0).get_node("StackLabel").visible, "Re-added single stack hides number.")
	# Test capped status behavior
	actor.add_status(bleed) # stack 2
	actor.add_status(bleed) # stack 3 (cap)
	actor.add_status(bleed) # try stack 4 -> stays 3
	check(actor.get_status(bleed.status_id).stack_count == 3, "Capped status stops at max_stacks (3).")
	check(debuffs.get_child(0).get_node("StackLabel").text == "3", "Capped status displays 3.")
	actor.remove_status(bleed.status_id)

	# Test unlimited status (max_stacks = 0)
	var unlimited_bleed := load("res://content/statuses/heroes/bayda/bayda_bleeding.tres") as BattleStatusDefinition
	check(unlimited_bleed.max_stacks == 0, "Bayda bleeding has max_stacks == 0 (unlimited).")
	check(unlimited_bleed.reapply_rule == BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH, "Bayda bleeding reapply_rule is ADD_STACK_AND_REFRESH.")
	check(unlimited_bleed.periodic_triggers[0].scale_damage_with_stacks, "Bayda bleeding scales damage with stacks.")

	# 1 stack
	actor.add_status(unlimited_bleed)
	var player_view: CombatantView = null
	for view in screen.get_node("BattleWorld/CombatantLayer").get_children():
		if view.state == actor:
			player_view = view
			break
	var get_hud_bleed = func() -> BattleStatusIcon: return debuffs.get_child(0) as BattleStatusIcon
	var get_world_bleed = func() -> BattleStatusIcon: return player_view.status_strip.chip_container.get_child(0) as BattleStatusIcon

	check(get_hud_bleed.call().custom_minimum_size == Vector2(22, 22), "HUD status icon rendered at 22x22.")
	check(get_world_bleed.call().custom_minimum_size == Vector2(20, 20), "World status icon unchanged at 20x20.")
	check(debuffs.get_theme_constant("separation") == 1, "DebuffStrip separation is 1.")
	check(buffs.get_theme_constant("separation") == 1, "BuffStrip separation is 1.")

	check(actor.get_status(unlimited_bleed.status_id).stack_count == 1, "First application stack_count == 1.")
	check(not get_hud_bleed.call().get_node("StackLabel").visible, "1 stack: HUD StackLabel is hidden.")
	check(not get_world_bleed.call().get_node("StackLabel").visible, "1 stack: World StackLabel is hidden.")
	check(get_hud_bleed.call().get_node("StackLabel").text == "1", "StackLabel text holds exact integer.")

	# 2 stacks
	actor.add_status(unlimited_bleed)
	check(actor.get_status(unlimited_bleed.status_id).stack_count == 2, "Second application stack_count == 2.")
	check(get_hud_bleed.call().get_node("StackLabel").visible and get_hud_bleed.call().get_node("StackLabel").text == "2", "2 stacks: HUD shows '2'.")
	check(get_world_bleed.call().get_node("StackLabel").visible and get_world_bleed.call().get_node("StackLabel").text == "2", "2 stacks: World shows '2'.")

	# 4 stacks
	actor.add_status(unlimited_bleed)
	actor.add_status(unlimited_bleed)
	check(actor.get_status(unlimited_bleed.status_id).stack_count == 4, "4 stacks accumulated.")
	check(get_hud_bleed.call().get_node("StackLabel").visible and get_hud_bleed.call().get_node("StackLabel").text == "4", "4 stacks: HUD shows '4'.")
	check(get_world_bleed.call().get_node("StackLabel").visible and get_world_bleed.call().get_node("StackLabel").text == "4", "4 stacks: World shows '4'.")
	check(not ("·" in get_hud_bleed.call().get_node("StackLabel").text or "/" in get_hud_bleed.call().get_node("StackLabel").text or "t" in get_hud_bleed.call().get_node("StackLabel").text), "StackLabel never displays remaining_turns.")

	# 50 stacks
	for i in range(46):
		actor.add_status(unlimited_bleed)
	check(actor.get_status(unlimited_bleed.status_id).stack_count == 50, "50 stacks accumulated without artificial cap.")
	check(get_hud_bleed.call().get_node("StackLabel").visible and get_hud_bleed.call().get_node("StackLabel").text == "50", "50 stacks: HUD shows '50'.")
	check(get_world_bleed.call().get_node("StackLabel").visible and get_world_bleed.call().get_node("StackLabel").text == "50", "50 stacks: World shows '50'.")
	check(actor.get_status(unlimited_bleed.status_id).remaining_turns == unlimited_bleed.duration_turns, "Reapplication refreshed remaining_turns.")

	# Test periodic damage scaling and single aggregate hit
	var processor := BattleStatusPeriodicProcessor.new()
	var base_source_damage := (unlimited_bleed.periodic_triggers[0].effects[0] as DamageEffect).base_damage
	var trigger_results := processor.process_owner_timing(screen.session, actor, BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END)
	check(trigger_results.size() == 1, "Exactly one periodic trigger executed for bleeding.")
	var trig_res := trigger_results[0]
	check(trig_res.is_successful, "Periodic trigger succeeded.")
	check(trig_res.effect_results.size() == 1, "Exactly one effect result generated for 50 stacks (single aggregated hit).")
	var raw_dealt: int = trig_res.effect_results[0].raw_amount
	check(raw_dealt == base_source_damage * 50, "Periodic damage scaled with 50 stacks (%d == %d)." % [raw_dealt, base_source_damage * 50])
	check((unlimited_bleed.periodic_triggers[0].effects[0] as DamageEffect).base_damage == base_source_damage, "Source DamageEffect Resource was not mutated.")

	# Non-scaling periodic effect check
	actor.current_health = actor.max_health
	actor.clear_statuses()
	var normal_status := definition(&"normal_dot", [&"bleeding"])
	normal_status.duration_turns = 2
	normal_status.max_stacks = 0
	normal_status.reapply_rule = BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH
	var normal_dmg := DamageEffect.new()
	normal_dmg.effect_id = &"effect_normal_dot"
	normal_dmg.base_damage = 3
	normal_dmg.armor_piercing = 999
	var normal_trig := BattleStatusPeriodicTrigger.new()
	normal_trig.timing = BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END
	normal_trig.scale_damage_with_stacks = false
	normal_trig.effects = [normal_dmg]
	normal_status.periodic_triggers = [normal_trig]
	actor.add_status(normal_status)
	actor.add_status(normal_status)
	actor.add_status(normal_status)
	check(actor.get_status(normal_status.status_id).stack_count == 3, "Normal status has 3 stacks.")
	var normal_results := processor.process_owner_timing(screen.session, actor, BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END)
	var normal_dealt: int = normal_results[0].effect_results[0].raw_amount
	check(normal_dealt == 3, "Non-scaling trigger deals unscaled base damage (3) despite 3 stacks.")

	# Expiry and cleanup
	actor.clear_statuses()
	check(debuffs.get_child_count() == 0 and buffs.get_child_count() == 0, "All statuses cleared.")
	check(buffs.size.x >= 12 * 22 + 11 * 1, "12 semantic icons fit authored shelf with 22px and 1px separation.")
	screen.queue_free()
	await process_frame
	print("SEMANTIC STATUS HUD SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
