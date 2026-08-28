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

@export_group("World")

@export
var world_map_definition: CampaignWorldMapDefinition

## Абсолютный игровой день старта кампании.
## Ноль — первый день первого сезона.
@export_range(0, 999999999, 1)
var starting_day: int = 0

## Количество дней в одном сезоне.
## Сам сезон является derived data и отдельно
## в CampaignState не сохраняется.
@export_range(1, 9999, 1)
var days_per_season: int = 20

@export_range(-999999999, 999999999, 1)
var starting_reputation: int = 0

@export_range(0, 999999999, 1)
var starting_materials: int = 0


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
					+ "unknown campaign location '%s'."
					% world_node.campaign_location_id
				)

	if starting_day < 0:
		errors.append(
			"Campaign starting day cannot be negative."
		)

	if days_per_season <= 0:
		errors.append(
			"Campaign days per season must be positive."
		)

	if starting_materials < 0:
		errors.append(
			"Campaign starting materials cannot be negative."
		)

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

func get_equipment_item_definition(
	item_id: StringName
) -> HeroEquipmentItemDefinition:
	if item_id == &"":
		return null

	var result: HeroEquipmentItemDefinition

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

	return result