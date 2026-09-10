extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var campaign := load(CampaignRuntimeService.DEBUG_CAMPAIGN_DEFINITION_PATH) as CampaignDefinition
	var state := CampaignStateFactory.new().create_from_definition(campaign)
	var item := state.inventory_state.get_item(&"debug_testing_sabre_start")
	var good: bool = item != null and item.definition.primary_ability.effects[0].base_damage == 50
	good = good and not item.definition.is_trade_enabled() and not item.definition.is_loot_enabled()
	for loot in campaign.loot_catalog:
		good = good and loot.item_id != &"debug_testing_sabre"
	for trader in campaign.traders:
		for entry in trader.starting_stock:
			good = good and entry.item_definition.item_id != &"debug_testing_sabre"
	if good:
		print("SMOKE GREEN: separate starting DEBUG sabre, 50 base damage, no loot or trade.")
	else:
		push_error("Debug sabre contract failed.")
	quit(0 if good else 1)
