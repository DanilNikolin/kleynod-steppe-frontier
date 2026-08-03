class_name CampaignState
extends RefCounted


var campaign_id: StringName = &""

var heroes: Array[CampaignHeroState] = []

var active_hero_id: StringName = &""
var current_location_id: StringName = &""

var completed_battle_count: int = 0

var last_battle_result: CampaignBattleResult


func get_hero(
	hero_id: StringName
) -> CampaignHeroState:
	if hero_id == &"":
		return null

	for hero_state in heroes:
		if (
			hero_state != null
			and hero_state.get_hero_id() == hero_id
		):
			return hero_state

	return null


func get_active_hero() -> CampaignHeroState:
	return get_hero(
		active_hero_id
	)