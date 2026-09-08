@tool
class_name CampaignTraderStockEntryDefinition
extends Resource


@export
var item_definition: HeroEquipmentItemDefinition

@export_range(1, 999, 1)
var quantity: int = 1


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