extends SceneTree
var scene
func _initialize() -> void:
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame

func run() -> void:
	var runtime = root.get_node("CampaignRuntime")
	runtime.start_new_campaign()
	var state = runtime.campaign_state
	for pair in [["trade_yard", "primitive_campfire"], ["residential_yard", "temporary_party_shelter"], ["household_yard", "primitive_common_shelter"], ["workshop_west", "forge_shell"]]:
		var zone = state.home_settlement_state.get_zone(StringName(pair[0]))
		zone.building_id = StringName(pair[1])
		zone.building_level = 1
	state.materials = 100
	scene = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene._show_view(scene.View.LOCAL_LOCATION)
	var local = scene._shell._content_host.get_child(0)
	local._on_interaction_selected(&"home_forge_site")
	assert(local._actions_row.get_child_count() == 1)
	assert(local._actions_row.get_child(0).text == "ОТКРЫТЬ КУЗНИЦУ")
	local._actions_row.get_child(0).pressed.emit()
	await capture("inactive")
	var panel = scene._shell._modal_layer.get_child(0)
	assert(panel is CampaignForgePanel)
	state.get_resident(&"resident_blacksmith_ostap").status = CampaignResidentState.Status.HOME_SETTLEMENT
	panel.refresh()
	await capture("basic")
	panel._retool(&"weapon_equipment", &"", panel._revision)
	await capture("weapon")
	var old_revision = panel._revision
	panel._commission(&"resident_blacksmith_ostap", &"ostap_weapon", old_revision)
	var paid_gold = state.inventory_state.gold
	var item_count = state.inventory_state.items.size()
	panel._commission(&"resident_blacksmith_ostap", &"ostap_weapon", old_revision)
	assert(state.inventory_state.gold == paid_gold and state.inventory_state.items.size() == item_count)
	await capture("order")
	panel._retool(&"armor_equipment", &"weapon_equipment", panel._revision)
	await capture("armor")
	panel.talk_requested.emit(&"debug_home_blacksmith")
	assert(scene._dialogue_panel != null)
	await capture("dialogue")
	scene._on_dialogue_closed(local)
	await capture("return")
	assert(scene._shell._modal_layer.get_child(0) is CampaignForgePanel)
	panel = scene._shell._modal_layer.get_child(0)
	panel.close_requested.emit()
	assert(not scene._shell.has_modal())
	local._on_interaction_selected(&"debug_home_blacksmith")
	var forge_button_found = false
	for child in local._actions_row.get_children():
		assert(not child.text.begins_with("ЗАКАЗАТЬ"))
		if child.text == "ОТКРЫТЬ КУЗНИЦУ":
			forge_button_found = true
			child.pressed.emit()
	assert(forge_button_found and scene._shell._modal_layer.get_child(0) is CampaignForgePanel)
	print("FORGE UI SMOKE GREEN: inactive, basic, weapon, produced item, armor, talk and return.")
	quit()
