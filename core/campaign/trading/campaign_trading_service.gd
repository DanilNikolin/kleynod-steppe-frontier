class_name CampaignTradingService
extends RefCounted


const MAX_GOLD: int = 999999999

var _settlement_effect_service := (
	CampaignSettlementEffectService.new()
)


func get_buy_price(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	item_definition: HeroEquipmentItemDefinition
) -> int:
	if (
		trader_definition == null
		or item_definition == null
		or not item_definition.is_trade_enabled()
	):
		return 0

	var multiplier := (
		trader_definition.buy_price_multiplier
	)

	if campaign_state != null:
		var tier := (
			trader_definition
				.get_reputation_pricing_tier(
					campaign_state.reputation
				)
		)

		if tier != null:
			multiplier = (
				tier.buy_price_multiplier
			)

	return maxi(
		ceili(
			float(
				item_definition.base_trade_value
			)
			* multiplier
		),
		1
	)


func get_sell_price(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	item_definition: HeroEquipmentItemDefinition
) -> int:
	if (
		trader_definition == null
		or item_definition == null
		or not item_definition.is_trade_enabled()
	):
		return 0

	var multiplier := (
		trader_definition.sell_price_multiplier
	)

	if campaign_state != null:
		var tier := (
			trader_definition
				.get_reputation_pricing_tier(
					campaign_state.reputation
				)
		)

		if tier != null:
			multiplier = (
				tier.sell_price_multiplier
			)

	return maxi(
		floori(
			float(
				item_definition.base_trade_value
			)
			* multiplier
		),
		1
	)


func get_stock_access_error(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	settlement_definition: CampaignSettlementDefinition,
	item_definition: HeroEquipmentItemDefinition
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if trader_definition == null:
		return "Trader definition is missing."

	if item_definition == null:
		return "Item definition is missing."

	var stock_entry := (
		trader_definition
			.get_stock_entry_for_item_id(
				item_definition.item_id
			)
	)

	## Не authored starting stock.
	## Например вещь, которую игрок сам
	## когда-то продал торговцу.
	if stock_entry == null:
		return ""

	if (
		campaign_state.reputation
		< stock_entry.required_reputation
	):
		if not stock_entry.access_requirement_text.strip_edges().is_empty():
			return stock_entry.access_requirement_text

		return (
			"Required reputation: %d."
			% stock_entry.required_reputation
		)

	if (
		stock_entry.required_home_settlement_effect_id
		!= &""
	):
		if (
			settlement_definition == null
			or campaign_state.home_settlement_state == null
		):
			return (
				"Home settlement state is unavailable."
			)

		if not _settlement_effect_service.has_active_effect(
			settlement_definition,
			campaign_state.home_settlement_state,
			stock_entry.required_home_settlement_effect_id
		):
			if not stock_entry.access_requirement_text.strip_edges().is_empty():
				return stock_entry.access_requirement_text

			return (
				"Required settlement effect: %s."
				% stock_entry
					.required_home_settlement_effect_id
			)

	return ""


func is_stock_item_available(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	settlement_definition: CampaignSettlementDefinition,
	item_definition: HeroEquipmentItemDefinition
) -> bool:
	return get_stock_access_error(
		campaign_state,
		trader_definition,
		settlement_definition,
		item_definition
	).is_empty()


func get_buy_error(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	trader_state: CampaignTraderState,
	item_instance_id: StringName,
	settlement_definition: CampaignSettlementDefinition = null
) -> String:
	var shared_error := _get_shared_error(
		campaign_state,
		trader_definition,
		trader_state
	)

	if not shared_error.is_empty():
		return shared_error

	var player_inventory := (
		campaign_state.inventory_state
	)

	if player_inventory == null:
		return "Player inventory is missing."

	if not player_inventory.can_add_items(1):
		return "Нет свободного места в инвентаре."

	var item := trader_state.get_item(
		item_instance_id
	)

	if item == null:
		return "Trader does not own this item."

	if (
		item.definition == null
		or not item.definition.is_trade_enabled()
	):
		return "Item is not tradeable."

	var stock_access_error := (
		get_stock_access_error(
			campaign_state,
			trader_definition,
			settlement_definition,
			item.definition
		)
	)

	if not stock_access_error.is_empty():
		return stock_access_error

	var price := get_buy_price(
		campaign_state,
		trader_definition,
		item.definition
	)

	if price <= 0:
		return "Item has no valid buy price."

	if player_inventory.gold < price:
		return "Not enough gold."

	if player_inventory.has_item(
		item.instance_id
	):
		return "Player already owns this item instance."

	if trader_state.gold > MAX_GOLD - price:
		return "Trader gold would overflow."

	return ""


func apply_buy(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	trader_state: CampaignTraderState,
	item_instance_id: StringName,
	settlement_definition: CampaignSettlementDefinition = null
) -> bool:
	if not get_buy_error(
		campaign_state,
		trader_definition,
		trader_state,
		item_instance_id,
		settlement_definition
	).is_empty():
		return false

	var player_inventory := (
		campaign_state.inventory_state
	)

	var item := trader_state.get_item(
		item_instance_id
	)

	if (
		player_inventory == null
		or item == null
		or item.definition == null
	):
		return false

	var price := get_buy_price(
		campaign_state,
		trader_definition,
		item.definition
	)

	var trader_item_index := (
		trader_state.items.find(
			item
		)
	)

	if trader_item_index < 0:
		return false

	var previous_player_gold := (
		player_inventory.gold
	)

	var previous_trader_gold := (
		trader_state.gold
	)

	trader_state.items.remove_at(
		trader_item_index
	)

	player_inventory.items.append(
		item
	)

	player_inventory.gold -= price
	trader_state.gold += price

	if (
		player_inventory.is_valid_state()
		and trader_state.is_valid_state()
		and campaign_state.is_valid_state()
	):
		return true

	player_inventory.gold = (
		previous_player_gold
	)

	trader_state.gold = (
		previous_trader_gold
	)

	player_inventory.items.erase(
		item
	)

	trader_state.items.insert(
		trader_item_index,
		item
	)

	return false


func get_sell_error(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	trader_state: CampaignTraderState,
	item_instance_id: StringName
) -> String:
	var shared_error := _get_shared_error(
		campaign_state,
		trader_definition,
		trader_state
	)

	if not shared_error.is_empty():
		return shared_error

	var player_inventory := (
		campaign_state.inventory_state
	)

	if player_inventory == null:
		return "Player inventory is missing."

	var item := player_inventory.get_item(
		item_instance_id
	)

	if item == null:
		return "Player does not own this item."

	if campaign_state.get_equipment_owner(
		item_instance_id
	) != null:
		return "Equipped items cannot be sold."

	if (
		item.definition == null
		or not item.definition.is_trade_enabled()
	):
		return "Item is not tradeable."

	if trader_state.has_item(
		item.instance_id
	):
		return "Trader already owns this item instance."

	var price := get_sell_price(
		campaign_state,
		trader_definition,
		item.definition
	)

	if price <= 0:
		return "Item has no valid sell price."

	if trader_state.gold < price:
		return "Trader does not have enough gold."

	if player_inventory.gold > MAX_GOLD - price:
		return "Player gold would overflow."

	return ""


func apply_sell(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	trader_state: CampaignTraderState,
	item_instance_id: StringName
) -> bool:
	if not get_sell_error(
		campaign_state,
		trader_definition,
		trader_state,
		item_instance_id
	).is_empty():
		return false

	var player_inventory := (
		campaign_state.inventory_state
	)

	var item := player_inventory.get_item(
		item_instance_id
	)

	if (
		item == null
		or item.definition == null
	):
		return false

	var price := get_sell_price(
		campaign_state,
		trader_definition,
		item.definition
	)

	var player_item_index := (
		player_inventory.items.find(
			item
		)
	)

	if player_item_index < 0:
		return false

	var previous_player_gold := (
		player_inventory.gold
	)

	var previous_trader_gold := (
		trader_state.gold
	)

	player_inventory.items.remove_at(
		player_item_index
	)

	trader_state.items.append(
		item
	)

	player_inventory.gold += price
	trader_state.gold -= price

	if (
		player_inventory.is_valid_state()
		and trader_state.is_valid_state()
		and campaign_state.is_valid_state()
	):
		return true

	player_inventory.gold = (
		previous_player_gold
	)

	trader_state.gold = (
		previous_trader_gold
	)

	trader_state.items.erase(
		item
	)

	player_inventory.items.insert(
		player_item_index,
		item
	)

	return false


func _get_shared_error(
	campaign_state: CampaignState,
	trader_definition: CampaignTraderDefinition,
	trader_state: CampaignTraderState
) -> String:
	if campaign_state == null:
		return "Campaign state is missing."

	if trader_definition == null:
		return "Trader definition is missing."

	if trader_state == null:
		return "Trader state is missing."

	if (
		trader_state.trader_id
		!= trader_definition.trader_id
	):
		return "Trader state does not match definition."

	if (
		campaign_state.current_world_node_id
		!= trader_definition.world_node_id
	):
		return "Campaign party is not at this trader."

	if not trader_state.is_valid_state():
		return "Trader state is invalid."

	return ""