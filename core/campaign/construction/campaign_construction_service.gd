class_name CampaignConstructionService
extends RefCounted


func get_contract(state: CampaignState, project_id: StringName) -> CampaignConstructionContract:
	for contract in state.construction_contracts:
		if contract.project_id == project_id:
			return contract
	return null


func worksite_available(campaign: CampaignDefinition, state: CampaignState) -> bool:
	var carpenter := state.get_resident(campaign.construction_resident_id)
	return carpenter != null and carpenter.is_at_home()


func get_project_gate(campaign: CampaignDefinition, state: CampaignState, project: CampaignConstructionProjectDefinition) -> String:
	if project == null:
		return "Проект не найден."
	if not worksite_available(campaign, state):
		return "Сначала пригласите плотника в HOME."
	if not state.construction_knowledge_ids.has(project.required_knowledge_id):
		return "Пока не хватает строительного знания."
	if not state.construction_agreement_ids.has(project.required_agreement_id):
		return "Плотник умеет, но пока не согласен: «Я кузню обещал. Мы так не договаривались»."
	if project.required_specialist_id != &"":
		var specialist := state.get_resident(project.required_specialist_id)
		if specialist == null or not specialist.is_at_home():
			return "Для строительства нужен профильный специалист в HOME."
	if not project.implementation_enabled:
		return "Этот проект будет доступен на следующем этапе истории."
	return ""


func available_workers(campaign: CampaignDefinition, state: CampaignState, source: CampaignCrewSourceDefinition, excluding_project: StringName = &"") -> int:
	var available := source.get_capacity(state.reputation)
	for contract in state.construction_contracts:
		if contract.source_id == source.source_id and contract.project_id != excluding_project and contract.status != CampaignConstructionContract.Status.COMPLETED:
			available -= contract.crew_size
	return maxi(0, available)


func quote(project: CampaignConstructionProjectDefinition, source: CampaignCrewSourceDefinition, crew: int) -> Dictionary:
	if project == null or source == null or crew < project.minimum_crew or crew > project.maximum_effective_crew:
		return {}
	var minutes := ceili(float(project.labor_worker_days * 1440) / crew)
	var labor_gold := ceili(float(minutes * crew * source.daily_wage) / 1440)
	return {"minutes": minutes, "gold": labor_gold + crew * source.mobilization_per_worker + project.component_gold_cost, "labor_gold": labor_gold, "mobilization_gold": crew * source.mobilization_per_worker}


func reservation_error(campaign: CampaignDefinition, state: CampaignState, project_id: StringName, source_id: StringName, crew: int) -> String:
	var project := campaign.get_construction_project(project_id)
	var source := campaign.get_crew_source(source_id)
	var gate := get_project_gate(campaign, state, project)
	if not gate.is_empty():
		return gate
	if source == null or state.current_world_node_id != source.world_node_id:
		return "Договоритесь о бригаде у старосты в поселении-источнике."
	var contract := get_contract(state, project_id)
	if contract != null and contract.status != CampaignConstructionContract.Status.RESERVED:
		return "Контракт уже подписан или проект завершён."
	if not state.home_settlement_state.get_zone(project.zone_id).is_empty():
		return "Участок уже застроен."
	for other in state.construction_contracts:
		if other.project_id != project_id and campaign.get_construction_project(other.project_id).zone_id == project.zone_id:
			return "Этот участок уже занят другим проектом."
	if quote(project, source, crew).is_empty():
		return "Бригаде нужно от %d до %d работников." % [project.minimum_crew, project.maximum_effective_crew]
	if crew > available_workers(campaign, state, source, project_id):
		return "В этом поселении сейчас не хватает свободных работников."
	return ""


func reserve(campaign: CampaignDefinition, state: CampaignState, project_id: StringName, source_id: StringName, crew: int) -> String:
	var error := reservation_error(campaign, state, project_id, source_id, crew)
	if not error.is_empty():
		return error
	var contract := get_contract(state, project_id)
	if contract == null:
		contract = CampaignConstructionContract.new()
		contract.project_id = project_id
		state.construction_contracts.append(contract)
	contract.source_id = source_id
	contract.crew_size = crew
	return ""


func release_reservation(campaign: CampaignDefinition, state: CampaignState, project_id: StringName) -> String:
	var contract := get_contract(state, project_id)
	if contract == null or contract.status != CampaignConstructionContract.Status.RESERVED:
		return "Можно отменить только неподписанную договорённость."
	var source := campaign.get_crew_source(contract.source_id)
	if state.current_world_node_id != source.world_node_id:
		return "Отменить договорённость можно у старосты."
	state.construction_contracts.erase(contract)
	return ""


func start_error(campaign: CampaignDefinition, state: CampaignState, project_id: StringName) -> String:
	if state.current_world_node_id != campaign.home_settlement_definition.world_node_id:
		return "Подпишите контракт на рабочем месте плотника в HOME."
	var project := campaign.get_construction_project(project_id)
	var gate := get_project_gate(campaign, state, project)
	if not gate.is_empty():
		return gate
	var contract := get_contract(state, project_id)
	if contract == null:
		return "Нет бригады. Договоритесь с работниками у старосты в Малом селе."
	if contract.status != CampaignConstructionContract.Status.RESERVED:
		return "Проект уже оплачен или завершён."
	if not state.home_settlement_state.get_zone(project.zone_id).is_empty():
		return "Участок уже застроен."
	var source := campaign.get_crew_source(contract.source_id)
	var price := quote(project, source, contract.crew_size)
	if price.is_empty():
		return "Некорректный состав бригады."
	if state.materials < project.material_cost:
		return "Нужно %d материалов. Лесоматериал можно собрать в Ближней роще." % project.material_cost
	if state.inventory_state.gold < int(price.gold):
		return "Не хватает грошей: весь контракт стоит %d гр." % int(price.gold)
	var now := state.current_day * 1440 + state.current_minute_of_day
	if now + int(price.minutes) > CampaignTimeService.MAX_CAMPAIGN_DAY * 1440 + 1439:
		return "Срок выходит за пределы календаря кампании."
	return ""


func start(campaign: CampaignDefinition, state: CampaignState, project_id: StringName) -> String:
	var error := start_error(campaign, state, project_id)
	if not error.is_empty():
		return error
	var project := campaign.get_construction_project(project_id)
	var contract := get_contract(state, project_id)
	var price := quote(project, campaign.get_crew_source(contract.source_id), contract.crew_size)
	contract.paid_gold = int(price.gold)
	contract.paid_materials = project.material_cost
	contract.started_at = state.current_day * 1440 + state.current_minute_of_day
	contract.completes_at = contract.started_at + int(price.minutes)
	contract.status = CampaignConstructionContract.Status.ACTIVE
	state.inventory_state.gold -= contract.paid_gold
	state.materials -= contract.paid_materials
	return ""


func complete_due(campaign: CampaignDefinition, state: CampaignState) -> bool:
	if not get_state_error(campaign, state).is_empty():
		return false
	var now := state.current_day * 1440 + state.current_minute_of_day
	for contract in state.construction_contracts:
		if contract.status != CampaignConstructionContract.Status.ACTIVE or now < contract.completes_at:
			continue
		var project := campaign.get_construction_project(contract.project_id)
		var zone := state.home_settlement_state.get_zone(project.zone_id)
		zone.building_id = project.building_id
		zone.building_level = project.target_level
		contract.status = CampaignConstructionContract.Status.COMPLETED
	return true


func get_state_error(campaign: CampaignDefinition, state: CampaignState) -> String:
	var seen: Dictionary = {}
	var zones: Dictionary = {}
	for contract in state.construction_contracts:
		if contract == null or not contract.is_valid_state() or seen.has(contract.project_id):
			return "Invalid or duplicate construction contract."
		seen[contract.project_id] = true
		var project := campaign.get_construction_project(contract.project_id)
		var source := campaign.get_crew_source(contract.source_id)
		if project == null or source == null or not project.implementation_enabled or zones.has(project.zone_id):
			return "Unknown or conflicting construction project."
		zones[project.zone_id] = true
		var price := quote(project, source, contract.crew_size)
		if price.is_empty() or contract.crew_size > source.maximum_capacity:
			return "Invalid construction crew."
		if not state.construction_knowledge_ids.has(project.required_knowledge_id) or not state.construction_agreement_ids.has(project.required_agreement_id):
			return "Construction prerequisites are missing."
		var zone := state.home_settlement_state.get_zone(project.zone_id)
		if zone == null:
			return "Construction target is missing."
		if contract.status == CampaignConstructionContract.Status.COMPLETED:
			if zone.building_id != project.building_id or zone.building_level != project.target_level:
				return "Completed contract does not match its building."
		elif not zone.is_empty():
			return "Construction target is already occupied."
		if contract.status != CampaignConstructionContract.Status.RESERVED:
			if contract.paid_gold != int(price.gold) or contract.paid_materials != project.material_cost or contract.completes_at - contract.started_at != int(price.minutes):
				return "Saved construction quote does not match the project."
			var now := state.current_day * 1440 + state.current_minute_of_day
			if contract.started_at > now or (contract.status == CampaignConstructionContract.Status.COMPLETED and contract.completes_at > now):
				return "Invalid construction dates."
	for source in campaign.crew_sources:
		var used := 0
		for contract in state.construction_contracts:
			if contract.source_id == source.source_id and contract.status != CampaignConstructionContract.Status.COMPLETED:
				used += contract.crew_size
		if used > source.maximum_capacity:
			return "Crew source is overbooked."
	return ""
