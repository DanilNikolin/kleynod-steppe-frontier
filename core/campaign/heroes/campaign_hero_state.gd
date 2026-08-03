@tool
class_name CampaignHeroState
extends Resource


@export_group("Hero")

@export
var hero_definition: HeroDefinition

@export
var progression_state: HeroProgressionState


@export_group("Campaign Presentation")

## Временный герой, использующий общий debug-контент.
## Campaign Flow уже работает, но уникальный набор
## способностей героя ещё не реализован.
@export
var is_placeholder_content: bool = false

@export_multiline
var roster_note: String = ""


func get_hero_id() -> StringName:
	if hero_definition == null:
		return &""

	return hero_definition.hero_id


func get_display_name() -> String:
	if hero_definition == null:
		return "Неизвестный герой"

	return hero_definition.display_name


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