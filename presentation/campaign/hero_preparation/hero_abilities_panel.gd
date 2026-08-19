class_name HeroAbilitiesPanel
extends PanelContainer


signal state_changed
signal ability_selected(ability_id: StringName)


var hero_definition: HeroDefinition
var progression: HeroProgressionState

var selected_ability_id: StringName = &""

var build_resolver := (
	HeroBattleBuildResolver.new()
)

var ability_resolver := (
	AbilityRuntimeResolver.new()
)

static var _expanded_ability_sections: Dictionary = {
	AbilityDefinition.Branch.STRENGTH: true,
	AbilityDefinition.Branch.AGILITY: false,
	AbilityDefinition.Branch.SPIRIT: false,
	AbilityDefinition.Branch.NONE: false,
}

func bind(
	p_hero_definition: HeroDefinition,
	p_progression: HeroProgressionState,
	p_selected_ability_id: StringName = &""
) -> void:
	hero_definition = p_hero_definition
	progression = p_progression
	selected_ability_id = p_selected_ability_id

	_rebuild_interface()


func _rebuild_interface() -> void:
	_clear_children()

	var root := VBoxContainer.new()

	root.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	root.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_theme_constant_override(
		"separation",
		14
	)

	add_child(
		root
	)

	var title := Label.new()

	title.text = "ЛИЧНЫЕ УМЕНИЯ"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	root.add_child(
		title
	)

	if (
		hero_definition == null
		or progression == null
	):
		var error_label := Label.new()

		error_label.text = (
			"Данные героя недоступны."
		)

		root.add_child(
			error_label
		)

		return

	var build := build_resolver.resolve(
		hero_definition,
		progression
	)

	if build == null:
		var error_label := Label.new()

		error_label.text = (
			"Не удалось собрать Hero Battle Build."
		)

		root.add_child(
			error_label
		)

		return

	var known_abilities := (
		_get_known_personal_abilities(
			build
		)
	)

	if known_abilities.is_empty():
		var error_label := Label.new()

		error_label.text = (
			"У героя пока нет известных "
			+"личных умений."
		)

		root.add_child(
			error_label
		)

		return

	_ensure_valid_selection(
		known_abilities
	)

	var upper_split := HSplitContainer.new()

	upper_split.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	upper_split.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	root.add_child(
		upper_split
	)

	var ability_list := _create_ability_list(
		known_abilities,
		build
	)

	ability_list.custom_minimum_size = Vector2(
		360,
		0
	)

	upper_split.add_child(
		ability_list
	)

	var ability_details := _create_ability_details(
		build
	)

	ability_details.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	ability_details.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	upper_split.add_child(
		ability_details
	)

	root.add_child(
		HSeparator.new()
	)

	var loadout_header := Label.new()

	loadout_header.text = "АКТИВНЫЙ LOADOUT"

	loadout_header.add_theme_font_size_override(
		"font_size",
		18
	)

	root.add_child(
		loadout_header
	)

	var loadout_panel := HeroLoadoutPanel.new()

	loadout_panel.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	loadout_panel.state_changed.connect(
		_on_loadout_state_changed
	)

	root.add_child(
		loadout_panel
	)

	loadout_panel.bind(
		hero_definition,
		progression
	)


func _get_known_personal_abilities(
	build: HeroBattleBuild
) -> Array[AbilityDefinition]:
	var result: Array[AbilityDefinition] = []

	if build == null:
		return result

	for ability_id in (
		build.known_personal_ability_ids
	):
		var ability := (
			hero_definition
				.get_personal_ability(
					ability_id
				)
		)

		if ability == null:
			continue

		result.append(
			ability
		)

	return result


func _ensure_valid_selection(
	abilities: Array[AbilityDefinition]
) -> void:
	var selected_ability: AbilityDefinition = null

	for ability in abilities:
		if ability == null:
			continue

		if (
			ability.ability_id
			== selected_ability_id
		):
			selected_ability = ability
			break

	if selected_ability == null:
		selected_ability = abilities[0]

		selected_ability_id = (
			selected_ability.ability_id
		)

	_expanded_ability_sections[
		selected_ability.branch
	] = true


func _create_ability_list(
	abilities: Array[AbilityDefinition],
	build: HeroBattleBuild
) -> Control:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		10
	)

	margin.add_theme_constant_override(
		"margin_top",
		10
	)

	margin.add_theme_constant_override(
		"margin_right",
		10
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		10
	)

	panel.add_child(
		margin
	)

	var column := VBoxContainer.new()

	column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	column.add_theme_constant_override(
		"separation",
		8
	)

	margin.add_child(
		column
	)

	var header := Label.new()

	header.text = "ИЗВЕСТНЫЕ ПРИЁМЫ"

	column.add_child(
		header
	)

	column.add_child(
		HSeparator.new()
	)

	var scroll := ScrollContainer.new()

	scroll.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	column.add_child(
		scroll
	)

	var sections := VBoxContainer.new()

	sections.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	sections.add_theme_constant_override(
		"separation",
		6
	)

	scroll.add_child(
		sections
	)

	var grouped_abilities: Dictionary = {
		AbilityDefinition.Branch.STRENGTH: [],
		AbilityDefinition.Branch.AGILITY: [],
		AbilityDefinition.Branch.SPIRIT: [],
		AbilityDefinition.Branch.NONE: [],
	}

	for ability in abilities:
		if ability == null:
			continue

		grouped_abilities[
			ability.branch
		].append(
			ability
		)

	var branch_order := [
		AbilityDefinition.Branch.STRENGTH,
		AbilityDefinition.Branch.AGILITY,
		AbilityDefinition.Branch.SPIRIT,
		AbilityDefinition.Branch.NONE,
	]

	for branch in branch_order:
		var branch_abilities: Array = (
			grouped_abilities[branch]
		)

		if branch_abilities.is_empty():
			continue

		sections.add_child(
			_create_ability_group(
				branch,
				branch_abilities,
				build
			)
		)

	return panel

func _create_ability_group(
	branch: int,
	abilities: Array,
	build: HeroBattleBuild
) -> Control:
	var section := VBoxContainer.new()

	section.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	section.add_theme_constant_override(
		"separation",
		5
	)

	var expanded := bool(
		_expanded_ability_sections.get(
			branch,
			false
		)
	)

	var header := Button.new()

	header.toggle_mode = true

	header.set_pressed_no_signal(
		expanded
	)

	header.text = _build_ability_group_title(
		branch,
		abilities.size(),
		expanded
	)

	header.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	header.custom_minimum_size = Vector2(
		0,
		40
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
		5
	)

	section.add_child(
		body
	)

	for ability in abilities:
		if ability == null:
			continue

		var rank := _get_ability_rank(
			ability,
			build
		)

		var button := Button.new()

		button.text = (
			"%s\nRank %d"
			% [
				ability.display_name,
				rank,
			]
		)

		button.custom_minimum_size = Vector2(
			0,
			56
		)

		button.size_flags_horizontal = (
			Control.SIZE_EXPAND_FILL
		)

		button.disabled = (
			ability.ability_id
			== selected_ability_id
		)

		button.pressed.connect(
			_on_ability_pressed.bind(
				ability.ability_id
			)
		)

		body.add_child(
			button
		)

	header.toggled.connect(
		_on_ability_group_toggled.bind(
			branch,
			body,
			header,
			abilities.size()
		)
	)

	return section


func _build_ability_group_title(
	branch: int,
	ability_count: int,
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
			_get_branch_name(
				branch
			).to_upper(),
			ability_count,
		]
	)


func _on_ability_group_toggled(
	expanded: bool,
	branch: int,
	body: Control,
	header: Button,
	ability_count: int
) -> void:
	_expanded_ability_sections[
		branch
	] = expanded

	body.visible = expanded

	header.text = _build_ability_group_title(
		branch,
		ability_count,
		expanded
	)
    

func _create_ability_details(
	build: HeroBattleBuild
) -> Control:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		16
	)

	margin.add_theme_constant_override(
		"margin_top",
		12
	)

	margin.add_theme_constant_override(
		"margin_right",
		16
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		12
	)

	panel.add_child(
		margin
	)

	var column := VBoxContainer.new()

	column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	column.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	column.add_theme_constant_override(
		"separation",
		10
	)

	margin.add_child(
		column
	)

	var source_ability := (
		hero_definition
			.get_personal_ability(
				selected_ability_id
			)
	)

	if source_ability == null:
		var error_label := Label.new()

		error_label.text = (
			"Выбранная способность "
			+"не найдена."
		)

		column.add_child(
			error_label
		)

		return panel

	var current_rank := _get_ability_rank(
		source_ability,
		build
	)

	var ability_title := Label.new()

	ability_title.text = (
		source_ability.display_name
	)

	ability_title.add_theme_font_size_override(
		"font_size",
		24
	)

	column.add_child(
		ability_title
	)

	var branch_label := Label.new()

	branch_label.text = (
		"%s · Rank %d / %d"
		% [
			_get_branch_name(
				source_ability.branch
			),
			current_rank,
			AbilityGrowthTableDefinition.MAX_RANK,
		]
	)

	column.add_child(
		branch_label
	)

	var description := Label.new()

	description.text = (
		source_ability.description
	)

	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	column.add_child(
		description
	)

	column.add_child(
		HSeparator.new()
	)

	var versions := HBoxContainer.new()

	versions.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	versions.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	versions.add_theme_constant_override(
		"separation",
		12
	)

	column.add_child(
		versions
	)

	var current_ability := (
		ability_resolver.resolve(
			source_ability,
			current_rank
		)
	)

	var current_card := _create_rank_card(
		"ТЕКУЩИЙ · RANK %d"
		% current_rank,
		current_ability
	)

	current_card.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	current_card.size_flags_stretch_ratio = 1.0

	versions.add_child(
		current_card
	)

	if source_ability.growth_table == null:
		var no_growth_card := (
			_create_message_card(
				"СЛЕДУЮЩИЙ RANK",
				"Для этой способности Growth Table "
				+"ещё не настроена."
			)
		)

		no_growth_card.size_flags_horizontal = (
			Control.SIZE_EXPAND_FILL
		)

		no_growth_card.size_flags_stretch_ratio = 1.0

		versions.add_child(
			no_growth_card
		)

	elif (
		current_rank
		>= AbilityGrowthTableDefinition.MAX_RANK
	):
		var max_card := (
			_create_message_card(
				"МАКСИМАЛЬНЫЙ RANK",
				"Способность полностью развита."
			)
		)

		max_card.size_flags_horizontal = (
			Control.SIZE_EXPAND_FILL
		)

		max_card.size_flags_stretch_ratio = 1.0

		versions.add_child(
			max_card
		)

	else:
		var next_rank := current_rank + 1

		var next_ability := (
			ability_resolver.resolve(
				source_ability,
				next_rank
			)
		)

		var next_card := _create_rank_card(
			"СЛЕДУЮЩИЙ · RANK %d"
			% next_rank,
			next_ability
		)

		next_card.size_flags_horizontal = (
			Control.SIZE_EXPAND_FILL
		)

		next_card.size_flags_stretch_ratio = 1.0

		versions.add_child(
			next_card
		)

	return panel


func _create_rank_card(
	card_title: String,
	ability: AbilityDefinition
) -> Control:
	if ability == null:
		return _create_message_card(
			card_title,
			"Не удалось разрешить "
			+"версию способности."
		)

	var panel := PanelContainer.new()
	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		12
	)

	margin.add_theme_constant_override(
		"margin_top",
		10
	)

	margin.add_theme_constant_override(
		"margin_right",
		12
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		10
	)

	panel.add_child(
		margin
	)

	var column := VBoxContainer.new()

	column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	column.add_theme_constant_override(
		"separation",
		8
	)

	margin.add_child(
		column
	)

	var title := Label.new()

	title.text = card_title

	title.add_theme_font_size_override(
		"font_size",
		18
	)

	column.add_child(
		title
	)

	var meta := Label.new()

	meta.text = (
		BattleAbilityPresentationBuilder
			.build_meta_text(
				ability
			)
	)

	meta.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	column.add_child(
		meta
	)

	column.add_child(
		HSeparator.new()
	)

	var effects := Label.new()

	effects.text = (
		BattleAbilityPresentationBuilder
			.build_effects_text(
				ability
			)
	)

	effects.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	effects.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	column.add_child(
		effects
	)

	return panel


func _create_message_card(
	card_title: String,
	message: String
) -> Control:
	var panel := PanelContainer.new()
	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		12
	)

	margin.add_theme_constant_override(
		"margin_top",
		10
	)

	margin.add_theme_constant_override(
		"margin_right",
		12
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		10
	)

	panel.add_child(
		margin
	)

	var column := VBoxContainer.new()

	column.add_theme_constant_override(
		"separation",
		8
	)

	margin.add_child(
		column
	)

	var title := Label.new()

	title.text = card_title

	title.add_theme_font_size_override(
		"font_size",
		18
	)

	column.add_child(
		title
	)

	var message_label := Label.new()

	message_label.text = message

	message_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	column.add_child(
		message_label
	)

	return panel


func _get_ability_rank(
	ability: AbilityDefinition,
	build: HeroBattleBuild
) -> int:
	if (
		ability == null
		or build == null
	):
		return 0

	return ability.get_growth_rank(
		build.strength_rank,
		build.agility_rank,
		build.spirit_rank
	)


func _get_branch_name(
	branch: int
) -> String:
	match branch:
		AbilityDefinition.Branch.STRENGTH:
			return "Сила"

		AbilityDefinition.Branch.AGILITY:
			return "Спритность"

		AbilityDefinition.Branch.SPIRIT:
			return "Воля"

		AbilityDefinition.Branch.NONE:
			return "Без ветки"

	return "Неизвестная ветка"


func _on_ability_pressed(
	ability_id: StringName
) -> void:
	if selected_ability_id == ability_id:
		return

	selected_ability_id = ability_id

	ability_selected.emit(
		selected_ability_id
	)

	_rebuild_interface()


func _on_loadout_state_changed() -> void:
	state_changed.emit()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()