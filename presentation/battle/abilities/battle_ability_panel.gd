class_name BattleAbilityPanel
extends PanelContainer


signal ability_selected(
	ability: AbilityDefinition
)


@onready
var actor_label: Label = (
	$ContentMargin/VBoxContainer /
	HeaderRow / ActorLabel
)

@onready
var ability_grid: GridContainer = (
	$ContentMargin/VBoxContainer /
	CollapsibleContent / AbilityGrid
)

@onready
var card_title_label: Label = (
	$ContentMargin/VBoxContainer /
	CollapsibleContent / CardPanel /
	CardMargin / CardVBox / CardTitleLabel
)

@onready
var card_meta_label: Label = (
	$ContentMargin/VBoxContainer /
	CollapsibleContent / CardPanel /
	CardMargin / CardVBox / CardMetaLabel
)

@onready
var card_description_label: Label = (
	$ContentMargin/VBoxContainer /
	CollapsibleContent / CardPanel /
	CardMargin / CardVBox /
	CardDescriptionLabel
)

@onready
var card_effects_label: Label = (
	$ContentMargin/VBoxContainer /
	CollapsibleContent / CardPanel /
	CardMargin / CardVBox / CardEffectsLabel
)


var _combatant: CombatantState

var _abilities: Array[AbilityDefinition] = []
var _buttons: Array[Button] = []

var _selected_ability_id: StringName = &""
var _interactable: bool = true

var _button_group: ButtonGroup

var _stamina_changed_callback: Callable

var _ability_lock_changed_callback: Callable


func _ready() -> void:
	_stamina_changed_callback = Callable(
		self,
		"_on_combatant_stamina_changed"
	)
	
	visible = false

	_ability_lock_changed_callback = Callable(
		self,
		"_on_combatant_ability_lock_changed"
	)


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

	_combatant.ability_lock_changed.connect(
		_ability_lock_changed_callback
	)
	
	_rebuild_buttons()

	if (
		selected_ability != null
		and _combatant.has_ability(
			selected_ability.ability_id
		)
		and not _combatant
		.is_ability_restricted(
			selected_ability.ability_id
		)
		and not _combatant.is_ability_locked(
			selected_ability.ability_id
		)
	):
		_selected_ability_id = (
			selected_ability.ability_id
		)

	else:
		var default_ability := (
			_get_first_available_ability()
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
	card_title_label.text = ""
	card_meta_label.text = ""
	card_description_label.text = ""
	card_effects_label.text = ""

	visible = false


func set_selected_ability(
	ability: AbilityDefinition
) -> bool:
	if _combatant == null:
		return false

	if ability == null:
		_selected_ability_id = &""
		_refresh_visual_state()
		return true

	if not _combatant.has_ability(
		ability.ability_id
	):
		return false

	if _combatant.is_ability_locked(
		ability.ability_id
	):
		return false

	if _combatant.is_ability_restricted(
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

	if _combatant.is_ability_restricted(
		ability.ability_id
	):
		return false

	if _combatant.is_ability_locked(
		ability.ability_id
	):
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

	var loadout_abilities := (
		_combatant.get_abilities()
	)

	for ability in loadout_abilities:
		if ability != null:
			_abilities.append(
				ability
			)

	_button_group = ButtonGroup.new()
	_button_group.allow_unpress = false

	for ability_index in range(
		_abilities.size()
	):
		var ability := _abilities[
			ability_index
		]

		var button := Button.new()

		button.custom_minimum_size = Vector2(
			230.0,
			68.0
		)

		button.toggle_mode = true
		button.button_group = _button_group

		button.text = _build_button_text(
			ability_index,
			ability
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


func _get_first_available_ability() -> AbilityDefinition:
	if _combatant == null:
		return null

	var default_ability := (
		_combatant.get_default_ability()
	)

	if (
		default_ability != null
		and not _combatant
		.is_ability_restricted(
			default_ability.ability_id
		)
		and not _combatant.is_ability_locked(
			default_ability.ability_id
		)
	):
		return default_ability

	for ability in _abilities:
		if ability == null:
			continue

		if _combatant.is_ability_restricted(
			ability.ability_id
		):
			continue

		if _combatant.is_ability_locked(
			ability.ability_id
		):
			continue

		return ability

	return null

func _refresh_visual_state() -> void:
	if _combatant == null:
		return

	actor_label.text = (
		"%s  |  Выносливость: %d/%d"
		% [
			_combatant.definition.display_name,
			_combatant.current_stamina,
			_combatant.max_stamina,
		]
	)

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

		var restricted := (
			_combatant.is_ability_restricted(
				ability.ability_id
			)
		)

		var ability_locked := (
			_combatant.is_ability_locked(
				ability.ability_id
			)
		)

		button.text = _build_button_text(
			ability_index,
			ability
		)

		button.disabled = (
			not _interactable
			or not affordable
			or restricted
			or ability_locked
		)

		button.set_pressed_no_signal(
			ability.ability_id
			== _selected_ability_id
		)

	_refresh_card()


func _refresh_card() -> void:
	var selected_ability := (
		get_selected_ability()
	)

	if selected_ability == null:
		card_title_label.text = (
			"Способность не выбрана"
		)

		card_meta_label.text = ""
		card_description_label.text = ""
		card_effects_label.text = ""

		return

	var remaining_lock_turns := (
		_combatant
		.get_ability_lock_remaining_turns(
			selected_ability.ability_id
		)
	)

	var lock_kind := (
		_combatant.get_ability_lock_kind(
			selected_ability.ability_id
		)
	)

	var ability_restricted := (
		_combatant != null
		and _combatant.is_ability_restricted(
			selected_ability.ability_id
		)
	)

	var affordability_text: String

	if remaining_lock_turns > 0:
		var formatted_turns := (
			BattleAbilityPresentationBuilder
			.format_turn_count(
				remaining_lock_turns
			)
		)

		if (
			lock_kind
			== CombatantState
			.AbilityLockKind
			.INITIAL
		):
			affordability_text = (
				"СТАРТОВАЯ ЗАДЕРЖКА: %s"
				% formatted_turns
			)

		else:
			affordability_text = (
				"КУЛДАУН: %s"
				% formatted_turns
			)

	elif ability_restricted:
		affordability_text = (
			"ЗАПРЕЩЕНО СТАТУСОМ"
		)

	elif (
		_combatant != null
		and _combatant.can_spend_stamina(
			selected_ability.stamina_cost
		)
	):
		affordability_text = "ДОСТУПНО"

	else:
		affordability_text = (
			"НЕ ХВАТАЕТ ВЫНОСЛИВОСТИ"
		)

	card_title_label.text = (
		selected_ability.display_name
	)

	card_meta_label.text = (
		"%s  •  %s"
		% [
			BattleAbilityPresentationBuilder
			.build_meta_text(
				selected_ability
			),
			affordability_text,
		]
	)

	card_description_label.text = (
		selected_ability.description
	)

	card_effects_label.text = (
		BattleAbilityPresentationBuilder
		.build_effects_text(
			selected_ability,
			_combatant
		)
	)


func _disconnect_combatant_signals() -> void:
	if _combatant == null:
		return

	if (
		_stamina_changed_callback.is_valid()
		and _combatant.is_connected(
			&"stamina_changed",
			_stamina_changed_callback
		)
	):
		_combatant.disconnect(
			&"stamina_changed",
			_stamina_changed_callback
		)

	if (
		_ability_lock_changed_callback.is_valid()
		and _combatant.is_connected(
			&"ability_lock_changed",
			_ability_lock_changed_callback
		)
	):
		_combatant.disconnect(
			&"ability_lock_changed",
			_ability_lock_changed_callback
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


func _on_combatant_ability_lock_changed(
	_ability_id: StringName,
	_previous_remaining_turns: int,
	_current_remaining_turns: int
) -> void:
	_refresh_visual_state()


func _build_button_text(
	ability_index: int,
	ability: AbilityDefinition
) -> String:
	if ability == null:
		return ""

	var details := (
		"%d выносливости"
		% ability.stamina_cost
	)

	if _combatant != null:
		var remaining_turns := (
			_combatant
			.get_ability_lock_remaining_turns(
				ability.ability_id
			)
		)

		if remaining_turns > 0:
			var lock_kind := (
				_combatant.get_ability_lock_kind(
					ability.ability_id
				)
			)

			if (
				lock_kind
				== CombatantState
				.AbilityLockKind
				.INITIAL
			):
				details += (
					" • Старт: %d"
					% remaining_turns
				)

			else:
				details += (
					" • КД: %d"
					% remaining_turns
				)

	return (
		"%d. %s\n%s"
		% [
			ability_index + 1,
			ability.display_name,
			details,
		]
	)
