extends SceneTree
var failures: int = 0
var runtime: CampaignRuntimeService
func check(ok: bool, text: String) -> void:
	if not ok:
		failures += 1
		push_error(text)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	runtime = CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Valid new campaign")
	if runtime.campaign_state == null:
		runtime.free()
		quit(1)
		return
	var state := runtime.campaign_state
	var campaign := runtime.campaign_definition
	var forge := runtime.forge_service
	var settlement := state.home_settlement_state
	state.materials = 100
	check(not forge.operational_error(campaign, state).is_empty(), "No shell")
	var zone := settlement.get_zone(&"workshop_west")
	zone.building_id = &"forge_shell"
	zone.building_level = 1
	check(forge.operational_error(campaign, state).contains("кузнец"), "Shell without smith inactive")
	check(not runtime.retool_forge(&"weapon_equipment", &"").is_empty(), "No smith cannot equip")
	var smith := state.get_resident(&"resident_blacksmith_ostap")
	smith.status = CampaignResidentState.Status.HOME_SETTLEMENT
	check(forge.operational_error(campaign, state).is_empty(), "Ostap activates shell")
	check(runtime.get_home_resident_commission_error(smith.resident_id, &"ostap_forged_sabre").is_empty(), "Basic available without module")
	check(runtime.get_home_resident_commission_error(smith.resident_id, &"ostap_weapon").contains("Оружейная"), "Weapon reason")
	check(CampaignForgeService.MAJOR_SLOT_COUNT == 1, "One slot")
	var save_path := "user://forge_smoke_%s.json" % Time.get_ticks_usec()
	var saves := CampaignSaveService.new(save_path)
	for module: StringName in [&"", &"weapon_equipment", &"armor_equipment", &"weapon_equipment"]:
		if module != &"":
			var old := settlement.forge_major_module_id
			var gold := state.inventory_state.gold
			var materials := state.materials
			var time := state.current_day * 1440 + state.current_minute_of_day
			check(runtime.retool_forge(module, old).is_empty(), "Retool " + String(module))
			check(state.inventory_state.gold == gold - 20 and state.materials == materials - 4, "Charge once")
			check(state.current_day * 1440 + state.current_minute_of_day == time + 240, "Advance four hours")
			check(not runtime.retool_forge(module, old).is_empty(), "Stale request rejected")
			check(state.inventory_state.gold == gold - 20 and state.materials == materials - 4, "No duplicate payment")
		check(saves.save_campaign(state).is_successful, "Save module " + String(module))
		var loaded := saves.load_campaign(campaign)
		check(loaded.is_successful, "Load: " + loaded.message)
		if loaded.is_successful:
			runtime.campaign_state = loaded.campaign_state
			state = runtime.campaign_state
			settlement = state.home_settlement_state
		check(settlement.forge_major_module_id == module, "Module survives")
		check(runtime.get_home_resident_commission_error(smith.resident_id, &"ostap_forged_sabre").is_empty(), "Basic survives")
		check(runtime.get_home_resident_commission_error(smith.resident_id, &"ostap_weapon").is_empty() == (module == &"weapon_equipment"), "Weapon filter after load")
		check(runtime.get_home_resident_commission_error(smith.resident_id, &"ostap_armor").is_empty() == (module == &"armor_equipment"), "Armor filter after load")
		if module != &"":
			check(runtime.commission_home_resident_item(smith.resident_id, &"ostap_weapon" if module == &"weapon_equipment" else &"ostap_armor") != null, "Produce specialized item")
	check(runtime.commission_home_resident_item(smith.resident_id, &"ostap_forged_sabre") != null, "Produce basic commission")
	var owner := campaign.get_resident(smith.resident_id)
	var original_id := owner.resident_id
	owner.resident_id = &"test_other_master"
	state.get_resident(original_id).resident_id = owner.resident_id
	check(forge.get_master(campaign, state) == owner, "Master selection has no Ostap ID dependency")
	var personal_catalog := owner.equipment_commissions.duplicate()
	owner.equipment_commissions.clear()
	check(not runtime.get_home_resident_commission_error(owner.resident_id, &"ostap_weapon").is_empty(), "Module cannot grant absent personal recipe")
	owner.equipment_commissions.assign(personal_catalog)
	state.get_resident(owner.resident_id).resident_id = original_id
	owner.resident_id = original_id
	settlement.forge_major_module_id = &"invalid_module"
	check(not settlement.is_valid_against_definition(campaign.home_settlement_definition), "Unknown module invalid")
	settlement.forge_major_module_id = &"weapon_equipment"
	var current_zone := settlement.get_zone(&"workshop_west")
	current_zone.building_id = &""
	current_zone.building_level = 0
	check(not settlement.is_valid_against_definition(campaign.home_settlement_definition), "Module without building invalid")
	current_zone.building_id = &"forge_shell"
	current_zone.building_level = 1
	var gold := state.inventory_state.gold
	state.materials = 0
	check(not runtime.retool_forge(&"armor_equipment", &"weapon_equipment").is_empty(), "Insufficient materials")
	check(state.inventory_state.gold == gold, "Rejected action free")
	state.materials = 100
	runtime._equipment_work_active = true
	check(not runtime.get_forge_retool_error(&"armor_equipment", &"weapon_equipment").is_empty(), "Busy work blocks retool")
	check(runtime.commission_home_resident_item(smith.resident_id, &"ostap_forged_sabre") == null, "Busy work blocks commission")
	runtime._equipment_work_active = false
	var old_day := state.current_day
	state.current_day = CampaignTimeService.MAX_CAMPAIGN_DAY
	state.current_minute_of_day = 1439
	check(not runtime.retool_forge(&"armor_equipment", &"weapon_equipment").is_empty(), "Calendar overflow rejected")
	check(state.inventory_state.gold == gold and settlement.forge_major_module_id == &"weapon_equipment", "Overflow unchanged")
	state.current_day = old_day
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	var valid_data := data.duplicate(true)
	data["home_settlement"]["forge_major_module_id"] = "invalid_module"
	var invalid_file := FileAccess.open(save_path, FileAccess.WRITE)
	invalid_file.store_string(JSON.stringify(data))
	invalid_file.close()
	check(not saves.load_campaign(campaign).is_successful, "Unknown saved module rejected")
	data = valid_data.duplicate(true)
	data["home_settlement"].erase("forge_major_module_id")
	invalid_file = FileAccess.open(save_path, FileAccess.WRITE)
	invalid_file.store_string(JSON.stringify(data))
	invalid_file.close()
	check(not saves.load_campaign(campaign).is_successful, "Missing saved module field rejected")
	data = valid_data
	data["format_version"] = 12
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	check(not saves.load_campaign(campaign).is_successful, "Old save rejected")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	runtime.free()
	if failures == 0:
		print("FORGE GREEN: shell/master, one slot, basic and specialized orders, bidirectional retool, exact costs/time, stale/busy/overflow guards, save/load.")
	quit(0 if failures == 0 else 1)
