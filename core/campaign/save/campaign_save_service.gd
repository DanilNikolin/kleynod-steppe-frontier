class_name CampaignSaveService
extends RefCounted


const CURRENT_SAVE_VERSION: int = 2
const DEFAULT_SAVE_PATH: String = "user://campaign_save.json"

const STATUS_SAVED: StringName = &"saved"
const STATUS_LOADED: StringName = &"loaded"
const STATUS_NO_SAVE: StringName = &"no_save"
const STATUS_SAVE_ERROR: StringName = &"save_error"
const STATUS_LOAD_ERROR: StringName = &"load_error"

const EQUIPMENT_KEYS := [
	"weapon_1",
	"weapon_2",
	"head",
	"armor",
	"gloves",
	"boots",
	"charm",
	"ring_1",
	"ring_2",
]


var save_path: String = DEFAULT_SAVE_PATH

var _error_message: String = ""

var _state_factory := CampaignStateFactory.new()
var _build_resolver := HeroBattleBuildResolver.new()
var _experience_service := HeroExperienceService.new()


func _init(
	custom_save_path: String = DEFAULT_SAVE_PATH
) -> void:
	save_path = custom_save_path


func has_save() -> bool:
	return FileAccess.file_exists(
		save_path
	)


func save_campaign(
	state: CampaignState
) -> CampaignSaveResult:
	if (
		state == null
		or not state.is_valid_state()
	):
		return _result(
			false,
			STATUS_SAVE_ERROR,
			"Campaign state is missing or invalid."
		)

	var file := FileAccess.open(
		save_path,
		FileAccess.WRITE
	)

	if file == null:
		return _result(
			false,
			STATUS_SAVE_ERROR,
			"Could not open save file. Error: %d."
			% FileAccess.get_open_error()
		)

	var stored := file.store_string(
		JSON.stringify(
			_encode_campaign(
				state
			),
			"\t"
		)
	)

	file.flush()

	var write_error := file.get_error()

	file.close()

	if (
		not stored
		or write_error != OK
	):
		return _result(
			false,
			STATUS_SAVE_ERROR,
			"Save write failed. Error: %d."
			% write_error
		)

	return _result(
		true,
		STATUS_SAVED,
		"Campaign saved."
	)


func load_campaign(
	definition: CampaignDefinition
) -> CampaignSaveResult:
	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return _result(
			false,
			STATUS_LOAD_ERROR,
			"Campaign definition is missing or invalid."
		)

	if not has_save():
		return _result(
			false,
			STATUS_NO_SAVE,
			"Save file does not exist."
		)

	var file := FileAccess.open(
		save_path,
		FileAccess.READ
	)

	if file == null:
		return _result(
			false,
			STATUS_LOAD_ERROR,
			"Could not open save file. Error: %d."
			% FileAccess.get_open_error()
		)

	var text := file.get_as_text()

	file.close()

	var json := JSON.new()

	var parse_error := json.parse(
		text
	)

	if parse_error != OK:
		return _result(
			false,
			STATUS_LOAD_ERROR,
			"Invalid save JSON at line %d: %s"
			% [
				json.get_error_line(),
				json.get_error_message(),
			]
		)

	if typeof(
		json.data
	) != TYPE_DICTIONARY:
		return _result(
			false,
			STATUS_LOAD_ERROR,
			"Save root must be a Dictionary."
		)

	_error_message = ""

	var root: Dictionary = json.data

	var loaded_state := _decode_campaign(
		root,
		definition
	)

	if loaded_state == null:
		return _result(
			false,
			STATUS_LOAD_ERROR,
			(
				_error_message
				if not _error_message.is_empty()
				else "Save data is invalid."
			)
		)

	return _result(
		true,
		STATUS_LOADED,
		"Campaign loaded.",
		loaded_state
	)


func _encode_campaign(
	state: CampaignState
) -> Dictionary:
	var heroes: Array = []

	for hero in state.heroes:
		heroes.append(
			_encode_hero(
				hero
			)
		)

	return {
		"format_version": CURRENT_SAVE_VERSION,
		"campaign_id": String(
			state.campaign_id
		),
		"selected_hero_id": String(
			state.selected_hero_id
		),
		"party_member_hero_ids": (
			_names_to_array(
				state.party_member_hero_ids
			)
		),
		"current_location_id": String(
			state.current_location_id
		),
		"current_world_node_id": String(
			state.current_world_node_id
		),
		"current_day": state.current_day,
		"reputation": state.reputation,
		"materials": state.materials,

		"completed_battle_count": (
			state.completed_battle_count
		),
		"heroes": heroes,
		"inventory": _encode_inventory(
			state.inventory_state
		),
		"last_battle_result": (
			_encode_battle_result(
				state.last_battle_result
			)
		),
	}


func _encode_hero(
	hero: CampaignHeroState
) -> Dictionary:
	var progression := (
		hero.progression_state
	)

	return {
		"hero_id": String(
			hero.get_hero_id()
		),
		"level": progression.level,
		"experience": progression.experience,
		"unspent_skill_points": (
			progression.unspent_skill_points
		),
		"purchased_node_ids": (
			_names_to_array(
				progression.purchased_node_ids
			)
		),
		"attached_skill_block_ids": (
			_names_to_array(
				progression.attached_skill_block_ids
			)
		),
		"selected_personal_ability_ids": (
			_names_to_array(
				progression
					.selected_personal_ability_ids
			)
		),
		"equipment": _encode_equipment(
			progression.equipment_state
		),
	}


func _encode_inventory(
	inventory: CampaignInventoryState
) -> Dictionary:
	var items: Array = []

	for item in inventory.items:
		items.append(
			{
				"instance_id": String(
					item.instance_id
				),
				"item_id": String(
					item.definition.item_id
				),
			}
		)

	return {
		"gold": inventory.gold,
		"next_generated_item_serial": (
			inventory
				.next_generated_item_serial
		),
		"items": items,
	}


func _encode_equipment(
	equipment: HeroEquipmentState
) -> Dictionary:
	var result: Dictionary = {}

	for key in EQUIPMENT_KEYS:
		var item: HeroEquipmentItemInstance

		if equipment != null:
			item = equipment.get_item(
				_slot_for_key(
					key
				)
			)

		result[key] = (
			String(
				item.instance_id
			)
			if item != null
			else ""
		)

	return result


func _encode_battle_result(
	result: CampaignBattleResult
) -> Variant:
	if result == null:
		return null

	var level_ups: Dictionary = {}

	for hero_id in (
		result.level_ups_by_hero_id
	):
		level_ups[
			String(hero_id)
		] = int(
			result
				.level_ups_by_hero_id[
					hero_id
				]
		)

	return {
		"request_id": String(
			result.request_id
		),
		"location_id": String(
			result.location_id
		),
		"encounter_id": String(
			result.encounter_id
		),
		"party_member_hero_ids": (
			_names_to_array(
				result.party_member_hero_ids
			)
		),
		"winning_team_id": String(
			result.winning_team_id
		),
		"outcome": int(
			result.outcome
		),
		"defeated_enemy_experience_pool": (
			result
				.defeated_enemy_experience_pool
		),
		"experience_per_party_member": (
			result
				.experience_per_party_member
		),
		"undistributed_experience": (
			result
				.undistributed_experience
		),
		"level_ups_by_hero_id": level_ups,
		"loot_budget": result.loot_budget,
		"loot_tier_cap": result.loot_tier_cap,
		"loot_item_value": result.loot_item_value,
		"loot_item_instance_ids": (
			_names_to_array(
				result.loot_item_instance_ids
			)
		),
		"loot_item_display_names": (
			_packed_to_array(
				result.loot_item_display_names
			)
		),
		"gold_reward": result.gold_reward,
	}


func _decode_campaign(
	data: Dictionary,
	definition: CampaignDefinition
) -> CampaignState:
	if not _has_keys(
		data,
		[
			"format_version",
			"campaign_id",
			"selected_hero_id",
			"party_member_hero_ids",
			"current_location_id",
			"current_world_node_id",
			"current_day",
			"reputation",
			"materials",
			"completed_battle_count",
			"heroes",
			"inventory",
			"last_battle_result",
		],
		"save root"
	):
		return null

	var version := _int_value(
		data["format_version"],
		"format_version",
		1,
		2147483647
	)

	if _failed():
		return null

	if version != CURRENT_SAVE_VERSION:
		_fail(
			"Unsupported save version %d. Expected %d."
			% [
				version,
				CURRENT_SAVE_VERSION,
			]
		)

		return null

	var campaign_id := _string_value(
		data["campaign_id"],
		"campaign_id",
		false
	)

	if _failed():
		return null

	if StringName(
		campaign_id
	) != definition.campaign_id:
		_fail(
			"Save campaign '%s' does not match '%s'."
			% [
				campaign_id,
				definition.campaign_id,
			]
		)

		return null

	var state := (
		_state_factory.create_from_definition(
			definition
		)
	)

	if state == null:
		_fail(
			"Could not create a fresh campaign state for loading."
		)

		return null

	var inventory := _decode_inventory(
		data["inventory"],
		definition
	)

	if inventory == null:
		return null

	state.inventory_state = inventory

	var inventory_map := _inventory_map(
		inventory
	)

	if not _decode_heroes(
		data["heroes"],
		state,
		inventory_map
	):
		return null

	state.selected_hero_id = StringName(
		_string_value(
			data["selected_hero_id"],
			"selected_hero_id",
			false
		)
	)

	state.party_member_hero_ids = (
		_name_array(
			data["party_member_hero_ids"],
			"party_member_hero_ids"
		)
	)

	state.current_location_id = StringName(
		_string_value(
			data["current_location_id"],
			"current_location_id",
			true
		)
	)

	state.current_world_node_id = StringName(
		_string_value(
			data["current_world_node_id"],
			"current_world_node_id",
			false
		)
	)

	state.current_day = _int_value(
		data["current_day"],
		"current_day",
		0,
		999999999
	)

	state.reputation = _int_value(
		data["reputation"],
		"reputation",
		-999999999,
		999999999
	)

	state.materials = _int_value(
		data["materials"],
		"materials",
		0,
		999999999
	)

	state.completed_battle_count = (
		_int_value(
			data["completed_battle_count"],
			"completed_battle_count",
			0,
			999999999
		)
	)

	if _failed():
		return null

	if (
		state.current_location_id != &""
		and definition.get_location(
			state.current_location_id
		) == null
	):
		_fail(
			"Unknown current location '%s'."
			% state.current_location_id
		)

		return null

	if (
		definition.world_map_definition == null
		or definition
			.world_map_definition
			.get_node(
				state.current_world_node_id
			) == null
	):
		_fail(
			"Unknown current world node '%s'."
			% state.current_world_node_id
		)

		return null

	if (
		data["last_battle_result"]
		!= null
	):
		state.last_battle_result = (
			_decode_battle_result(
				data["last_battle_result"],
				state,
				definition
			)
		)

		if state.last_battle_result == null:
			return null

	else:
		state.last_battle_result = null

	var validation_errors := (
		state.get_validation_errors()
	)

	if not validation_errors.is_empty():
		_fail(
			"Loaded campaign state is invalid: %s"
			% "; ".join(
				validation_errors
			)
		)

		return null

	## Не сохраняем derived build.
	## Но после восстановления Source of Truth
	## обязаны убедиться, что он снова резолвится
	## против актуального content.
	for hero in state.heroes:
		if (
			_build_resolver.resolve(
				hero.hero_definition,
				hero.progression_state
			)
			== null
		):
			_fail(
				"Loaded progression for hero '%s' "
				% hero.get_hero_id()
				+"cannot be resolved against "
				+"current content."
			)

			return null

	return state


func _decode_inventory(
	value: Variant,
	definition: CampaignDefinition
) -> CampaignInventoryState:
	if typeof(
		value
	) != TYPE_DICTIONARY:
		_fail(
			"inventory must be a Dictionary."
		)

		return null

	var data: Dictionary = value

	if not _has_keys(
		data,
		[
			"gold",
			"next_generated_item_serial",
			"items",
		],
		"inventory"
	):
		return null

	if typeof(
		data["items"]
	) != TYPE_ARRAY:
		_fail(
			"inventory.items must be an Array."
		)

		return null

	var inventory := (
		CampaignInventoryState.new()
	)

	inventory.gold = _int_value(
		data["gold"],
		"inventory.gold",
		0,
		999999999
	)

	inventory.next_generated_item_serial = (
		_int_value(
			data["next_generated_item_serial"],
			"inventory.next_generated_item_serial",
			1,
			999999999
		)
	)

	if _failed():
		return null

	var items_data: Array = data["items"]
	var used_ids: Dictionary = {}

	for index in range(
		items_data.size()
	):
		var item_value: Variant = (
			items_data[index]
		)

		if typeof(
			item_value
		) != TYPE_DICTIONARY:
			_fail(
				"inventory.items[%d] "
				% index
				+"must be a Dictionary."
			)

			return null

		var item_data: Dictionary = (
			item_value
		)

		if not _has_keys(
			item_data,
			[
				"instance_id",
				"item_id",
			],
			"inventory item %d"
			% index
		):
			return null

		var instance_id := StringName(
			_string_value(
				item_data["instance_id"],
				"inventory item instance_id",
				false
			)
		)

		var item_id := StringName(
			_string_value(
				item_data["item_id"],
				"inventory item item_id",
				false
			)
		)

		if _failed():
			return null

		if used_ids.has(
			instance_id
		):
			_fail(
				"Duplicate inventory instance '%s'."
				% instance_id
			)

			return null

		var item_definition := (
			definition
				.get_equipment_item_definition(
					item_id
				)
		)

		if item_definition == null:
			_fail(
				"Unknown equipment definition '%s'."
				% item_id
			)

			return null

		var item := (
			HeroEquipmentItemInstance.new()
		)

		item.instance_id = instance_id
		item.definition = item_definition

		if not item.is_valid_instance():
			_fail(
				"Inventory item '%s' is invalid."
				% instance_id
			)

			return null

		inventory.items.append(
			item
		)

		used_ids[
			instance_id
		] = true

	if not inventory.is_valid_state():
		_fail(
			"Loaded inventory is invalid."
		)

		return null

	return inventory


func _decode_heroes(
	value: Variant,
	state: CampaignState,
	inventory_map: Dictionary
) -> bool:
	if typeof(
		value
	) != TYPE_ARRAY:
		_fail(
			"heroes must be an Array."
		)

		return false

	var data: Array = value

	if data.size() != state.heroes.size():
		_fail(
			"Saved hero roster does not match "
			+"current campaign content."
		)

		return false

	var seen: Dictionary = {}

	for index in range(
		data.size()
	):
		var hero_value: Variant = (
			data[index]
		)

		if typeof(
			hero_value
		) != TYPE_DICTIONARY:
			_fail(
				"heroes[%d] must be a Dictionary."
				% index
			)

			return false

		var hero_data: Dictionary = hero_value

		if not _has_keys(
			hero_data,
			[
				"hero_id",
				"level",
				"experience",
				"unspent_skill_points",
				"purchased_node_ids",
				"attached_skill_block_ids",
				"selected_personal_ability_ids",
				"equipment",
			],
			"hero %d"
			% index
		):
			return false

		var hero_id := StringName(
			_string_value(
				hero_data["hero_id"],
				"hero_id",
				false
			)
		)

		if _failed():
			return false

		if seen.has(
			hero_id
		):
			_fail(
				"Duplicate saved hero '%s'."
				% hero_id
			)

			return false

		var hero := state.get_hero(
			hero_id
		)

		if hero == null:
			_fail(
				"Unknown saved hero '%s'."
				% hero_id
			)

			return false

		var progression := (
			hero.progression_state
		)

		progression.level = _int_value(
			hero_data["level"],
			"level",
			1,
			HeroExperienceService.MAX_LEVEL
		)

		progression.experience = _int_value(
			hero_data["experience"],
			"experience",
			0,
			999999999
		)

		progression.unspent_skill_points = (
			_int_value(
				hero_data["unspent_skill_points"],
				"unspent_skill_points",
				0,
				999
			)
		)

		if _failed():
			return false

		if (
			progression.level
			>= HeroExperienceService.MAX_LEVEL
		):
			if progression.experience != 0:
				_fail(
					"Max-level hero '%s' "
					% hero_id
					+"must have zero stored XP."
				)

				return false

		else:
			var required_experience := (
				_experience_service
					.get_experience_required_for_next_level(
						progression.level
					)
			)

			if (
				progression.experience
				>= required_experience
			):
				_fail(
					"Hero '%s' has XP outside "
					% hero_id
					+"the current level range."
				)

				return false

		progression.purchased_node_ids = (
			_name_array(
				hero_data["purchased_node_ids"],
				"purchased_node_ids"
			)
		)

		progression.attached_skill_block_ids = (
			_name_array(
				hero_data[
					"attached_skill_block_ids"
				],
				"attached_skill_block_ids"
			)
		)

		progression.selected_personal_ability_ids = (
			_name_array(
				hero_data[
					"selected_personal_ability_ids"
				],
				"selected_personal_ability_ids"
			)
		)

		if _failed():
			return false

		progression.equipment_state = (
			_decode_equipment(
				hero_data["equipment"],
				inventory_map,
				hero_id
			)
		)

		if progression.equipment_state == null:
			return false

		seen[
			hero_id
		] = true

	return (
		seen.size()
		== state.heroes.size()
	)


func _decode_equipment(
	value: Variant,
	inventory_map: Dictionary,
	hero_id: StringName
) -> HeroEquipmentState:
	if typeof(
		value
	) != TYPE_DICTIONARY:
		_fail(
			"Equipment for '%s' "
			% hero_id
			+"must be a Dictionary."
		)

		return null

	var data: Dictionary = value

	if not _has_keys(
		data,
		EQUIPMENT_KEYS,
		"equipment for '%s'"
		% hero_id
	):
		return null

	var equipment := (
		HeroEquipmentState.new()
	)

	for key in EQUIPMENT_KEYS:
		var instance_id_text := (
			_string_value(
				data[key],
				"%s.%s"
				% [
					hero_id,
					key,
				],
				true
			)
		)

		if _failed():
			return null

		if instance_id_text.is_empty():
			continue

		var instance_id := StringName(
			instance_id_text
		)

		if not inventory_map.has(
			instance_id
		):
			_fail(
				"Hero '%s' references "
				% hero_id
				+"missing inventory item '%s'."
				% instance_id
			)

			return null

		## Здесь намеренно НЕ вызываем equip service.
		## Load восстанавливает точное сохранённое
		## состояние. Один instance_id всегда
		## возвращает один canonical object.
		equipment.set_item(
			_slot_for_key(
				key
			),
			inventory_map[
				instance_id
			]
		)

	if not equipment.is_valid_state():
		_fail(
			"Loaded equipment for '%s' is invalid."
			% hero_id
		)

		return null

	return equipment


func _decode_battle_result(
	value: Variant,
	state: CampaignState,
	definition: CampaignDefinition
) -> CampaignBattleResult:
	if typeof(
		value
	) != TYPE_DICTIONARY:
		_fail(
			"last_battle_result must be "
			+"a Dictionary or null."
		)

		return null

	var data: Dictionary = value

	if not _has_keys(
		data,
		[
			"request_id",
			"location_id",
			"encounter_id",
			"party_member_hero_ids",
			"winning_team_id",
			"outcome",
			"defeated_enemy_experience_pool",
			"experience_per_party_member",
			"undistributed_experience",
			"level_ups_by_hero_id",
			"loot_budget",
			"loot_tier_cap",
			"loot_item_value",
			"loot_item_instance_ids",
			"loot_item_display_names",
			"gold_reward",
		],
		"last_battle_result"
	):
		return null

	var result := CampaignBattleResult.new()

	result.request_id = StringName(
		_string_value(
			data["request_id"],
			"battle.request_id",
			false
		)
	)

	result.location_id = StringName(
		_string_value(
			data["location_id"],
			"battle.location_id",
			false
		)
	)

	result.encounter_id = StringName(
		_string_value(
			data["encounter_id"],
			"battle.encounter_id",
			true
		)
	)

	result.party_member_hero_ids = (
		_name_array(
			data["party_member_hero_ids"],
			"battle.party_member_hero_ids"
		)
	)

	result.winning_team_id = StringName(
		_string_value(
			data["winning_team_id"],
			"battle.winning_team_id",
			true
		)
	)

	result.outcome = _int_value(
		data["outcome"],
		"battle.outcome",
		CampaignBattleResult.Outcome.VICTORY,
		CampaignBattleResult.Outcome.DRAW
	)

	result.defeated_enemy_experience_pool = (
		_int_value(
			data[
				"defeated_enemy_experience_pool"
			],
			"battle.defeated_enemy_experience_pool",
			0,
			999999999
		)
	)

	result.experience_per_party_member = (
		_int_value(
			data[
				"experience_per_party_member"
			],
			"battle.experience_per_party_member",
			0,
			999999999
		)
	)

	result.undistributed_experience = (
		_int_value(
			data[
				"undistributed_experience"
			],
			"battle.undistributed_experience",
			0,
			999999999
		)
	)

	result.loot_budget = _int_value(
		data["loot_budget"],
		"battle.loot_budget",
		0,
		999999999
	)

	result.loot_tier_cap = _int_value(
		data["loot_tier_cap"],
		"battle.loot_tier_cap",
		0,
		99
	)

	result.loot_item_value = _int_value(
		data["loot_item_value"],
		"battle.loot_item_value",
		0,
		999999999
	)

	result.loot_item_instance_ids = (
		_name_array(
			data["loot_item_instance_ids"],
			"battle.loot_item_instance_ids"
		)
	)

	result.loot_item_display_names = (
		_packed_strings(
			data["loot_item_display_names"],
			"battle.loot_item_display_names"
		)
	)

	result.gold_reward = _int_value(
		data["gold_reward"],
		"battle.gold_reward",
		0,
		999999999
	)

	if _failed():
		return null

	if definition.get_location(
		result.location_id
	) == null:
		_fail(
			"Last battle references unknown location '%s'."
			% result.location_id
		)

		return null

	for hero_id in (
		result.party_member_hero_ids
	):
		if state.get_hero(
			hero_id
		) == null:
			_fail(
				"Last battle references unknown hero '%s'."
				% hero_id
			)

			return null

	if typeof(
		data["level_ups_by_hero_id"]
	) != TYPE_DICTIONARY:
		_fail(
			"battle.level_ups_by_hero_id "
			+"must be a Dictionary."
		)

		return null

	var level_ups_data: Dictionary = (
		data["level_ups_by_hero_id"]
	)

	for hero_id_text in level_ups_data:
		if typeof(
			hero_id_text
		) != TYPE_STRING:
			_fail(
				"Battle level-up hero ID "
				+"must be a String."
			)

			return null

		var hero_id := StringName(
			String(hero_id_text)
		)

		if state.get_hero(
			hero_id
		) == null:
			_fail(
				"Battle level-up references "
				+"unknown hero '%s'."
				% hero_id
			)

			return null

		result.level_ups_by_hero_id[
			hero_id
		] = _int_value(
			level_ups_data[
				hero_id_text
			],
			"battle.level_up",
			1,
			999
		)

		if _failed():
			return null

	return result


func _inventory_map(
	inventory: CampaignInventoryState
) -> Dictionary:
	var result: Dictionary = {}

	for item in inventory.items:
		result[
			item.instance_id
		] = item

	return result


func _has_keys(
	data: Dictionary,
	keys: Array,
	context: String
) -> bool:
	for key in keys:
		if not data.has(
			key
		):
			_fail(
				"%s is missing '%s'."
				% [
					context,
					key,
				]
			)

			return false

	return true


func _string_value(
	value: Variant,
	context: String,
	allow_empty: bool
) -> String:
	if typeof(
		value
	) != TYPE_STRING:
		_fail(
			"%s must be a String."
			% context
		)

		return ""

	var result := String(
		value
	)

	if (
		not allow_empty
		and result.is_empty()
	):
		_fail(
			"%s cannot be empty."
			% context
		)

	return result


func _int_value(
	value: Variant,
	context: String,
	minimum: int,
	maximum: int
) -> int:
	var result: int

	if typeof(
		value
	) == TYPE_INT:
		result = int(
			value
		)

	elif (
		typeof(
			value
		) == TYPE_FLOAT
		and float(
			value
		) == floor(
			float(value)
		)
	):
		result = int(
			value
		)

	else:
		_fail(
			"%s must be an integer number."
			% context
		)

		return minimum

	if (
		result < minimum
		or result > maximum
	):
		_fail(
			"%s must be between %d and %d."
			% [
				context,
				minimum,
				maximum,
			]
		)

	return result


func _name_array(
	value: Variant,
	context: String
) -> Array[StringName]:
	var result: Array[StringName] = []

	if typeof(
		value
	) != TYPE_ARRAY:
		_fail(
			"%s must be an Array."
			% context
		)

		return result

	var values: Array = value

	for index in range(
		values.size()
	):
		if (
			typeof(
				values[index]
			) != TYPE_STRING
			or String(
				values[index]
			).is_empty()
		):
			_fail(
				"%s[%d] must be a non-empty String."
				% [
					context,
					index,
				]
			)

			return result

		result.append(
			StringName(
				String(
					values[index]
				)
			)
		)

	return result


func _packed_strings(
	value: Variant,
	context: String
) -> PackedStringArray:
	var result := PackedStringArray()

	if typeof(
		value
	) != TYPE_ARRAY:
		_fail(
			"%s must be an Array."
			% context
		)

		return result

	var values: Array = value

	for index in range(
		values.size()
	):
		if typeof(
			values[index]
		) != TYPE_STRING:
			_fail(
				"%s[%d] must be a String."
				% [
					context,
					index,
				]
			)

			return result

		result.append(
			String(
				values[index]
			)
		)

	return result


func _packed_to_array(
	values: PackedStringArray
) -> Array:
	var result: Array = []

	for value in values:
		result.append(
			value
		)

	return result


func _names_to_array(
	values: Array[StringName]
) -> Array:
	var result: Array = []

	for value in values:
		result.append(
			String(value)
		)

	return result


func _slot_for_key(
	key: String
) -> int:
	match key:
		"weapon_1":
			return HeroEquipmentState.Slot.WEAPON_1

		"weapon_2":
			return HeroEquipmentState.Slot.WEAPON_2

		"head":
			return HeroEquipmentState.Slot.HEAD

		"armor":
			return HeroEquipmentState.Slot.ARMOR

		"gloves":
			return HeroEquipmentState.Slot.GLOVES

		"boots":
			return HeroEquipmentState.Slot.BOOTS

		"charm":
			return HeroEquipmentState.Slot.CHARM

		"ring_1":
			return HeroEquipmentState.Slot.RING_1

		"ring_2":
			return HeroEquipmentState.Slot.RING_2

	return -1


func _fail(
	message: String
) -> void:
	if _error_message.is_empty():
		_error_message = message


func _failed() -> bool:
	return not _error_message.is_empty()


func _result(
	is_successful: bool,
	status_code: StringName,
	message: String,
	campaign_state: CampaignState = null
) -> CampaignSaveResult:
	var result := CampaignSaveResult.new()

	result.is_successful = is_successful
	result.status_code = status_code
	result.message = message
	result.campaign_state = campaign_state

	return result