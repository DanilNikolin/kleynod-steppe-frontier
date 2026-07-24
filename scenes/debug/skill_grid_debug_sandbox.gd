class_name SkillGridDebugSandbox
extends Control


@export
var hero_definition: HeroDefinition

@export
var progression_source: HeroProgressionState


var progression: HeroProgressionState

var purchase_service := (
	SkillGridPurchaseService.new()
)

var build_resolver := (
	HeroBattleBuildResolver.new()
)

var loadout_service := (
	HeroPersonalLoadoutService.new()
)

func _ready() -> void:
	if (
		hero_definition == null
		or progression_source == null
	):
		_show_initialization_error()
		return

	_reset_progression()


func _reset_progression() -> void:
	progression = (
		progression_source.duplicate(true)
		as HeroProgressionState
	)

	if progression == null:
		_show_initialization_error()
		return

	_rebuild_interface()


func _rebuild_interface() -> void:
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
		0.06,
		0.06,
		0.075,
		1.0
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
		24
	)

	margin.add_theme_constant_override(
		"margin_top",
		24
	)

	margin.add_theme_constant_override(
		"margin_right",
		24
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		24
	)

	add_child(
		margin
	)

	var main_row := HBoxContainer.new()

	main_row.add_theme_constant_override(
		"separation",
		24
	)

	margin.add_child(
		main_row
	)

	var nodes_panel := _create_nodes_panel()

	nodes_panel.custom_minimum_size = Vector2(
		560,
		0
	)

	main_row.add_child(
		nodes_panel
	)

	var right_column := VBoxContainer.new()

	right_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	right_column.add_theme_constant_override(
		"separation",
		16
	)

	main_row.add_child(
		right_column
	)

	var summary_panel := _create_summary_panel()

	summary_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	summary_panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	right_column.add_child(
		summary_panel
	)

	var loadout_panel := _create_loadout_panel()

	loadout_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	right_column.add_child(
		loadout_panel
	)


func _create_nodes_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = (
		"DEBUG SKILL GRID — %s"
		% hero_definition.display_name
	)

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	content.add_child(
		title
	)

	var points_label := Label.new()

	points_label.text = (
		"Свободные Skill Points: %d"
		% progression.unspent_skill_points
	)

	points_label.add_theme_font_size_override(
		"font_size",
		18
	)

	content.add_child(
		points_label
	)

	var separator := HSeparator.new()

	content.add_child(
		separator
	)

	for node in hero_definition.skill_grid.nodes:
		if node == null:
			continue

		content.add_child(
			_create_node_row(
				node
			)
		)

	var spacer := Control.new()

	spacer.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	content.add_child(
		spacer
	)

	var reset_button := Button.new()

	reset_button.text = (
		"Сбросить debug-прогрессию"
	)

	reset_button.pressed.connect(
		_reset_progression
	)

	content.add_child(
		reset_button
	)

	return panel


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
		"%s  ·  %d SP"
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

	var state_label := Label.new()

	var purchase_result := (
		purchase_service.get_purchase_result(
			hero_definition.skill_grid,
			progression,
			node.node_id
		)
	)

	state_label.text = (
		_get_node_state_text(
			node,
			purchase_result
		)
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


func _create_summary_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		content
	)

	var title := Label.new()

	title.text = "RESOLVED HERO BUILD"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	content.add_child(
		title
	)

	var summary := Label.new()

	summary.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	summary.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	var build := build_resolver.resolve(
		hero_definition,
		progression
	)

	if build == null:
		summary.text = (
			"Battle Build не удалось собрать.\n\n"
			+"Проверь зависимости купленных нод "
			+"и выбранный личный loadout."
		)

		content.add_child(
			summary
		)

		return panel

	summary.text = _build_summary_text(
		build
	)

	content.add_child(
		summary
	)

	return panel


func _create_loadout_panel() -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	panel.add_child(
		content
	)

	var known_ability_ids := (
		loadout_service.get_known_ability_ids(
			hero_definition,
			progression
		)
	)

	var selected_ability_ids := (
		loadout_service
			.get_effective_selected_ability_ids(
				hero_definition,
				progression
			)
	)

	var active_slot_count := (
		loadout_service.get_active_slot_count(
			hero_definition,
			progression
		)
	)

	var title := Label.new()

	title.text = (
		"ЛИЧНЫЙ LOADOUT · %d/%d"
		% [
			selected_ability_ids.size(),
			active_slot_count,
		]
	)

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	content.add_child(
		title
	)

	for ability in (
		hero_definition.personal_abilities
	):
		if ability == null:
			continue

		content.add_child(
			_create_loadout_ability_row(
				ability,
				known_ability_ids,
				selected_ability_ids
			)
		)

	return panel


func _create_loadout_ability_row(
	ability: AbilityDefinition,
	known_ability_ids: Array[StringName],
	selected_ability_ids: Array[StringName]
) -> Control:
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		12
	)

	var text_column := VBoxContainer.new()

	text_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	row.add_child(
		text_column
	)

	var ability_name := Label.new()

	ability_name.text = ability.display_name

	text_column.add_child(
		ability_name
	)

	var is_known := known_ability_ids.has(
		ability.ability_id
	)

	var is_selected := selected_ability_ids.has(
		ability.ability_id
	)

	var state_label := Label.new()

	state_label.text = _get_loadout_state_text(
		ability,
		is_known,
		is_selected
	)

	text_column.add_child(
		state_label
	)

	var action_button := Button.new()

	action_button.custom_minimum_size = Vector2(
		130,
		38
	)

	if not is_known:
		action_button.text = "Не изучено"
		action_button.disabled = true

	elif is_selected:
		if (
			ability.ability_id
			== hero_definition.default_ability_id
		):
			action_button.text = "Обязательный"
			action_button.disabled = true

		else:
			var remove_result := (
				loadout_service.get_remove_result(
					hero_definition,
					progression,
					ability.ability_id
				)
			)

			action_button.text = "Убрать"
			action_button.disabled = (
				not remove_result.is_successful
			)

			action_button.pressed.connect(
				_on_remove_ability_pressed.bind(
					ability.ability_id
				)
			)

	else:
		var add_result := (
			loadout_service.get_add_result(
				hero_definition,
				progression,
				ability.ability_id
			)
		)

		action_button.text = (
			_get_add_button_text(
				add_result
			)
		)

		action_button.disabled = (
			not add_result.is_successful
		)

		action_button.pressed.connect(
			_on_add_ability_pressed.bind(
				ability.ability_id
			)
		)

	row.add_child(
		action_button
	)

	return row


func _get_loadout_state_text(
	ability: AbilityDefinition,
	is_known: bool,
	is_selected: bool
) -> String:
	if not is_known:
		return "Состояние: не изучено"

	if (
		is_selected
		and ability.ability_id
			== hero_definition.default_ability_id
	):
		return (
			"Состояние: выбран базовым приёмом"
		)

	if is_selected:
		return "Состояние: выбран"

	return "Состояние: изучен, но не выбран"


func _get_add_button_text(
	result: HeroPersonalLoadoutChangeResult
) -> String:
	if result.is_successful:
		return "Добавить"

	match result.failure_code:
		HeroPersonalLoadoutService.FAILURE_NO_ACTIVE_SLOT:
			return "Нет слота"

		HeroPersonalLoadoutService.FAILURE_ABILITY_NOT_KNOWN:
			return "Не изучено"

		HeroPersonalLoadoutService.FAILURE_ALREADY_SELECTED:
			return "Выбрано"

	return "Недоступно"


func _on_add_ability_pressed(
	ability_id: StringName
) -> void:
	var result := loadout_service.add_ability(
		hero_definition,
		progression,
		ability_id
	)

	if not result.is_successful:
		push_warning(
			"Personal ability add failed: %s"
			% result.failure_code
		)

		return

	_rebuild_interface()


func _on_remove_ability_pressed(
	ability_id: StringName
) -> void:
	var result := loadout_service.remove_ability(
		hero_definition,
		progression,
		ability_id
	)

	if not result.is_successful:
		push_warning(
			"Personal ability remove failed: %s"
			% result.failure_code
		)

		return

	_rebuild_interface()
	
func _build_summary_text(
	build: HeroBattleBuild
) -> String:
	var known_ability_names := (
		_get_ability_names(
			build.known_personal_ability_ids
		)
	)

	var selected_ability_names := (
		_get_ability_names(
			build.selected_personal_ability_ids
		)
	)

	return (
		"Уровень: %d\n"
		% progression.level
		+"\n"
		+"Сила: %d\n"
		% build.strength_rank
		+"Спритность: %d\n"
		% build.agility_rank
		+"Воля: %d\n"
		% build.spirit_rank
		+"\n"
		+"HP: %d\n"
		% build.combatant_definition.max_health
		+"Max Stamina: %d\n"
		% build.combatant_definition.max_stamina
		+"Start Stamina: %d\n"
		% build.combatant_definition.start_stamina
		+"Armor: %d\n"
		% build.combatant_definition.base_armor
		+"\n"
		+"Активные личные слоты: %d\n"
		% build.active_slot_count
		+"\n"
		+"Известные личные приёмы:\n%s\n"
		% known_ability_names
		+"\n"
		+"Выбранные личные приёмы:\n%s\n"
		% selected_ability_names
		+"\n"
		+"Купленные ноды:\n%s"
		% _get_purchased_node_names()
	)


func _get_ability_names(
	ability_ids: Array[StringName]
) -> String:
	if ability_ids.is_empty():
		return "—"

	var names := PackedStringArray()

	for ability_id in ability_ids:
		var ability := (
			hero_definition.get_personal_ability(
				ability_id
			)
		)

		if ability == null:
			names.append(
				String(ability_id)
			)

			continue

		names.append(
			"• %s"
			% ability.display_name
		)

	return "\n".join(
		names
	)


func _get_purchased_node_names() -> String:
	if progression.purchased_node_ids.is_empty():
		return "—"

	var names := PackedStringArray()

	for node_id in progression.purchased_node_ids:
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
			"• %s"
			% node.display_name
		)

	return "\n".join(
		names
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

	_rebuild_interface()


func _show_initialization_error() -> void:
	var label := Label.new()

	label.text = (
		"Skill Grid Debug Sandbox:\n"
		+"HeroDefinition или ProgressionState "
		+"не назначены."
	)

	label.position = Vector2(
		24,
		24
	)

	add_child(
		label
	)
