extends SceneTree
var failures: int = 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var runtime := CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Start campaign")
	var state := runtime.campaign_state
	var hero := state.get_selected_hero()
	var id := hero.get_hero_id()
	var progression := hero.progression_state
	progression.level = 5
	progression.experience = 7
	progression.unspent_skill_points = 8
	var grid := hero.hero_definition.skill_grid
	var attachments := SkillGridBlockAttachmentService.new()
	var candidates := attachments.get_attachment_candidates(grid, progression)
	check(not candidates.is_empty(), "Choose initial branch")
	attachments.attach(grid, progression, candidates[0].block_id)
	var purchases := SkillGridPurchaseService.new()
	for node in grid.nodes:
		if purchases.can_purchase(grid, progression, node.node_id) and progression.purchased_node_ids.size() < 3:
			check(purchases.purchase(grid, progression, node.node_id).is_successful, "Buy node")
	check(not progression.purchased_node_ids.is_empty(), "Purchased fixture")
	var save_path := "user://respec_smoke_%d.json" % Time.get_ticks_usec()
	var saves := CampaignSaveService.new(save_path)
	var before := saves._encode_campaign(state)
	check(not runtime.respec_hero_skills(id).is_empty(), "No B2 gate")
	check(saves._encode_campaign(state) == before, "Gate no mutation")
	var zone := state.home_settlement_state.get_zone(&"residential_yard")
	zone.building_id = &"temporary_party_shelter"
	zone.building_level = 2
	check(runtime.has_active_home_settlement_effect(&"party_respec_access"), "Fixture enables B2 effect")
	check(not runtime.get_home_settlement_upgrade_error(&"residential_yard").is_empty() or not runtime.campaign_definition.get_construction_project(&"party_kurin").required_agreement_id.is_empty(), "Agreement remains authored")
	state.current_world_node_id = &"debug_village"
	check(not runtime.respec_hero_skills(id).is_empty(), "Outside HOME")
	state.current_world_node_id = &"debug_home"
	hero.is_placeholder_content = true
	check(not runtime.respec_hero_skills(id).is_empty(), "Placeholder denied")
	hero.is_placeholder_content = false
	check(not runtime.respec_hero_skills(&"unknown_hero").is_empty(), "Unknown hero denied")
	progression.unspent_skill_points = 999
	check(not runtime.respec_hero_skills(id).is_empty(), "Refund overflow denied")
	check(hero.progression_state == progression and not progression.purchased_node_ids.is_empty(), "Failure preserves original resource")
	progression.unspent_skill_points = 8
	var expected := progression.unspent_skill_points
	for node_id in progression.purchased_node_ids:
		expected += grid.get_node_definition(node_id).skill_point_cost
	before = saves._encode_campaign(state)
	var equipment := progression.equipment_state
	check(runtime.respec_hero_skills(id).is_empty(), "Respec succeeds")
	var after := hero.progression_state
	check(after.purchased_node_ids.is_empty() and after.attached_skill_block_ids.is_empty(), "All grid choices removed")
	check(after.unspent_skill_points == expected, "Exact refund")
	check(after.level == 5 and after.experience == 7 and after.equipment_state == equipment, "XP level equipment preserved")
	var encoded := saves._encode_campaign(state)
	# Compare entire persisted campaign except the explicitly reset fields.
	for hero_data in before.heroes:
		if hero_data.hero_id == String(id):
			hero_data.purchased_node_ids = []
			hero_data.attached_skill_block_ids = []
			hero_data.unspent_skill_points = expected
			hero_data.selected_personal_ability_ids = Array(after.selected_personal_ability_ids)
	check(encoded == before, "All unrelated campaign and hero data preserved")
	check(HeroBattleBuildResolver.new().resolve(hero.hero_definition, after) != null, "Derived build valid")
	check(not runtime.respec_hero_skills(id).is_empty(), "Repeat denied")
	check(hero.progression_state.unspent_skill_points == expected, "No SP duplication")
	check(saves.save_campaign(state).is_successful, "Save reset")
	var loaded := saves.load_campaign(runtime.campaign_definition)
	check(loaded.is_successful, "Load reset: " + loaded.message)
	if loaded.is_successful:
		check(saves._encode_campaign(loaded.campaign_state) == encoded, "Full saved state roundtrip")
	# A fresh attachment after reset demonstrates unlimited reuse without SP cost.
	attachments.attach(grid, after, candidates[0].block_id)
	check(runtime.respec_hero_skills(id).is_empty(), "Reset free branch choice repeatedly")
	check(hero.progression_state.unspent_skill_points == expected, "Free branch produces no SP")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	runtime.free()
	if failures == 0:
		print("RESPEC GREEN: effect/location/hero gates, exact refund, preservation, repeat safety, save/load, transaction refusal.")
	quit(0 if failures == 0 else 1)
