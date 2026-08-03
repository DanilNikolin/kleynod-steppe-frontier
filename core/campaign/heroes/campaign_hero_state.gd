@tool
class_name CampaignHeroState
extends Resource


@export_group("Hero")

@export
var hero_definition: HeroDefinition

@export
var progression_state: HeroProgressionState


func get_hero_id() -> StringName:
	if hero_definition == null:
		return &""

	return hero_definition.hero_id


func is_valid_state() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if hero_definition == null:
		errors.append(
			"Campaign hero definition is not assigned."
		)

	elif not hero_definition.is_valid_definition():
		errors.append(
			"Campaign hero definition is invalid."
		)

	if progression_state == null:
		errors.append(
			"Campaign hero progression is not assigned."
		)

	elif not progression_state.is_valid_state():
		errors.append(
			"Campaign hero progression is invalid."
		)

	return errors