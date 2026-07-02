class_name BattleActionPreviewResult
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var ability_id: StringName = &""

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var target_previews: Array[BattleTargetPreview] = []


func get_target_preview(
	target_id: StringName
) -> BattleTargetPreview:
	for target_preview in target_previews:
		if (
			target_preview != null
			and target_preview.target_id
				== target_id
		):
			return target_preview

	return null