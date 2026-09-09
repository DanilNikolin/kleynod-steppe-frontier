@tool
class_name CampaignDialogueNode
extends Resource


@export var node_id: StringName = &""
@export_multiline var text: String = ""
## Evaluated for entry selection and rechecked before choosing an answer.
@export var conditions: Array[CampaignDialogueCondition] = []
## An empty list is a terminal reply; the panel still offers Close.
@export var choices: Array[CampaignDialogueChoice] = []


func is_available(state: CampaignState, campaign: CampaignDefinition) -> bool:
	for condition in conditions:
		if condition == null or not condition.matches(state, campaign):
			return false
	return true


func get_choice(id: StringName) -> CampaignDialogueChoice:
	for choice in choices:
		if choice != null and choice.choice_id == id:
			return choice
	return null


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if node_id == &"" or text.strip_edges().is_empty():
		errors.append("Dialogue node needs an ID and text.")
	for condition in conditions:
		if condition == null:
			errors.append("Null dialogue node condition.")
		else:
			errors.append_array(condition.get_validation_errors())
	var used_ids: Dictionary = {}
	for choice in choices:
		if choice == null:
			errors.append("Null dialogue choice.")
			continue
		errors.append_array(choice.get_validation_errors())
		if used_ids.has(choice.choice_id):
			errors.append("Duplicate dialogue choice: %s." % choice.choice_id)
		used_ids[choice.choice_id] = true
	return errors
