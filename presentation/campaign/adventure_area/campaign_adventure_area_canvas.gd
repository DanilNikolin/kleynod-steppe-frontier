class_name CampaignAdventureAreaCanvas
extends Control


signal site_selected(
	site_id: StringName
)


var _definition: CampaignAdventureAreaDefinition
var _state: CampaignAdventureAreaState

var _selected_site_id: StringName = &""


func bind(
	definition: CampaignAdventureAreaDefinition,
	state: CampaignAdventureAreaState
) -> void:
	_definition = definition
	_state = state

	_rebuild_site_buttons()

	queue_redraw()


func set_selected_site(
	site_id: StringName
) -> void:
	_selected_site_id = site_id

	_rebuild_site_buttons()

	queue_redraw()


func _draw() -> void:
	if (
		_definition == null
		or _state == null
	):
		return

	for site in _definition.sites:
		if (
			site == null
			or not _is_site_visible(
				site.site_id
			)
		):
			continue

		for target_id in (
			site.connected_site_ids
		):
			var target := (
				_definition.get_site(
					target_id
				)
			)

			if (
				target == null
				or not _is_site_visible(
					target.site_id
				)
			):
				continue

			draw_line(
				site.map_position,
				target.map_position,
				Color(
					0.42,
					0.44,
					0.48,
					1.0
				),
				3.0
			)


func _rebuild_site_buttons() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	if (
		_definition == null
		or _state == null
	):
		return

	for site in _definition.sites:
		if (
			site == null
			or not _is_site_visible(
				site.site_id
			)
		):
			continue

		var site_state := (
			_state.get_site(
				site.site_id
			)
		)

		if site_state == null:
			continue

		var button := Button.new()

		var prefix := (
			"→ "
			if site.site_id
				== _selected_site_id
			else ""
		)

		var suffix := (
			" · ЗАЧИЩЕНО"
			if site_state.is_cleared()
			else ""
		)

		button.text = (
			"%s%s%s"
			% [
				prefix,
				site.display_name,
				suffix,
			]
		)

		button.custom_minimum_size = Vector2(
			190,
			46
		)

		button.size = Vector2(
			190,
			46
		)

		button.position = (
			site.map_position
			- Vector2(
				95,
				23
			)
		)

		button.pressed.connect(
			_on_site_pressed.bind(
				site.site_id
			)
		)

		add_child(
			button
		)


func _is_site_visible(
	site_id: StringName
) -> bool:
	var site_state := (
		_state.get_site(
			site_id
		)
	)

	return (
		site_state != null
		and not site_state.is_hidden()
	)


func _on_site_pressed(
	site_id: StringName
) -> void:
	_selected_site_id = site_id

	_rebuild_site_buttons()

	site_selected.emit(
		site_id
	)