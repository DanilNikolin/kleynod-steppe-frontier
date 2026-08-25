class_name HeroSkillGridBlockView
extends VBoxContainer


signal state_changed


var hero_definition: HeroDefinition
var progression: HeroProgressionState

var purchase_service := (
	SkillGridPurchaseService.new()
)

var block_progress_service := (
	SkillGridBlockProgressService.new()
)

var attachment_service := (
	SkillGridBlockAttachmentService.new()
)

var selected_node_id: StringName = &""
var preview_block_id: StringName = &""


func bind(
	p_hero_definition: HeroDefinition,
	p_progression: HeroProgressionState
) -> void:
	hero_definition = p_hero_definition
	progression = p_progression

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	add_theme_constant_override(
		"separation",
		10
	)

	if (
		hero_definition == null
		or progression == null
		or hero_definition.skill_grid == null
	):
		var error_label := Label.new()

		error_label.text = (
			"Skill Grid недоступен."
		)

		add_child(
			error_label
		)

		return

	var candidates := (
		attachment_service
			.get_attachment_candidates(
				hero_definition.skill_grid,
				progression
			)
	)

	_normalize_preview_block_id(
		candidates
	)

	add_child(
		_create_header()
	)

	add_child(
		HSeparator.new()
	)

	if not candidates.is_empty():
		add_child(
			_create_attachment_picker(
				candidates
			)
		)

		add_child(
			HSeparator.new()
		)

	var body := HBoxContainer.new()

	body.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	body.add_theme_constant_override(
		"separation",
		14
	)

	add_child(
		body
	)

	body.add_child(
		_create_graph_area(
			candidates
		)
	)

	body.add_child(
		_create_details_panel()
	)


func _create_header() -> Control:
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		16
	)

	var title := Label.new()

	title.text = "SKILL GRID"

	title.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	row.add_child(
		title
	)

	var points := Label.new()

	points.text = (
		"Свободно SP: %d"
		% progression.unspent_skill_points
	)

	points.add_theme_font_size_override(
		"font_size",
		18
	)

	row.add_child(
		points
	)

	return row


func _create_attachment_picker(
	candidates: Array[SkillGridBlockDefinition]
) -> Control:
	var panel := PanelContainer.new()

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		14
	)

	margin.add_theme_constant_override(
		"margin_top",
		12
	)

	margin.add_theme_constant_override(
		"margin_right",
		14
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		12
	)

	panel.add_child(
		margin
	)

	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	margin.add_child(
		content
	)

	var title := Label.new()

	if progression.attached_skill_block_ids.is_empty():
		title.text = "ВЫБЕРИТЕ ПЕРВЫЙ БЛОК"

	else:
		title.text = "ВЫБЕРИТЕ СЛЕДУЮЩИЙ БЛОК"

	title.add_theme_font_size_override(
		"font_size",
		18
	)

	content.add_child(
		title
	)

	var description := Label.new()

	if progression.attached_skill_block_ids.is_empty():
		description.text = (
			"Этот блок станет началом общего "
			+"Skill Grid героя."
		)

	else:
		description.text = (
			"Последний блок готов к расширению. "
			+"Выберите, куда продолжить развитие."
		)

	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		description
	)

	var candidate_row := HBoxContainer.new()

	candidate_row.add_theme_constant_override(
		"separation",
		8
	)

	content.add_child(
		candidate_row
	)

	for block in candidates:
		if block == null:
			continue

		var button := Button.new()

		button.text = block.display_name

		button.custom_minimum_size = Vector2(
			190.0,
			44.0
		)

		button.toggle_mode = true

		button.set_pressed_no_signal(
			block.block_id == preview_block_id
		)

		button.pressed.connect(
			_on_attachment_preview_pressed.bind(
				block.block_id
			)
		)

		candidate_row.add_child(
			button
		)

	if preview_block_id == &"":
		var hint := Label.new()

		hint.text = (
			"Нажмите на блок, чтобы увидеть "
			+"его предпросмотр."
		)

		content.add_child(
			hint
		)

		return panel

	var preview_block := (
		hero_definition
			.skill_grid
			.get_block_definition(
				preview_block_id
			)
	)

	if preview_block == null:
		return panel

	var selection_separator := HSeparator.new()

	content.add_child(
		selection_separator
	)

	var selection_info := Label.new()

	selection_info.text = (
		"Предпросмотр: %s · %d нод · "
		+"для следующего расширения: %d нод + EXIT"
		% [
			preview_block.display_name,
			preview_block.node_ids.size(),
			preview_block.minimum_purchased_nodes,
		]
	)

	selection_info.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		selection_info
	)

	var actions := HBoxContainer.new()

	actions.add_theme_constant_override(
		"separation",
		8
	)

	content.add_child(
		actions
	)

	var confirm_button := Button.new()

	confirm_button.text = "ПОДТВЕРДИТЬ"

	confirm_button.custom_minimum_size = Vector2(
		180.0,
		44.0
	)

	confirm_button.pressed.connect(
		_on_attachment_confirm_pressed
	)

	actions.add_child(
		confirm_button
	)

	var cancel_button := Button.new()

	cancel_button.text = "ОТМЕНА"

	cancel_button.custom_minimum_size = Vector2(
		120.0,
		44.0
	)

	cancel_button.pressed.connect(
		_on_attachment_cancel_pressed
	)

	actions.add_child(
		cancel_button
	)

	return panel


func _create_graph_area(
	candidates: Array[SkillGridBlockDefinition]
) -> Control:
	var scroll := ScrollContainer.new()

	scroll.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	var blocks_row := HBoxContainer.new()

	blocks_row.add_theme_constant_override(
		"separation",
		32
	)

	scroll.add_child(
		blocks_row
	)

	var attached_block_count := 0

	for block_id in (
		progression.attached_skill_block_ids
	):
		var block := (
			hero_definition
				.skill_grid
				.get_block_definition(
					block_id
				)
		)

		if block == null:
			continue

		blocks_row.add_child(
			_create_block_column(
				block,
				false
			)
		)

		attached_block_count += 1

	if preview_block_id != &"":
		var preview_block := (
			hero_definition
				.skill_grid
				.get_block_definition(
					preview_block_id
				)
		)

		if preview_block != null:
			blocks_row.add_child(
				_create_block_column(
					preview_block,
					true
				)
			)

	if (
		attached_block_count == 0
		and preview_block_id == &""
	):
		var empty_label := Label.new()

		if candidates.is_empty():
			empty_label.text = (
				"Нет доступных блоков Skill Grid."
			)

		else:
			empty_label.text = (
				"Выберите первый блок выше."
			)

		blocks_row.add_child(
			empty_label
		)

	return scroll


func _create_block_column(
	block: SkillGridBlockDefinition,
	is_preview: bool = false
) -> Control:
	var column := VBoxContainer.new()

	column.add_theme_constant_override(
		"separation",
		8
	)

	var title := Label.new()

	if is_preview:
		title.text = (
			"ПРЕДПРОСМОТР · %s"
			% block.display_name
		)

	else:
		var purchased_count := (
			_get_purchased_count_for_block(
				block
			)
		)

		title.text = (
			"%s · %d/%d нод"
			% [
				block.display_name,
				purchased_count,
				block.node_ids.size(),
			]
		)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		18
	)

	column.add_child(
		title
	)

	if not is_preview:
		column.add_child(
			_create_block_progress_label(
				block
			)
		)

	var graph := SkillGridGraphView.new()

	graph.bind(
		hero_definition.skill_grid,
		block,
		progression,
		is_preview
	)

	if not is_preview:
		graph.set_selected_node_id(
			selected_node_id
		)

		graph.node_selected.connect(
			_on_node_selected
		)

	column.add_child(
		graph
	)

	return column


func _create_block_progress_label(
	block: SkillGridBlockDefinition
) -> Label:
	var label := Label.new()

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.add_theme_font_size_override(
		"font_size",
		14
	)

	var purchased_count := (
		block_progress_service
			.get_purchased_node_count(
				block,
				progression
			)
	)

	var has_exit := (
		block_progress_service
			.has_reached_exit(
				block,
				progression
			)
	)

	var is_ready := (
		block_progress_service
			.is_ready_for_expansion(
				block,
				progression
			)
	)

	if is_ready:
		label.text = (
			"ГОТОВ К РАСШИРЕНИЮ"
		)

		label.add_theme_color_override(
			"font_color",
			Color(
				0.93,
				0.73,
				0.24,
				1.0
			)
		)

		return label

	if (
		purchased_count
		< block.minimum_purchased_nodes
	):
		if has_exit:
			label.text = (
				"До расширения: ноды %d/%d"
				% [
					purchased_count,
					block.minimum_purchased_nodes,
				]
			)

		else:
			label.text = (
				"До расширения: ноды %d/%d + выход"
				% [
					purchased_count,
					block.minimum_purchased_nodes,
				]
			)

		return label

	label.text = (
		"До расширения: достигните выхода"
	)

	return label


func _create_details_panel() -> Control:
	var panel := PanelContainer.new()

	panel.custom_minimum_size = Vector2(
		300.0,
		0.0
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		16
	)

	margin.add_theme_constant_override(
		"margin_top",
		16
	)

	margin.add_theme_constant_override(
		"margin_right",
		16
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		16
	)

	panel.add_child(
		margin
	)

	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		12
	)

	margin.add_child(
		content
	)

	var heading := Label.new()

	heading.text = "ДЕТАЛИ"

	heading.add_theme_font_size_override(
		"font_size",
		18
	)

	content.add_child(
		heading
	)

	content.add_child(
		HSeparator.new()
	)

	if selected_node_id == &"":
		var hint := Label.new()

		if preview_block_id != &"":
			hint.text = (
				"Справа показан предпросмотр "
				+"выбранного блока. Подтвердите "
				+"или отмените выбор выше."
			)

		else:
			hint.text = (
				"Выберите ноду на схеме."
			)

		hint.autowrap_mode = (
			TextServer.AUTOWRAP_WORD_SMART
		)

		content.add_child(
			hint
		)

		return panel

	var node := (
		hero_definition
			.skill_grid
			.get_node_definition(
				selected_node_id
			)
	)

	if node == null:
		var missing := Label.new()

		missing.text = (
			"Выбранная нода не найдена."
		)

		content.add_child(
			missing
		)

		return panel

	var title := Label.new()

	title.text = node.display_name

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	title.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		title
	)

	var description := Label.new()

	description.text = node.description

	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		description
	)

	var cost := Label.new()

	cost.text = (
		"Стоимость: %d SP"
		% node.skill_point_cost
	)

	content.add_child(
		cost
	)

	var purchase_result := (
		purchase_service.get_purchase_result(
			hero_definition.skill_grid,
			progression,
			node.node_id
		)
	)

	var state := Label.new()

	state.text = (
		"Состояние: %s"
		% _get_node_state_text(
			node,
			purchase_result
		)
	)

	content.add_child(
		state
	)

	var spacer := Control.new()

	spacer.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	content.add_child(
		spacer
	)

	var purchase_button := Button.new()

	purchase_button.custom_minimum_size = Vector2(
		0.0,
		48.0
	)

	if progression.purchased_node_ids.has(
		node.node_id
	):
		purchase_button.text = "КУПЛЕНО"
		purchase_button.disabled = true

	else:
		purchase_button.text = (
			"КУПИТЬ · %d SP"
			% node.skill_point_cost
		)

		purchase_button.disabled = (
			not purchase_result.is_successful
		)

		purchase_button.pressed.connect(
			_on_purchase_pressed.bind(
				node.node_id
			)
		)

	content.add_child(
		purchase_button
	)

	return panel


func _get_node_state_text(
	node: SkillGridNodeDefinition,
	result: SkillGridPurchaseResult
) -> String:
	if progression.purchased_node_ids.has(
		node.node_id
	):
		return "Куплено"

	if result.is_successful:
		return "Доступно"

	match result.failure_code:
		SkillGridPurchaseService.FAILURE_PATH_NOT_REACHED:
			return "Нет открытого пути"

		SkillGridPurchaseService.FAILURE_NOT_ENOUGH_SKILL_POINTS:
			return "Недостаточно Skill Points"

		SkillGridPurchaseService.FAILURE_MISSING_PREREQUISITES:
			return "Не выполнены обязательные условия"

		SkillGridPurchaseService.FAILURE_BLOCK_NOT_ATTACHED:
			return "Блок не присоединён"

		SkillGridPurchaseService.FAILURE_ALREADY_PURCHASED:
			return "Куплено"

	return (
		"Недоступно · %s"
		% String(result.failure_code)
	)


func _get_purchased_count_for_block(
	block: SkillGridBlockDefinition
) -> int:
	return (
		block_progress_service
			.get_purchased_node_count(
				block,
				progression
			)
	)


func _normalize_preview_block_id(
	candidates: Array[SkillGridBlockDefinition]
) -> void:
	if preview_block_id == &"":
		return

	if _contains_candidate(
		candidates,
		preview_block_id
	):
		return

	preview_block_id = &""


func _contains_candidate(
	candidates: Array[SkillGridBlockDefinition],
	block_id: StringName
) -> bool:
	for candidate in candidates:
		if (
			candidate != null
			and candidate.block_id == block_id
		):
			return true

	return false


func _on_attachment_preview_pressed(
	block_id: StringName
) -> void:
	preview_block_id = block_id
	selected_node_id = &""

	_rebuild_interface()


func _on_attachment_cancel_pressed() -> void:
	preview_block_id = &""

	_rebuild_interface()


func _on_attachment_confirm_pressed() -> void:
	if preview_block_id == &"":
		return

	var result := attachment_service.attach(
		hero_definition.skill_grid,
		progression,
		preview_block_id
	)

	if not result.is_successful:
		push_warning(
			"Skill Grid block attachment failed: %s"
			% result.failure_code
		)

		return

	preview_block_id = &""
	selected_node_id = &""

	state_changed.emit()


func _on_node_selected(
	node_id: StringName
) -> void:
	selected_node_id = node_id

	_rebuild_interface()


func _on_purchase_pressed(
	node_id: StringName
) -> void:
	var result := purchase_service.purchase(
		hero_definition.skill_grid,
		progression,
		node_id
	)

	if not result.is_successful:
		push_warning(
			"Skill Grid purchase failed: %s"
			% result.failure_code
		)

		return

	selected_node_id = node_id

	state_changed.emit()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()