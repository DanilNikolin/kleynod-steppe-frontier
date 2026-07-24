class_name CombatantLoadoutRuntimeResolver
extends RefCounted


var ability_resolver := (
	AbilityRuntimeResolver.new()
)


func resolve(
	source: CombatantLoadoutDefinition,
	strength_rank: int,
	agility_rank: int,
	spirit_rank: int
) -> CombatantLoadoutDefinition:
	if source == null:
		return null

	if not source.is_valid_definition():
		return null

	var result := (
		CombatantLoadoutDefinition.new()
	)

	result.loadout_id = source.loadout_id
	result.display_name = source.display_name
	result.default_ability_id = (
		source.default_ability_id
	)

	for source_ability in (
		source.get_abilities()
	):
		if source_ability == null:
			return null

		var ability_rank := (
			source_ability.get_growth_rank(
				strength_rank,
				agility_rank,
				spirit_rank
			)
		)

		var resolved_ability := (
			ability_resolver.resolve(
				source_ability,
				ability_rank
			)
		)

		if resolved_ability == null:
			return null

		result.abilities.append(
			resolved_ability
		)

	if not result.is_valid_definition():
		return null

	return result