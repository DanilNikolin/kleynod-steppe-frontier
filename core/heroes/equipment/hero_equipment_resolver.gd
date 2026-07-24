class_name HeroEquipmentResolver
extends RefCounted


func resolve(
	state: HeroEquipmentState
) -> HeroEquipmentResolution:
	var result := HeroEquipmentResolution.new()

	if state == null:
		result.is_valid = true
		return result

	for state_error in state.get_validation_errors():
		result.errors.append(
			state_error
		)

	if not result.errors.is_empty():
		return result

	var used_instance_ids: Dictionary = {}
	var used_ability_ids: Dictionary = {}

	for slot in HeroEquipmentState.get_all_slots():
		var item := state.get_item(
			slot
		)

		if item == null:
			continue

		if used_instance_ids.has(
			item.instance_id
		):
			continue

		used_instance_ids[
			item.instance_id
		] = true

		result.equipped_items.append(
			item
		)

		var definition := item.definition

		if definition.stat_bonuses != null:
			result.stat_bonuses.add_from(
				definition.stat_bonuses
			)

		for ability in definition.granted_abilities:
			if (
				ability == null
				or used_ability_ids.has(
					ability.ability_id
				)
			):
				continue

			used_ability_ids[
				ability.ability_id
			] = true

			result.granted_abilities.append(
				ability
			)

	result.is_valid = true
	return result