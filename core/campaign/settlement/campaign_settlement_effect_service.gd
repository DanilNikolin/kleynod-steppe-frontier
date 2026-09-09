class_name CampaignSettlementEffectService
extends RefCounted


func get_active_effects(
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState
) -> Array[CampaignSettlementEffectDefinition]:
	var result: Array[CampaignSettlementEffectDefinition] = []

	if (
		settlement_definition == null
		or settlement_state == null
		or not settlement_state.is_valid_against_definition(
			settlement_definition
		)
	):
		return result

	var used_effect_ids: Dictionary = {}

	for zone_definition in (
		settlement_definition.zones
	):
		if zone_definition == null:
			continue

		var zone_state := (
			settlement_state.get_zone(
				zone_definition.zone_id
			)
		)

		if (
			zone_state == null
			or zone_state.is_empty()
		):
			continue

		var building := (
			zone_definition.get_building(
				zone_state.building_id
			)
		)

		if building == null:
			continue

		for effect in (
			building.get_active_effects_for_level(
				zone_state.building_level
			)
		):
			if (
				effect == null
				or effect.effect_id == &""
				or used_effect_ids.has(
					effect.effect_id
				)
			):
				continue

			used_effect_ids[
				effect.effect_id
			] = true

			result.append(
				effect
			)

	return result


func has_active_effect(
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState,
	effect_id: StringName
) -> bool:
	if effect_id == &"":
		return false

	for effect in get_active_effects(
		settlement_definition,
		settlement_state
	):
		if effect.effect_id == effect_id:
			return true

	return false