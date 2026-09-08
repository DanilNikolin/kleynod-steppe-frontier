class_name CampaignTraderStateFactory
extends RefCounted


func create_from_definition(
	definition: CampaignTraderDefinition
) -> CampaignTraderState:
	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return null

	var result := CampaignTraderState.new()

	result.trader_id = definition.trader_id
	result.gold = definition.starting_gold

	var stock_serial := 1

	for stock_entry in definition.starting_stock:
		if (
			stock_entry == null
			or stock_entry.item_definition == null
		):
			return null

		for _quantity_index in range(
			stock_entry.quantity
		):
			var item := (
				HeroEquipmentItemInstance.new()
			)

			item.instance_id = StringName(
				"trader_%s_%04d_%s"
				% [
					definition.trader_id,
					stock_serial,
					stock_entry
						.item_definition
						.item_id,
				]
			)

			item.definition = (
				stock_entry.item_definition
			)

			if not item.is_valid_instance():
				return null

			result.items.append(
				item
			)

			stock_serial += 1

	if not result.is_valid_state():
		return null

	return result