@tool
class_name CampaignForgeModuleDefinition
extends Resource

@export var module_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
## Provisional costs apply to both first installation and replacement.
@export var gold_cost: int = 20
@export var material_cost: int = 4
@export var duration_minutes: int = 240

func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if module_id == &"" or display_name.is_empty():
		errors.append("Forge module needs identity.")
	if gold_cost < 0 or material_cost < 0 or duration_minutes <= 0:
		errors.append("Invalid forge module costs or time.")
	return errors
