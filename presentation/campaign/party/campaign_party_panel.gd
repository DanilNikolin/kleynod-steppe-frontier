class_name CampaignPartyPanel
extends PanelContainer


signal state_changed
signal preparation_requested(hero_id: StringName)


var campaign_state: CampaignState

var party_service := (
	CampaignPartyService.new()
)


func bind(
	p_campaign_state: CampaignState
) -> void:
	campaign_state = p_campaign_state

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	var outer := VBoxContainer.new()

	outer.add_theme_constant_override(
		"separation",
		12
	)

	add_child(
		outer
	)

	var title := Label.new()

	title.text = (
		"ОТРЯД · %d/3"
		% _get_party_size()
	)

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	outer.add_child(
		title
	)

	if (
		campaign_state == null
		or not campaign_state.is_valid_state()
	):
		var error_label := Label.new()

		error_label.text = (
			"Campaign Party State недоступен."
		)

		outer.add_child(
			error_label
		)

		return

	var slots_title := Label.new()

	slots_title.text = "БОЕВЫЕ МЕСТА"

	outer.add_child(
		slots_title
	)

	for slot_index in range(
		CampaignState.MAX_PARTY_SIZE
	):
		outer.add_child(
			_create_party_slot_row(
				slot_index
			)
		)

	outer.add_child(
		HSeparator.new()
	)

	var roster_title := Label.new()

	roster_title.text = "РОСТЕР ГЕРОЕВ"

	outer.add_child(
		roster_title
	)

	var scroll := ScrollContainer.new()

	scroll.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	outer.add_child(
		scroll
	)

	var roster_content := VBoxContainer.new()

	roster_content.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	roster_content.add_theme_constant_override(
		"separation",
		10
	)

	scroll.add_child(
		roster_content
	)

	for hero_state in campaign_state.heroes:
		if hero_state == null:
			continue

		roster_content.add_child(
			_create_roster_row(
				hero_state
			)
		)


func _create_party_slot_row(
	slot_index: int
) -> Control:
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		8
	)

	var slot_label := Label.new()

	slot_label.custom_minimum_size = Vector2(
		100,
		0
	)

	slot_label.text = (
		"Место %d"
		% (
			slot_index + 1
		)
	)

	row.add_child(
		slot_label
	)

	var hero_state: CampaignHeroState

	if (
		slot_index
		< campaign_state.party_member_hero_ids.size()
	):
		hero_state = campaign_state.get_hero(
			campaign_state.party_member_hero_ids[
				slot_index
			]
		)

	var hero_label := Label.new()

	hero_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	if hero_state == null:
		hero_label.text = "— пусто"

	else:
		hero_label.text = hero_state.get_display_name()

	row.add_child(
		hero_label
	)

	if hero_state == null:
		return row

	var prepare_button := Button.new()

	prepare_button.text = "Подготовить"

	prepare_button.pressed.connect(
		_on_prepare_pressed.bind(
			hero_state.get_hero_id()
		)
	)

	row.add_child(
		prepare_button
	)

	var remove_result := (
		party_service.get_remove_result(
			campaign_state,
			hero_state.get_hero_id()
		)
	)

	var remove_button := Button.new()

	remove_button.text = "Убрать"

	remove_button.disabled = (
		not remove_result.is_successful
	)

	remove_button.pressed.connect(
		_on_remove_pressed.bind(
			hero_state.get_hero_id()
		)
	)

	row.add_child(
		remove_button
	)

	return row


func _create_roster_row(
	hero_state: CampaignHeroState
) -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		row
	)

	var text_column := VBoxContainer.new()

	text_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	row.add_child(
		text_column
	)

	var hero_name := Label.new()

	hero_name.text = hero_state.get_display_name()

	hero_name.add_theme_font_size_override(
		"font_size",
		18
	)

	text_column.add_child(
		hero_name
	)

	var states := PackedStringArray()

	if (
		campaign_state.selected_hero_id
		== hero_state.get_hero_id()
	):
		states.append(
			"выбран"
		)

	if campaign_state.is_hero_in_party(
		hero_state.get_hero_id()
	):
		states.append(
			"в отряде"
		)

	if hero_state.is_placeholder_content:
		states.append(
			"контент-заглушка"
		)

	var state_label := Label.new()

	state_label.text = (
		" · ".join(
			states
		)
		if not states.is_empty()
		else "в резерве"
	)

	text_column.add_child(
		state_label
	)

	if not hero_state.roster_note.is_empty():
		var note_label := Label.new()

		note_label.text = hero_state.roster_note

		note_label.autowrap_mode = (
			TextServer.AUTOWRAP_WORD_SMART
		)

		text_column.add_child(
			note_label
		)

	var prepare_button := Button.new()

	prepare_button.text = "Настроить"

	prepare_button.pressed.connect(
		_on_prepare_pressed.bind(
			hero_state.get_hero_id()
		)
	)

	row.add_child(
		prepare_button
	)

	var party_button := Button.new()

	if campaign_state.is_hero_in_party(
		hero_state.get_hero_id()
	):
		var remove_result := (
			party_service.get_remove_result(
				campaign_state,
				hero_state.get_hero_id()
			)
		)

		party_button.text = "Убрать"

		party_button.disabled = (
			not remove_result.is_successful
		)

		party_button.pressed.connect(
			_on_remove_pressed.bind(
				hero_state.get_hero_id()
			)
		)

	else:
		var add_result := (
			party_service.get_add_result(
				campaign_state,
				hero_state.get_hero_id()
			)
		)

		party_button.text = (
			"В отряд"
			if add_result.is_successful
			else "Отряд заполнен"
		)

		party_button.disabled = (
			not add_result.is_successful
		)

		party_button.pressed.connect(
			_on_add_pressed.bind(
				hero_state.get_hero_id()
			)
		)

	row.add_child(
		party_button
	)

	return panel


func _on_prepare_pressed(
	hero_id: StringName
) -> void:
	if campaign_state.selected_hero_id != hero_id:
		var select_result := party_service.select_hero(
			campaign_state,
			hero_id
		)

		if not select_result.is_successful:
			push_warning(
				"Campaign hero selection failed: %s"
				% select_result.failure_code
			)

			return

	preparation_requested.emit(
		hero_id
	)


func _on_add_pressed(
	hero_id: StringName
) -> void:
	var result := party_service.add_hero(
		campaign_state,
		hero_id
	)

	if not result.is_successful:
		push_warning(
			"Campaign party add failed: %s"
			% result.failure_code
		)

		return

	state_changed.emit()


func _on_remove_pressed(
	hero_id: StringName
) -> void:
	var result := party_service.remove_hero(
		campaign_state,
		hero_id
	)

	if not result.is_successful:
		push_warning(
			"Campaign party remove failed: %s"
			% result.failure_code
		)

		return

	state_changed.emit()


func _get_party_size() -> int:
	if campaign_state == null:
		return 0

	return campaign_state.party_member_hero_ids.size()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()