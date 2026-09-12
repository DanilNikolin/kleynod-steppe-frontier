extends SceneTree
var failures: int = 0
var runtime: CampaignRuntimeService
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	runtime = CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Campaign definition valid")
	if runtime.campaign_state == null:
		runtime.free()
		quit(1)
		return
	var state := runtime.campaign_state
	var campaign := runtime.campaign_definition
	var inventory := state.inventory_state
	check(runtime.construct_home_settlement_building(&"trade_yard", &"primitive_campfire"), "Campfire unlocks grove")
	check(runtime.advance_time(120), "Campfire finishes")
	state.current_world_node_id = &"debug_home_materials_node"
	var before_count := inventory.items.size()
	check(runtime.explore_adventure_site(&"debug_home_outskirts_materials_area", &"starter_materials_cache"), "Starter pickup")
	check(state.materials == 0 and inventory.get_carried_materials() == 8 and inventory.items.size() == before_count + 2, "Eight materials are two physical items, not HOME stockpile")
	var cargo: HeroEquipmentItemInstance = inventory.items.back()
	check(HeroEquipmentService.new().get_compatible_slots(cargo).is_empty(), "Cargo cannot be equipped to evade capacity")
	check(not cargo.definition.is_trade_enabled(), "Bundles cannot enter equipment trade")
	check(not runtime.unload_materials().is_empty(), "Cannot unload outside HOME")
	var area := runtime.get_adventure_area_definition(&"debug_home_outskirts_materials_area")
	var area_state := runtime.get_adventure_area_state(area.area_id)
	check(not runtime.adventure_service.get_landmark_exploration_error(state, area, area_state, &"starter_materials_cache").is_empty(), "One time pickup")
	var normal_capacity := inventory.slot_capacity
	inventory.slot_capacity = inventory.items.size()
	check(not runtime.adventure_service.get_landmark_exploration_error(state, area, area_state, &"construction_timber").is_empty(), "Full bag rejects next reward")
	check(area_state.get_site(&"construction_timber").is_available(), "Full bag preserves reward")
	var trader := campaign.traders[0]
	state.current_world_node_id = trader.world_node_id
	var trader_state := state.get_trader(trader.trader_id)
	check(not runtime.trading_service.get_buy_error(state, trader, trader_state, trader_state.items[0].instance_id, campaign.home_settlement_definition).is_empty(), "Equipment competes for same slots")
	# A full bag must not block battle completion or grant over-capacity loot.
	var roll := BattleLootRewardRoll.new()
	roll.dropped_item_definitions.append(trader_state.items[0].definition)
	var battle := CampaignBattleResult.new()
	check(CampaignLootRewardApplicationService.new().apply_reward(battle, roll, inventory, true), "Full bag permits battle reward resolution")
	check(battle.loot_item_instance_ids.is_empty() and battle.left_behind_item_names.size() == 1, "Excess battle item left behind explicitly")
	inventory.slot_capacity = normal_capacity
	state.current_world_node_id = &"debug_home"
	check(not runtime.get_home_settlement_construction_error(&"residential_yard", &"temporary_party_shelter").is_empty(), "Cargo cannot fund construction")
	var path := "user://logistics_smoke_%d.json" % Time.get_ticks_usec()
	var saves := CampaignSaveService.new(path)
	check(saves.save_campaign(state).is_successful, "Save cargo")
	var loaded := saves.load_campaign(campaign)
	check(loaded.is_successful, "Load cargo: " + loaded.message)
	if loaded.is_successful:
		runtime.campaign_state = loaded.campaign_state
		state = runtime.campaign_state
		inventory = state.inventory_state
	check(inventory.get_carried_materials() == 8 and state.materials == 0, "Cargo preserved separately")
	check(runtime.unload_materials().is_empty(), "Unload before C2")
	check(inventory.get_carried_materials() == 0 and state.materials == 8, "Unload exact conversion")
	check(not runtime.unload_materials().is_empty() and state.materials == 8, "No duplicate unload")
	check(runtime.construct_home_settlement_building(&"residential_yard", &"temporary_party_shelter"), "B1 costs five")
	check(runtime.construct_home_settlement_building(&"household_yard", &"primitive_common_shelter"), "C1 costs three")
	check(runtime.advance_time(120), "B1 and C1 finish")
	check(state.materials == 0, "Starter eight exactly enough")
	check(not runtime.get_supply_order_error(&"village_materials", &"small").is_empty(), "C2 capability gate")
	state.home_settlement_state.get_zone(&"household_yard").building_level = 2
	check(runtime.has_active_home_settlement_effect(&"material_supply_access"), "C2 fixture")
	check(not runtime.get_supply_order_error(&"village_materials", &"small").is_empty(), "No relationship")
	state.current_world_node_id = &"debug_village"
	var dialogue := CampaignDialogueSession.new()
	check(dialogue.begin(runtime, &"debug_village_innkeeper"), "Real innkeeper conversation")
	check(dialogue.choose(&"supply_contact", dialogue.revision).is_empty(), "Authored supplier agreement")
	check(state.supplier_relationship_ids.has(&"village_materials"), "Relationship established")
	dialogue.close()
	state.current_world_node_id = &"debug_home"
	var supplier := campaign.get_supplier(&"village_materials")
	var offer := supplier.get_package(&"small")
	state.reputation = -1
	check(not runtime.get_supply_order_error(supplier.supplier_id, offer.package_id).is_empty(), "Reputation access")
	state.reputation = 0
	var base := runtime.supply_service.price(campaign, state, supplier, offer)
	state.reputation = 10
	var good := runtime.supply_service.price(campaign, state, supplier, offer)
	state.reputation = 20
	var excellent := runtime.supply_service.price(campaign, state, supplier, offer)
	state.reputation = 999
	check(base == 30 and good == 27 and excellent == 24 and runtime.supply_service.price(campaign, state, supplier, offer) == excellent, "Existing rep tiers, capped discount")
	var gold := inventory.gold
	inventory.gold = 0
	check(not runtime.order_material_supply(supplier.supplier_id, offer.package_id).is_empty(), "No money no delivery")
	inventory.gold = gold
	check(runtime.order_material_supply(supplier.supplier_id, offer.package_id, excellent).is_empty(), "Order shipment")
	check(inventory.gold == gold - excellent and state.materials == 0, "Paid once and no immediate materials")
	check(not runtime.order_material_supply(supplier.supplier_id, offer.package_id).is_empty() and inventory.gold == gold - excellent, "One active delivery per supplier")
	check(saves.save_campaign(state).is_successful, "Save active shipment")
	var valid_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	for mutation in ["old_version", "duplicate", "wrong_amount", "unpaid", "unknown_package", "missing_relationships", "capacity"]:
		var invalid := valid_data.duplicate(true)
		match mutation:
			"old_version": invalid.format_version = 13
			"duplicate": invalid.active_deliveries.append(invalid.active_deliveries[0].duplicate())
			"wrong_amount": invalid.active_deliveries[0].amount += 1
			"unpaid": invalid.active_deliveries[0].paid_gold = 0
			"unknown_package": invalid.active_deliveries[0].package_id = "unknown"
			"missing_relationships": invalid.erase("supplier_relationship_ids")
			"capacity": invalid.inventory.slot_capacity = 0
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(invalid))
		file.close()
		check(not saves.load_campaign(campaign).is_successful, "Reject invalid save: " + mutation)
	check(saves.save_campaign(state).is_successful, "Restore valid active save")
	loaded = saves.load_campaign(campaign)
	check(loaded.is_successful, "Load active shipment: " + loaded.message)
	if loaded.is_successful:
		runtime.campaign_state = loaded.campaign_state
		state = runtime.campaign_state
		inventory = state.inventory_state
	state.current_world_node_id = &"debug_village"
	check(runtime.advance_time(1439) and state.materials == 0, "Before arrival no credit")
	check(runtime.advance_time(1) and state.materials == 5 and state.active_deliveries.is_empty(), "Delivery at exact time while away")
	check(runtime.advance_time(0) and state.materials == 5, "No repeated credit")
	check(saves.save_campaign(state).is_successful, "Save completed shipment")
	loaded = saves.load_campaign(campaign)
	check(loaded.is_successful and loaded.campaign_state.materials == 5 and loaded.campaign_state.active_deliveries.is_empty(), "Completed state survives")
	# Fixture-only second supplier proves no global delivery lock.
	state.current_world_node_id = &"debug_home"
	var second := supplier.duplicate(true) as CampaignSupplierDefinition
	second.supplier_id = &"test_second_supplier"
	campaign.suppliers.append(second)
	state.supplier_relationship_ids.append(second.supplier_id)
	check(runtime.order_material_supply(supplier.supplier_id, offer.package_id).is_empty(), "Next delivery allowed after arrival")
	check(runtime.order_material_supply(second.supplier_id, offer.package_id).is_empty(), "Different supplier concurrent delivery")
	check(state.active_deliveries.size() == 2, "Two independent deliveries")
	check(runtime.advance_time(1440) and state.materials == 15, "Both delivered once")
	state.supplier_relationship_ids.erase(second.supplier_id)
	campaign.suppliers.erase(second)
	check(not campaign.home_settlement_definition.get_building(&"primitive_common_shelter").upgrades[0].upgrade_enabled, "C2 agreement not opened")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	runtime.free()
	if failures == 0:
		print("LOGISTICS GREEN: cargo/capacity/unload/early loop, relationship, reputation/access/prices, payment, timed and concurrent deliveries, save/load, duplicate safety.")
	quit(0 if failures == 0 else 1)

