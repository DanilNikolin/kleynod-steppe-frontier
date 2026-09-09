@tool
class_name CampaignDialogueDefinition
extends Resource


@export var dialogue_id: StringName = &""
@export var speaker_name: String = ""
## First matching node wins. The last entry must be unconditional.
@export var entry_node_ids: Array[StringName] = []
@export var nodes: Array[CampaignDialogueNode] = []


func get_node(id: StringName) -> CampaignDialogueNode:
	for node in nodes:
		if node != null and node.node_id == id:
			return node
	return null


func get_entry(state: CampaignState, campaign: CampaignDefinition) -> CampaignDialogueNode:
	for id in entry_node_ids:
		var node := get_node(id)
		if node != null and node.is_available(state, campaign):
			return node
	return null


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if dialogue_id == &"" or speaker_name.strip_edges().is_empty():
		errors.append("Dialogue needs an ID and speaker name.")
	if entry_node_ids.is_empty():
		errors.append("Dialogue has no entry nodes.")
	var used_ids: Dictionary = {}
	for node in nodes:
		if node == null:
			errors.append("Null dialogue node.")
			continue
		errors.append_array(node.get_validation_errors())
		if used_ids.has(node.node_id):
			errors.append("Duplicate dialogue node: %s." % node.node_id)
		used_ids[node.node_id] = true
		for choice in node.choices:
			if choice != null and choice.next_node_id != &"" and get_node(choice.next_node_id) == null:
				errors.append("Missing dialogue destination: %s." % choice.next_node_id)
			if choice != null and choice.action != CampaignDialogueChoice.Action.NONE and choice.next_node_id != &"":
				var destination := get_node(choice.next_node_id)
				if destination != null and not destination.conditions.is_empty():
					errors.append("Dialogue action destination must be unconditional.")
	used_ids.clear()
	for index in range(entry_node_ids.size()):
		var id := entry_node_ids[index]
		var node := get_node(id)
		if used_ids.has(id):
			errors.append("Duplicate dialogue entry: %s." % id)
		used_ids[id] = true
		if node == null:
			errors.append("Missing dialogue entry: %s." % id)
		elif index == entry_node_ids.size() - 1:
			if not node.conditions.is_empty():
				errors.append("Last dialogue entry must be unconditional.")
		elif node.conditions.is_empty():
			errors.append("Unconditional dialogue entry shadows later entries.")
	return errors


func get_reference_errors(campaign: CampaignDefinition) -> PackedStringArray:
	var errors := PackedStringArray()
	for node in nodes:
		if node == null:
			continue
		for condition in node.conditions:
			if condition != null:
				errors.append_array(condition.get_reference_errors(campaign))
		for choice in node.choices:
			if choice == null:
				continue
			for condition in choice.conditions:
				if condition != null:
					errors.append_array(condition.get_reference_errors(campaign))
			match choice.action:
				CampaignDialogueChoice.Action.START_QUEST, CampaignDialogueChoice.Action.TURN_IN_QUEST:
					if campaign.get_quest(choice.target_id) == null:
						errors.append("Unknown dialogue action quest: %s." % choice.target_id)
				CampaignDialogueChoice.Action.INVITE_RESIDENT:
					if campaign.get_resident(choice.target_id) == null:
						errors.append("Unknown dialogue action resident: %s." % choice.target_id)
	return errors
