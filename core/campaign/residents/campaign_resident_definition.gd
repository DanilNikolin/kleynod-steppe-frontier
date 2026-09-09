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