class_name CampaignConstructionContract
extends RefCounted

enum Status { RESERVED, ACTIVE, COMPLETED }

var project_id: StringName = &""
var source_id: StringName = &""
var crew_size: int = 0
var status: Status = Status.RESERVED
## Immutable paid quote once signed. Campaign time, not wall-clock time.
var started_at: int = 0
var completes_at: int = 0
var paid_gold: int = 0
var paid_materials: int = 0


func is_valid_state() -> bool:
	if project_id == &"" or source_id == &"" or crew_size < 1 or crew_size > 100 or not Status.values().has(status):
		return false
	if status == Status.RESERVED:
		return started_at == 0 and completes_at == 0 and paid_gold == 0 and paid_materials == 0
	return started_at >= 0 and completes_at > started_at and paid_gold >= 0 and paid_materials >= 0
