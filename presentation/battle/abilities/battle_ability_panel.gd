class_name BattleAbilityPanel
extends PanelContainer


signal ability_selected(
	ability: AbilityDefinition
)


@onready
var actor_label: Label = (
	$ContentMargin/VBoxContainer/ActorLabel
)

@onready
var ability_grid: GridContainer = (
	$ContentMargin/VBoxContainer/AbilityGrid
)

@onready
var description_label: Label = (
	$ContentMargin/VBoxContainer/DescriptionLabel
)


var _combatant: CombatantState

var _abilities: Array[AbilityDefinition] = []
var _buttons: Array[Button] = []

var _selected_ability_id: StringName = &""
var _interactable: bool = true

var _button_group: ButtonGroup

var _stamina_changed_callback: Callable


func _ready() -> void:
	_stamina_changed_callback = Callable(
		self,
		"_on_combatant_stamina_changed"
	)

	visible = false


func bind_combatant(
	combatant: CombatantState,
	selected_ability: AbilityDefinition = null
) -> void:
	_disconnect_combatant_signals()

	_combatant = combatant

	if (
		_combatant == null
		or not _combatant.is_alive
		or _combatant.loadout == null
	):
		clear_combatant()
		return

	_combatant.stamina_changed.connect(
		_stamina_changed_callback
	)

	actor_label.text = (
		"%s — способности"
		% _combatant.definition.display_name
	)

	_rebuild_buttons()

	if (
		selected_ability != null
		and _combatant.has_ability(
			selected_ability.ability_id
		)
	):
		_selected_ability_id = (
			selected_ability.ability_id
		)

	else:
		var default_ability := (
			_combatant.loadout
			.get_default_ability()
		)

		_selected_ability_id = (
			default_ability.ability_id
			if default_ability != null
			else &""
		)

	_refresh_visual_state()

	visible = true


func clear_combatant() -> void:
	_disconnect_combatant_signals()

	_combatant = null
	_selected_ability_id = &""

	_clear_buttons()

	actor_label.text = ""
	description_label.text = ""

	visible = false


func set_selected_ability(
	ability: AbilityDefinition
) -> bool:
	if _combatant == null:
		return false

	if ability == null:
		return false

	if not _combatant.has_ability(
		ability.ability_id
	):
		return false

	_selected_ability_id = (
		ability.ability_id
	)

	_refresh_visual_state()
	return true


func select_ability_by_index(
	ability_index: int,
	emit_selection_signal: bool = true
) -> bool:
	if not _interactable:
		return false

	if (
		ability_index < 0
		or ability_index >= _abilities.size()
	):
		return false

	if _combatant == null:
		return false

	var ability := _abilities[
		ability_index
	]

	if ability == null:
		return false

	if not _combatant.can_spend_stamina(
		ability.stamina_cost
	):
		return false

	_selected_ability_id = ability.ability_id

	_refresh_visual_state()

	if emit_selection_signal:
		ability_selected.emit(
			ability
		)

	return true


func set_interactable(
	interactable: bool
) -> void:
	_interactable = interactable
	_refresh_visual_state()


func get_selected_ability() -> AbilityDefinition:
	for ability in _abilities:
		if (
			ability != null
			and ability.ability_id
			== _selected_ability_id
		):
			return ability

	return null


func _rebuild_buttons() -> void:
	_clear_buttons()

	if _combatant == null:
		return

	_abilities = (
		_combatant.loadout
		.get_abilities()
	)

	_button_group = ButtonGroup.new()
	_button_group.allow_unpress = false

	for ability_index in range(
		_abilities.size()
	):
		var ability := _abilities[
			ability_index
		]

		if ability == null:
			continue

		var button := Button.new()

		button.custom_minimum_size = Vector2(
			220.0,
			72.0
		)

		button.toggle_mode = true
		button.button_group = _button_group

		button.text = (
			"%d. %s\nВыносливость: %d"
			% [
				ability_index + 1,
				ability.display_name,
				ability.stamina_cost,
			]
		)

		button.tooltip_text = (
			ability.description
		)

		button.pressed.connect(
			_on_ability_button_pressed.bind(
				ability_index
			)
		)

		ability_grid.add_child(
			button
		)

		_buttons.append(
			button
		)


func _clear_buttons() -> void:
	for child in ability_grid.get_children():
		ability_grid.remove_child(
			child
		)

		child.queue_free()

	_buttons.clear()
	_abilities.clear()

	_button_group = null


func _refresh_visual_state() -> void:
	if _combatant == null:
		return

	for ability_index in range(
		_buttons.size()
	):
		if ability_index >= _abilities.size():
			continue

		var button := _buttons[
			ability_index
		]

		var ability := _abilities[
			ability_index
		]

		if button == null or ability == null:
			continue

		var affordable := (
			_combatant.can_spend_stamina(
				ability.stamina_cost
			)
		)

		button.disabled = (
			not _interactable
			or not affordable
		)

		button.set_pressed_no_signal(
			ability.ability_id
			== _selected_ability_id
		)

	_refresh_description()


func _refresh_description() -> void:
	var selected_ability := (
		get_selected_ability()
	)

	if selected_ability == null:
		description_label.text = (
			"Способность не выбрана."
		)

		return

	var affordability_text := (
		"доступно"
		if (
			_combatant != null
			and _combatant.can_spend_stamina(
				selected_ability.stamina_cost
			)
		)
		else "не хватает выносливости"
	)

	description_label.text = (
		"Выбрано: %s | Цена: %d | %s\n%s"
		% [
			selected_ability.display_name,
			selected_ability.stamina_cost,
			affordability_text,
			selected_ability.description,
		]
	)


func _disconnect_combatant_signals() -> void:
	if _combatant == null:
		return

	if not _stamina_changed_callback.is_valid():
		return

	if _combatant.is_connected(
		&"stamina_changed",
		_stamina_changed_callback
	):
		_combatant.disconnect(
			&"stamina_changed",
			_stamina_changed_callback
		)


func _on_ability_button_pressed(
	ability_index: int
) -> void:
	select_ability_by_index(
		ability_index,
		true
	)


func _on_combatant_stamina_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	_refresh_visual_state()