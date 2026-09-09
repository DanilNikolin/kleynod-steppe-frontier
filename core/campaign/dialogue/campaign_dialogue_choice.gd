@tool
class_name CampaignDialogueChoice
extends Resource


enum Action { NONE, START_QUEST, TURN_IN_QUEST, INVITE_RESIDENT, OPEN_TRADING }

@export var choice_id: StringName = &""
@export_multiline var text: String = ""
## Empty destination ends the conversation after a successful action.
@export var next_node_id: StringName = &""
@export var conditions: Array[CampaignDialogueCondition] = []
@export var hide_when_unavailable: bool = true
@export var action: Action = Action.NONE
@export var target_id: StringName = &""


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if choice_id == &"" or text.strip_edges().is_empty():
		errors.append("Dialogue choice needs an ID and text.")
	if not Action.values().has(action):
		errors.append("Unknown dialogue action.")
	if action != Action.NONE and target_id == &"":
		errors.append("Dialogue action target is empty.")
	if action == Action.NONE and target_id != &"":
		errors.append("A dialogue choice without an action cannot have a target.")
	if action == Action.OPEN_TRADING and next_node_id == &"":
		errors.append("Trading choice needs a return node.")
	for condition in conditions:
		if condition == null:
			errors.append("Null dialogue choice condition.")
		else:
			errors.append_array(condition.get_validation_errors())
	return errors
