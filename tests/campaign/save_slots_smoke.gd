extends SceneTree

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
	else:
		print("OK: ", message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var runtime := CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Start campaign")

	# Clean up any leftover slot files from previous runs
	for i in range(1, CampaignSaveService.SLOT_COUNT + 1):
		var p := CampaignSaveService.get_slot_save_path(i)
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

	# 1. State A (Initial state)
	var state_a_day := runtime.campaign_state.current_day
	var state_a_gold := runtime.campaign_state.inventory_state.gold
	runtime.campaign_state.inventory_state.gold = 555
	state_a_gold = 555

	var save_slot_1_res: CampaignSaveResult = runtime.save_campaign_to_slot(1)
	check(save_slot_1_res.is_successful, "Save to slot 1 successful")
	check(FileAccess.file_exists(CampaignSaveService.get_slot_save_path(1)), "Slot 1 file exists")

	# 2. State B (Advanced time & modified gold)
	check(runtime.advance_time(180), "Advance time by 180 min")
	runtime.campaign_state.inventory_state.gold = 999
	var state_b_day := runtime.campaign_state.current_day
	var state_b_gold := runtime.campaign_state.inventory_state.gold
	var state_b_minute := runtime.campaign_state.current_minute_of_day

	var save_slot_2_res: CampaignSaveResult = runtime.save_campaign_to_slot(2)
	check(save_slot_2_res.is_successful, "Save to slot 2 successful")
	check(FileAccess.file_exists(CampaignSaveService.get_slot_save_path(2)), "Slot 2 file exists")

	# 3. Verify slot info metadata
	var slot_infos := runtime.get_save_slot_infos()
	check(slot_infos.size() == 5, "Slot count is 5")

	var info1: Dictionary = slot_infos[0]
	check(info1.get("slot_index") == 1, "Slot 1 index is 1")
	check(info1.get("exists") == true, "Slot 1 exists is true")
	check(info1.get("valid") == true, "Slot 1 valid is true")
	check(info1.get("day") == state_a_day, "Slot 1 day matches state A")

	var info2: Dictionary = slot_infos[1]
	check(info2.get("slot_index") == 2, "Slot 2 index is 2")
	check(info2.get("exists") == true, "Slot 2 exists is true")
	check(info2.get("valid") == true, "Slot 2 valid is true")
	check(info2.get("minute_of_day") == state_b_minute, "Slot 2 minute matches state B")

	var info3: Dictionary = slot_infos[2]
	check(info3.get("exists") == false, "Slot 3 exists is false")

	# 4. Load Slot 1 -> verify State A
	var load_slot_1_res: CampaignSaveResult = runtime.load_campaign_from_slot(1)
	check(load_slot_1_res.is_successful, "Load from slot 1 successful")
	check(runtime.campaign_state.inventory_state.gold == state_a_gold, "State A gold restored from slot 1")
	check(runtime.campaign_state.current_day == state_a_day, "State A day restored from slot 1")

	# 5. Load Slot 2 -> verify State B
	var load_slot_2_res: CampaignSaveResult = runtime.load_campaign_from_slot(2)
	check(load_slot_2_res.is_successful, "Load from slot 2 successful")
	check(runtime.campaign_state.inventory_state.gold == state_b_gold, "State B gold restored from slot 2")
	check(runtime.campaign_state.current_minute_of_day == state_b_minute, "State B minute restored from slot 2")

	# 6. Overwrite Slot 1 with new state C
	runtime.campaign_state.inventory_state.gold = 12345
	var save_slot_1_overwrite: CampaignSaveResult = runtime.save_campaign_to_slot(1)
	check(save_slot_1_overwrite.is_successful, "Overwrite slot 1 successful")

	# Verify Slot 2 remains untouched
	var load_slot_2_again: CampaignSaveResult = runtime.load_campaign_from_slot(2)
	check(load_slot_2_again.is_successful, "Load slot 2 again successful")
	check(runtime.campaign_state.inventory_state.gold == state_b_gold, "Slot 2 gold still matches state B")

	# 7. Loading empty slot 5 should fail gracefully
	var load_empty_slot: CampaignSaveResult = runtime.load_campaign_from_slot(5)
	check(not load_empty_slot.is_successful, "Loading empty slot 5 returns unsuccessful")
	check(load_empty_slot.status_code == CampaignSaveService.STATUS_NO_SAVE, "Empty slot status is STATUS_NO_SAVE")

	# 8. Boundary conditions: invalid slot indices (0, 6)
	check(not runtime.is_valid_save_slot_index(0), "Slot 0 is invalid")
	check(not runtime.is_valid_save_slot_index(6), "Slot 6 is invalid")
	var save_invalid: CampaignSaveResult = runtime.save_campaign_to_slot(0)
	check(not save_invalid.is_successful, "Saving slot 0 fails")
	var load_invalid: CampaignSaveResult = runtime.load_campaign_from_slot(6)
	check(not load_invalid.is_successful, "Loading slot 6 fails")

	# 9. Legacy save/load compatibility
	var legacy_save: CampaignSaveResult = runtime.save_campaign()
	check(legacy_save.is_successful, "Legacy save_campaign works")
	check(FileAccess.file_exists("user://campaign_save.json"), "Legacy user://campaign_save.json exists")
	var legacy_load: CampaignSaveResult = runtime.load_campaign()
	check(legacy_load.is_successful, "Legacy load_campaign works")

	# Clean up files created during test
	for i in range(1, CampaignSaveService.SLOT_COUNT + 1):
		var path := CampaignSaveService.get_slot_save_path(i)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)

	runtime.free()

	if failures == 0:
		print("SMOKE GREEN: campaign save slots 1..5, metadata, isolation, legacy compatibility passed.")
		quit(0)
	else:
		print("SMOKE FAILED: %d errors" % failures)
		quit(1)
