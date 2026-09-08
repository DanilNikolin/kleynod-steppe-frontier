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