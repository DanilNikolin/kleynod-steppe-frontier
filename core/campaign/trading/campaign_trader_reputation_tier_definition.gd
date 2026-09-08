@tool
class_name CampaignTraderReputationTierDefinition
extends Resource


@export_group("Identity")

@export
var display_name: String = "Reputation Tier"


@export_group("Requirement")

@export_range(-999999999, 999999999, 1)
var minimum_reputation: int = 0


@export_group("Prices")

## Финальный multiplier цены покупки игроком.
@export_range(0.01, 100.0, 0.01)
var buy_price_multiplier: float = 1.0

## Финальный multiplier цены продажи игроком.
@export_range(0.01, 100.0, 0.01)
var sell_price_multiplier: float = 0.5


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if display_name.strip_edges().is_empty():
		errors.append(
			"Trader reputation tier display name is empty."
		)

	if buy_price_multiplier <= 0.0:
		errors.append(
			"Trader reputation tier buy multiplier "
			+"must be positive."
		)

	if sell_price_multiplier <= 0.0:
		errors.append(
			"Trader reputation tier sell multiplier "
			+"must be positive."
		)

	if sell_price_multiplier > buy_price_multiplier:
		errors.append(
			"Trader reputation tier sell multiplier "
			+"cannot exceed buy multiplier."
		)

	return errors