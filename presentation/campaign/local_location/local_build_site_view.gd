class_name LocalBuildSiteView
extends LocalInteractionAnchor


enum BuildVisualState {
	EMPTY,
	CONSTRUCTING,
	BUILT,
}


func get_interaction_button() -> Button:
	return get_node_or_null("InteractionButton") as Button


func set_build_state(state: BuildVisualState) -> void:
	var construction_visual := (
		get_node_or_null("ConstructionVisual")
		as CanvasItem
	)
	var built_visual := (
		get_node_or_null("BuiltVisual")
		as CanvasItem
	)

	match state:
		BuildVisualState.EMPTY:
			if construction_visual != null:
				construction_visual.visible = false
			if built_visual != null:
				built_visual.visible = false

		BuildVisualState.CONSTRUCTING:
			if construction_visual != null:
				construction_visual.visible = true
			if built_visual != null:
				built_visual.visible = false

		BuildVisualState.BUILT:
			if construction_visual != null:
				construction_visual.visible = false
			if built_visual != null:
				built_visual.visible = true


func set_built(is_built: bool) -> void:
	set_build_state(
		BuildVisualState.BUILT
		if is_built
		else BuildVisualState.EMPTY
	)


func is_built_visual_available() -> bool:
	return (
		get_node_or_null("BuiltVisual")
		is CanvasItem
	)
