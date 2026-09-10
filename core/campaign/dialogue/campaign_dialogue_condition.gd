@tool
class_name CampaignDialogueCondition
extends Resource


enum Kind { QUEST_NOT_STARTED, QUEST_ACTIVE, QUEST_READY, QUEST_COMPLETED, RESIDENT_AT_HOME, RESIDENT_MET }

@export var kind: Kind = Kind.QUEST_NOT_STARTED
@export var target_id: StringName = &""
@export var unavailable_text: String = "Этот ответ сейчас недоступен."


func matches(state: CampaignState, campaign: CampaignDefinition) -> bool:
	if state == null or campaign == null:
		return false
	if kind in [Kind.RESIDENT_AT_HOME, Kind.RESIDENT_MET]:
		var resident := state.get_resident(target_id)
		return resident != null and (resident.has_met if kind == Kind.RESIDENT_MET else resident.is_at_home())
	var quest := state.get_quest(target_id)
	var definition := campaign.get_quest(target_id)
	if quest == null or definition == null:
		return false
	match kind:
		Kind.QUEST_NOT_STARTED:
			return quest.is_not_started()
		Kind.QUEST_ACTIVE:
			return quest.is_active()
		Kind.QUEST_READY:
			return quest.is_ready_to_turn_in(definition)
		Kind.QUEST_COMPLETED:
			return quest.is_completed()
	return false


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if not Kind.values().has(kind):
		errors.append("Unknown dialogue condition kind.")
	if target_id == &"":
		errors.append("Dialogue condition target is empty.")
	if unavailable_text.strip_edges().is_empty():
		errors.append("Dialogue condition needs an unavailable explanation.")
	return errors


func get_reference_errors(campaign: CampaignDefinition) -> PackedStringArray:
	if kind in [Kind.RESIDENT_AT_HOME, Kind.RESIDENT_MET]:
		if campaign.get_resident(target_id) == null:
			return PackedStringArray(["Unknown dialogue resident: %s." % target_id])
	elif campaign.get_quest(target_id) == null:
		return PackedStringArray(["Unknown dialogue quest: %s." % target_id])
	return PackedStringArray()
