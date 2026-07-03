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
var surface_placement_previews: Array[BattleSurfacePlacementPreview] = []


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


func get_surface_placement_previews_at(
	coordinate: Vector2i
) -> Array[BattleSurfacePlacementPreview]:
	var result: Array[BattleSurfacePlacementPreview] = []

	for placement_preview in surface_placement_previews:
		if (
			placement_preview != null
			and placement_preview.coordinate
				== coordinate
		):
			result.append(
				placement_preview
			)

	return result