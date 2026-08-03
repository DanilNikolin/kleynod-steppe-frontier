class_name CampaignPartyService
extends RefCounted


const MIN_PARTY_SIZE: int = 1
const MAX_PARTY_SIZE: int = 3

const FAILURE_INVALID_CAMPAIGN_STATE: StringName = (
	&"invalid_campaign_state"
)

const FAILURE_UNKNOWN_HERO: StringName = (
	&"unknown_campaign_hero"
)

const FAILURE_ALREADY_SELECTED: StringName = (
	&"hero_already_selected"
)

const FAILURE_ALREADY_IN_PARTY: StringName = (
	&"hero_already_in_party"
)

const FAILURE_NOT_IN_PARTY: StringName = (
	&"hero_not_in_party"
)

const FAILURE_PARTY_FULL: StringName = (
	&"party_is_full"
)

const FAILURE_PARTY_MINIMUM: StringName = (
	&"party_requires_at_least_one_hero"
)


func get_select_result(
	state: CampaignState,
	hero_id: StringName
) -> CampaignPartyChangeResult:
	var result := _create_result(
		hero_id
	)

	if (
		state == null
		or not state.is_valid_state()
	):
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

		return result

	if state.get_hero(
		hero_id
	) == null:
		result.failure_code = FAILURE_UNKNOWN_HERO
		return result

	if state.selected_hero_id == hero_id:
		result.failure_code = FAILURE_ALREADY_SELECTED
		return result

	result.is_successful = true
	return result


func select_hero(
	state: CampaignState,
	hero_id: StringName
) -> CampaignPartyChangeResult:
	var result := get_select_result(
		state,
		hero_id
	)

	if not result.is_successful:
		return result

	state.selected_hero_id = hero_id

	if not state.is_valid_state():
		result.is_successful = false
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

	return result


func get_add_result(
	state: CampaignState,
	hero_id: StringName
) -> CampaignPartyChangeResult:
	var result := _create_result(
		hero_id
	)

	if (
		state == null
		or not state.is_valid_state()
	):
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

		return result

	if state.get_hero(
		hero_id
	) == null:
		result.failure_code = FAILURE_UNKNOWN_HERO
		return result

	if state.is_hero_in_party(
		hero_id
	):
		result.failure_code = FAILURE_ALREADY_IN_PARTY
		return result

	if (
		state.party_member_hero_ids.size()
		>= MAX_PARTY_SIZE
	):
		result.failure_code = FAILURE_PARTY_FULL
		return result

	result.is_successful = true
	return result


func add_hero(
	state: CampaignState,
	hero_id: StringName
) -> CampaignPartyChangeResult:
	var result := get_add_result(
		state,
		hero_id
	)

	if not result.is_successful:
		return result

	state.party_member_hero_ids.append(
		hero_id
	)

	if not state.is_valid_state():
		state.party_member_hero_ids.erase(
			hero_id
		)

		result.is_successful = false
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

	return result


func get_remove_result(
	state: CampaignState,
	hero_id: StringName
) -> CampaignPartyChangeResult:
	var result := _create_result(
		hero_id
	)

	if (
		state == null
		or not state.is_valid_state()
	):
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

		return result

	if state.get_hero(
		hero_id
	) == null:
		result.failure_code = FAILURE_UNKNOWN_HERO
		return result

	if not state.is_hero_in_party(
		hero_id
	):
		result.failure_code = FAILURE_NOT_IN_PARTY
		return result

	if (
		state.party_member_hero_ids.size()
		<= MIN_PARTY_SIZE
	):
		result.failure_code = FAILURE_PARTY_MINIMUM
		return result

	result.is_successful = true
	return result


func remove_hero(
	state: CampaignState,
	hero_id: StringName
) -> CampaignPartyChangeResult:
	var result := get_remove_result(
		state,
		hero_id
	)

	if not result.is_successful:
		return result

	var previous_index := (
		state.party_member_hero_ids.find(
			hero_id
		)
	)

	state.party_member_hero_ids.erase(
		hero_id
	)

	if not state.is_valid_state():
		state.party_member_hero_ids.insert(
			previous_index,
			hero_id
		)

		result.is_successful = false
		result.failure_code = (
			FAILURE_INVALID_CAMPAIGN_STATE
		)

	return result


func _create_result(
	hero_id: StringName
) -> CampaignPartyChangeResult:
	var result := CampaignPartyChangeResult.new()

	result.hero_id = hero_id

	return result