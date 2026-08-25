class_name CampaignLootRewardApplicationService
extends RefCounted


func apply_reward(
	battle_result: CampaignBattleResult,
	loot_roll: BattleLootRewardRoll,
	inventory: CampaignInventoryState,
	allow_reward: bool
) -> bool:
	if (
		battle_result == null
		or inventory == null
	):
		return false

	if loot_roll == null:
		return true

	battle_result.loot_budget = (
		loot_roll.total_budget
	)

	battle_result.loot_tier_cap = (
		loot_roll.tier_cap
	)

	if not allow_reward:
		return true

	var generated_instances: Array[HeroEquipmentItemInstance] = []

	var next_serial := maxi(
		inventory.next_generated_item_serial,
		1
	)

	for definition in (
		loot_roll.dropped_item_definitions
	):
		if (
			definition == null
			or not definition.is_valid_definition()
			or not definition.is_loot_enabled()
		):
			return false

		var instance_id: StringName = &""

		while instance_id == &"":
			var candidate_id := StringName(
				"loot_%06d_%s"
				% [
					next_serial,
					definition.item_id,
				]
			)

			next_serial += 1

			if inventory.has_item(
				candidate_id
			):
				continue

			if _contains_instance_id(
				generated_instances,
				candidate_id
			):
				continue

			instance_id = candidate_id

		var instance := (
			HeroEquipmentItemInstance.new()
		)

		instance.instance_id = instance_id
		instance.definition = definition

		if not instance.is_valid_instance():
			return false

		generated_instances.append(
			instance
		)

	## До этой точки мы только готовили данные.
	## Реальное состояние меняем после полной проверки.
	inventory.gold += maxi(
		loot_roll.gold_reward,
		0
	)

	inventory.next_generated_item_serial = (
		next_serial
	)

	battle_result.gold_reward = maxi(
		loot_roll.gold_reward,
		0
	)

	battle_result.loot_item_value = (
		loot_roll.spent_item_value
	)

	for instance in generated_instances:
		inventory.items.append(instance)
		battle_result.loot_item_instance_ids.append(instance.instance_id)
		battle_result.loot_item_display_names.append(instance.definition.display_name)

	return true


func _contains_instance_id(
	instances: Array[HeroEquipmentItemInstance],
	instance_id: StringName
) -> bool:
	for instance in instances:
		if (
			instance != null
			and instance.instance_id
				== instance_id
		):
			return true

	return false