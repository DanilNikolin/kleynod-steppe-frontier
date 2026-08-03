@tool
class_name CampaignDefinition
extends Resource


@export_group("Identity")

@export
var campaign_id: StringName = &""

@export
var display_name: String = "Unnamed Campaign"


@export_group("Heroes")

@export
var starting_heroes: Array[CampaignHeroState] = []

@export
var starting_active_hero_id: StringName = &""


@export_group("Inventory")

@export
var starting_inventory_items: Array[HeroEquipmentItemInstance] = []


@export_group("Locations")

@export
var locations: Array[CampaignLocationDefinition] = []


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

	if starting_active_hero_id == &"":
		errors.append(
			"Starting active hero ID is empty."
		)

	elif not used_hero_ids.has(
		starting_active_hero_id
	):
		errors.append(
			"Starting active hero '%s' does not exist."
			% starting_active_hero_id
		)

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