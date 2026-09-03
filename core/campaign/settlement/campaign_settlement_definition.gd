@tool
class_name CampaignSettlementDefinition
extends Resource


@export_group("Identity")

@export
var settlement_id: StringName = &""

@export
var display_name: String = "Unnamed Settlement"

@export_multiline
var description: String = ""


@export_group("World")

## Stable ID World Node, где физически находится
## собственное поселение игрока.
@export
var world_node_id: StringName = &""


@export_group("Zones")

@export
var zones: Array[CampaignSettlementZoneDefinition] = []


func get_zone(
	zone_id: StringName
) -> CampaignSettlementZoneDefinition:
	if zone_id == &"":
		return null

	for zone in zones:
		if (
			zone != null
			and zone.zone_id == zone_id
		):
			return zone

	return null


func get_zone_by_local_interaction_id(
	interaction_id: StringName
) -> CampaignSettlementZoneDefinition:
	if interaction_id == &"":
		return null

	for zone in zones:
		if (
			zone != null
			and zone.local_interaction_id
				== interaction_id
		):
			return zone

	return null


func get_building(
	building_id: StringName
) -> CampaignSettlementBuildingDefinition:
	if building_id == &"":
		return null

	for zone in zones:
		if zone == null:
			continue

		var building := zone.get_building(
			building_id
		)

		if building != null:
			return building

	return null


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if settlement_id == &"":
		errors.append(
			"Settlement ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Settlement display name is empty."
		)

	if world_node_id == &"":
		errors.append(
			"Settlement world node ID is empty."
		)

	if zones.is_empty():
		errors.append(
			"Settlement has no zones."
		)

	var used_zone_ids: Dictionary = {}
	var used_building_ids: Dictionary = {}
	var used_local_interaction_ids: Dictionary = {}

	for zone_index in range(
		zones.size()
	):
		var zone := zones[
			zone_index
		]

		if zone == null:
			errors.append(
				"Settlement zone at index %d is null."
				% zone_index
			)

			continue

		for zone_error in (
			zone.get_validation_errors()
		):
			errors.append(
				"Zone %d: %s"
				% [
					zone_index,
					zone_error,
				]
			)

		if zone.zone_id != &"":
			if used_zone_ids.has(
				zone.zone_id
			):
				errors.append(
					"Duplicate settlement zone ID: %s."
					% zone.zone_id
				)

			else:
				used_zone_ids[
					zone.zone_id
				] = true

		if zone.local_interaction_id != &"":
			if used_local_interaction_ids.has(
				zone.local_interaction_id
			):
				errors.append(
					"Settlement zones share local interaction '%s'."
					% zone.local_interaction_id
				)

			else:
				used_local_interaction_ids[
					zone.local_interaction_id
				] = true

		for building in (
			zone.allowed_buildings
		):
			if (
				building == null
				or building.building_id == &""
			):
				continue

			if used_building_ids.has(
				building.building_id
			):
				errors.append(
					"Building ID '%s' is used by multiple zones."
					% building.building_id
				)

			else:
				used_building_ids[
					building.building_id
				] = true

	return errors