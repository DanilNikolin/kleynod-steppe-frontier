@tool
class_name CampaignCrewSourceDefinition
extends Resource

@export var source_id: StringName = &""
@export var display_name: String = ""
@export var world_node_id: StringName = &""
@export var interaction_id: StringName = &""
## Settlement size is authored per source; reputation expands its available crew.
@export var base_capacity: int = 4
@export var maximum_capacity: int = 6
@export var minimum_reputation: int = 0
@export var reputation_per_extra_worker: int = 5
@export var daily_wage: int = 2
## More hands finish sooner; mobilizing a larger crew increases total cost.
@export var mobilization_per_worker: int = 2


func get_capacity(reputation: int) -> int:
	if reputation < minimum_reputation:
		return 0
	return mini(maximum_capacity, base_capacity + maxi(0, reputation - minimum_reputation) / reputation_per_extra_worker)


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if source_id == &"" or display_name.is_empty() or world_node_id == &"" or interaction_id == &"":
		errors.append("Crew source needs identity and a local contact.")
	if base_capacity < 1 or maximum_capacity < base_capacity or maximum_capacity > 100 or reputation_per_extra_worker < 1 or daily_wage < 0 or mobilization_per_worker < 0:
		errors.append("Invalid crew capacity or wages.")
	return errors
