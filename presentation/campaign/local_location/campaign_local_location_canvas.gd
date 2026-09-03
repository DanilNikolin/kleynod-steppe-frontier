class_name CampaignLocalLocationCanvas
extends Control


signal interaction_selected(
	interaction_id: StringName
)


const INTERACTION_SIZE := Vector2(
	180.0,
	60.0
)

const SIDE_PADDING := 40.0


var _definition: CampaignLocalLocationDefinition
var _selected_interaction_id: StringName = &""

var _page_index: int = 0

var _buttons_by_interaction_id: Dictionary = {}


func _ready() -> void:
	clip_contents = true

	resized.connect(
		_on_resized
	)


func bind(
	definition: CampaignLocalLocationDefinition
) -> void:
	_definition = definition
	_selected_interaction_id = &""
	_page_index = 0

	_rebuild_buttons()
	queue_redraw()


func get_page_count() -> int:
	if _definition == null:
		return 1

	return _definition.get_view_page_count()


func get_page_index() -> int:
	return _page_index


func set_page(
	page_index: int
) -> void:
	var next_page := clampi(
		page_index,
		0,
		maxi(
			get_page_count() - 1,
			0
		)
	)

	if next_page == _page_index:
		return

	_page_index = next_page
	_selected_interaction_id = &""

	_refresh_button_texts()
	_layout_buttons()
	queue_redraw()


func set_selected_interaction(
	interaction_id: StringName
) -> void:
	_selected_interaction_id = interaction_id

	_refresh_button_texts()
	queue_redraw()


func _draw() -> void:
	var ground_start_y := (
		size.y * 0.58
	)

	draw_rect(
		Rect2(
			Vector2(
				0.0,
				ground_start_y
			),
			Vector2(
				size.x,
				size.y - ground_start_y
			)
		),
		Color(
			0.09,
			0.085,
			0.075,
			1.0
		)
	)

	draw_line(
		Vector2(
			0.0,
			ground_start_y
		),
		Vector2(
			size.x,
			ground_start_y
		),
		Color(
			0.28,
			0.25,
			0.20,
			1.0
		),
		2.0
	)


func _rebuild_buttons() -> void:
	for button_value in (
		_buttons_by_interaction_id.values()
	):
		var button := button_value as Button

		if button == null:
			continue

		remove_child(
			button
		)

		button.queue_free()

	_buttons_by_interaction_id.clear()

	if _definition == null:
		return

	for interaction in (
		_definition.interactions
	):
		if interaction == null:
			continue

		var button := Button.new()

		button.size = INTERACTION_SIZE
		button.custom_minimum_size = (
			INTERACTION_SIZE
		)

		button.tooltip_text = (
			interaction.description
		)

		button.pressed.connect(
			_on_interaction_pressed.bind(
				interaction.interaction_id
			)
		)

		add_child(
			button
		)

		_buttons_by_interaction_id[
			interaction.interaction_id
		] = button

	_refresh_button_texts()
	_layout_buttons()


func _refresh_button_texts() -> void:
	if _definition == null:
		return

	for interaction in (
		_definition.interactions
	):
		if (
			interaction == null
			or not _buttons_by_interaction_id.has(
				interaction.interaction_id
			)
		):
			continue

		var button := (
			_buttons_by_interaction_id[
				interaction.interaction_id
			] as Button
		)

		if button == null:
			continue

		var prefix := ""

		if (
			interaction.interaction_id
			== _selected_interaction_id
		):
			prefix = "→ "

		button.text = (
			prefix
			+ interaction.display_name
		)


func _layout_buttons() -> void:
	if _definition == null:
		return

	if (
		_definition.reference_size.x <= 0.0
		or _definition.reference_size.y <= 0.0
		or _definition.view_width <= 0.0
	):
		return

	var page_start_x := (
		float(_page_index)
		* _definition.view_width
	)

	var page_end_x := minf(
		page_start_x
			+ _definition.view_width,
		_definition.reference_size.x
	)

	var is_last_page := (
		_page_index
		== get_page_count() - 1
	)

	for interaction in (
		_definition.interactions
	):
		if (
			interaction == null
			or not _buttons_by_interaction_id.has(
				interaction.interaction_id
			)
		):
			continue

		var button := (
			_buttons_by_interaction_id[
				interaction.interaction_id
			] as Button
		)

		if button == null:
			continue

		var is_visible := (
			interaction.local_position.x
				>= page_start_x
			and (
				interaction.local_position.x
					< page_end_x
				or (
					is_last_page
					and interaction.local_position.x
						<= page_end_x
				)
			)
		)

		button.visible = is_visible

		if not is_visible:
			continue

		var normalized := Vector2(
			clampf(
				(
					interaction.local_position.x
					- page_start_x
				)
				/ _definition.view_width,
				0.0,
				1.0
			),
			clampf(
				interaction.local_position.y
					/ _definition.reference_size.y,
				0.0,
				1.0
			)
		)

		var half_size := (
			INTERACTION_SIZE * 0.5
		)

		var available_width := maxf(
			size.x
				- SIDE_PADDING * 2.0
				- INTERACTION_SIZE.x,
			0.0
		)

		var available_height := maxf(
			size.y
				- SIDE_PADDING * 2.0
				- INTERACTION_SIZE.y,
			0.0
		)

		var center := Vector2(
			SIDE_PADDING
				+ half_size.x
				+ available_width
					* normalized.x,
			SIDE_PADDING
				+ half_size.y
				+ available_height
					* normalized.y
		)

		button.position = (
			center
			- half_size
		)


func _on_interaction_pressed(
	interaction_id: StringName
) -> void:
	set_selected_interaction(
		interaction_id
	)

	interaction_selected.emit(
		interaction_id
	)


func _on_resized() -> void:
	_layout_buttons()
	queue_redraw()