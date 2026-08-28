class_name CampaignCalendarRules
extends RefCounted


enum Season {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER,
}


const SEASON_COUNT: int = 4


func get_season(
	current_day: int,
	days_per_season: int
) -> int:
	if (
		current_day < 0
		or days_per_season <= 0
	):
		return Season.SPRING

	var season_number := floori(
		float(current_day)
		/ float(days_per_season)
	)

	return (
		season_number
		% SEASON_COUNT
	)


func get_year_number(
	current_day: int,
	days_per_season: int
) -> int:
	if (
		current_day < 0
		or days_per_season <= 0
	):
		return 1

	var days_per_year := (
		days_per_season
		* SEASON_COUNT
	)

	return floori(
		float(current_day)
		/ float(days_per_year)
	) + 1


func get_day_in_season(
	current_day: int,
	days_per_season: int
) -> int:
	if (
		current_day < 0
		or days_per_season <= 0
	):
		return 1

	return (
		current_day
		% days_per_season
	) + 1


func get_day_in_year(
	current_day: int,
	days_per_season: int
) -> int:
	if (
		current_day < 0
		or days_per_season <= 0
	):
		return 1

	var days_per_year := (
		days_per_season
		* SEASON_COUNT
	)

	return (
		current_day
		% days_per_year
	) + 1


func get_absolute_day_number(
	current_day: int
) -> int:
	return maxi(
		current_day + 1,
		1
	)