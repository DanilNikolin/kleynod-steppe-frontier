extends SceneTree

var failures: int = 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var runtime = root.get_node("CampaignRuntime")
	runtime.start_new_campaign()
	var state = runtime.campaign_state
	var hero = state.get_selected_hero()
	var progression = hero.progression_state
	progression.unspent_skill_points = 20
	var grid_definition = hero.hero_definition.skill_grid
	var attachments = SkillGridBlockAttachmentService.new()
	attachments.attach(grid_definition, progression, attachments.get_attachment_candidates(grid_definition, progression)[0].block_id)
	var purchases = SkillGridPurchaseService.new()
	for node in grid_definition.nodes:
		if purchases.can_purchase(grid_definition, progression, node.node_id):
			purchases.purchase(grid_definition, progression, node.node_id)
	var sandbox = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(sandbox)
	for destination in [&"debug_home", &"debug_village", &"debug_city"]:
		state.current_world_node_id = destination
		for local in [false, true]:
			sandbox._view_stack.clear()
			var origin = sandbox.View.LOCAL_LOCATION if local else sandbox.View.WORLD_MAP
			sandbox._show_view(origin)
			sandbox._on_shell_section_requested(CampaignShell.SECTION_INVENTORY)
			var panel = sandbox._shell._content_host.get_child(0)
			check(panel is HeroPreparationPanel, "Inventory available at each location")
			check(panel._current_tab == HeroPreparationPanel.PreparationTab.EQUIPMENT, "Opens equipment first")
			check(panel.read_only_build, "Build locked without HOME capability")
			var equipment = panel.find_children("*", "HeroEquipmentPanel", true, false)[0]
			var weapon = progression.equipment_state.weapon_1
			if weapon == null:
				for item in state.inventory_state.items:
					if HeroEquipmentService.new().get_compatible_slots(item).has(HeroEquipmentState.Slot.WEAPON_1):
						weapon = item
						equipment._on_equip_pressed(item.instance_id, HeroEquipmentState.Slot.WEAPON_1)
						break
			check(weapon != null, "Weapon available")
			if weapon != null:
				equipment._on_unequip_pressed(HeroEquipmentState.Slot.WEAPON_1)
				check(progression.equipment_state.weapon_1 == null, "Unequip outside HOME")
				equipment._on_equip_pressed(weapon.instance_id, HeroEquipmentState.Slot.WEAPON_1)
				check(progression.equipment_state.weapon_1 == weapon, "Equip outside HOME")
			var points: int = state.get_selected_hero().progression_state.unspent_skill_points
			panel._on_qa_add_skill_points_pressed()
			check(state.get_selected_hero().progression_state.unspent_skill_points == points, "QA cannot bypass lock")
			panel._on_tab_pressed(HeroPreparationPanel.PreparationTab.PROGRESSION)
			var grid = panel.find_children("*", "HeroSkillGridPanel", true, false)[0]
			check(grid.read_only, "Progression is read-only")
			var blocks = grid.find_children("*", "HeroSkillGridBlockView", true, false)
			if not blocks.is_empty():
				check(blocks[0].read_only, "Graph inherits lock")
				blocks[0]._on_purchase_pressed(&"invalid")
				blocks[0]._on_attachment_confirm_pressed()
			panel._on_tab_pressed(HeroPreparationPanel.PreparationTab.ABILITIES)
			var loadouts = panel.find_children("*", "HeroLoadoutPanel", true, false)
			check(not loadouts.is_empty(), "Known abilities show loadout")
			if loadouts.is_empty():
				quit(1)
				return
			var loadout = loadouts[0]
			check(loadout.read_only, "Loadout is read-only")
			loadout._on_add_pressed(&"invalid")
			loadout._on_remove_pressed(&"invalid")
			panel._on_close_pressed()
			check(sandbox._current_view == origin, "Back restores origin")
			await process_frame
	state.current_world_node_id = &"debug_home"
	var zone = state.home_settlement_state.get_zone(&"residential_yard")
	zone.building_id = &"temporary_party_shelter"
	zone.building_level = 1
	sandbox._view_stack.clear()
	sandbox._show_view(sandbox.View.LOCAL_LOCATION)
	sandbox._on_shell_section_requested(CampaignShell.SECTION_INVENTORY)
	var panel = sandbox._shell._content_host.get_child(0)
	check(not panel.read_only_build, "Equipped HOME unlocks configuration")
	sandbox._on_shell_section_requested(CampaignShell.SECTION_PARTY)
	check(sandbox._current_view == sandbox.View.PARTY, "Party management remains available in HOME")
	sandbox.queue_free()
	await process_frame
	print("INVENTORY ACCESS: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
