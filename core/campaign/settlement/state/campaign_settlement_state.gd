class_name CampaignSettlementState
extends RefCounted


var settlement_id: StringName = &""

var zones: Array[CampaignSettlementZoneState] = []


func get_zone(
	zone_id: StringName
) -> CampaignSettlementZoneState:
	if zone_id == &"":
		return null

	for zone in zones:
		if (
			zone != null
			and zone.zone_id == zone_id
		):
			return zone

	return null


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if settlement_id == &"":
		errors.append(
			"Settlement state ID is empty."
		)

	var used_zone_ids: Dictionary = {}

	for zone_index in range(
		zones.size()
	):
		var zone := zones[
			zone_index
		]

		if zone == null:
			errors.append(
				"Settlement zone state at index %d is null."
				% zone_index
			)

			continue

		for zone_error in (
			zone.get_validation_errors()
		):
			errors.append(
				"Settlement zone state %d: %s"
				% [
					zone_index,
					zone_error,
				]
			)

		if zone.zone_id == &"":
			continue

		if used_zone_ids.has(
			zone.zone_id
		):
			errors.append(
				"Duplicate settlement zone state ID: %s."
				% zone.zone_id
			)

			continue

		used_zone_ids[
			zone.zone_id
		] = true

	return errors


func is_valid_against_definition(
	definition: CampaignSettlementDefinition
) -> bool:
	return (
		get_definition_validation_errors(
			definition
		).is_empty()
	)


func get_definition_validation_errors(
	definition: CampaignSettlementDefinition
) -> PackedStringArray:
	var errors := get_validation_errors()

	if definition == null:
		errors.append(
			"Settlement definition is missing."
		)

		return errors

	if settlement_id != definition.settlement_id:
		errors.append(
			"Settlement state '%s' does not match definition '%s'."
			% [
				settlement_id,
				definition.settlement_id,
			]
		)

	if zones.size() != definition.zones.size():
		errors.append(
			"Settlement state zone count does not match definition."
		)

	for zone_definition in definition.zones:
		if zone_definition == null:
			continue

		var zone_state := get_zone(
			zone_definition.zone_id
		)

		if zone_state == null:
			errors.append(
				"Settlement state is missing zone '%s'."
				% zone_definition.zone_id
			)

			continue

		if zone_state.building_id == &"":
			continue

		var building_definition := (
			zone_definition.get_building(
				zone_state.building_id
			)
		)

		if building_definition == null:
			errors.append(
				"Zone '%s' contains disallowed building '%s'."
				% [
					zone_state.zone_id,
					zone_state.building_id,
				]
			)

			continue

		if (
			zone_state.building_level
			> building_definition.max_level
		):
			errors.append(
				"Building '%s' level %d exceeds max level %d."
				% [
					zone_state.building_id,
					zone_state.building_level,
					building_definition.max_level,
				]
			)

	return errors