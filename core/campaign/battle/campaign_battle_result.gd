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

## Полный XP pool со всех реально побеждённых врагов.
var defeated_enemy_experience_pool: int = 0

## Одинаковая целая доля, выданная каждому участнику боя.
var experience_per_party_member: int = 0

## Остаток integer division.
## Намеренно не распределяется, чтобы все участники
## получали строго одинаковое количество XP.
var undistributed_experience: int = 0

## hero_id -> количество level-up в этом бою.
var level_ups_by_hero_id: Dictionary = {}


func get_level_ups_for_hero(
	hero_id: StringName
) -> int:
	if hero_id == &"":
		return 0

	return int(
		level_ups_by_hero_id.get(
			hero_id,
			0
		)
	)


func has_level_ups() -> bool:
	return not level_ups_by_hero_id.is_empty()


func get_outcome_display_name() -> String:
	match outcome:
		Outcome.VICTORY:
			return "Победа"

		Outcome.DEFEAT:
			return "Поражение"

		Outcome.DRAW:
			return "Бой завершён без победителя"

	return "Нет результата"