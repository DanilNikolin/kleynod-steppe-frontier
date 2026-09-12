class_name LocalBuildableVisual
extends Node2D


@export var construction_root: CanvasItem
@export var built_root: CanvasItem


func _ready() -> void:
	if construction_root == null:
		construction_root = get_node_or_null("Construction") as CanvasItem
	if built_root == null:
		built_root = get_node_or_null("Built") as CanvasItem


func set_build_state(
	state: LocalBuildSiteView.BuildVisualState,
	construction_progress: float = 0.0
) -> void:
	if construction_root == null:
		construction_root = get_node_or_null("Construction") as CanvasItem
	if built_root == null:
		built_root = get_node_or_null("Built") as CanvasItem

	match state:
		LocalBuildSiteView.BuildVisualState.EMPTY:
			if construction_root != null:
				construction_root.visible = false
			if built_root != null:
				built_root.visible = false

		LocalBuildSiteView.BuildVisualState.CONSTRUCTING:
			if built_root != null:
				built_root.visible = false
			if construction_root != null:
				construction_root.visible = true
				_apply_construction_stage(construction_progress)

		LocalBuildSiteView.BuildVisualState.BUILT:
			if construction_root != null:
				construction_root.visible = false
			if built_root != null:
				built_root.visible = true


func _apply_construction_stage(progress: float) -> void:
	if construction_root == null:
		return

	var stages: Array[Node] = []
	for child in construction_root.get_children():
		if child is CanvasItem:
			stages.append(child)

	if stages.is_empty():
		return

	# If stages have LocalConstructionStageVisual, find the best match by start_progress
	var stage_visuals: Array[Dictionary] = []
	for stage in stages:
		var start_p: float = 0.0
		if stage is LocalConstructionStageVisual:
			start_p = stage.start_progress
		elif stage.has_meta("start_progress"):
			start_p = float(stage.get_meta("start_progress"))

		stage_visuals.append({
			"node": stage as CanvasItem,
			"start_progress": start_p,
		})

	stage_visuals.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return float(a["start_progress"]) < float(b["start_progress"])
	)

	var active_node: CanvasItem = null
	for item in stage_visuals:
		if progress >= float(item["start_progress"]):
			active_node = item["node"] as CanvasItem

	# If progress is before the first threshold, default to the first stage
	if active_node == null and not stage_visuals.is_empty():
		active_node = stage_visuals[0]["node"] as CanvasItem

	for item in stage_visuals:
		var node := item["node"] as CanvasItem
		node.visible = (node == active_node)
