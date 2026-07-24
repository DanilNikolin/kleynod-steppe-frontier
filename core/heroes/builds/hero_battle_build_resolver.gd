class_name HeroBattleBuildResolver
extends RefCounted


var skill_grid_resolver := SkillGridResolver.new()

var loadout_resolver := (
	CombatantLoadoutRuntimeResolver.new()
)


func resolve(
	hero: HeroDefinition,
	progression: HeroProgressionState
) -> HeroBattleBuild:
	if hero == null or progression == null:
		return null

	if not hero.is_valid_definition():
		return null

	if not progression.is_valid_state():
		return null

	var grid_resolution := (
		skill_grid_resolver.resolve(
			hero.skill_grid,
			progression
		)
	)

	if not grid_resolution.is_valid:
		return null

	var skill_grid_bonuses := (
		grid_resolution
			.stat_bonuses
			.create_copy()
	)

	## Следующим модулем сюда будет подаваться
	## результат Equipment Resolver.
	var equipment_bonuses := (
		HeroBuildStatBonuses.new()
	)

	var total_bonuses := (
		skill_grid_bonuses.create_copy()
	)

	total_bonuses.add_from(
		equipment_bonuses
	)

	var combatant_definition := (
		hero
			.base_combatant_definition
			.duplicate(true)
		as CombatantDefinition
	)

	if combatant_definition == null:
		return null

	combatant_definition.base_strength = clampi(
		combatant_definition.base_strength
			+ total_bonuses.strength_rank_bonus,
		0,
		AbilityGrowthTableDefinition.MAX_RANK
	)

	combatant_definition.base_agility = clampi(
		combatant_definition.base_agility
			+ total_bonuses.agility_rank_bonus,
		0,
		AbilityGrowthTableDefinition.MAX_RANK
	)

	combatant_definition.base_spirit = clampi(
		combatant_definition.base_spirit
			+ total_bonuses.spirit_rank_bonus,
		0,
		AbilityGrowthTableDefinition.MAX_RANK
	)

	combatant_definition.max_health = maxi(
		1,
		combatant_definition.max_health
			+ total_bonuses.max_health_bonus
	)

	combatant_definition.max_stamina = maxi(
		1,
		combatant_definition.max_stamina
			+ total_bonuses.max_stamina_bonus
	)

	var resolved_base_start_stamina := (
		hero
			.base_combatant_definition
			.start_stamina
	)

	if resolved_base_start_stamina < 0:
		resolved_base_start_stamina = (
			combatant_definition.max_stamina
		)

	combatant_definition.start_stamina = clampi(
		resolved_base_start_stamina
			+ total_bonuses.start_stamina_bonus,
		0,
		combatant_definition.max_stamina
	)

	combatant_definition.base_armor = maxi(
		0,
		combatant_definition.base_armor
			+ total_bonuses.armor_bonus
	)

	var known_ability_ids: Array[StringName] = []

	for ability_id in (
		hero.starting_known_ability_ids
	):
		if not known_ability_ids.has(
			ability_id
		):
			known_ability_ids.append(
				ability_id
			)

	for ability_id in (
		grid_resolution.learned_ability_ids
	):
		if not known_ability_ids.has(
			ability_id
		):
			known_ability_ids.append(
				ability_id
			)

	var active_slot_count := clampi(
		hero.starting_active_slot_count
			+ total_bonuses.active_slot_bonus,
		1,
		hero.maximum_active_slot_count
	)

	var selected_ability_ids := (
		_get_selected_ability_ids(
			hero,
			progression,
			active_slot_count
		)
	)

	if selected_ability_ids.is_empty():
		return null

	if selected_ability_ids.size() > active_slot_count:
		return null

	if not selected_ability_ids.has(
		hero.default_ability_id
	):
		return null

	var unresolved_loadout := (
		CombatantLoadoutDefinition.new()
	)

	unresolved_loadout.loadout_id = StringName(
		"%s_runtime_personal"
		% hero.hero_id
	)

	unresolved_loadout.display_name = (
		"%s — личный набор"
		% hero.display_name
	)

	unresolved_loadout.default_ability_id = (
		hero.default_ability_id
	)

	for ability_id in selected_ability_ids:
		if not known_ability_ids.has(
			ability_id
		):
			return null

		var ability := hero.get_personal_ability(
			ability_id
		)

		if ability == null:
			return null

		unresolved_loadout.abilities.append(
			ability
		)

	if not unresolved_loadout.is_valid_definition():
		return null

	var resolved_loadout := (
		loadout_resolver.resolve(
			unresolved_loadout,
			combatant_definition.base_strength,
			combatant_definition.base_agility,
			combatant_definition.base_spirit
		)
	)

	if resolved_loadout == null:
		return null

	combatant_definition.default_loadout = (
		resolved_loadout
	)

	if not combatant_definition.is_valid_definition():
		return null

	var result := HeroBattleBuild.new()

	result.combatant_definition = (
		combatant_definition
	)

	result.loadout = resolved_loadout

	result.strength_rank = (
		combatant_definition.base_strength
	)

	result.agility_rank = (
		combatant_definition.base_agility
	)

	result.spirit_rank = (
		combatant_definition.base_spirit
	)

	result.active_slot_count = (
		active_slot_count
	)

	result.skill_grid_bonuses = (
		skill_grid_bonuses
	)

	result.equipment_bonuses = (
		equipment_bonuses
	)

	result.total_bonuses = (
		total_bonuses
	)
    
	for ability_id in known_ability_ids:
		result.known_personal_ability_ids.append(
			ability_id
		)

	for ability_id in selected_ability_ids:
		result.selected_personal_ability_ids.append(
			ability_id
		)

	for feature_id in (
		grid_resolution.unlocked_feature_ids
	):
		result.unlocked_feature_ids.append(
			feature_id
		)

	return result


func _get_selected_ability_ids(
	hero: HeroDefinition,
	progression: HeroProgressionState,
	active_slot_count: int
) -> Array[StringName]:
	var result: Array[StringName] = []

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

	for ability_id in (
		hero.starting_known_ability_ids
	):
		if result.size() >= active_slot_count:
			break

		result.append(
			ability_id
		)

	return result