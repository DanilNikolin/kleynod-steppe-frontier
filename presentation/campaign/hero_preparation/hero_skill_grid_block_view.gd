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

var selected_node_id: StringName = &""


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

	add_child(
		_create_header()
	)

	var separator := HSeparator.new()

	add_child(
		separator
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
		_create_graph_area()
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


func _create_graph_area() -> Control:
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
				block
			)
		)

		attached_block_count += 1

	if attached_block_count == 0:
		var empty_label := Label.new()

		empty_label.text = (
			"Нет присоединённых блоков Skill Grid."
		)

		blocks_row.add_child(
			empty_label
		)

	return scroll


func _create_block_column(
	block: SkillGridBlockDefinition
) -> Control:
	var column := VBoxContainer.new()

	column.add_theme_constant_override(
		"separation",
		8
	)

	var purchased_count := (
		_get_purchased_count_for_block(
			block
		)
	)

	var title := Label.new()

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

	column.add_child(
		_create_block_progress_label(
			block
		)
	)

	var graph := SkillGridGraphView.new()

	graph.bind(
		hero_definition.skill_grid,
		block,
		progression
	)

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