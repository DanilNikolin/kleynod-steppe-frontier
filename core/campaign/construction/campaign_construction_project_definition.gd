@tool
class_name CampaignConstructionProjectDefinition
extends Resource

@export var project_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var zone_id: StringName = &""
@export var building_id: StringName = &""
@export_range(1, 99) var target_level: int = 1
@export var required_knowledge_id: StringName = &""
@export var required_agreement_id: StringName = &""
## A construction specialist, if required. Forge equipment is NOT part of its shell.
@export var required_specialist_id: StringName = &""
@export var implementation_enabled: bool = false
@export_range(1, 10000) var labor_worker_days: int = 12
@export_range(1, 100) var minimum_crew: int = 2
@export_range(1, 100) var maximum_effective_crew: int = 4
@export_range(0, 999999) var material_cost: int = 12
@export_range(0, 999999) var component_gold_cost: int = 0


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if project_id == &"" or display_name.is_empty() or zone_id == &"" or building_id == &"":
		errors.append("Construction project needs identity and a target building.")
	if required_knowledge_id == &"" or required_agreement_id == &"":
		errors.append("Knowledge and agreement must be specified independently.")
	if labor_worker_days < 1 or minimum_crew < 1 or maximum_effective_crew < minimum_crew or maximum_effective_crew > 100:
		errors.append("Invalid project labor or crew bounds.")
	if material_cost < 0 or component_gold_cost < 0 or target_level < 1:
		errors.append("Invalid construction costs or target level.")
	return errors
