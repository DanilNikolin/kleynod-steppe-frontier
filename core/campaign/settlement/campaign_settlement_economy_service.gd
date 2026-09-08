class_name CampaignSettlementEconomyService
extends RefCounted


const MAX_GOLD: int = 999999999


func get_seasonal_gold_income(
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState
) -> int:
	if (
		settlement_definition == null
		or settlement_state == null
		or not settlement_state
			.is_valid_against_definition(
				settlement_definition
			)
	):
		return 0

	var result := 0

	for zone_definition in (
		settlement_definition.zones
	):
		if zone_definition == null:
			continue

		var zone_state := settlement_state.get_zone(
			zone_definition.zone_id
		)

		if (
			zone_state == null
			or zone_state.is_empty()
		):
			continue

		var building := zone_definition.get_building(
			zone_state.building_id
		)

		if building == null:
			continue

		result += building.get_seasonal_gold_income(
			zone_state.building_level
		)

	return maxi(
		result,
		0
	)


func get_crossed_season_count(
	previous_day: int,
	current_day: int,
	days_per_season: int
) -> int:
	if (
		previous_day < 0
		or current_day < previous_day
		or days_per_season <= 0
	):
		return 0

	var previous_season_index := (
		previous_day
		/ days_per_season
	)

	var current_season_index := (
		current_day
		/ days_per_season
	)

	return maxi(
		current_season_index
			- previous_season_index,
		0
	)


func accrue_crossed_seasons(
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState,
	previous_day: int,
	current_day: int,
	days_per_season: int
) -> bool:
	if (
		settlement_definition == null
		or settlement_state == null
		or days_per_season <= 0
	):
		return false

	var crossed_seasons := (
		get_crossed_season_count(
			previous_day,
			current_day,
			days_per_season
		)
	)

	if crossed_seasons <= 0:
		return true

	var income_per_season := (
		get_seasonal_gold_income(
			settlement_definition,
			settlement_state
		)
	)

	if income_per_season <= 0:
		return true

	var produced_gold := (
		income_per_season
		* crossed_seasons
	)

	if (
		settlement_state.uncollected_gold
		> MAX_GOLD - produced_gold
	):
		return false

	settlement_state.uncollected_gold += (
		produced_gold
	)

	return (
		settlement_state
			.is_valid_against_definition(
				settlement_definition
			)
	)


func collect_uncollected_gold(
	settlement_state: CampaignSettlementState,
	inventory: CampaignInventoryState
) -> bool:
	if (
		settlement_state == null
		or inventory == null
	):
		return false

	if settlement_state.uncollected_gold <= 0:
		return true

	if (
		inventory.gold
		> MAX_GOLD
			- settlement_state.uncollected_gold
	):
		return false

	inventory.gold += (
		settlement_state.uncollected_gold
	)

	settlement_state.uncollected_gold = 0

	return (
		inventory.is_valid_state()
		and settlement_state.is_valid_state()
	)