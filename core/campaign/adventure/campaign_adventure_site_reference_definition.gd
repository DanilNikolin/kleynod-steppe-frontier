@tool
class_name CampaignAdventureSiteReferenceDefinition
extends Resource


@export
var area_id: StringName = &""

@export
var site_id: StringName = &""


func is_valid_definition() -> bool:
	return (
		area_id != &""
		and site_id != &""
	)
