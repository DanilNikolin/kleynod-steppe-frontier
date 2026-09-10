@tool
class_name CampaignResidentDefinition
extends Resource


@export_group("Identity")

@export
var resident_id: StringName = &""

@export
var display_name: String = "Unnamed Resident"

@export_multiline
var description: String = ""


@export_group("Dialogue")

@export
var dialogue: CampaignDialogueDefinition


@export_group("Recruitment")

## Где NPC находится до приглашения.
@export
var origin_world_node_id: StringName = &""

## Interaction внутри origin Local Location.
@export
var origin_interaction_id: StringName = &""

## Interaction внутри HOME после приглашения.
@export
var home_interaction_id: StringName = &""

@export_range(-999999999, 999999999, 1)
var required_reputation: int = 0

## Debug/content starting state.
## В будущем quest system выставит runtime-state unlock.
@export
var starting_recruitment_unlocked: bool = false


## Guest arrival is distinct from permanent settlement.
@export var arrives_as_guest: bool = false
@export var arrival_construction_knowledge_ids: Array[StringName] = []
@export var arrival_construction_agreement_ids: Array[StringName] = []
@export var required_home_effect_ids: Array[StringName] = []


@export_group("Wandering")

## Empty for stationary residents. All locations share origin_interaction_id.
@export var wandering_world_node_ids: Array[StringName] = []
## DEV pacing: three days per job; tune when the early region is authored.
@export_range(1, 999999, 1) var wandering_interval_minutes: int = 4320


@export_group("Workplace")

## Оба поля могут быть пустыми для жителя,
## которому не требуется специальное рабочее место.
@export
var required_workplace_zone_id: StringName = &""

@export
var required_workplace_building_id: StringName = &""


@export_group("Services")

@export
var equipment_commissions: Array[CampaignEquipmentCommissionDefinition] = []


func get_equipment_commission(
	commission_id: StringName
) -> CampaignEquipmentCommissionDefinition:
	if commission_id == &"":
		return null

	for commission in equipment_commissions:
		if (
			commission != null
			and commission.commission_id
				== commission_id
		):
			return commission

	return null


func has_required_workplace() -> bool:
	return (
		required_workplace_zone_id != &""
		and required_workplace_building_id != &""
	)


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if resident_id == &"":
		errors.append(
			"Resident ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Resident display name is empty."
		)

	if origin_world_node_id == &"":
		errors.append(
			"Resident origin world node ID is empty."
		)

	if origin_interaction_id == &"":
		errors.append(
			"Resident origin interaction ID is empty."
		)

	if home_interaction_id == &"":
		errors.append(
			"Resident home interaction ID is empty."
		)

	var has_workplace_zone := (
		required_workplace_zone_id != &""
	)

	var has_workplace_building := (
		required_workplace_building_id != &""
	)

	if (
		has_workplace_zone
		!= has_workplace_building
	):
		errors.append(
			"Resident workplace requires both zone "
			+"and building IDs."
		)

	if not wandering_world_node_ids.is_empty():
		if wandering_world_node_ids.size() < 2 or not wandering_world_node_ids.has(origin_world_node_id):
			errors.append("Wandering needs at least two locations including the origin.")
		var seen_locations: Dictionary = {}
		for id in wandering_world_node_ids:
			if id == &"" or seen_locations.has(id):
				errors.append("Empty or duplicate wandering location.")
			seen_locations[id] = true
		if wandering_interval_minutes < 1:
			errors.append("Wandering interval must be positive.")

	var seen_home_effects: Dictionary = {}
	for id in required_home_effect_ids:
		if id == &"" or seen_home_effects.has(id):
			errors.append("Empty or duplicate HOME recruitment effect.")
		seen_home_effects[id] = true
	if arrives_as_guest and not required_home_effect_ids.has(&"temporary_guest_access"):
		errors.append("Guest arrival requires temporary_guest_access.")

	var used_commission_ids: Dictionary = {}

	for commission_index in range(
		equipment_commissions.size()
	):
		var commission := equipment_commissions[
			commission_index
		]

		if commission == null:
			errors.append(
				"Equipment commission at index %d is null."
				% commission_index
			)

			continue

		for commission_error in (
			commission.get_validation_errors()
		):
			errors.append(
				"Equipment commission %d: %s"
				% [
					commission_index,
					commission_error,
				]
			)

		if commission.commission_id == &"":
			continue

		if used_commission_ids.has(
			commission.commission_id
		):
			errors.append(
				"Duplicate equipment commission ID: %s."
				% commission.commission_id
			)

			continue

		used_commission_ids[
			commission.commission_id
		] = true

	if dialogue != null:
		errors.append_array(dialogue.get_validation_errors())

	return errors
