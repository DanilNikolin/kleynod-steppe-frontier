class_name CampaignForgeService
extends RefCounted

const MAJOR_SLOT_COUNT: int = 1

func has_shell(definition: CampaignSettlementDefinition, state: CampaignSettlementState) -> bool:
	if definition == null or state == null or definition.forge_zone_id == &"":
		return false
	var zone := state.get_zone(definition.forge_zone_id)
	return zone != null and zone.building_id == definition.forge_building_id


## Stable content order chooses one eligible master. No persistent duplicate of
## workplace/resident state; future resident definitions can supply other catalogs.
func get_master(campaign: CampaignDefinition, state: CampaignState) -> CampaignResidentDefinition:
	if campaign == null or state == null:
		return null
	if not has_shell(campaign.home_settlement_definition, state.home_settlement_state):
		return null
	var residents := CampaignResidentService.new()
	for resident in campaign.residents:
		if resident.is_forge_master and residents.is_workplace_ready(resident, state.get_resident(resident.resident_id), campaign.home_settlement_definition, state.home_settlement_state):
			return resident
	return null


func operational_error(campaign: CampaignDefinition, state: CampaignState) -> String:
	if not has_shell(campaign.home_settlement_definition, state.home_settlement_state):
		return "Сначала постройте корпус кузницы у плотника."
	if get_master(campaign, state) == null:
		return "Кузница не работает: требуется кузнец в HOME."
	return ""


func retool_error(campaign: CampaignDefinition, state: CampaignState, module_id: StringName, expected_module_id: StringName) -> String:
	var error := operational_error(campaign, state)
	if not error.is_empty():
		return error
	if state.current_world_node_id != campaign.home_settlement_definition.world_node_id:
		return "Переоснащение доступно только в HOME."
	var current := state.home_settlement_state.forge_major_module_id
	if current != expected_module_id:
		return "Оснастка уже изменилась. Обновите кузницу."
	var module := campaign.home_settlement_definition.get_forge_module(module_id)
	if module == null:
		return "Неизвестная оснастка."
	if current == module_id:
		return "Эта оснастка уже установлена."
	if state.materials < module.material_cost:
		return "Нужно %d материалов." % module.material_cost
	if state.inventory_state.gold < module.gold_cost:
		return "Нужно %d гр." % module.gold_cost
	if state.current_day * 1440 + state.current_minute_of_day + module.duration_minutes > CampaignTimeService.MAX_CAMPAIGN_DAY * 1440 + 1439:
		return "Не хватает времени в календаре кампании."
	return ""
