@tool
class_name CampaignTraderDefinition
extends Resource


@export_group("Identity")

@export
var trader_id: StringName = &""

@export
var display_name: String = "Unnamed Trader"

@export_multiline
var description: String = ""


@export_group("Location")

@export
var world_node_id: StringName = &""

@export
var local_interaction_id: StringName = &""

## Какая authored action-кнопка interaction
## открывает торговый экран этого торговца.
@export
var open_action_label: String = "Торговля"


@export_group("Economy")

@export_range(0, 999999999, 1)
var starting_gold: int = 0

## Цена, которую PLAYER платит торговцу.
@export_range(0.01, 100.0, 0.01)
var buy_price_multiplier: float = 1.0

## Цена, которую TRADER платит игроку.
@export_range(0.01, 100.0, 0.01)
var sell_price_multiplier: float = 0.5


@export_group("Reputation Pricing")

## Выбирается tier с самым высоким
## minimum_reputation, который игрок выполняет.
##
## Если подходящего tier нет,
## используются базовые multipliers торговца.
@export
var reputation_pricing_tiers: Array[CampaignTraderReputationTierDefinition] = []


@export_group("Starting Stock")

@export
var starting_stock: Array[CampaignTraderStockEntryDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if trader_id == &"":
		errors.append(
			"Trader ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Trader display name is empty."
		)

	if world_node_id == &"":
		errors.append(
			"Trader world node ID is empty."
		)

	if local_interaction_id == &"":
		errors.append(
			"Trader local interaction ID is empty."
		)

	if open_action_label.strip_edges().is_empty():
		errors.append(
			"Trader open action label is empty."
		)

	if starting_gold < 0:
		errors.append(
			"Trader starting gold cannot be negative."
		)

	if buy_price_multiplier <= 0.0:
		errors.append(
			"Trader buy price multiplier must be positive."
		)

	if sell_price_multiplier <= 0.0:
		errors.append(
			"Trader sell price multiplier must be positive."
		)

	if sell_price_multiplier > buy_price_multiplier:
		errors.append(
			"Trader sell multiplier cannot exceed "
			+"buy multiplier."
		)

	var used_reputation_thresholds: Dictionary = {}

	for tier_index in range(
		reputation_pricing_tiers.size()
	):
		var tier := reputation_pricing_tiers[
			tier_index
		]

		if tier == null:
			errors.append(
				"Trader reputation tier at index %d is null."
				% tier_index
			)

			continue

		for tier_error in tier.get_validation_errors():
			errors.append(
				"Trader reputation tier %d: %s"
				% [
					tier_index,
					tier_error,
				]
			)

		if used_reputation_thresholds.has(
			tier.minimum_reputation
		):
			errors.append(
				"Duplicate trader reputation threshold: %d."
					% tier.minimum_reputation
			)

			continue

		used_reputation_thresholds[
			tier.minimum_reputation
		] = true

	var used_item_ids: Dictionary = {}

	for stock_index in range(
		starting_stock.size()
	):
		var stock_entry := starting_stock[
			stock_index
		]

		if stock_entry == null:
			errors.append(
				"Trader stock entry at index %d is null."
				% stock_index
			)

			continue

		for stock_error in (
			stock_entry.get_validation_errors()
		):
			errors.append(
				"Trader stock entry %d: %s"
				% [
					stock_index,
					stock_error,
				]
			)

		if stock_entry.item_definition == null:
			continue

		var item_id := (
			stock_entry.item_definition.item_id
		)

		if item_id == &"":
			continue

		if used_item_ids.has(
			item_id
		):
			errors.append(
				"Duplicate trader starting stock item: %s."
				% item_id
			)

			continue

		used_item_ids[
			item_id
		] = true

	return errors


func get_reputation_pricing_tier(
	reputation: int
) -> CampaignTraderReputationTierDefinition:
	var result: CampaignTraderReputationTierDefinition
	var best_threshold := -2147483648

	for tier in reputation_pricing_tiers:
		if tier == null:
			continue

		if (
			reputation >= tier.minimum_reputation
			and tier.minimum_reputation
				> best_threshold
		):
			result = tier
			best_threshold = tier.minimum_reputation

	return result


func get_stock_entry_for_item_id(
	item_id: StringName
) -> CampaignTraderStockEntryDefinition:
	if item_id == &"":
		return null

	for stock_entry in starting_stock:
		if (
			stock_entry != null
			and stock_entry.item_definition != null
			and stock_entry.item_definition.item_id
				== item_id
		):
			return stock_entry

	return null