class_name CampaignState
extends RefCounted


const MIN_PARTY_SIZE: int = 1
const MAX_PARTY_SIZE: int = 3


var campaign_id: StringName = &""

var heroes: Array[CampaignHeroState] = []

var inventory_state: CampaignInventoryState

## Герой, чью страницу сейчас показывает интерфейс.
## Он может находиться как в отряде, так и в резерве.
var selected_hero_id: StringName = &""

## Упорядоченный боевой отряд.
## Индекс определяет используемый party spawn.
var party_member_hero_ids: Array[StringName] = []

var current_location_id: StringName = &""

## Фактическое положение партии на глобальной карте.
## Не путать с current_location_id:
## current_location_id пока относится к CampaignLocation /
## последней боевой локации старого Campaign flow.
var current_world_node_id: StringName = &""

## Единственный Source of Truth глобального календаря.
## Сезон и год выводятся из этого числа.
var current_day: int = 0

## Минута внутри текущего игрового дня.
## 0 = 00:00
## 1439 = 23:59
var current_minute_of_day: int = 0

## Пока одна глобальная репутация.
var reputation: int = 0

## Универсальный ресурс развития поселения.
var materials: int = 0

## Persistent состояние собственного поселения.
var home_settlement_state: CampaignSettlementState

var completed_battle_count: int = 0

var last_battle_result: CampaignBattleResult


func get_hero(
	hero_id: StringName
) -> CampaignHeroState:
	if hero_id == &"":
		return null

	for hero_state in heroes:
		if (
			hero_state != null
			and hero_state.get_hero_id() == hero_id
		):
			return hero_state

	return null


func get_selected_hero() -> CampaignHeroState:
	return get_hero(
		selected_hero_id
	)


## Временный compatibility alias для старых debug-вызовов.
func get_active_hero() -> CampaignHeroState:
	return get_selected_hero()


func is_hero_in_party(
	hero_id: StringName
) -> bool:
	return party_member_hero_ids.has(
		hero_id
	)


func get_party_members() -> Array[CampaignHeroState]:
	var result: Array[CampaignHeroState] = []

	for hero_id in party_member_hero_ids:
		var hero_state := get_hero(
			hero_id
		)

		if hero_state != null:
			result.append(
				hero_state
			)

	return result


func get_equipment_owner(
	item_instance_id: StringName
) -> CampaignHeroState:
	if item_instance_id == &"":
		return null

	for hero_state in heroes:
		if (
			hero_state == null
			or hero_state.progression_state == null
			or hero_state
				.progression_state
				.equipment_state == null
		):
			continue

		for slot in HeroEquipmentState.get_all_slots():
			var item := (
				hero_state
					.progression_state
					.equipment_state
					.get_item(
						slot
					)
			)

			if (
				item != null
				and item.instance_id
					== item_instance_id
			):
				return hero_state

	return null


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if campaign_id == &"":
		errors.append(
			"Campaign state ID is empty."
		)

	if current_world_node_id == &"":
		errors.append(
			"Current world node ID is empty."
		)

	if current_day < 0:
		errors.append(
			"Campaign current day cannot be negative."
		)

	if (
		current_minute_of_day < 0
		or current_minute_of_day
			>= CampaignTimeService.MINUTES_PER_DAY
	):
		errors.append(
			"Campaign minute of day must be "
			+"between 0 and 1439."
		)
		
	if materials < 0:
		errors.append(
			"Campaign materials cannot be negative."
		)

	if home_settlement_state == null:
		errors.append(
			"Home settlement state is not assigned."
		)

	else:
		for settlement_error in (
			home_settlement_state
				.get_validation_errors()
		):
			errors.append(
				"Home settlement state: %s"
				% settlement_error
			)

	if heroes.is_empty():
		errors.append(
			"Campaign state has no heroes."
		)

	var used_hero_ids: Dictionary = {}

	for hero_index in range(
		heroes.size()
	):
		var hero_state := heroes[
			hero_index
		]

		if hero_state == null:
			errors.append(
				"Campaign hero at index %d is null."
				% hero_index
			)

			continue

		for hero_error in (
			hero_state.get_validation_errors()
		):
			errors.append(
				"Campaign hero %d: %s"
				% [
					hero_index,
					hero_error,
				]
			)

		var hero_id := hero_state.get_hero_id()

		if hero_id == &"":
			continue

		if used_hero_ids.has(
			hero_id
		):
			errors.append(
				"Duplicate campaign hero ID: %s."
				% hero_id
			)

			continue

		used_hero_ids[
			hero_id
		] = true

	if selected_hero_id == &"":
		errors.append(
			"Selected campaign hero ID is empty."
		)

	elif not used_hero_ids.has(
		selected_hero_id
	):
		errors.append(
			"Selected campaign hero '%s' does not exist."
			% selected_hero_id
		)

	if (
		party_member_hero_ids.size()
		< MIN_PARTY_SIZE
	):
		errors.append(
			"Campaign party requires at least one hero."
		)

	if (
		party_member_hero_ids.size()
		> MAX_PARTY_SIZE
	):
		errors.append(
			"Campaign party cannot contain "
			+"more than three heroes."
		)

	var used_party_hero_ids: Dictionary = {}

	for hero_id in party_member_hero_ids:
		if hero_id == &"":
			errors.append(
				"Campaign party hero ID is empty."
			)

			continue

		if not used_hero_ids.has(
			hero_id
		):
			errors.append(
				"Campaign party references "
				+"unknown hero: %s."
				% hero_id
			)

		if used_party_hero_ids.has(
			hero_id
		):
			errors.append(
				"Duplicate campaign party hero: %s."
				% hero_id
			)

			continue

		used_party_hero_ids[
			hero_id
		] = true

	if inventory_state == null:
		errors.append(
			"Campaign inventory state is not assigned."
		)

	else:
		for inventory_error in (
			inventory_state.get_validation_errors()
		):
			errors.append(
				"Campaign inventory: %s"
				% inventory_error
			)

	_append_equipment_ownership_errors(
		errors
	)

	return errors


func _append_equipment_ownership_errors(
	errors: PackedStringArray
) -> void:
	if inventory_state == null:
		return

	var owners_by_item_id: Dictionary = {}

	for hero_state in heroes:
		if (
			hero_state == null
			or hero_state.progression_state == null
			or hero_state
				.progression_state
				.equipment_state == null
		):
			continue

		var hero_id := hero_state.get_hero_id()
		var used_by_current_hero: Dictionary = {}

		var equipment_state := (
			hero_state
				.progression_state
				.equipment_state
		)

		for slot in HeroEquipmentState.get_all_slots():
			var item := equipment_state.get_item(
				slot
			)

			if item == null:
				continue

			if used_by_current_hero.has(
				item.instance_id
			):
				continue

			used_by_current_hero[
				item.instance_id
			] = true

			var inventory_item := inventory_state.get_item(
				item.instance_id
			)

			if inventory_item == null:
				errors.append(
					"Hero '%s' has equipment item '%s' "
					% [
						hero_id,
						item.instance_id,
					]
					+"that does not exist in campaign inventory."
				)

				continue

			if inventory_item != item:
				errors.append(
					"Hero '%s' uses a non-canonical "
					% hero_id
					+"instance of inventory item '%s'."
					% item.instance_id
				)

			if owners_by_item_id.has(
				item.instance_id
			):
				var previous_owner_id: StringName = (
					owners_by_item_id[
						item.instance_id
					]
				)

				if previous_owner_id != hero_id:
					errors.append(
						"Equipment item '%s' is equipped "
						% item.instance_id
						+"by both '%s' and '%s'."
						% [
							previous_owner_id,
							hero_id,
						]
					)

			else:
				owners_by_item_id[
					item.instance_id
				] = hero_id