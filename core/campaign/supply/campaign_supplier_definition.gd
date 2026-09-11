@tool
class_name CampaignSupplierDefinition
extends Resource
@export var supplier_id: StringName = &""
@export var display_name: String = ""
@export var trader_id: StringName = &""
@export var minimum_reputation: int = 0
## Reuse authored campaign conditions for future quest/faction/contact requirements.
@export var conditions: Array[CampaignDialogueCondition] = []
## DEV: never discount below 80% of base price, regardless of future trader tiers.
@export_range(0.01, 1.0, 0.01) var minimum_price_multiplier: float = 0.8
@export var packages: Array[CampaignSupplyPackageDefinition] = []
func get_package(id: StringName) -> CampaignSupplyPackageDefinition:
	for offer in packages:
		if offer != null and offer.package_id == id:
			return offer
	return null
func get_validation_errors(campaign: CampaignDefinition) -> PackedStringArray:
	var errors := PackedStringArray()
	if supplier_id == &"" or display_name.is_empty() or campaign.get_trader(trader_id) == null:
		errors.append("Supplier needs identity and an existing world trader.")
	if minimum_price_multiplier <= 0 or minimum_price_multiplier > 1:
		errors.append("Invalid supplier price floor.")
	var ids: Array[StringName] = []
	for offer in packages:
		if offer == null or not offer.is_valid_definition():
			errors.append("Invalid supplier package.")
			continue
		if ids.has(offer.package_id):
			errors.append("Duplicate supplier package.")
		ids.append(offer.package_id)
	if packages.is_empty():
		errors.append("Supplier has no offers.")
	for condition in conditions:
		if condition == null:
			errors.append("Null supplier condition.")
		else:
			errors.append_array(condition.get_validation_errors())
			errors.append_array(condition.get_reference_errors(campaign))
	return errors
