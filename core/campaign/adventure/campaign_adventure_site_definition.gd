@tool
class_name CampaignAdventureSiteDefinition
extends Resource


enum SiteType {
	LANDMARK,
	BATTLE,
}


@export_group("Identity")

@export
var site_id: StringName = &""

@export
var display_name: String = "Unnamed Adventure Site"

@export_multiline
var description: String = ""


@export_group("Area")

## Позиция на внутренней authored-карте региона.
@export
var map_position: Vector2 = Vector2.ZERO

## Связи рисуются от этой точки
## к указанным точкам.
@export
var connected_site_ids: Array[StringName] = []

## false = точка начинает HIDDEN.
@export
var starting_available: bool = true


@export_group("Action")

@export
var site_type: SiteType = SiteType.LANDMARK

## Stable ID CampaignLocationDefinition.
## Нужен только BATTLE-site.
@export
var campaign_location_id: StringName = &""

## После победы persistent state становится CLEARED.
@export
var clear_on_victory: bool = false


@export_group("Exploration")

## LANDMARK может иметь одноразовое authored-действие
## без запуска tactical battle.
@export
var exploration_enabled: bool = false

@export
var exploration_action_label: String = "ИССЛЕДОВАТЬ"

## Пока поддерживаем только нужный сейчас
## простой reward. Более общий reward model
## добавим только когда реально понадобится.
@export_range(0, 999999999, 1)
var material_reward: int = 0


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if site_id == &"":
		errors.append(
			"Adventure site ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Adventure site display name is empty."
		)

	match site_type:
		SiteType.LANDMARK:
			if campaign_location_id != &"":
				errors.append(
					"LANDMARK site cannot reference "
					+"a campaign battle location."
				)

			if clear_on_victory:
				errors.append(
					"LANDMARK site cannot clear on victory."
				)

			if (
				exploration_enabled
				and exploration_action_label
					.strip_edges()
					.is_empty()
			):
				errors.append(
					"Enabled LANDMARK exploration requires an action label."
				)

			if (
				material_reward > 0
				and not exploration_enabled
			):
				errors.append(
					"LANDMARK material reward requires exploration."
				)

		SiteType.BATTLE:
			if campaign_location_id == &"":
				errors.append(
					"BATTLE site requires "
					+"a campaign location ID."
				)

			if exploration_enabled:
				errors.append(
					"BATTLE site cannot use LANDMARK exploration."
				)

			if material_reward != 0:
				errors.append(
					"BATTLE site cannot use LANDMARK material reward."
				)

	var used_connection_ids: Dictionary = {}

	for connected_site_id in connected_site_ids:
		if connected_site_id == &"":
			errors.append(
				"Adventure site connection ID is empty."
			)

			continue

		if connected_site_id == site_id:
			errors.append(
				"Adventure site cannot connect to itself."
			)

			continue

		if used_connection_ids.has(
			connected_site_id
		):
			errors.append(
				"Duplicate adventure site connection: %s."
				% connected_site_id
			)

			continue

		used_connection_ids[
			connected_site_id
		] = true

	return errors