class_name HeroLoadoutPanel
extends PanelContainer


signal state_changed


var hero_definition: HeroDefinition
var progression: HeroProgressionState

var loadout_service := (
	HeroPersonalLoadoutService.new()
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

	if (
		hero_definition == null
		or progression == null
	):
		var error_label := Label.new()

		error_label.text = (
			"Личный loadout недоступен."
		)

		content.add_child(
			error_label
		)

		return

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

	for ability in hero_definition.personal_abilities:
		if ability == null:
			continue

		content.add_child(
			_create_ability_row(
				ability,
				known_ability_ids,
				selected_ability_ids
			)
		)


func _create_ability_row(
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

	state_label.text = _get_state_text(
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
				_on_remove_pressed.bind(
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

		action_button.text = _get_add_button_text(
			add_result
		)

		action_button.disabled = (
			not add_result.is_successful
		)

		action_button.pressed.connect(
			_on_add_pressed.bind(
				ability.ability_id
			)
		)

	row.add_child(
		action_button
	)

	return row


func _get_state_text(
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
		return "Состояние: выбран базовым приёмом"

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


func _on_add_pressed(
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

	state_changed.emit()


func _on_remove_pressed(
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

	state_changed.emit()


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()