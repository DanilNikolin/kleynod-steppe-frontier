extends SceneTree
var panel: HeroPreparationPanel
func _initialize() -> void:
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame

func run() -> void:
	var runtime = root.get_node("CampaignRuntime")
	runtime.start_new_campaign()
	var state = runtime.campaign_state
	var hero = state.get_selected_hero()
	var progression = hero.progression_state
	progression.level = 5
	progression.experience = 7
	progression.unspent_skill_points = 8
	var grid = hero.hero_definition.skill_grid
	var attachments = SkillGridBlockAttachmentService.new()
	attachments.attach(grid, progression, attachments.get_attachment_candidates(grid, progression)[0].block_id)
	var purchases = SkillGridPurchaseService.new()
	for node in grid.nodes:
		if purchases.can_purchase(grid, progression, node.node_id) and progression.purchased_node_ids.size() < 3:
			purchases.purchase(grid, progression, node.node_id)
	panel = load("res://presentation/campaign/hero_preparation/hero_preparation_panel.tscn").instantiate()
	root.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.bind_campaign(state, "К отряду", runtime)
	assert(panel.find_child("RespecButton", true, false) == null)
	panel._on_qa_reset_skill_grid_pressed()
	assert(not progression.purchased_node_ids.is_empty())
	await capture("before-capability")
	var zone = state.home_settlement_state.get_zone(&"residential_yard")
	zone.building_id = &"temporary_party_shelter"
	zone.building_level = 2
	panel._rebuild_interface()
	await process_frame
	assert(not panel.find_child("RespecButton", true, false).disabled)
	await capture("available")
	panel._confirm_respec()
	await capture("confirmation")
	panel.get_node("RespecConfirmation").confirmed.emit()
	await capture("after")
	assert(hero.progression_state.unspent_skill_points == 8)
	assert(panel.find_child("RespecButton", true, false).disabled)
	# Fresh choice, then walk out while confirmation is open: runtime must refuse.
	attachments.attach(grid, hero.progression_state, attachments.get_attachment_candidates(grid, hero.progression_state)[0].block_id)
	panel._rebuild_interface()
	await process_frame
	panel._confirm_respec()
	state.current_world_node_id = &"debug_village"
	panel.get_node("RespecConfirmation").confirmed.emit()
	await capture("outside")
	assert(not hero.progression_state.attached_skill_block_ids.is_empty())
	assert(panel.find_child("RespecButton", true, false).disabled)
	print("RESPEC UI GREEN: hidden before B2, available, confirmation, refund, repeat disabled, outside HOME and stale confirmation denied.")
	quit()
