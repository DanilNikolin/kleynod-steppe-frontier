@tool
class_name CampaignTraderStockEntryDefinition
extends Resource


@export
var item_definition: HeroEquipmentItemDefinition

@export_range(1, 999, 1)
var quantity: int = 1


@export_group("Access")

## Минимальная глобальная Reputation,
## при которой этот authored товар появляется
## в ассортименте.
##
## Очень низкое значение = требования нет.
@export_range(-999999999, 999999999, 1)
var required_reputation: int = -999999999

## Опциональный settlement effect.
##
## Например river_transport_access:
## товар доступен только при действующем Причале.
@export
var required_home_settlement_effect_id: StringName = &""

@export_multiline
var access_requirement_text: String = ""


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if item_definition == null:
		errors.append(
			"Trader stock item definition is missing."
		)

		return errors

	for item_error in (
		item_definition.get_validation_errors()
	):
		errors.append(
			"Trader stock item: %s"
			% item_error
		)

	if not item_definition.is_trade_enabled():
		errors.append(
			"Trader stock item '%s' has no trade value."
			% item_definition.item_id
		)

	if quantity <= 0:
		errors.append(
			"Trader stock quantity must be positive."
		)

	return errors