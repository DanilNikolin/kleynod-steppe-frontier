class_name BattleLootRewardService
extends RefCounted


const MAX_ITEM_DROPS: int = 5

const FIRST_ITEM_BASE_CHANCE: int = 45
const FIRST_ITEM_TIER_STEP: int = 9
const FIRST_ITEM_MIN_CHANCE: int = 50
const FIRST_ITEM_MAX_CHANCE: int = 95

const NEXT_ITEM_CHANCE_PENALTY: int = 15
const MIN_ITEM_CHANCE: int = 20

const HIGHEST_TIER_WEIGHT_MULTIPLIER: int = 6
const ONE_TIER_BELOW_WEIGHT_MULTIPLIER: int = 3

const GOLD_PER_REMAINING_BUDGET: int = 1


func roll_from_session(
	session: BattleSession,
	defeated_team_id: StringName,
	loot_catalog: Array[HeroEquipmentItemDefinition],
	can_receive_loot: bool,
	rng: RandomNumberGenerator = null
) -> BattleLootRewardRoll:
	var defeated_definitions: Array[CombatantDefinition] = []

	if (
		session != null
		and defeated_team_id != &""
	):
		for combatant in session.get_team_combatants(
			defeated_team_id,
			false
		):
			if (
				combatant == null
				or combatant.is_alive
				or combatant.definition == null
			):
				continue

			defeated_definitions.append(
				combatant.definition
			)

	return roll_from_defeated_definitions(
		defeated_definitions,
		loot_catalog,
		can_receive_loot,
		rng
	)


func roll_from_defeated_definitions(
	defeated_definitions: Array[CombatantDefinition],
	loot_catalog: Array[HeroEquipmentItemDefinition],
	can_receive_loot: bool,
	rng: RandomNumberGenerator = null
) -> BattleLootRewardRoll:
	var result := BattleLootRewardRoll.new()

	var primary_source: CombatantDefinition

	for definition in defeated_definitions:
		if definition == null:
			continue

		result.total_budget += maxi(
			definition.loot_budget,
			0
		)

		result.tier_cap = maxi(
			result.tier_cap,
			definition.loot_tier
		)

		_append_unique_tags(
			result.combined_loot_tags,
			definition.loot_tags
		)

		if _is_better_primary_source(
			definition,
			primary_source
		):
			primary_source = definition

	if primary_source != null:
		_append_unique_tags(
			result.primary_loot_tags,
			primary_source.loot_tags
		)

	if (
		not can_receive_loot
		or result.total_budget <= 0
		or result.tier_cap <= 0
	):
		return result

	var active_rng: RandomNumberGenerator = rng

	if active_rng == null:
		active_rng = RandomNumberGenerator.new()
		active_rng.randomize()

	var remaining_budget := result.total_budget

	var item_chance := clampi(
		FIRST_ITEM_BASE_CHANCE
		+ FIRST_ITEM_TIER_STEP
		* result.tier_cap,
		FIRST_ITEM_MIN_CHANCE,
		FIRST_ITEM_MAX_CHANCE
	)

	var used_item_ids: Dictionary = {}

	for drop_index in range(
		MAX_ITEM_DROPS
	):
		if remaining_budget <= 0:
			break

		if not _roll_percent(
			active_rng,
			item_chance
		):
			break

		var selected_item := _select_item(
			loot_catalog,
			remaining_budget,
			result.tier_cap,
			result.combined_loot_tags,
			result.primary_loot_tags,
			used_item_ids,
			drop_index == 0,
			active_rng
		)

		if selected_item == null:
			break

		result.dropped_item_definitions.append(
			selected_item
		)

		result.spent_item_value += (
			selected_item.loot_value
		)

		remaining_budget -= (
			selected_item.loot_value
		)

		used_item_ids[
			selected_item.item_id
		] = true

		item_chance = maxi(
			MIN_ITEM_CHANCE,
			item_chance
			- NEXT_ITEM_CHANCE_PENALTY
		)

	result.gold_reward = (
		remaining_budget
		* GOLD_PER_REMAINING_BUDGET
	)

	return result


func _select_item(
	loot_catalog: Array[HeroEquipmentItemDefinition],
	remaining_budget: int,
	tier_cap: int,
	combined_loot_tags: Array[StringName],
	primary_loot_tags: Array[StringName],
	used_item_ids: Dictionary,
	is_first_item: bool,
	rng: RandomNumberGenerator
) -> HeroEquipmentItemDefinition:
	var eligible := _collect_candidates(
		loot_catalog,
		remaining_budget,
		tier_cap,
		combined_loot_tags,
		used_item_ids
	)

	if eligible.is_empty():
		return null

	## Каждый предмет сначала проходит собственную
	## абсолютную проверку редкости.
	##
	## Например loot_drop_chance_percent = 7
	## означает примерно 7% шанс вообще попасть
	## в pool этого конкретного item-roll.
	var rarity_passed: Array[HeroEquipmentItemDefinition] = []

	for item in eligible:
		if _roll_percent(
			rng,
			item.loot_drop_chance_percent
		):
			rarity_passed.append(
				item
			)

	if rarity_passed.is_empty():
		return null

	if is_first_item:
		var primary_candidates: Array[HeroEquipmentItemDefinition] = []

		for item in rarity_passed:
			if _tags_match(
				item.loot_tags,
				primary_loot_tags
			):
				primary_candidates.append(
					item
				)

		if not primary_candidates.is_empty():
			return _pick_highest_tier_item(
				primary_candidates,
				rng
			)

		## Если у главного врага нет подходящей
		## прошедшей rarity вещи, разрешаем общий
		## тематический pool боя.
		return _pick_highest_tier_item(
			rarity_passed,
			rng
		)

	return _pick_weighted_item(
		rarity_passed,
		true,
		rng
	)


func _collect_candidates(
	loot_catalog: Array[HeroEquipmentItemDefinition],
	remaining_budget: int,
	tier_cap: int,
	combined_loot_tags: Array[StringName],
	used_item_ids: Dictionary
) -> Array[HeroEquipmentItemDefinition]:
	var result: Array[HeroEquipmentItemDefinition] = []

	for item in loot_catalog:
		if (
			item == null
			or not item.is_loot_enabled()
		):
			continue

		if used_item_ids.has(
			item.item_id
		):
			continue

		if (
			item.loot_value
			> remaining_budget
		):
			continue

		if (
			item.loot_tier
			> tier_cap
		):
			continue

		if not _tags_match(
			item.loot_tags,
			combined_loot_tags
		):
			continue

		result.append(
			item
		)

	return result


func _pick_highest_tier_item(
	candidates: Array[HeroEquipmentItemDefinition],
	rng: RandomNumberGenerator
) -> HeroEquipmentItemDefinition:
	if candidates.is_empty():
		return null

	var highest_tier: int = 0

	for item in candidates:
		highest_tier = maxi(
			highest_tier,
			item.loot_tier
		)

	var highest_candidates: Array[HeroEquipmentItemDefinition] = []

	for item in candidates:
		if item.loot_tier != highest_tier:
			continue

		highest_candidates.append(
			item
		)

	return _pick_weighted_item(
		highest_candidates,
		false,
		rng
	)


func _pick_weighted_item(
	candidates: Array[HeroEquipmentItemDefinition],
	use_tier_priority: bool,
	rng: RandomNumberGenerator
) -> HeroEquipmentItemDefinition:
	if candidates.is_empty():
		return null

	var highest_tier: int = 0

	for item in candidates:
		highest_tier = maxi(
			highest_tier,
			item.loot_tier
		)

	var weights: Array[int] = []
	var total_weight: int = 0

	for item in candidates:
		var tier_multiplier: int = 1

		if use_tier_priority:
			var tier_difference := (
				highest_tier
				- item.loot_tier
			)

			if tier_difference == 0:
				tier_multiplier = (
					HIGHEST_TIER_WEIGHT_MULTIPLIER
				)

			elif tier_difference == 1:
				tier_multiplier = (
					ONE_TIER_BELOW_WEIGHT_MULTIPLIER
				)

		var resolved_weight := (
			maxi(
				item.loot_weight,
				1
			)
			* tier_multiplier
		)

		weights.append(
			resolved_weight
		)

		total_weight += resolved_weight

	if total_weight <= 0:
		return null

	var rolled_weight := rng.randi_range(
		1,
		total_weight
	)

	for candidate_index in range(
		candidates.size()
	):
		rolled_weight -= weights[
			candidate_index
		]

		if rolled_weight <= 0:
			return candidates[
				candidate_index
			]

	return candidates.back()


func _tags_match(
	item_tags: Array[StringName],
	source_tags: Array[StringName]
) -> bool:
	## Пустые item tags означают generic loot,
	## допустимый для любого источника.
	if item_tags.is_empty():
		return true

	## Источник без тегов может выдавать
	## только generic loot.
	if source_tags.is_empty():
		return false

	for tag in item_tags:
		if source_tags.has(
			tag
		):
			return true

	return false


func _is_better_primary_source(
	candidate: CombatantDefinition,
	current: CombatantDefinition
) -> bool:
	if candidate == null:
		return false

	if current == null:
		return true

	if candidate.loot_tier != current.loot_tier:
		return (
			candidate.loot_tier
			> current.loot_tier
		)

	return (
		candidate.loot_budget
		> current.loot_budget
	)


func _append_unique_tags(
	target: Array[StringName],
	source: Array[StringName]
) -> void:
	for tag in source:
		if (
			tag == &""
			or target.has(
				tag
			)
		):
			continue

		target.append(
			tag
		)


func _roll_percent(
	rng: RandomNumberGenerator,
	chance_percent: int
) -> bool:
	var resolved_chance := clampi(
		chance_percent,
		0,
		100
	)

	if resolved_chance <= 0:
		return false

	if resolved_chance >= 100:
		return true

	return (
		rng.randi_range(
			1,
			100
		)
		<= resolved_chance
	)