@tool
class_name CampaignQuestObjectiveDefinition
extends Resource


enum ObjectiveType {
	WIN_LOCATION_BATTLE,
	EXPLORE_ADVENTURE_SITE,
}


@export_group("Identity")

@export
var objective_id: StringName = &""

@export
var display_name: String = "Unnamed Objective"


@export_group("Objective")

@export
var objective_type: ObjectiveType = (
	ObjectiveType.WIN_LOCATION_BATTLE
)

## CampaignLocationDefinition.location_id.
@export
var target_location_id: StringName = &""


## Used by EXPLORE_ADVENTURE_SITE; tools and testimony are quest progress,
## not sellable inventory items.
@export var target_area_id: StringName = &""
@export var target_site_id: StringName = &""


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if objective_id == &"":
		errors.append(
			"Quest objective ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Quest objective display name is empty."
		)

	match objective_type:
		ObjectiveType.WIN_LOCATION_BATTLE:
			if target_location_id == &"":
				errors.append(
					"WIN_LOCATION_BATTLE objective "
					+"requires target location ID."
				)

		ObjectiveType.EXPLORE_ADVENTURE_SITE:
			if target_area_id == &"" or target_site_id == &"":
				errors.append("Exploration objective requires an area and site.")
		_:
			errors.append("Unknown quest objective type.")
	return errors