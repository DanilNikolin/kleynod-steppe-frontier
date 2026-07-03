class_name BattleActionPreviewPresenter
extends RefCounted


const BLOCKED_SURFACE_PREVIEW_COLOR := Color(
	0.95,
	0.16,
	0.10,
	1.0
)


var combatant_presenter: BattleCombatantPresenter
var grid_view: BattleGridView

var _shown_target_ids: Array[StringName] = []


func _init(
	p_combatant_presenter: BattleCombatantPresenter,
	p_grid_view: BattleGridView
) -> void:
	assert(
		p_combatant_presenter != null,
		"Action preview presenter requires "
		+"a combatant presenter."
	)

	assert(
		p_grid_view != null,
		"Action preview presenter requires "
		+"a battle grid view."
	)

	combatant_presenter = (
		p_combatant_presenter
	)

	grid_view = p_grid_view


func show_preview(
	preview_result: BattleActionPreviewResult
) -> void:
	clear()

	if (
		preview_result == null
		or not preview_result.is_valid
	):
		return

	_show_target_previews(
		preview_result
	)

	_show_surface_placement_previews(
		preview_result
			.surface_placement_previews
	)


func clear() -> void:
	for target_id in _shown_target_ids:
		var view := combatant_presenter.get_view(
			target_id
		)

		if view != null:
			view.clear_action_preview()

	_shown_target_ids.clear()

	if grid_view != null:
		grid_view.clear_action_preview_cells()


func _show_target_previews(
	preview_result: BattleActionPreviewResult
) -> void:
	for target_preview in (
		preview_result.target_previews
	):
		if target_preview == null:
			continue

		var view := combatant_presenter.get_view(
			target_preview.target_id
		)

		if view == null:
			continue

		var text := (
			BattleActionPreviewFormatter
			.build_target_text(
				target_preview
			)
		)

		if text.strip_edges().is_empty():
			continue

		view.show_action_preview(
			text
		)

		_shown_target_ids.append(
			target_preview.target_id
		)


func _show_surface_placement_previews(
	placement_previews: Array[BattleSurfacePlacementPreview]
) -> void:
	var text_lines_by_coordinate: Dictionary = {}
	var color_by_coordinate: Dictionary = {}

	for placement_preview in placement_previews:
		if placement_preview == null:
			continue

		var coordinate := (
			placement_preview.coordinate
		)

		if not grid_view.is_valid_coordinate(
			coordinate
		):
			continue

		var text := (
			BattleActionPreviewFormatter
			.build_surface_placement_text(
				placement_preview
			)
		)

		if text.strip_edges().is_empty():
			continue

		var text_lines: PackedStringArray = (
			text_lines_by_coordinate.get(
				coordinate,
				PackedStringArray()
			)
		)

		text_lines.append(
			text
		)

		text_lines_by_coordinate[
			coordinate
		] = text_lines

		var preview_color := (
			placement_preview
				.presentation_color
		)

		if not placement_preview.can_place:
			preview_color = (
				BLOCKED_SURFACE_PREVIEW_COLOR
			)

		preview_color.a = 1.0

		if color_by_coordinate.has(
			coordinate
		):
			var existing_color: Color = (
				color_by_coordinate[
					coordinate
				]
			)

			preview_color = existing_color.lerp(
				preview_color,
				0.5
			)

		color_by_coordinate[
			coordinate
		] = preview_color

	for value in text_lines_by_coordinate.keys():
		var coordinate: Vector2i = value

		var text_lines: PackedStringArray = (
			text_lines_by_coordinate[
				coordinate
			]
		)

		var preview_color: Color = (
			color_by_coordinate.get(
				coordinate,
				Color.WHITE
			)
		)

		grid_view.set_action_preview_cell(
			coordinate,
			"\n".join(
				text_lines
			),
			preview_color
		)