class_name BattleLootRewardRoll
extends RefCounted


var total_budget: int = 0
var tier_cap: int = 0

var combined_loot_tags: Array[StringName] = []
var primary_loot_tags: Array[StringName] = []

var dropped_item_definitions: Array[HeroEquipmentItemDefinition] = []

var spent_item_value: int = 0
var gold_reward: int = 0


func has_items() -> bool:
	return not dropped_item_definitions.is_empty()


func get_item_display_names() -> PackedStringArray:
	var result := PackedStringArray()

	for definition in dropped_item_definitions:
		if definition == null:
			continue

		result.append(
			definition.display_name
		)

	return result