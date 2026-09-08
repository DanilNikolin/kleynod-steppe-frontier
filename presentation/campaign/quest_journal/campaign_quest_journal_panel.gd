class_name CampaignQuestJournalPanel
extends PanelContainer


signal close_requested

signal abandon_requested(
	quest_id: StringName
)


var _quest_definitions: Array[CampaignQuestDefinition] = []
var _resident_definitions: Array[CampaignResidentDefinition] = []

var _state: CampaignState

var _selected_quest_id: StringName = &""

## Первый клик на abandon только включает подтверждение.
var _abandon_confirmation_quest_id: StringName = &""


var _quest_list: VBoxContainer

var _detail_title: Label
var _detail_status: Label
var _detail_giver: Label
var _detail_description: Label
var _detail_objectives: Label
var _detail_rewards: Label

var _abandon_button: Button
var _status_label: Label


func bind(
	quest_definitions: Array[CampaignQuestDefinition],
	resident_definitions: Array[CampaignResidentDefinition],
	state: CampaignState
) -> void:
	_quest_definitions = quest_definitions
	_resident_definitions = resident_definitions
	_state = state

	_selected_quest_id = &""
	_abandon_confirmation_quest_id = &""

	_build_interface()

	refresh_state()


func refresh_state() -> void:
	if _state == null:
		return

	if not _is_quest_visible_in_journal(
		_selected_quest_id
	):
		_selected_quest_id = (
			_get_first_journal_quest_id()
		)

	_rebuild_quest_list()
	_refresh_details()


func show_status_message(
	message: String
) -> void:
	if _status_label == null:
		return

	_status_label.text = message


func _build_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	var background := ColorRect.new()

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.color = Color(
		0.04,
		0.045,
		0.055,
		0.98
	)

	add_child(
		background
	)

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left",
		48
	)

	margin.add_theme_constant_override(
		"margin_top",
		36
	)

	margin.add_theme_constant_override(
		"margin_right",
		48
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		36
	)

	add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.add_theme_constant_override(
		"separation",
		16
	)

	margin.add_child(
		root
	)

	var header := HBoxContainer.new()

	header.add_theme_constant_override(
		"separation",
		16
	)

	root.add_child(
		header
	)

	var title := Label.new()

	title.text = "ЗАДАНИЯ"

	title.add_theme_font_size_override(
		"font_size",
		32
	)

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	header.add_child(
		title
	)

	var close_button := Button.new()

	close_button.text = "ЗАКРЫТЬ"

	close_button.custom_minimum_size = Vector2(
		140,
		44
	)

	close_button.pressed.connect(
		_on_close_pressed
	)

	header.add_child(
		close_button
	)

	root.add_child(
		HSeparator.new()
	)

	var body := HBoxContainer.new()

	body.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	body.add_theme_constant_override(
		"separation",
		20
	)

	root.add_child(
		body
	)

	var list_panel := PanelContainer.new()

	list_panel.custom_minimum_size = Vector2(
		360,
		0
	)

	body.add_child(
		list_panel
	)

	var list_margin := MarginContainer.new()

	list_margin.add_theme_constant_override(
		"margin_left",
		14
	)

	list_margin.add_theme_constant_override(
		"margin_top",
		14
	)

	list_margin.add_theme_constant_override(
		"margin_right",
		14
	)

	list_margin.add_theme_constant_override(
		"margin_bottom",
		14
	)

	list_panel.add_child(
		list_margin
	)

	var list_scroll := ScrollContainer.new()

	list_scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	list_margin.add_child(
		list_scroll
	)

	_quest_list = VBoxContainer.new()

	_quest_list.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	_quest_list.add_theme_constant_override(
		"separation",
		8
	)

	list_scroll.add_child(
		_quest_list
	)

	var details_panel := PanelContainer.new()

	details_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	details_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	body.add_child(
		details_panel
	)

	var details_margin := MarginContainer.new()

	details_margin.add_theme_constant_override(
		"margin_left",
		22
	)

	details_margin.add_theme_constant_override(
		"margin_top",
		20
	)

	details_margin.add_theme_constant_override(
		"margin_right",
		22
	)

	details_margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	details_panel.add_child(
		details_margin
	)

	var details := VBoxContainer.new()

	details.add_theme_constant_override(
		"separation",
		12
	)

	details_margin.add_child(
		details
	)

	_detail_title = Label.new()

	_detail_title.add_theme_font_size_override(
		"font_size",
		28
	)

	details.add_child(
		_detail_title
	)

	_detail_status = Label.new()

	_detail_status.add_theme_font_size_override(
		"font_size",
		18
	)

	details.add_child(
		_detail_status
	)

	_detail_giver = Label.new()

	details.add_child(
		_detail_giver
	)

	details.add_child(
		HSeparator.new()
	)

	_detail_description = Label.new()

	_detail_description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	_detail_description.custom_minimum_size = Vector2(
		0,
		80
	)

	details.add_child(
		_detail_description
	)

	var objectives_title := Label.new()

	objectives_title.text = "ЦЕЛИ"

	objectives_title.add_theme_font_size_override(
		"font_size",
		20
	)

	details.add_child(
		objectives_title
	)

	_detail_objectives = Label.new()

	_detail_objectives.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	details.add_child(
		_detail_objectives
	)

	var rewards_title := Label.new()

	rewards_title.text = "НАГРАДА"

	rewards_title.add_theme_font_size_override(
		"font_size",
		20
	)

	details.add_child(
		rewards_title
	)

	_detail_rewards = Label.new()

	_detail_rewards.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	details.add_child(
		_detail_rewards
	)

	var spacer := Control.new()

	spacer.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	details.add_child(
		spacer
	)

	_abandon_button = Button.new()

	_abandon_button.custom_minimum_size = Vector2(
		0,
		48
	)

	_abandon_button.pressed.connect(
		_on_abandon_pressed
	)

	details.add_child(
		_abandon_button
	)

	_status_label = Label.new()

	_status_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	root.add_child(
		_status_label
	)


func _rebuild_quest_list() -> void:
	if _quest_list == null:
		return

	for child in _quest_list.get_children():
		_quest_list.remove_child(
			child
		)

		child.queue_free()

	var active_quests := (
		_get_quests_with_status(
			CampaignQuestState.Status.ACTIVE
		)
	)

	var completed_quests := (
		_get_quests_with_status(
			CampaignQuestState.Status.COMPLETED
		)
	)

	if (
		active_quests.is_empty()
		and completed_quests.is_empty()
	):
		var empty_label := Label.new()

		empty_label.text = (
			"Принятых заданий пока нет."
		)

		empty_label.autowrap_mode = (
			TextServer.AUTOWRAP_WORD_SMART
		)

		_quest_list.add_child(
			empty_label
		)

		return

	if not active_quests.is_empty():
		_add_section_title(
			"АКТИВНЫЕ"
		)

		for quest in active_quests:
			_add_quest_button(
				quest
			)

	if not completed_quests.is_empty():
		if not active_quests.is_empty():
			_quest_list.add_child(
				HSeparator.new()
			)

		_add_section_title(
			"ЗАВЕРШЁННЫЕ"
		)

		for quest in completed_quests:
			_add_quest_button(
				quest
			)


func _add_section_title(
	text: String
) -> void:
	var label := Label.new()

	label.text = text

	label.add_theme_font_size_override(
		"font_size",
		18
	)

	_quest_list.add_child(
		label
	)


func _add_quest_button(
	quest: CampaignQuestDefinition
) -> void:
	if quest == null:
		return

	var state := _state.get_quest(
		quest.quest_id
	)

	if state == null:
		return

	var marker := "○"

	if state.is_completed():
		marker = "✓"

	elif state.is_ready_to_turn_in(
		quest
	):
		marker = "!"

	if quest.quest_id == _selected_quest_id:
		marker = "→ " + marker

	var button := Button.new()

	button.text = (
		"%s %s"
		% [
			marker,
			quest.display_name,
		]
	)

	button.alignment = (
		HORIZONTAL_ALIGNMENT_LEFT
	)

	button.pressed.connect(
		_on_quest_selected.bind(
			quest.quest_id
		)
	)

	_quest_list.add_child(
		button
	)


func _refresh_details() -> void:
	_abandon_confirmation_quest_id = (
		_abandon_confirmation_quest_id
		if _abandon_confirmation_quest_id
			== _selected_quest_id
		else &""
	)

	var quest := _get_selected_quest()

	if quest == null:
		_detail_title.text = (
			"Задание не выбрано"
		)

		_detail_status.text = ""
		_detail_giver.text = ""

		_detail_description.text = (
			"Принятые задания появятся здесь."
		)

		_detail_objectives.text = "—"
		_detail_rewards.text = "—"

		_abandon_button.visible = false

		return

	var quest_state := _state.get_quest(
		quest.quest_id
	)

	if quest_state == null:
		return

	_detail_title.text = (
		quest.display_name
	)

	_detail_status.text = (
		"Статус: %s"
		% _get_status_text(
			quest,
			quest_state
		)
	)

	_detail_giver.text = (
		"Выдал: %s"
		% _get_resident_display_name(
			quest.giver_resident_id
		)
	)

	_detail_description.text = (
		quest.description
	)

	var objective_lines := PackedStringArray()

	for objective in quest.objectives:
		if objective == null:
			continue

		var marker := (
			"✓"
			if quest_state
				.is_objective_completed(
					objective.objective_id
				)
			else "○"
		)

		objective_lines.append(
			"%s %s"
			% [
				marker,
				objective.display_name,
			]
		)

	_detail_objectives.text = (
		"\n".join(
			objective_lines
		)
		if not objective_lines.is_empty()
		else "—"
	)

	_detail_rewards.text = (
		_get_rewards_text(
			quest
		)
	)

	_refresh_abandon_button(
		quest,
		quest_state
	)


func _refresh_abandon_button(
	quest: CampaignQuestDefinition,
	quest_state: CampaignQuestState
) -> void:
	if (
		quest == null
		or quest_state == null
		or not quest_state.is_active()
	):
		_abandon_button.visible = false

		return

	_abandon_button.visible = true

	if not quest.abandon_enabled:
		_abandon_button.text = (
			"ЭТО ЗАДАНИЕ НЕЛЬЗЯ ОТМЕНИТЬ"
		)

		_abandon_button.disabled = true

		return

	_abandon_button.disabled = false

	if (
		_abandon_confirmation_quest_id
		== quest.quest_id
	):
		_abandon_button.text = (
			"ПОДТВЕРДИТЬ ОТМЕНУ · ПРОГРЕСС БУДЕТ ПОТЕРЯН"
		)

	else:
		_abandon_button.text = (
			"ОТМЕНИТЬ ЗАДАНИЕ"
		)


func _get_status_text(
	quest: CampaignQuestDefinition,
	quest_state: CampaignQuestState
) -> String:
	if quest_state == null:
		return "—"

	if quest_state.is_completed():
		return "Завершено"

	if quest_state.is_ready_to_turn_in(
		quest
	):
		return "Цели выполнены · можно сдать"

	if quest_state.is_active():
		return "В процессе"

	return "Не начато"


func _get_rewards_text(
	quest: CampaignQuestDefinition
) -> String:
	if quest == null:
		return "—"

	var lines := PackedStringArray()

	if quest.reputation_reward > 0:
		lines.append(
			"+%d Репутации"
			% quest.reputation_reward
		)

	for resident_id in (
		quest.recruitment_unlock_resident_ids
	):
		lines.append(
			"Открывает возможность пригласить: %s"
			% _get_resident_display_name(
				resident_id
			)
		)

	if lines.is_empty():
		return "—"

	return "\n".join(
		lines
	)


func _get_resident_display_name(
	resident_id: StringName
) -> String:
	for resident in _resident_definitions:
		if (
			resident != null
			and resident.resident_id == resident_id
		):
			return resident.display_name

	return String(
		resident_id
	)


func _get_quests_with_status(
	status: int
) -> Array[CampaignQuestDefinition]:
	var result: Array[CampaignQuestDefinition] = []

	if _state == null:
		return result

	for quest in _quest_definitions:
		if quest == null:
			continue

		var quest_state := _state.get_quest(
			quest.quest_id
		)

		if (
			quest_state != null
			and quest_state.status == status
		):
			result.append(
				quest
			)

	return result


func _get_first_journal_quest_id() -> StringName:
	var active := _get_quests_with_status(
		CampaignQuestState.Status.ACTIVE
	)

	if not active.is_empty():
		return active[0].quest_id

	var completed := _get_quests_with_status(
		CampaignQuestState.Status.COMPLETED
	)

	if not completed.is_empty():
		return completed[0].quest_id

	return &""


func _is_quest_visible_in_journal(
	quest_id: StringName
) -> bool:
	if (
		quest_id == &""
		or _state == null
	):
		return false

	var state := _state.get_quest(
		quest_id
	)

	return (
		state != null
		and not state.is_not_started()
	)


func _get_selected_quest() -> CampaignQuestDefinition:
	if _selected_quest_id == &"":
		return null

	for quest in _quest_definitions:
		if (
			quest != null
			and quest.quest_id
				== _selected_quest_id
		):
			return quest

	return null


func _on_quest_selected(
	quest_id: StringName
) -> void:
	_selected_quest_id = quest_id

	_abandon_confirmation_quest_id = &""

	_rebuild_quest_list()
	_refresh_details()


func _on_abandon_pressed() -> void:
	var quest := _get_selected_quest()

	if quest == null:
		return

	var quest_state := _state.get_quest(
		quest.quest_id
	)

	if (
		quest_state == null
		or not quest_state.is_active()
		or not quest.abandon_enabled
	):
		return

	if (
		_abandon_confirmation_quest_id
		!= quest.quest_id
	):
		_abandon_confirmation_quest_id = (
			quest.quest_id
		)

		_refresh_details()

		return

	_abandon_confirmation_quest_id = &""

	abandon_requested.emit(
		quest.quest_id
	)


func _on_close_pressed() -> void:
	close_requested.emit()