@tool
class_name CampaignDefinition
extends Resource


const MIN_PARTY_SIZE: int = 1
const MAX_PARTY_SIZE: int = 3


@export_group("Identity")

@export
var campaign_id: StringName = &""

@export
var display_name: String = "Unnamed Campaign"


@export_group("Heroes")

@export
var starting_heroes: Array[CampaignHeroState] = []

@export
var starting_selected_hero_id: StringName = &""

@export
var starting_party_member_hero_ids: Array[StringName] = []


@export_group("Inventory")

@export
var starting_inventory_items: Array[HeroEquipmentItemInstance] = []

@export_range(0, 999999999, 1)
var starting_gold: int = 0


@export_group("Rewards")

## Определения вещей, доступных обычной
## Battle Loot системе этой кампании.
@export
var loot_catalog: Array[HeroEquipmentItemDefinition] = []


@export_group("Locations")

@export
var locations: Array[CampaignLocationDefinition] = []


@export_group("Adventure Areas")

@export
var adventure_areas: Array[CampaignAdventureAreaDefinition] = []


@export_group("World")

@export
var world_map_definition: CampaignWorldMapDefinition

## Абсолютный игровой день старта кампании.
## Ноль — первый день первого сезона.
@export_range(0, 999999999, 1)
var starting_day: int = 0

## Минута внутри стартового дня.
## 480 = 08:00.
@export_range(0, 1439, 1)
var starting_minute_of_day: int = 480

## Количество дней в одном сезоне.
## Сам сезон является derived data и отдельно
## в CampaignState не сохраняется.
@export_range(1, 9999, 1)
var days_per_season: int = 20

@export_range(-999999999, 999999999, 1)
var starting_reputation: int = 0

@export_range(0, 999999999, 1)
var starting_materials: int = 0


@export_group("Settlement")

@export
var home_settlement_definition: CampaignSettlementDefinition

@export_group("Residents")

@export
var residents: Array[CampaignResidentDefinition] = []

@export_group("Trading")

@export
var traders: Array[CampaignTraderDefinition] = []

@export_group("Quests")

@export
var quests: Array[CampaignQuestDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if campaign_id == &"":
		errors.append(
			"Campaign ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Campaign display name is empty."
		)

	if starting_heroes.is_empty():
		errors.append(
			"Campaign has no starting heroes."
		)

	var used_hero_ids: Dictionary = {}

	for hero_index in range(
		starting_heroes.size()
	):
		var hero_state := starting_heroes[
			hero_index
		]

		if hero_state == null:
			errors.append(
				"Starting hero at index %d is null."
				% hero_index
			)

			continue

		for hero_error in (
			hero_state.get_validation_errors()
		):
			errors.append(
				"Starting hero %d: %s"
				% [
					hero_index,
					hero_error,
				]
			)

		var hero_id := hero_state.get_hero_id()

		if hero_id == &"":
			continue

		if used_hero_ids.has(
			hero_id
		):
			errors.append(
				"Duplicate starting hero ID: %s."
				% hero_id
			)

			continue

		used_hero_ids[
			hero_id
		] = true

	if starting_selected_hero_id == &"":
		errors.append(
			"Starting selected hero ID is empty."
		)

	elif not used_hero_ids.has(
		starting_selected_hero_id
	):
		errors.append(
			"Starting selected hero '%s' does not exist."
			% starting_selected_hero_id
		)

	if (
		starting_party_member_hero_ids.size()
		< MIN_PARTY_SIZE
	):
		errors.append(
			"Starting party requires at least one hero."
		)

	if (
		starting_party_member_hero_ids.size()
		> MAX_PARTY_SIZE
	):
		errors.append(
			"Starting party cannot contain "
			+"more than three heroes."
		)

	var used_party_hero_ids: Dictionary = {}

	for hero_id in starting_party_member_hero_ids:
		if hero_id == &"":
			errors.append(
				"Starting party hero ID is empty."
			)

			continue

		if not used_hero_ids.has(
			hero_id
		):
			errors.append(
				"Starting party references "
				+"unknown hero: %s."
				% hero_id
			)

		if used_party_hero_ids.has(
			hero_id
		):
			errors.append(
				"Duplicate starting party hero: %s."
				% hero_id
			)

			continue

		used_party_hero_ids[
			hero_id
		] = true

	var used_inventory_item_ids: Dictionary = {}

	for item_index in range(
		starting_inventory_items.size()
	):
		var item := starting_inventory_items[
			item_index
		]

		if item == null:
			errors.append(
				"Starting inventory item at index %d is null."
				% item_index
			)

			continue

		for item_error in item.get_validation_errors():
			errors.append(
				"Starting inventory item %d: %s"
				% [
					item_index,
					item_error,
				]
			)

		if item.instance_id == &"":
			continue

		if used_inventory_item_ids.has(
			item.instance_id
		):
			errors.append(
				"Duplicate starting inventory item ID: %s."
				% item.instance_id
			)

			continue

		used_inventory_item_ids[
			item.instance_id
		] = true

	if starting_gold < 0:
		errors.append(
			"Starting gold cannot be negative."
		)

	var used_loot_item_ids: Dictionary = {}

	for loot_index in range(
		loot_catalog.size()
	):
		var loot_item := loot_catalog[
			loot_index
		]

		if loot_item == null:
			errors.append(
				"Loot catalog item at index %d is null."
				% loot_index
			)

			continue

		for item_error in (
			loot_item.get_validation_errors()
		):
			errors.append(
				"Loot catalog item %d: %s"
				% [
					loot_index,
					item_error,
				]
			)

		if not loot_item.is_loot_enabled():
			errors.append(
				"Loot catalog item '%s' has no loot value/tier."
				% loot_item.item_id
			)

		if loot_item.item_id == &"":
			continue

		if used_loot_item_ids.has(
			loot_item.item_id
		):
			errors.append(
				"Duplicate loot catalog item ID: %s."
				% loot_item.item_id
			)

			continue

		used_loot_item_ids[
			loot_item.item_id
		] = true

	if locations.is_empty():
		errors.append(
			"Campaign has no available locations."
		)

	var used_location_ids: Dictionary = {}

	for location_index in range(
		locations.size()
	):
		var location := locations[
			location_index
		]

		if location == null:
			errors.append(
				"Campaign location at index %d is null."
				% location_index
			)

			continue

		for location_error in (
			location.get_validation_errors()
		):
			errors.append(
				"Campaign location %d: %s"
				% [
					location_index,
					location_error,
				]
			)

		if used_location_ids.has(
			location.location_id
		):
			errors.append(
				"Duplicate campaign location ID: %s."
				% location.location_id
			)

			continue

		used_location_ids[
			location.location_id
		] = true

	var used_adventure_area_ids: Dictionary = {}

	for area_index in range(
		adventure_areas.size()
	):
		var area := adventure_areas[
			area_index
		]

		if area == null:
			errors.append(
				"Adventure area at index %d is null."
				% area_index
			)

			continue

		for area_error in (
			area.get_validation_errors()
		):
			errors.append(
				"Adventure area %d: %s"
				% [
					area_index,
					area_error,
				]
			)

		if area.area_id != &"":
			if used_adventure_area_ids.has(
				area.area_id
			):
				errors.append(
					"Duplicate adventure area ID: %s."
					% area.area_id
				)

			else:
				used_adventure_area_ids[
					area.area_id
				] = true

		for site in area.sites:
			if site == null:
				continue

			if (
				site.site_type
				== CampaignAdventureSiteDefinition
					.SiteType
					.BATTLE
				and get_location(
					site.campaign_location_id
				) == null
			):
				errors.append(
					"Adventure area '%s' site '%s' "
					% [
						area.area_id,
						site.site_id,
					]
					+"references unknown campaign location '%s'."
					% site.campaign_location_id
				)

	if world_map_definition == null:
		errors.append(
			"Campaign world map is not assigned."
		)

	else:
		for world_error in (
			world_map_definition
				.get_validation_errors()
		):
			errors.append(
				"Campaign world: %s"
				% world_error
			)

		for world_node in (
			world_map_definition.nodes
		):
			if (
				world_node == null
				or world_node.campaign_location_id
					== &""
			):
				continue

			if get_location(
				world_node.campaign_location_id
			) == null:
				errors.append(
					"World node '%s' references "
					% world_node.node_id
					+"unknown campaign location '%s'."
					% world_node.campaign_location_id
				)

			if (
				world_node != null
				and world_node.adventure_area_id
					!= &""
				and get_adventure_area(
					world_node.adventure_area_id
				) == null
			):
				errors.append(
					"World node '%s' references "
					% world_node.node_id
					+"unknown adventure area '%s'."
					% world_node.adventure_area_id
				)

		for route in (
			world_map_definition.routes
		):
			if (
				route == null
				or route.travel_event_profile == null
			):
				continue

			for entry in (
				route.travel_event_profile.entries
			):
				if (
					entry == null
					or entry.event == null
				):
					continue

				for event_node in (
					entry.event.nodes
				):
					if event_node == null:
						continue

					for choice in event_node.choices:
						if (
							choice == null
							or choice.action
								!= CampaignTravelEventChoice
									.Action
									.START_BATTLE
						):
							continue

						if get_location(
							choice.battle_location_id
						) == null:
							errors.append(
								"Travel event '%s' choice '%s' "
								% [
									entry.event.event_id,
									choice.choice_id,
								]
								+ "references unknown campaign "
								+ "location '%s'."
								% choice.battle_location_id
							)

	if starting_day < 0:
		errors.append(
			"Campaign starting day cannot be negative."
		)

	if (
		starting_minute_of_day < 0
		or starting_minute_of_day
			>= CampaignTimeService.MINUTES_PER_DAY
	):
		errors.append(
			"Campaign starting minute must be "
			+"between 0 and 1439."
		)
		
	if days_per_season <= 0:
		errors.append(
			"Campaign days per season must be positive."
		)

	if starting_materials < 0:
		errors.append(
			"Campaign starting materials cannot be negative."
		)

	if home_settlement_definition == null:
		errors.append(
			"Home settlement definition is not assigned."
		)

	else:
		for settlement_error in (
			home_settlement_definition
				.get_validation_errors()
		):
			errors.append(
				"Home settlement: %s"
				% settlement_error
			)

		if world_map_definition != null:
			var settlement_world_node := (
				world_map_definition.get_node(
					home_settlement_definition
						.world_node_id
				)
			)

			if settlement_world_node == null:
				errors.append(
					"Home settlement references "
					+ "unknown world node '%s'."
					% home_settlement_definition
						.world_node_id
				)

			elif (
				settlement_world_node.node_type
				!= CampaignWorldNodeDefinition
					.NodeType
					.HOME_SETTLEMENT
			):
				errors.append(
					"Home settlement world node "
					+ "must be HOME_SETTLEMENT."
				)

			else:
				var local_definition := (
					settlement_world_node
						.local_location_definition
				)

				if local_definition == null:
					errors.append(
						"Home settlement world node "
						+ "has no local location."
					)

				else:
					for settlement_zone in (
						home_settlement_definition.zones
					):
						if settlement_zone == null:
							continue

						## Settlement definition может заранее
						## содержать будущие content-зоны,
						## которые ещё не представлены
						## отдельной интерактивной точкой HOME.
						if (
							settlement_zone
								.local_interaction_id
							== &""
						):
							continue

						if (
							local_definition.get_interaction(
								settlement_zone
									.local_interaction_id
							)
							== null
						):
							errors.append(
								"Settlement zone '%s' references "
								% settlement_zone.zone_id
								+ "unknown local interaction '%s'."
								% settlement_zone
									.local_interaction_id
							)

	var used_resident_ids: Dictionary = {}

	for resident_index in range(
		residents.size()
	):
		var resident := residents[
			resident_index
		]

		if resident == null:
			errors.append(
				"Resident at index %d is null."
				% resident_index
			)

			continue

		for resident_error in (
			resident.get_validation_errors()
		):
			errors.append(
				"Resident %d: %s"
				% [
					resident_index,
					resident_error,
				]
			)

		if resident.resident_id != &"":
			if used_resident_ids.has(
				resident.resident_id
			):
				errors.append(
					"Duplicate resident ID: %s."
					% resident.resident_id
				)

			else:
				used_resident_ids[
					resident.resident_id
				] = true

		if world_map_definition != null:
			var origin_node := (
				world_map_definition.get_node(
					resident.origin_world_node_id
				)
			)

			if origin_node == null:
				errors.append(
					"Resident '%s' references "
					% resident.resident_id
					+ "unknown origin world node '%s'."
					% resident.origin_world_node_id
				)

			elif (
				origin_node.local_location_definition
				== null
			):
				errors.append(
					"Resident '%s' origin has no local location."
					% resident.resident_id
				)

			elif (
				origin_node
					.local_location_definition
					.get_interaction(
						resident.origin_interaction_id
					)
				== null
			):
				errors.append(
					"Resident '%s' references "
					% resident.resident_id
					+ "unknown origin interaction '%s'."
					% resident.origin_interaction_id
				)

		if (
			home_settlement_definition != null
			and world_map_definition != null
		):
			var home_node := (
				world_map_definition.get_node(
					home_settlement_definition
						.world_node_id
				)
			)

			if (
				home_node != null
				and home_node.local_location_definition != null
				and home_node
					.local_location_definition
					.get_interaction(
						resident.home_interaction_id
					)
					== null
			):
				errors.append(
					"Resident '%s' references "
					% resident.resident_id
					+ "unknown HOME interaction '%s'."
					% resident.home_interaction_id
				)

		if (
			resident.has_required_workplace()
			and home_settlement_definition != null
		):
			var workplace_zone := (
				home_settlement_definition.get_zone(
					resident.required_workplace_zone_id
				)
			)

			if workplace_zone == null:
				errors.append(
					"Resident '%s' references "
					% resident.resident_id
					+ "unknown workplace zone '%s'."
					% resident
						.required_workplace_zone_id
				)

			elif (
				workplace_zone.get_building(
					resident
						.required_workplace_building_id
				)
				== null
			):
				errors.append(
					"Resident '%s' references "
					% resident.resident_id
					+ "building '%s' that is not allowed "
					% resident
						.required_workplace_building_id
					+ "in workplace zone."
				)

	var used_trader_ids: Dictionary = {}

	for trader_index in range(
		traders.size()
	):
		var trader: CampaignTraderDefinition = (
			traders[trader_index]
		)

		if trader == null:
			errors.append(
				"Trader at index %d is null."
				% trader_index
			)

			continue

		for trader_error in (
			trader.get_validation_errors()
		):
			errors.append(
				"Trader %d: %s"
				% [
					trader_index,
					trader_error,
				]
			)

		if trader.trader_id != &"":
			if used_trader_ids.has(
				trader.trader_id
			):
				errors.append(
					"Duplicate trader ID: %s."
					% trader.trader_id
				)

			else:
				used_trader_ids[
					trader.trader_id
				] = true

		if world_map_definition == null:
			continue

		var trader_node := (
			world_map_definition.get_node(
				trader.world_node_id
			)
		)

		if trader_node == null:
			errors.append(
				"Trader '%s' references unknown "
				% trader.trader_id
				+"world node '%s'."
				% trader.world_node_id
			)

			continue

		if trader_node.local_location_definition == null:
			errors.append(
				"Trader '%s' world node "
				% trader.trader_id
				+"has no local location."
			)

			continue

		if (
			trader_node
				.local_location_definition
				.get_interaction(
					trader.local_interaction_id
				)
			== null
		):
			errors.append(
				"Trader '%s' references unknown "
				% trader.trader_id
				+"local interaction '%s'."
				% trader.local_interaction_id
			)

	var used_quest_ids: Dictionary = {}

	for quest_index in range(
		quests.size()
	):
		var quest := quests[
			quest_index
		]

		if quest == null:
			errors.append(
				"Quest at index %d is null."
				% quest_index
			)

			continue

		for quest_error in (
			quest.get_validation_errors()
		):
			errors.append(
				"Quest %d: %s"
				% [
					quest_index,
					quest_error,
				]
			)

		if quest.quest_id != &"":
			if used_quest_ids.has(
				quest.quest_id
			):
				errors.append(
					"Duplicate quest ID: %s."
					% quest.quest_id
				)

			else:
				used_quest_ids[
					quest.quest_id
				] = true

		match quest.giver_kind:
			CampaignQuestDefinition.GiverKind.RESIDENT:
				if get_resident(
					quest.giver_resident_id
				) == null:
					errors.append(
						"Quest '%s' references "
						% quest.quest_id
						+ "unknown giver resident '%s'."
						% quest.giver_resident_id
					)

			CampaignQuestDefinition.GiverKind.LOCAL_INTERACTION:
				if world_map_definition == null:
					errors.append(
						"Quest '%s' local giver requires a world map."
						% quest.quest_id
					)

				else:
					var giver_world_node := (
						world_map_definition.get_node(
							quest.giver_world_node_id
						)
					)

					if giver_world_node == null:
						errors.append(
							"Quest '%s' references unknown giver world node '%s'."
							% [
								quest.quest_id,
								quest.giver_world_node_id,
							]
						)

					elif giver_world_node.local_location_definition == null:
						errors.append(
							"Quest '%s' giver world node '%s' has no local location."
							% [
								quest.quest_id,
								quest.giver_world_node_id,
							]
						)

					elif (
						giver_world_node
							.local_location_definition
							.get_interaction(
								quest.giver_local_interaction_id
							)
						== null
					):
						errors.append(
							"Quest '%s' references unknown giver local interaction '%s'."
							% [
								quest.quest_id,
								quest.giver_local_interaction_id,
							]
						)

		for objective in quest.objectives:
			if objective == null:
				continue

			if (
				objective.objective_type
				== CampaignQuestObjectiveDefinition
					.ObjectiveType
					.WIN_LOCATION_BATTLE
				and get_location(
					objective.target_location_id
				) == null
			):
				errors.append(
					"Quest '%s' objective '%s' "
					% [
						quest.quest_id,
						objective.objective_id,
					]
					+ "references unknown location '%s'."
					% objective.target_location_id
				)

		for unlock_resident_id in (
			quest.recruitment_unlock_resident_ids
		):
			if get_resident(
				unlock_resident_id
			) == null:
				errors.append(
					"Quest '%s' recruitment reward "
					% quest.quest_id
					+ "references unknown resident '%s'."
					% unlock_resident_id
				)

		for unlock in (
			quest.start_adventure_site_unlocks
		):
			if unlock == null:
				continue

			var area := get_adventure_area(
				unlock.area_id
			)

			if area == null:
				errors.append(
					"Quest '%s' references "
					% quest.quest_id
					+"unknown adventure area '%s'."
					% unlock.area_id
				)

				continue

			if area.get_site(
				unlock.site_id
			) == null:
				errors.append(
					"Quest '%s' references "
					% quest.quest_id
					+"unknown adventure site '%s/%s'."
					% [
						unlock.area_id,
						unlock.site_id,
					]
				)

	# Resolve dialogue references against this campaign, after content validation.
	for resident in residents:
		if resident != null and resident.dialogue != null:
			errors.append_array(resident.dialogue.get_reference_errors(self))
	if world_map_definition != null:
		for world_node in world_map_definition.nodes:
			if world_node == null or world_node.local_location_definition == null:
				continue
			for interaction in world_node.local_location_definition.interactions:
				if interaction != null and interaction.dialogue != null:
					errors.append_array(interaction.dialogue.get_reference_errors(self))
	return errors


func get_location(
	location_id: StringName
) -> CampaignLocationDefinition:
	if location_id == &"":
		return null

	for location in locations:
		if (
			location != null
			and location.location_id == location_id
		):
			return location

	return null


func get_resident(
	resident_id: StringName
) -> CampaignResidentDefinition:
	if resident_id == &"":
		return null

	for resident in residents:
		if (
			resident != null
			and resident.resident_id
				== resident_id
		):
			return resident

	return null

func get_equipment_item_definition(
	item_id: StringName
) -> HeroEquipmentItemDefinition:
	if item_id == &"":
		return null

	var result: HeroEquipmentItemDefinition = null

	for item_instance in starting_inventory_items:
		if (
			item_instance == null
			or item_instance.definition == null
			or item_instance.definition.item_id
				!= item_id
		):
			continue

		if (
			result != null
			and result
				!= item_instance.definition
		):
			return null

		result = item_instance.definition

	for item_definition in loot_catalog:
		if (
			item_definition == null
			or item_definition.item_id
				!= item_id
		):
			continue

		if (
			result != null
			and result
				!= item_definition
		):
			return null

		result = item_definition

	for resident in residents:
		if resident == null:
			continue

		for commission in (
			resident.equipment_commissions
		):
			if (
				commission == null
				or commission.output_item_definition
					== null
				or commission
					.output_item_definition
					.item_id
					!= item_id
			):
				continue

			if (
				result != null
				and result
					!= commission
						.output_item_definition
			):
				return null

			result = (
				commission.output_item_definition
			)

	for trader in traders:
		if trader == null:
			continue

		for stock_entry in trader.starting_stock:
			if (
				stock_entry == null
				or stock_entry.item_definition == null
				or stock_entry.item_definition.item_id
					!= item_id
			):
				continue

			if (
				result != null
				and result
					!= stock_entry.item_definition
			):
				return null

			result = (
				stock_entry.item_definition
			)

	return result


func get_trader(
	trader_id: StringName
) -> CampaignTraderDefinition:
	if trader_id == &"":
		return null

	for trader in traders:
		if (
			trader != null
			and trader.trader_id == trader_id
		):
			return trader

	return null


func get_trader_for_interaction(
	world_node_id: StringName,
	interaction_id: StringName
) -> CampaignTraderDefinition:
	if (
		world_node_id == &""
		or interaction_id == &""
	):
		return null

	for trader in traders:
		if (
			trader != null
			and trader.world_node_id == world_node_id
			and trader.local_interaction_id
				== interaction_id
		):
			return trader

	return null


func get_quest(
	quest_id: StringName
) -> CampaignQuestDefinition:
	if quest_id == &"":
		return null

	for quest in quests:
		if (
			quest != null
			and quest.quest_id == quest_id
		):
			return quest

	return null


func get_adventure_area(
	area_id: StringName
) -> CampaignAdventureAreaDefinition:
	if area_id == &"":
		return null

	for area in adventure_areas:
		if (
			area != null
			and area.area_id == area_id
		):
			return area

	return null