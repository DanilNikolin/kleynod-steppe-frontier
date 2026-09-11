class_name LocalBuildSiteView
extends LocalInteractionAnchor


func get_interaction_button() -> Button:
	return get_node_or_null("InteractionButton") as Button


func set_built(is_built: bool) -> void:
	var built_visual := (
		get_node_or_null("BuiltVisual")
		as CanvasItem
	)

	if built_visual != null:
		built_visual.visible = is_built


func is_built_visual_available() -> bool:
	return (
		get_node_or_null("BuiltVisual")
		is CanvasItem
	)
