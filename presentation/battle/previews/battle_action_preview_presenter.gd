class_name BattleActionPreviewPresenter
extends RefCounted


var combatant_presenter: BattleCombatantPresenter
var overlay_state: BattleTacticalState

var _shown_target_ids: Array[StringName] = []


func _init(
	p_combatant_presenter: BattleCombatantPresenter,
	p_overlay_state: BattleTacticalState
) -> void:
	assert(
		p_combatant_presenter != null,
		"Action preview presenter requires "
		+"a combatant presenter."
	)

	assert(
		p_overlay_state != null,
		"Action preview presenter requires "
		+"a battle grid view."
	)

	combatant_presenter = (
		p_combatant_presenter
	)

	overlay_state = p_overlay_state


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

	if overlay_state != null:
		overlay_state.clear_surface_previews()


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
	overlay_state.set_surface_previews(placement_previews)
