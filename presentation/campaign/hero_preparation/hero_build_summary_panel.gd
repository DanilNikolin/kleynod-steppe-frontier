class_name HeroBuildSummaryPanel
extends PanelContainer


var hero_definition: HeroDefinition
var progression: HeroProgressionState

var build_resolver := (
	HeroBattleBuildResolver.new()
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

	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		10
	)

	add_child(
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

	var scroll := ScrollContainer.new()

	scroll.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	content.add_child(
		scroll
	)

	var summary := Label.new()

	summary.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	summary.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	scroll.add_child(
		summary
	)

	if (
		hero_definition == null
		or progression == null
	):
		summary.text = (
			"Hero Battle Build недоступен."
		)

		return

	var build := build_resolver.resolve(
		hero_definition,
		progression
	)

	if build == null:
		summary.text = (
			"Battle Build не удалось собрать.\n\n"
			+"Проверь Skill Grid, выбранный loadout "
			+"и Equipment State."
		)

		return

	summary.text = _build_summary_text(
		build
	)


func _build_summary_text(
	build: HeroBattleBuild
) -> String:
	var base := (
		hero_definition.base_combatant_definition
	)

	var grid := build.skill_grid_bonuses
	var equipment := build.equipment_bonuses
	var final_definition := build.combatant_definition

	var lines := PackedStringArray()

	lines.append(
		"Уровень: %d"
		% progression.level
	)

	lines.append("")
	lines.append("ВЕТКИ РОСТА")

	lines.append(
		_build_breakdown_line(
			"Сила",
			base.base_strength,
			grid.strength_rank_bonus,
			equipment.strength_rank_bonus,
			build.strength_rank
		)
	)

	lines.append(
		_build_breakdown_line(
			"Спритность",
			base.base_agility,
			grid.agility_rank_bonus,
			equipment.agility_rank_bonus,
			build.agility_rank
		)
	)

	lines.append(
		_build_breakdown_line(
			"Воля",
			base.base_spirit,
			grid.spirit_rank_bonus,
			equipment.spirit_rank_bonus,
			build.spirit_rank
		)
	)

	lines.append("")
	lines.append("БОЕВЫЕ ПАРАМЕТРЫ")

	lines.append(
		_build_breakdown_line(
			"Max Health",
			base.max_health,
			grid.max_health_bonus,
			equipment.max_health_bonus,
			final_definition.max_health
		)
	)

	lines.append(
		_build_breakdown_line(
			"Armor",
			base.base_armor,
			grid.armor_bonus,
			equipment.armor_bonus,
			final_definition.base_armor
		)
	)

	lines.append(
		_build_breakdown_line(
			"Max Stamina",
			base.max_stamina,
			grid.max_stamina_bonus,
			equipment.max_stamina_bonus,
			final_definition.max_stamina
		)
	)

	lines.append(
		_build_breakdown_line(
			"Start Stamina",
			_get_base_start_stamina(),
			grid.start_stamina_bonus,
			equipment.start_stamina_bonus,
			final_definition.start_stamina
		)
	)

	lines.append(
		"Stamina Regen: база %d | итог %d"
		% [
			base.stamina_regeneration,
			final_definition.stamina_regeneration,
		]
	)

	lines.append("")
	lines.append("СБОРКА")

	lines.append(
		_build_breakdown_line(
			"Активные личные слоты",
			hero_definition.starting_active_slot_count,
			grid.active_slot_bonus,
			equipment.active_slot_bonus,
			build.active_slot_count
		)
	)

	lines.append("")
	lines.append(
		"Известные личные приёмы:\n%s"
		% _get_personal_ability_names(
			build.known_personal_ability_ids
		)
	)

	lines.append("")
	lines.append(
		"Выбранные личные приёмы:\n%s"
		% _get_personal_ability_names(
			build.selected_personal_ability_ids
		)
	)

	lines.append("")
	lines.append(
		"Итоговые боевые способности:\n%s"
		% _get_runtime_ability_names(
			build
		)
	)

	lines.append("")
	lines.append(
		"Экипированные предметы:\n%s"
		% _get_equipped_item_names(
			build
		)
	)

	lines.append("")
	lines.append(
		"Купленные ноды:\n%s"
		% _get_purchased_node_names()
	)

	return "\n".join(
		lines
	)


func _build_breakdown_line(
	label: String,
	base_value: int,
	skill_grid_bonus: int,
	equipment_bonus: int,
	final_value: int
) -> String:
	return (
		"%s: база %d | Skill Grid %s | "
		% [
			label,
			base_value,
			_format_bonus(
				skill_grid_bonus
			),
		]
		+"Equipment %s | итог %d"
		% [
			_format_bonus(
				equipment_bonus
			),
			final_value,
		]
	)


func _format_bonus(
	value: int
) -> String:
	if value >= 0:
		return "+%d" % value

	return str(value)


func _get_base_start_stamina() -> int:
	var base := (
		hero_definition.base_combatant_definition
	)

	if base.start_stamina < 0:
		return base.max_stamina

	return mini(
		base.start_stamina,
		base.max_stamina
	)


func _get_personal_ability_names(
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


func _get_runtime_ability_names(
	build: HeroBattleBuild
) -> String:
	var names := PackedStringArray()

	for ability in build.loadout.get_abilities():
		names.append(
			"• %s"
			% ability.display_name
		)

	if names.is_empty():
		return "—"

	return "\n".join(
		names
	)


func _get_equipped_item_names(
	build: HeroBattleBuild
) -> String:
	var names := PackedStringArray()

	for item in build.equipped_items:
		if (
			item == null
			or item.definition == null
		):
			continue

		names.append(
			"• %s"
			% item.definition.display_name
		)

	if names.is_empty():
		return "—"

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


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()