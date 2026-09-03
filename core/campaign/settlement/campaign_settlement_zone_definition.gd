@tool
class_name CampaignSettlementZoneDefinition
extends Resource


enum ZoneKind {
	WORKSHOP,
	RIVERBANK,
	STEPPE,
	HOUSEHOLD,
	TRADE,
	RESIDENTIAL,
	HEALING,
	DEFENSE,
	LANDMARK,
}


@export_group("Identity")

@export
var zone_id: StringName = &""

@export
var display_name: String = "Unnamed Zone"

@export_multiline
var description: String = ""

@export
var zone_kind: ZoneKind = ZoneKind.WORKSHOP


@export_group("Presentation")

## Позже свяжем эту зону с конкретной точкой
## внутри длинной side-view HOME location.
@export
var local_interaction_id: StringName = &""


@export_group("Buildings")

@export
var allowed_buildings: Array[CampaignSettlementBuildingDefinition] = []

## Пустое значение означает, что участок
## начинает кампанию незастроенным.
@export
var starting_building_id: StringName = &""


func get_building(
	building_id: StringName
) -> CampaignSettlementBuildingDefinition:
	if building_id == &"":
		return null

	for building in allowed_buildings:
		if (
			building != null
			and building.building_id == building_id
		):
			return building

	return null


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if zone_id == &"":
		errors.append(
			"Settlement zone ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Settlement zone display name is empty."
		)

	if allowed_buildings.is_empty():
		errors.append(
			"Settlement zone has no allowed buildings."
		)

	var used_building_ids: Dictionary = {}

	for building_index in range(
		allowed_buildings.size()
	):
		var building := allowed_buildings[
			building_index
		]

		if building == null:
			errors.append(
				"Settlement building at index %d is null."
				% building_index
			)

			continue

		for building_error in (
			building.get_validation_errors()
		):
			errors.append(
				"Building %d: %s"
				% [
					building_index,
					building_error,
				]
			)

		if building.building_id == &"":
			continue

		if used_building_ids.has(
			building.building_id
		):
			errors.append(
				"Duplicate building ID '%s' in zone '%s'."
				% [
					building.building_id,
					zone_id,
				]
			)

			continue

		used_building_ids[
			building.building_id
		] = true

	if (
		starting_building_id != &""
		and not used_building_ids.has(
			starting_building_id
		)
	):
		errors.append(
			"Starting building '%s' is not allowed in zone '%s'."
			% [
				starting_building_id,
				zone_id,
			]
		)

	return errors