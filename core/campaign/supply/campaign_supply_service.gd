class_name CampaignSupplyService
extends RefCounted
const MAX_MATERIALS: int = 999999999
func get_delivery(state: CampaignState, supplier_id: StringName) -> CampaignSupplyDelivery:
	for delivery in state.active_deliveries:
		if delivery.supplier_id == supplier_id:
			return delivery
	return null
func price(campaign: CampaignDefinition, state: CampaignState, supplier: CampaignSupplierDefinition, offer: CampaignSupplyPackageDefinition) -> int:
	var trader := campaign.get_trader(supplier.trader_id)
	var multiplier := trader.buy_price_multiplier
	var tier := trader.get_reputation_pricing_tier(state.reputation)
	if tier != null:
		multiplier = tier.buy_price_multiplier
	return maxi(1, ceili(offer.base_price * clampf(multiplier, supplier.minimum_price_multiplier, 1.0)))
func relationship_error(campaign: CampaignDefinition, state: CampaignState, id: StringName, interaction_id: StringName) -> String:
	var supplier := campaign.get_supplier(id)
	if supplier == null:
		return "Неизвестный поставщик."
	var trader := campaign.get_trader(supplier.trader_id)
	if trader.world_node_id != state.current_world_node_id or trader.local_interaction_id != interaction_id:
		return "Договоритесь с поставщиком лично в его поселении."
	if state.supplier_relationship_ids.has(id):
		return "Связь с поставщиком уже установлена."
	for condition in supplier.conditions:
		if not condition.matches(state, campaign):
			return condition.unavailable_text
	return ""
func order_error(campaign: CampaignDefinition, state: CampaignState, id: StringName, package_id: StringName) -> String:
	if state.current_world_node_id != campaign.home_settlement_definition.world_node_id:
		return "Заказы поставок оформляются в HOME."
	if not CampaignSettlementEffectService.new().has_active_effect(campaign.home_settlement_definition, state.home_settlement_state, &"material_supply_access"):
		return "Для поставок нужен общий склад."
	var supplier := campaign.get_supplier(id)
	if supplier == null or not state.supplier_relationship_ids.has(id):
		return "Нет установленной связи с поставщиком."
	for condition in supplier.conditions:
		if not condition.matches(state, campaign):
			return condition.unavailable_text
	var offer := supplier.get_package(package_id)
	if offer == null:
		return "Нет такой партии."
	if get_delivery(state, id) != null:
		return "От этого поставщика уже идёт доставка."
	var required := maxi(supplier.minimum_reputation, offer.minimum_reputation)
	if state.reputation < required:
		return "Недостаточная репутация: %d / %d." % [state.reputation, required]
	if state.inventory_state.gold < price(campaign, state, supplier, offer):
		return "Не хватает грошей."
	var now := state.current_day * 1440 + state.current_minute_of_day
	if now + offer.duration_minutes > CampaignTimeService.MAX_CAMPAIGN_DAY * 1440 + 1439:
		return "Доставка выходит за пределы календаря."
	return ""
func due_amount(state: CampaignState, at: int) -> int:
	var total: int = 0
	for delivery in state.active_deliveries:
		if delivery.arrives_at <= at:
			total += delivery.amount
	return total
func complete_due(state: CampaignState) -> void:
	if not state.is_valid_state():
		return
	if state.materials > MAX_MATERIALS - due_amount(state, state.current_day * 1440 + state.current_minute_of_day):
		return
	var now := state.current_day * 1440 + state.current_minute_of_day
	var remaining: Array[CampaignSupplyDelivery] = []
	var total: int = 0
	for delivery in state.active_deliveries:
		if delivery.arrives_at <= now:
			total += delivery.amount
		else:
			remaining.append(delivery)
	state.materials += total
	state.active_deliveries = remaining
func validation_errors(campaign: CampaignDefinition, state: CampaignState) -> PackedStringArray:
	var errors := PackedStringArray()
	var ids: Array[StringName] = []
	for id in state.supplier_relationship_ids:
		if campaign.get_supplier(id) == null or ids.has(id):
			errors.append("Unknown or duplicate supplier relationship.")
		ids.append(id)
	ids.clear()
	for delivery in state.active_deliveries:
		if delivery == null or not delivery.is_valid_state():
			errors.append("Invalid active delivery.")
			continue
		var supplier := campaign.get_supplier(delivery.supplier_id)
		var offer := supplier.get_package(delivery.package_id) if supplier != null else null
		if offer == null or not state.supplier_relationship_ids.has(delivery.supplier_id) or ids.has(delivery.supplier_id):
			errors.append("Invalid delivery supplier/package.")
			continue
		ids.append(delivery.supplier_id)
		if delivery.amount != offer.amount or delivery.arrives_at - delivery.ordered_at != offer.duration_minutes or delivery.paid_gold > offer.base_price or delivery.paid_gold < ceili(offer.base_price * supplier.minimum_price_multiplier):
			errors.append("Delivery snapshot does not match its package.")
		if delivery.ordered_at > state.current_day * 1440 + state.current_minute_of_day or delivery.arrives_at > CampaignTimeService.MAX_CAMPAIGN_DAY * 1440 + 1439:
			errors.append("Invalid delivery calendar.")
	return errors
