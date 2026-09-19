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
	actor.advance_statuses_after_owner_turn()
	actor.advance_statuses_after_owner_turn()
	actor.advance_statuses_after_owner_turn()
	check(debuffs.get_child_count() == 0 and buffs.get_child_count() == 0, "Expiry removes icons without polling.")
	check(hud.get_node("PortraitPanel/Armor/Value").text == str(actor.armor) and hud.get_node("PortraitPanel/StaminaRegen/Value").text == "+%d" % actor.stamina_regeneration, "Expiry resets effective stats.")
	check(buffs.size.x >= 12 * 20 + 11 * 3, "Twelve semantic icons fit authored shelf.")
	screen.queue_free()
	await process_frame
	print("SEMANTIC STATUS HUD SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
