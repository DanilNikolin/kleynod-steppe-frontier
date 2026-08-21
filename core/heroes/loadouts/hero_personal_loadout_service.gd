class_name HeroPersonalLoadoutService
extends RefCounted


const FAILURE_INVALID_HERO: StringName = (
	&"invalid_hero_definition"
)

const FAILURE_INVALID_PROGRESSION: StringName = (
	&"invalid_progression_state"
)

const FAILURE_INVALID_SKILL_GRID_STATE: StringName = (
	&"invalid_skill_grid_state"
)

const FAILURE_INVALID_CURRENT_LOADOUT: StringName = (
	&"invalid_current_loadout"
)

const FAILURE_EMPTY_ABILITY_ID: StringName = (
	&"empty_ability_id"
)

const FAILURE_UNKNOWN_ABILITY: StringName = (
	&"unknown_personal_ability"
)

const FAILURE_ABILITY_NOT_KNOWN: StringName = (
	&"ability_not_known"
)

const FAILURE_ALREADY_SELECTED: StringName = (
	&"ability_already_selected"
)

const FAILURE_NOT_SELECTED: StringName = (
	&"ability_not_selected"
)

const FAILURE_NO_ACTIVE_SLOT: StringName = (
	&"no_active_slot_available"
)

const FAILURE_DEFAULT_ABILITY_REQUIRED: StringName = (
	&"default_ability_required"
)


var skill_grid_resolver := (
	SkillGridResolver.new()
)


func get_known_ability_ids(
	hero: HeroDefinition,
	progression: HeroProgressionState
) -> Array[StringName]:
	var result: Array[StringName] = []

	var grid_resolution := _resolve_grid(
		hero,
		progression
	)

	if grid_resolution == null:
		return result

	for ability_id in (
		hero.starting_known_ability_ids
	):
		if result.has(
			ability_id
		):
			continue

		result.append(
			ability_id
		)

	for ability_id in (
		grid_resolution.learned_ability_ids
	):
		if result.has(
			ability_id
		):
			continue

		result.append(
			ability_id
		)

	return result


func get_active_slot_count(
	hero: HeroDefinition,
	progression: HeroProgressionState
) -> int:
	var grid_resolution := _resolve_grid(
		hero,
		progression
	)

	if grid_resolution == null:
		return 0

	return clampi(
		hero.starting_active_slot_count
			+ grid_resolution
				.stat_bonuses
				.active_slot_bonus,
		1,
		hero.maximum_active_slot_count
	)


func get_effective_selected_ability_ids(
	hero: HeroDefinition,
	progression: HeroProgressionState
) -> Array[StringName]:
	var result: Array[StringName] = []

	if (
		hero == null
		or progression == null
	):
		return result

	if not (
		progression
			.selected_personal_ability_ids
			.is_empty()
	):
		for ability_id in (
			progression
				.selected_personal_ability_ids
		):
			result.append(
				ability_id
			)

		return result

	var active_slot_count := get_active_slot_count(
		hero,
		progression
	)

	for ability_id in (
		hero.starting_known_ability_ids
	):
		if result.size() >= active_slot_count:
			break

		result.append(
			ability_id
		)

	return result


func get_add_result(
	hero: HeroDefinition,
	progression: HeroProgressionState,
	ability_id: StringName
) -> HeroPersonalLoadoutChangeResult:
	var result := HeroPersonalLoadoutChangeResult.new()

	result.ability_id = ability_id

	var context_failure := _get_context_failure(
		hero,
		progression
	)

	if context_failure != &"":
		result.failure_code = context_failure
		return result

	if ability_id == &"":
		result.failure_code = (
			FAILURE_EMPTY_ABILITY_ID
		)

		return result

	if not hero.has_personal_ability(
		ability_id
	):
		result.failure_code = (
			FAILURE_UNKNOWN_ABILITY
		)

		return result

	var known_ability_ids := (
		get_known_ability_ids(
			hero,
			progression
		)
	)

	if not known_ability_ids.has(
		ability_id
	):
		result.failure_code = (
			FAILURE_ABILITY_NOT_KNOWN
		)

		return result

	var selected_ability_ids := (
		get_effective_selected_ability_ids(
			hero,
			progression
		)
	)

	result.active_slot_count = (
		get_active_slot_count(
			hero,
			progression
		)
	)

	_copy_ids(
		selected_ability_ids,
		result.previous_selected_ability_ids
	)

	_copy_ids(
		selected_ability_ids,
		result.current_selected_ability_ids
	)

	var selection_failure := (
		_get_selection_failure(
			hero,
			known_ability_ids,
			selected_ability_ids,
			result.active_slot_count
		)
	)

	if selection_failure != &"":
		result.failure_code = selection_failure
		return result

	if selected_ability_ids.has(
		ability_id
	):
		result.failure_code = (
			FAILURE_ALREADY_SELECTED
		)

		return result

	if (
		selected_ability_ids.size()
		>= result.active_slot_count
	):
		result.failure_code = (
			FAILURE_NO_ACTIVE_SLOT
		)

		return result

	result.current_selected_ability_ids.append(
		ability_id
	)

	result.is_successful = true
	return result


func add_ability(
	hero: HeroDefinition,
	progression: HeroProgressionState,
	ability_id: StringName
) -> HeroPersonalLoadoutChangeResult:
	var result := get_add_result(
		hero,
		progression,
		ability_id
	)

	if not result.is_successful:
		return result

	progression.selected_personal_ability_ids.clear()

	for selected_ability_id in (
		result.current_selected_ability_ids
	):
		progression.selected_personal_ability_ids.append(
			selected_ability_id
		)

	return result


func get_remove_result(
	hero: HeroDefinition,
	progression: HeroProgressionState,
	ability_id: StringName
) -> HeroPersonalLoadoutChangeResult:
	var result := HeroPersonalLoadoutChangeResult.new()

	result.ability_id = ability_id

	var context_failure := _get_context_failure(
		hero,
		progression
	)

	if context_failure != &"":
		result.failure_code = context_failure
		return result

	if ability_id == &"":
		result.failure_code = (
			FAILURE_EMPTY_ABILITY_ID
		)

		return result

	if not hero.has_personal_ability(
		ability_id
	):
		result.failure_code = (
			FAILURE_UNKNOWN_ABILITY
		)

		return result

	var known_ability_ids := (
		get_known_ability_ids(
			hero,
			progression
		)
	)

	var selected_ability_ids := (
		get_effective_selected_ability_ids(
			hero,
			progression
		)
	)

	result.active_slot_count = (
		get_active_slot_count(
			hero,
			progression
		)
	)

	_copy_ids(
		selected_ability_ids,
		result.previous_selected_ability_ids
	)

	_copy_ids(
		selected_ability_ids,
		result.current_selected_ability_ids
	)

	var selection_failure := (
		_get_selection_failure(
			hero,
			known_ability_ids,
			selected_ability_ids,
			result.active_slot_count
		)
	)

	if selection_failure != &"":
		result.failure_code = selection_failure
		return result

	if not selected_ability_ids.has(
		ability_id
	):
		result.failure_code = (
			FAILURE_NOT_SELECTED
		)

		return result

	## Только старые debug-герои ещё держат
	## default ability внутри personal loadout.
	if (
		hero.fallback_ability == null
		and ability_id == hero.default_ability_id
	):
		result.failure_code = (
			FAILURE_DEFAULT_ABILITY_REQUIRED
		)

		return result

	result.current_selected_ability_ids.erase(
		ability_id
	)

	result.is_successful = true
	return result


func remove_ability(
	hero: HeroDefinition,
	progression: HeroProgressionState,
	ability_id: StringName
) -> HeroPersonalLoadoutChangeResult:
	var result := get_remove_result(
		hero,
		progression,
		ability_id
	)

	if not result.is_successful:
		return result

	progression.selected_personal_ability_ids.clear()

	for selected_ability_id in (
		result.current_selected_ability_ids
	):
		progression.selected_personal_ability_ids.append(
			selected_ability_id
		)

	return result


func _resolve_grid(
	hero: HeroDefinition,
	progression: HeroProgressionState
) -> SkillGridResolution:
	if (
		hero == null
		or not hero.is_valid_definition()
	):
		return null

	if (
		progression == null
		or not progression.is_valid_state()
	):
		return null

	var resolution := skill_grid_resolver.resolve(
		hero.skill_grid,
		progression
	)

	if not resolution.is_valid:
		return null

	return resolution


func _get_context_failure(
	hero: HeroDefinition,
	progression: HeroProgressionState
) -> StringName:
	if (
		hero == null
		or not hero.is_valid_definition()
	):
		return FAILURE_INVALID_HERO

	if (
		progression == null
		or not progression.is_valid_state()
	):
		return FAILURE_INVALID_PROGRESSION

	var grid_resolution := (
		skill_grid_resolver.resolve(
			hero.skill_grid,
			progression
		)
	)

	if not grid_resolution.is_valid:
		return FAILURE_INVALID_SKILL_GRID_STATE

	return &""


func _get_selection_failure(
	hero: HeroDefinition,
	known_ability_ids: Array[StringName],
	selected_ability_ids: Array[StringName],
	active_slot_count: int
) -> StringName:
	if selected_ability_ids.size() > active_slot_count:
		return FAILURE_INVALID_CURRENT_LOADOUT

	if (
		hero.fallback_ability == null
		and not selected_ability_ids.has(
			hero.default_ability_id
		)
	):
		return FAILURE_INVALID_CURRENT_LOADOUT

	for ability_id in selected_ability_ids:
		if not known_ability_ids.has(
			ability_id
		):
			return FAILURE_INVALID_CURRENT_LOADOUT

	return &""


func _copy_ids(
	source: Array[StringName],
	target: Array[StringName]
) -> void:
	target.clear()

	for ability_id in source:
		target.append(
			ability_id
		)