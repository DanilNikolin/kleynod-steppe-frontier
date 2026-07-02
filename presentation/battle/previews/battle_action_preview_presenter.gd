class_name BattleActionPreviewPresenter
extends RefCounted


var combatant_presenter: BattleCombatantPresenter

var _shown_target_ids: Array[StringName] = []


func _init(
	p_combatant_presenter: BattleCombatantPresenter
) -> void:
	assert(
		p_combatant_presenter != null,
		"Action preview presenter requires "
		+"a combatant presenter."
	)

	combatant_presenter = (
		p_combatant_presenter
	)


func show_preview(
	preview_result: BattleActionPreviewResult
) -> void:
	clear()

	if (
		preview_result == null
		or not preview_result.is_valid
	):
		return

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


func clear() -> void:
	for target_id in _shown_target_ids:
		var view := combatant_presenter.get_view(
			target_id
		)

		if view != null:
			view.clear_action_preview()

	_shown_target_ids.clear()