class_name HeroSkillGridPanel
extends PanelContainer


signal state_changed


static var _expanded_sections: Dictionary = {
	SkillGridNodeDefinition.Branch.STRENGTH: true,
	SkillGridNodeDefinition.Branch.AGILITY: false,
	SkillGridNodeDefinition.Branch.SPIRIT: false,
	SkillGridNodeDefinition.Branch.NONE: false,
}


var hero_definition: HeroDefinition
var progression: HeroProgressionState

var purchase_service := (
	SkillGridPurchaseService.new()
)


func bind(
	p_hero_definition: HeroDefinition,
	p_progression: HeroProgressionState
) -> void:
	hero_definition = p_hero_definition
	progression = p_progression

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	if _should_use_block_graph_mode():
		_rebuild_block_graph_interface()
		return

	var outer := VBoxContainer.new()

	outer.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	outer.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	outer.add_theme_constant_override(
		"separation",
		10
	)

	add_child(
		outer
	)

	var title := Label.new()

	title.text = "SKILL GRID"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	outer.add_child(
		title
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

		outer.add_child(
			error_label
		)

		return

	var points_label := Label.new()

	points_label.text = (
		"Свободные Skill Points: %d"
		% progression.unspent_skill_points
	)

	points_label.add_theme_font_size_override(
		"font_size",
		18
	)

	outer.add_child(
		points_label
	)

	outer.add_child(
		HSeparator.new()
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

	var sections := VBoxContainer.new()

	sections.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	sections.add_theme_constant_override(
		"separation",
		10
	)

	scroll.add_child(
		sections
	)

	var grouped_nodes: Dictionary = {
		SkillGridNodeDefinition.Branch.STRENGTH: [],
		SkillGridNodeDefinition.Branch.AGILITY: [],
		SkillGridNodeDefinition.Branch.SPIRIT: [],
		SkillGridNodeDefinition.Branch.NONE: [],
	}

	for node in hero_definition.skill_grid.nodes:
		if node == null:
			continue

		var branch := _get_node_branch(
			node
		)

		grouped_nodes[branch].append(
			node
		)

	var section_order := [
		SkillGridNodeDefinition.Branch.STRENGTH,
		SkillGridNodeDefinition.Branch.AGILITY,
		SkillGridNodeDefinition.Branch.SPIRIT,
		SkillGridNodeDefinition.Branch.NONE,
	]

	for branch in section_order:
		var branch_nodes: Array = (
			grouped_nodes[branch]
		)

		if branch_nodes.is_empty():
			continue

		sections.add_child(
			_create_node_section(
				branch,
				branch_nodes
			)
		)


func _create_node_section(
	branch: int,
	nodes: Array
) -> Control:
	var section := VBoxContainer.new()

	section.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	section.add_theme_constant_override(
		"separation",
		6
	)

	var expanded := bool(
		_expanded_sections.get(
			branch,
			false
		)
	)

	var header := Button.new()

	header.toggle_mode = true

	header.set_pressed_no_signal(
		expanded
	)

	header.text = _build_section_title(
		branch,
		nodes.size(),
		expanded
	)

	header.custom_minimum_size = Vector2(
		0,
		44
	)

	header.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	section.add_child(
		header
	)

	var body := VBoxContainer.new()

	body.visible = expanded

	body.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	body.add_theme_constant_override(
		"separation",
		6
	)

	section.add_child(
		body
	)

	for node in nodes:
		if node == null:
			continue

		body.add_child(
			_create_node_row(
				node
			)
		)

	header.toggled.connect(
		_on_section_toggled.bind(
			branch,
			body,
			header,
			nodes.size()
		)
	)

	return section


func _create_node_row(
	node: SkillGridNodeDefinition
) -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		12
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

	var title := Label.new()

	title.text = (
		"%s · %d SP"
		% [
			node.display_name,
			node.skill_point_cost,
		]
	)

	text_column.add_child(
		title
	)

	var description := Label.new()

	description.text = node.description

	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	text_column.add_child(
		description
	)

	var purchase_result := (
		purchase_service.get_purchase_result(
			hero_definition.skill_grid,
			progression,
			node.node_id
		)
	)

	var state_label := Label.new()

	state_label.text = _get_node_state_text(
		node,
		purchase_result
	)

	text_column.add_child(
		state_label
	)

	var purchase_button := Button.new()

	purchase_button.custom_minimum_size = Vector2(
		110,
		42
	)

	if progression.purchased_node_ids.has(
		node.node_id
	):
		purchase_button.text = "Куплено"
		purchase_button.disabled = true

	else:
		purchase_button.text = "Купить"

		purchase_button.disabled = (
			not purchase_result.is_successful
		)

		purchase_button.pressed.connect(
			_on_purchase_pressed.bind(
				node.node_id
			)
		)

	row.add_child(
		purchase_button
	)

	return panel


func _get_node_branch(
	node: SkillGridNodeDefinition
) -> int:
	if node == null:
		return SkillGridNodeDefinition.Branch.NONE

	if (
		node.branch
		!= SkillGridNodeDefinition.Branch.NONE
	):
		return node.branch

	if (
		node.node_type
		== SkillGridNodeDefinition.NodeType.LEARN_ABILITY
		and node.granted_ability != null
	):
		match node.granted_ability.branch:
			AbilityDefinition.Branch.STRENGTH:
				return (
					SkillGridNodeDefinition
						.Branch.STRENGTH
				)

			AbilityDefinition.Branch.AGILITY:
				return (
					SkillGridNodeDefinition
						.Branch.AGILITY
				)

			AbilityDefinition.Branch.SPIRIT:
				return (
					SkillGridNodeDefinition
						.Branch.SPIRIT
				)

	return SkillGridNodeDefinition.Branch.NONE


func _build_section_title(
	branch: int,
	node_count: int,
	expanded: bool
) -> String:
	var arrow := (
		"▼"
		if expanded
		else "▶"
	)

	return (
		"%s  %s · %d"
		% [
			arrow,
			_get_section_name(
				branch
			),
			node_count,
		]
	)


func _get_section_name(
	branch: int
) -> String:
	match branch:
		SkillGridNodeDefinition.Branch.STRENGTH:
			return "СИЛА"

		SkillGridNodeDefinition.Branch.AGILITY:
			return "СПРИТНОСТЬ"

		SkillGridNodeDefinition.Branch.SPIRIT:
			return "ВОЛЯ"

	return "ПРОЧЕЕ"


func _on_section_toggled(
	expanded: bool,
	branch: int,
	body: Control,
	header: Button,
	node_count: int
) -> void:
	_expanded_sections[
		branch
	] = expanded

	body.visible = expanded

	header.text = _build_section_title(
		branch,
		node_count,
		expanded
	)


func _get_node_state_text(
	node: SkillGridNodeDefinition,
	result: SkillGridPurchaseResult
) -> String:
	if progression.purchased_node_ids.has(
		node.node_id
	):
		return "Состояние: куплено"

	if result.is_successful:
		return "Состояние: доступно"

	match result.failure_code:
		SkillGridPurchaseService.FAILURE_MISSING_PREREQUISITES:
			return (
				"Требуются ноды: %s"
				% _get_node_name_list(
					result.missing_prerequisite_node_ids
				)
			)

		SkillGridPurchaseService.FAILURE_NOT_ENOUGH_SKILL_POINTS:
			return "Недостаточно Skill Points"

		SkillGridPurchaseService.FAILURE_ALREADY_PURCHASED:
			return "Состояние: куплено"

	return (
		"Недоступно: %s"
		% result.failure_code
	)


func _get_node_name_list(
	node_ids: Array[StringName]
) -> String:
	var names := PackedStringArray()

	for node_id in node_ids:
		var node := (
			hero_definition
				.skill_grid
				.get_node_definition(
					node_id
				)
		)

		if node == null:
			names.append(
				String(node_id)
			)

			continue

		names.append(
			node.display_name
		)

	return ", ".join(
		names
	)


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

	state_changed.emit()


func _should_use_block_graph_mode() -> bool:
	return (
		hero_definition != null
		and progression != null
		and hero_definition.skill_grid != null
		and not hero_definition.skill_grid.blocks.is_empty()
	)


func _rebuild_block_graph_interface() -> void:
	var block_view := (
		HeroSkillGridBlockView.new()
	)

	block_view.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	block_view.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	block_view.state_changed.connect(
		_on_block_graph_state_changed
	)

	add_child(
		block_view
	)

	block_view.bind(
		hero_definition,
		progression
	)


func _on_block_graph_state_changed() -> void:
	state_changed.emit()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()