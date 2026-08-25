class_name HeroExperienceService
extends RefCounted


const MAX_LEVEL: int = 999

const BASE_EXPERIENCE_TO_NEXT_LEVEL: int = 100
const EXPERIENCE_GROWTH_PER_LEVEL: int = 50


func get_experience_required_for_next_level(
	level: int
) -> int:
	var safe_level := maxi(
		level,
		1
	)

	if safe_level >= MAX_LEVEL:
		return 0

	return (
		BASE_EXPERIENCE_TO_NEXT_LEVEL
		+ EXPERIENCE_GROWTH_PER_LEVEL
		* (safe_level - 1)
	)


func get_progress_ratio(
	progression: HeroProgressionState
) -> float:
	if progression == null:
		return 0.0

	if progression.level >= MAX_LEVEL:
		return 1.0

	var required := get_experience_required_for_next_level(
		progression.level
	)

	if required <= 0:
		return 1.0

	return clampf(
		float(progression.experience)
		/ float(required),
		0.0,
		1.0
	)


## Возвращает количество полученных уровней.
func grant_experience(
	progression: HeroProgressionState,
	amount: int
) -> int:
	if (
		progression == null
		or amount <= 0
	):
		return 0

	if progression.level >= MAX_LEVEL:
		progression.level = MAX_LEVEL
		progression.experience = 0

		return 0

	progression.experience += amount

	var gained_levels: int = 0

	while progression.level < MAX_LEVEL:
		var required := (
			get_experience_required_for_next_level(
				progression.level
			)
		)

		if (
			required <= 0
			or progression.experience < required
		):
			break

		progression.experience -= required
		progression.level += 1
		progression.unspent_skill_points += 1
		gained_levels += 1

	if progression.level >= MAX_LEVEL:
		progression.level = MAX_LEVEL
		progression.experience = 0

	return gained_levels
