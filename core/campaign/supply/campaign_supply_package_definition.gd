@tool
class_name CampaignSupplyPackageDefinition
extends Resource
@export var package_id: StringName = &""
@export var display_name: String = ""
@export_range(1, 999999, 1) var amount: int = 5
@export_range(1, 999999, 1) var base_price: int = 30
@export_range(1, 999999, 1) var duration_minutes: int = 1440
@export var minimum_reputation: int = 0
func is_valid_definition() -> bool:
	return package_id != &"" and not display_name.is_empty() and amount > 0 and base_price > 0 and duration_minutes > 0
