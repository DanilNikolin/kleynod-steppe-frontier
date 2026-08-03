class_name CampaignBattleResult
extends RefCounted


enum Outcome {
	NONE,
	VICTORY,
	DEFEAT,
	DRAW,
}


var request_id: StringName = &""

var location_id: StringName = &""
var encounter_id: StringName = &""

var party_member_hero_ids: Array[StringName] = []

var winning_team_id: StringName = &""

var outcome: Outcome = Outcome.NONE


func get_outcome_display_name() -> String:
	match outcome:
		Outcome.VICTORY:
			return "Победа"

		Outcome.DEFEAT:
			return "Поражение"

		Outcome.DRAW:
			return "Бой завершён без победителя"

	return "Нет результата"