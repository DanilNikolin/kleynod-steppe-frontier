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
	check(not debuffs.get_child(1).get_node("MagnitudeLabel").visible, "Single stack has no count.")
	actor.add_status(bleed)
	check(debuffs.get_child(1).get_node("MagnitudeLabel").visible and debuffs.get_child(1).get_node("MagnitudeLabel").text == "2", "Stack count updates via signal.")
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
	check(not debuffs.get_child(0).get_node("MagnitudeLabel").visible, "Re-added single stack hides number.")
	actor.remove_status(bleed.status_id)
	actor.add_status(bleed)
	check(not debuffs.get_child(0).get_node("MagnitudeLabel").visible, "Re-added single stack hides number.")
	# Test capped status behavior
	actor.add_status(bleed) # stack 2
	actor.add_status(bleed) # stack 3 (cap)
	actor.add_status(bleed) # try stack 4 -> stays 3
	check(actor.get_status(bleed.status_id).stack_count == 3, "Capped status stops at max_stacks (3).")
	check(debuffs.get_child(0).get_node("MagnitudeLabel").text == "3", "Capped status displays 3.")
	actor.remove_status(bleed.status_id)

	# Test unlimited status (max_stacks = 0)
	var unlimited_bleed := load("res://content/statuses/heroes/bayda/bayda_bleeding.tres") as BattleStatusDefinition
	check(unlimited_bleed.max_stacks == 0, "Bayda bleeding has max_stacks == 0 (unlimited).")
	check(unlimited_bleed.reapply_rule == BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH, "Bayda bleeding reapply_rule is ADD_STACK_AND_REFRESH.")
	check(unlimited_bleed.periodic_triggers[0].scale_damage_with_stacks, "Bayda bleeding scales damage with stacks.")

	# Verify normalized base_damage = 1 for all production Bayda Bleeding ranks
	for rank_suffix in ["", "_rank2", "_rank5", "_rank7", "_rank10"]:
		var path := "res://content/statuses/heroes/bayda/bayda_bleeding%s.tres" % rank_suffix
		var res := load(path) as BattleStatusDefinition
		var dmg_effect := res.periodic_triggers[0].effects[0] as DamageEffect
		check(dmg_effect.base_damage == 1, "Bleeding %s base_damage is normalized to 1." % path)
		check(res.periodic_triggers[0].scale_damage_with_stacks, "Bleeding %s scales with stacks." % path)

	# 1 stack
	actor.add_status(unlimited_bleed)
	var player_view: CombatantView = null
	for view in screen.get_node("BattleWorld/CombatantLayer").get_children():
		if view.state == actor:
			player_view = view
			break
	var get_hud_bleed = func() -> BattleStatusIcon: return debuffs.get_child(0) as BattleStatusIcon
	var get_world_bleed = func() -> BattleStatusIcon: return player_view.status_strip.chip_container.get_child(0) as BattleStatusIcon

	check(get_hud_bleed.call().custom_minimum_size == Vector2(30, 30), "HUD status icon rendered at native 30x30.")
	check(get_world_bleed.call().custom_minimum_size == Vector2(20, 20), "World status icon unchanged at 20x20.")
	check(debuffs.get_theme_constant("separation") == 1, "DebuffStrip separation is 1.")
	check(buffs.get_theme_constant("separation") == 1, "BuffStrip separation is 1.")

	check(actor.get_status(unlimited_bleed.status_id).stack_count == 1, "First application stack_count == 1.")
	check(not get_hud_bleed.call().get_node("MagnitudeLabel").visible, "1 stack: HUD MagnitudeLabel is hidden.")
	check(not get_world_bleed.call().get_node("MagnitudeLabel").visible, "1 stack: World MagnitudeLabel is hidden.")
	check(get_hud_bleed.call().get_node("MagnitudeLabel").text == "1", "MagnitudeLabel text holds exact integer.")

	# 2 stacks
	actor.add_status(unlimited_bleed)
	check(actor.get_status(unlimited_bleed.status_id).stack_count == 2, "Second application stack_count == 2.")
	check(get_hud_bleed.call().get_node("MagnitudeLabel").visible and get_hud_bleed.call().get_node("MagnitudeLabel").text == "2", "2 stacks: HUD shows '2'.")
	check(get_world_bleed.call().get_node("MagnitudeLabel").visible and get_world_bleed.call().get_node("MagnitudeLabel").text == "2", "2 stacks: World shows '2'.")

	# Generic stacks_to_apply test:
	# Clear and test applying 2 then 4 via ApplyStatusEffect
	actor.clear_statuses()
	var apply_eff_2 := ApplyStatusEffect.new()
	apply_eff_2.effect_id = &"eff_apply_2"
	apply_eff_2.status_definition = unlimited_bleed
	apply_eff_2.stacks_to_apply = 2
	var resolver := EffectResolver.new()
	var res1 := resolver.resolve(apply_eff_2, actor, actor, screen.session)
	check(res1.is_successful, "ApplyStatusEffect 2 stacks succeeded.")
	check(res1.previous_status_stack_count == 0, "Previous stack count was 0.")
	check(res1.current_status_stack_count == 2, "Current stack count is 2.")
	check(actor.get_status(unlimited_bleed.status_id).stack_count == 2, "Actor has 2 stacks.")
	check(get_hud_bleed.call().get_node("MagnitudeLabel").visible and get_hud_bleed.call().get_node("MagnitudeLabel").text == "2", "HUD shows '2'.")
	check(get_world_bleed.call().get_node("MagnitudeLabel").visible and get_world_bleed.call().get_node("MagnitudeLabel").text == "2", "World shows '2'.")

	# Now apply 4 more stacks -> 6
	var apply_eff_4 := ApplyStatusEffect.new()
	apply_eff_4.effect_id = &"eff_apply_4"
	apply_eff_4.status_definition = unlimited_bleed
	apply_eff_4.stacks_to_apply = 4
	var res2 := resolver.resolve(apply_eff_4, actor, actor, screen.session)
	check(res2.is_successful, "ApplyStatusEffect 4 stacks succeeded.")
	check(res2.previous_status_stack_count == 2, "Previous stack count was 2.")
	check(res2.current_status_stack_count == 6, "Current stack count is 6.")
	check(actor.get_status(unlimited_bleed.status_id).stack_count == 6, "Actor has 6 stacks.")
	check(get_hud_bleed.call().get_node("MagnitudeLabel").visible and get_hud_bleed.call().get_node("MagnitudeLabel").text == "6", "HUD shows '6'.")
	check(get_world_bleed.call().get_node("MagnitudeLabel").visible and get_world_bleed.call().get_node("MagnitudeLabel").text == "6", "World shows '6'.")

	# Check periodic damage for 6 stacks == 6
	var processor := BattleStatusPeriodicProcessor.new()
	var trig_6 := processor.process_owner_timing(screen.session, actor, BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END)
	check(trig_6.size() == 1 and trig_6[0].effect_results.size() == 1, "One aggregated tick produced for 6 stacks.")
	check(trig_6[0].effect_results[0].raw_amount == 6, "6 stacks produce exactly 6 raw periodic damage (%d == 6)." % trig_6[0].effect_results[0].raw_amount)

	# Apply up to 50 stacks
	var apply_eff_44 := ApplyStatusEffect.new()
	apply_eff_44.effect_id = &"eff_apply_44"
	apply_eff_44.status_definition = unlimited_bleed
	apply_eff_44.stacks_to_apply = 44
	var res50 := resolver.resolve(apply_eff_44, actor, actor, screen.session)
	check(res50.current_status_stack_count == 50, "Current stack count reached 50.")
	check(get_hud_bleed.call().get_node("MagnitudeLabel").visible and get_hud_bleed.call().get_node("MagnitudeLabel").text == "50", "50 stacks: HUD shows '50'.")
	check(get_world_bleed.call().get_node("MagnitudeLabel").visible and get_world_bleed.call().get_node("MagnitudeLabel").text == "50", "50 stacks: World shows '50'.")
	check(not ("·" in get_hud_bleed.call().get_node("MagnitudeLabel").text or "/" in get_hud_bleed.call().get_node("MagnitudeLabel").text or "t" in get_hud_bleed.call().get_node("MagnitudeLabel").text), "MagnitudeLabel never displays remaining_turns.")

	# Periodic damage for 50 stacks == 50
	var trig_50 := processor.process_owner_timing(screen.session, actor, BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END)
	check(trig_50.size() == 1 and trig_50[0].effect_results.size() == 1, "Exactly one aggregated periodic result for 50 stacks.")
	check(trig_50[0].effect_results[0].raw_amount == 50, "50 stacks produce exactly 50 raw periodic damage (%d == 50)." % trig_50[0].effect_results[0].raw_amount)

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
	actor.add_status(normal_status, &"", 3)
	check(actor.get_status(normal_status.status_id).stack_count == 3, "Normal status has 3 stacks.")
	var normal_results := processor.process_owner_timing(screen.session, actor, BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END)
	var normal_dealt: int = normal_results[0].effect_results[0].raw_amount
	check(normal_dealt == 3, "Non-scaling trigger deals unscaled base damage (3) despite 3 stacks.")

	# Steppe Raider / Debug Rending Cut and Bleeding test
	actor.current_health = actor.max_health
	actor.clear_statuses()
	var rending_cut: AbilityDefinition = load("res://content/abilities/debug/debug_rending_cut.tres")
	var rending_bleed_res: BattleStatusDefinition = load("res://content/statuses/debug/debug_bleeding.tres")
	check(rending_cut != null and rending_bleed_res != null, "Debug rending cut and bleeding loaded.")
	check(rending_bleed_res.max_stacks == 0, "debug_bleeding has unlimited max_stacks (0).")
	check(rending_bleed_res.reapply_rule == BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH, "debug_bleeding reapply_rule is ADD_STACK_AND_REFRESH.")
	check(rending_bleed_res.periodic_triggers[0].scale_damage_with_stacks, "debug_bleeding scales damage with stacks.")
	check((rending_bleed_res.periodic_triggers[0].effects[0] as DamageEffect).base_damage == 1, "debug_bleeding base_damage is 1.")

	# First application of Rending Cut effects
	var apply_status_eff: ApplyStatusEffect = null
	for eff in rending_cut.effects:
		if eff is ApplyStatusEffect:
			apply_status_eff = eff
			break
	check(apply_status_eff != null and apply_status_eff.stacks_to_apply == 2, "Rending cut applies 2 stacks.")
	var r1 := resolver.resolve(apply_status_eff, actor, actor, screen.session)
	check(r1.is_successful, "First application succeeded.")
	var st_inst := actor.get_status(rending_bleed_res.status_id)
	check(st_inst != null and st_inst.stack_count == 2, "First application gives stack_count == 2.")
	check(st_inst.remaining_turns == 2, "Remaining turns is 2.")
	check(get_hud_bleed.call().get_node("MagnitudeLabel").visible and get_hud_bleed.call().get_node("MagnitudeLabel").text == "2", "HUD label is '2'.")
	check(get_world_bleed.call().get_node("MagnitudeLabel").visible and get_world_bleed.call().get_node("MagnitudeLabel").text == "2", "World label is '2'.")

	# 1st periodic tick: 2 stacks = 2 damage
	var tick_1 := processor.process_owner_timing(screen.session, actor, BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END)
	check(tick_1.size() == 1 and tick_1[0].effect_results.size() == 1, "Only one aggregated periodic result for 2 stacks.")
	check(tick_1[0].effect_results[0].raw_amount == 2, "2 stacks deal exactly 2 damage (%d == 2)." % tick_1[0].effect_results[0].raw_amount)

	# Simulate turn pass decrementing remaining_turns
	st_inst.remaining_turns = 1

	# Second application of Rending Cut
	var r2 := resolver.resolve(apply_status_eff, actor, actor, screen.session)
	check(r2.is_successful, "Second application succeeded.")
	check(st_inst.stack_count == 4, "Second application gives stack_count == 4.")
	check(st_inst.remaining_turns == 2, "Duration refreshed back to 2.")
	check(get_hud_bleed.call().get_node("MagnitudeLabel").visible and get_hud_bleed.call().get_node("MagnitudeLabel").text == "4", "HUD label updated to '4'.")
	check(get_world_bleed.call().get_node("MagnitudeLabel").visible and get_world_bleed.call().get_node("MagnitudeLabel").text == "4", "World label updated to '4'.")

	# 2nd periodic tick: 4 stacks = 4 damage
	var tick_2 := processor.process_owner_timing(screen.session, actor, BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END)
	check(tick_2.size() == 1 and tick_2[0].effect_results.size() == 1, "Only one aggregated periodic result for 4 stacks.")
	check(tick_2[0].effect_results[0].raw_amount == 4, "4 stacks deal exactly 4 damage (%d == 4)." % tick_2[0].effect_results[0].raw_amount)

	# ==========================================================
	# Comprehensive Semantic Magnitude Badges Test Suite
	# ==========================================================
	actor.clear_statuses()

	# 1. Armor Down: -2 with 1 stack -> magnitude 2
	var armor_down_2 := definition(&"armor_down_2", [&"armor_debuff"])
	armor_down_2.stat_modifiers = [modifier(BattleStatModifier.Stat.ARMOR, -2)]
	actor.add_status(armor_down_2)
	var hud_ad = func() -> BattleStatusIcon: return debuffs.get_child(0) as BattleStatusIcon
	var world_ad = func() -> BattleStatusIcon: return player_view.status_strip.chip_container.get_child(0) as BattleStatusIcon
	check(hud_ad.call().get_node("MagnitudeLabel").visible and hud_ad.call().get_node("MagnitudeLabel").text == "2", "Armor Down -2 with 1 stack shows badge '2' in HUD.")
	check(world_ad.call().get_node("MagnitudeLabel").visible and world_ad.call().get_node("MagnitudeLabel").text == "2", "Armor Down -2 with 1 stack shows badge '2' in World.")

	# Armor Down: -2 with 3 stacks -> magnitude 6
	armor_down_2.max_stacks = 3
	armor_down_2.reapply_rule = BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH
	actor.add_status(armor_down_2) # 2 stacks -> -4
	actor.add_status(armor_down_2) # 3 stacks -> -6
	check(actor.get_status(armor_down_2.status_id).stack_count == 3, "Armor Down has 3 stacks.")
	check(hud_ad.call().get_node("MagnitudeLabel").visible and hud_ad.call().get_node("MagnitudeLabel").text == "6", "Armor Down -2 with 3 stacks shows badge '6' in HUD (not '3').")
	check(world_ad.call().get_node("MagnitudeLabel").visible and world_ad.call().get_node("MagnitudeLabel").text == "6", "Armor Down -2 with 3 stacks shows badge '6' in World.")

	# Armor Down: -1 with 1 stack -> magnitude 1 -> badge hidden
	actor.clear_statuses()
	var armor_down_1 := definition(&"armor_down_1", [&"armor_debuff"])
	armor_down_1.stat_modifiers = [modifier(BattleStatModifier.Stat.ARMOR, -1)]
	actor.add_status(armor_down_1)
	check(not hud_ad.call().get_node("MagnitudeLabel").visible, "Armor Down -1 with 1 stack hides badge.")

	# 2. Armor Up: +3 with 1 stack -> magnitude 3
	actor.clear_statuses()
	var armor_up_3 := definition(&"armor_up_3", [&"armor_buff"], 1)
	armor_up_3.stat_modifiers = [modifier(BattleStatModifier.Stat.ARMOR, 3)]
	actor.add_status(armor_up_3)
	var hud_au = func() -> BattleStatusIcon: return buffs.get_child(0) as BattleStatusIcon
	var world_au = func() -> BattleStatusIcon: return player_view.status_strip.chip_container.get_child(0) as BattleStatusIcon
	check(hud_au.call().get_node("MagnitudeLabel").visible and hud_au.call().get_node("MagnitudeLabel").text == "3", "Armor Up +3 shows badge '3' in HUD.")
	check(world_au.call().get_node("MagnitudeLabel").visible and world_au.call().get_node("MagnitudeLabel").text == "3", "Armor Up +3 shows badge '3' in World.")

	# 3. Stamina Regen Up: +2 with 1 stack -> magnitude 2, +2 with 3 stacks -> magnitude 6
	actor.clear_statuses()
	var s_regen := definition(&"s_regen", [&"stamina_regeneration_buff"], 1)
	s_regen.stat_modifiers = [modifier(BattleStatModifier.Stat.STAMINA_REGENERATION, 2)]
	s_regen.max_stacks = 3
	s_regen.reapply_rule = BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH
	actor.add_status(s_regen)
	var hud_sr = func() -> BattleStatusIcon: return buffs.get_child(0) as BattleStatusIcon
	check(hud_sr.call().get_node("MagnitudeLabel").visible and hud_sr.call().get_node("MagnitudeLabel").text == "2", "Stamina Regen Up +2 shows badge '2'.")
	actor.add_status(s_regen)
	actor.add_status(s_regen)
	check(hud_sr.call().get_node("MagnitudeLabel").visible and hud_sr.call().get_node("MagnitudeLabel").text == "6", "Stamina Regen Up +2 with 3 stacks shows badge '6'.")

	# 4. Composite status: "На крюке" (immobilized + armor_debuff -2)
	actor.clear_statuses()
	var hooked := load("res://content/statuses/heroes/bayda/bayda_gallows_hooked_exposed.tres") as BattleStatusDefinition
	check(hooked != null, "bayda_gallows_hooked_exposed loaded.")
	actor.add_status(hooked)
	check(debuffs.get_child_count() == 2, "Hooked produces 2 entries (immobilized, armor_down).")
	var hook_immob := debuffs.get_child(0) as BattleStatusIcon
	var hook_armordown := debuffs.get_child(1) as BattleStatusIcon
	check(hook_immob.semantic == "immobilized" and not hook_immob.get_node("MagnitudeLabel").visible, "Hooked immobilized has magnitude 0 and no badge.")
	check(hook_armordown.semantic == "armor_down" and hook_armordown.get_node("MagnitudeLabel").visible and hook_armordown.get_node("MagnitudeLabel").text == "2", "Hooked armor_down has magnitude 2 and shows '2'.")

	# 5. Binary non-numeric semantics: stun, immobilized, counterattack -> magnitude 0
	actor.clear_statuses()
	actor.add_status(definition(&"test_stun", [&"stun"]))
	actor.add_status(definition(&"test_immob", [&"immobilized"]))
	actor.add_status(definition(&"test_counter", [&"counterattack"], 1))
	check(not (debuffs.get_child(0) as BattleStatusIcon).get_node("MagnitudeLabel").visible, "Stun has no badge.")
	check(not (debuffs.get_child(1) as BattleStatusIcon).get_node("MagnitudeLabel").visible, "Immobilized has no badge.")
	check(not (buffs.get_child(0) as BattleStatusIcon).get_node("MagnitudeLabel").visible, "Counterattack has no badge.")

	# 6. Reactive semantics: reactive_guard, reactive_stamina -> magnitude 0
	actor.clear_statuses()
	var do_not_bend := load("res://content/statuses/heroes/bayda/bayda_do_not_bend_stance_rank1.tres") as BattleStatusDefinition
	var hit_me_more := load("res://content/statuses/heroes/bayda/bayda_hit_me_more_stance.tres") as BattleStatusDefinition
	actor.add_status(do_not_bend)
	actor.add_status(hit_me_more)
	check(buffs.get_child_count() == 2, "Both reactive buffs present.")
	for i in range(2):
		var b_icon := buffs.get_child(i) as BattleStatusIcon
		check(not b_icon.get_node("MagnitudeLabel").visible, "Reactive status %s has no magnitude badge." % b_icon.semantic)

	# 7. Unrelated statuses with same semantic are NOT merged
	actor.clear_statuses()
	var debuff_a := definition(&"debuff_a", [&"armor_debuff"])
	debuff_a.stat_modifiers = [modifier(BattleStatModifier.Stat.ARMOR, -2)]
	var debuff_b := definition(&"debuff_b", [&"armor_debuff"])
	debuff_b.stat_modifiers = [modifier(BattleStatModifier.Stat.ARMOR, -4)]
	actor.add_status(debuff_a)
	actor.add_status(debuff_b)
	check(debuffs.get_child_count() == 2, "Unrelated statuses sharing semantic icon are NOT merged.")
	check((debuffs.get_child(0) as BattleStatusIcon).get_node("MagnitudeLabel").text == "2", "First status magnitude is 2.")
	check((debuffs.get_child(1) as BattleStatusIcon).get_node("MagnitudeLabel").text == "4", "Second status magnitude is 4.")

	# Expiry and cleanup
	actor.clear_statuses()
	check(debuffs.get_child_count() == 0 and buffs.get_child_count() == 0, "All statuses cleared.")
	check(buffs.size.x >= 9 * 30 + 8 * 1, "Exactly 9 native 30px icons fit authored 278px shelf.")
	screen.queue_free()
	await process_frame
	print("SEMANTIC STATUS HUD SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)

