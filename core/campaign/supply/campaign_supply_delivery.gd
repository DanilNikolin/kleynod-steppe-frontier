class_name CampaignSupplyDelivery
extends RefCounted
var supplier_id: StringName = &""
var package_id: StringName = &""
var amount: int = 0
## Presence in active_deliveries means already paid. No duplicate paid boolean.
var paid_gold: int = 0
var ordered_at: int = 0
var arrives_at: int = 0
func is_valid_state() -> bool:
	return supplier_id != &"" and package_id != &"" and amount > 0 and paid_gold > 0 and ordered_at >= 0 and arrives_at > ordered_at
