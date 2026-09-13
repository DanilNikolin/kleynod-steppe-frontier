class_name LocalBuildableVisual
extends Node2D


@export var construction_root: CanvasItem
@export var built_root: CanvasItem
@export var ambient: ConstructionAmbient
@export var transition_fx: ConstructionTransitionFX

var _has_received_state: bool = false
var _last_visual_state: int = -1
var _last_active_stage: CanvasItem = null


func _ready() -> void:
	if construction_root == null:
		construction_root = get_node_or_null("Construction") as CanvasItem
	if built_root == null:
		built_root = get_node_or_null("Built") as CanvasItem
	if ambient == null:
		ambient = get_node_or_null("Construction/Ambient") as ConstructionAmbient
		if ambient == null and construction_root != null:
			for child in construction_root.get_children():
				if child is ConstructionAmbient:
					ambient = child
					break
	if transition_fx == null:
		transition_fx = get_node_or_null("TransitionFX") as ConstructionTransitionFX
		if transition_fx == null:
			for child in get_children():
				if child is ConstructionTransitionFX:
					transition_fx = child
					break


func set_build_state(
	state: LocalBuildSiteView.BuildVisualState,
	construction_progress: float = 0.0
) -> void:
	if construction_root == null:
		construction_root = get_node_or_null("Construction") as CanvasItem
	if built_root == null:
		built_root = get_node_or_null("Built") as CanvasItem
	if ambient == null:
		ambient = get_node_or_null("Construction/Ambient") as ConstructionAmbient
		if ambient == null and construction_root != null:
			for child in construction_root.get_children():
				if child is ConstructionAmbient:
					ambient = child
					break
	if transition_fx == null:
		transition_fx = get_node_or_null("TransitionFX") as ConstructionTransitionFX
		if transition_fx == null:
			for child in get_children():
				if child is ConstructionTransitionFX:
					transition_fx = child
					break

	var active_stage: CanvasItem = null
	var stage_changed: bool = false

	match state:
		LocalBuildSiteView.BuildVisualState.EMPTY:
			if construction_root != null:
				construction_root.visible = false
			if built_root != null:
				built_root.visible = false
			if ambient != null:
				ambient.set_active(false)
			if _last_active_stage != null:
				_set_stage_detail_animations_active(_last_active_stage, false)

		LocalBuildSiteView.BuildVisualState.CONSTRUCTING:
			if built_root != null:
				built_root.visible = false
			if construction_root != null:
				construction_root.visible = true
				active_stage = _apply_construction_stage(construction_progress)
			if _last_visual_state == int(LocalBuildSiteView.BuildVisualState.CONSTRUCTING):
				if active_stage != null and _last_active_stage != null and active_stage != _last_active_stage:
					stage_changed = true
					_set_stage_detail_animations_active(_last_active_stage, false)
			elif _last_active_stage != null and _last_active_stage != active_stage:
				_set_stage_detail_animations_active(_last_active_stage, false)

			if active_stage != null:
				_set_stage_detail_animations_active(active_stage, true)

			if ambient != null:
				ambient.set_active(true)

		LocalBuildSiteView.BuildVisualState.BUILT:
			if construction_root != null:
				construction_root.visible = false
			if built_root != null:
				built_root.visible = true
			if ambient != null:
				ambient.set_active(false)
			if _last_active_stage != null:
				_set_stage_detail_animations_active(_last_active_stage, false)

	# Transition FX trigger criteria:
	# Only triggers if this is NOT the first state synchronization.
	# A. EMPTY -> CONSTRUCTING
	# B. CONSTRUCTING -> CONSTRUCTING (real stage change)
	# C. CONSTRUCTING -> BUILT
	if _has_received_state and transition_fx != null:
		var should_transition: bool = false
		if _last_visual_state == int(LocalBuildSiteView.BuildVisualState.EMPTY) and state == LocalBuildSiteView.BuildVisualState.CONSTRUCTING:
			should_transition = true
		elif _last_visual_state == int(LocalBuildSiteView.BuildVisualState.CONSTRUCTING) and state == LocalBuildSiteView.BuildVisualState.CONSTRUCTING and stage_changed:
			should_transition = true
		elif _last_visual_state == int(LocalBuildSiteView.BuildVisualState.CONSTRUCTING) and state == LocalBuildSiteView.BuildVisualState.BUILT:
			should_transition = true

		if should_transition:
			transition_fx.play_transition()

	_has_received_state = true
	_last_visual_state = int(state)
	_last_active_stage = active_stage


func _set_stage_detail_animations_active(stage_node: Node, active: bool) -> void:
	if stage_node == null:
		return

	var controllers := stage_node.find_children("*", "IntermittentDetailAnimation", true, false)
	for controller in controllers:
		if controller is IntermittentDetailAnimation:
			controller.set_active(active)
		elif controller.has_method("set_active"):
			controller.call("set_active", active)


func _apply_construction_stage(progress: float) -> CanvasItem:
	if construction_root == null:
		return null

	var stages: Array[Node] = []
	for child in construction_root.get_children():
		# Only consider nodes that are not ConstructionAmbient
		if child is CanvasItem and not (child is ConstructionAmbient):
			stages.append(child)

	if stages.is_empty():
		return null

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

	return active_node

