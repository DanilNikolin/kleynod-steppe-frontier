class_name BattleAbilityPanel
extends Control

signal ability_selected(ability: AbilityDefinition)

var hud_actor: CombatantState
var hud_abilities: Array[AbilityDefinition] = []
var hud_slots: Array[BattleAbilitySlot] = []
var hud_selected: AbilityDefinition
var hud_interactable: bool = true
var _card_layout_revision: int = 0

func _ready() -> void:
	for child in $Slots.get_children():
		var slot := child as BattleAbilitySlot
		hud_slots.append(slot)
		slot.pressed.connect(select_ability_by_index.bind(hud_slots.size() - 1))
		slot.mouse_entered.connect(_show_hud_card.bind(hud_slots.size() - 1))
		slot.mouse_exited.connect(_hide_hud_card)
	clear_combatant()

func bind_combatant(combatant: CombatantState, selected_ability: AbilityDefinition = null) -> void:
	_disconnect_hud_actor()
	hud_actor = combatant
	if hud_actor == null:
		clear_combatant()
		return
	hud_abilities = hud_actor.get_abilities()
	if hud_abilities.size() > 6:
		push_error("Battle HUD supports 6 equipped abilities; %s has %d. Use the debug sandbox panel for test loadouts." % [hud_actor.instance_id, hud_abilities.size()])
	hud_actor.stamina_changed.connect(_hud_changed)
	hud_actor.max_stamina_changed.connect(_hud_changed)
	hud_actor.ability_lock_changed.connect(_hud_changed)
	hud_actor.status_added.connect(_hud_changed)
	hud_actor.status_updated.connect(_hud_changed)
	hud_actor.status_removed.connect(_hud_changed)
	hud_selected = null
	var candidate := selected_ability if selected_ability != null else hud_actor.get_default_ability()
	if not set_selected_ability(candidate):
		for ability in hud_abilities.slice(0, 6):
			if set_selected_ability(ability):
				break
	_refresh_hud_slots()

func clear_combatant() -> void:
	_disconnect_hud_actor()
	hud_actor = null
	hud_abilities.clear()
	hud_selected = null
	for i in range(hud_slots.size()):
		hud_slots[i].bind_empty(i)
	if is_node_ready():
		_hide_hud_card()

func set_selected_ability(ability: AbilityDefinition) -> bool:
	if hud_actor == null:
		return false
	if ability != null:
		if not hud_abilities.slice(0, 6).has(ability) or hud_actor.is_ability_locked(ability.ability_id) or hud_actor.is_ability_restricted(ability.ability_id):
			return false
	hud_selected = ability
	_refresh_hud_slots()
	return true

func select_ability_by_index(index: int, emit_selection_signal: bool = true) -> bool:
	if not hud_interactable or hud_actor == null or index < 0 or index >= mini(6, hud_abilities.size()):
		return false
	var ability := hud_abilities[index]
	if not hud_actor.can_spend_stamina(ability.stamina_cost) or not set_selected_ability(ability):
		return false
	if emit_selection_signal:
		ability_selected.emit(ability)
	return true

func set_interactable(value: bool) -> void:
	hud_interactable = value
	_refresh_hud_slots()

func get_selected_ability() -> AbilityDefinition:
	return hud_selected

func _refresh_hud_slots() -> void:
	for i in range(hud_slots.size()):
		var slot := hud_slots[i]
		if hud_actor == null or i >= hud_abilities.size():
			slot.bind_empty(i)
			continue
		var ability := hud_abilities[i]
		slot.bind_ability(hud_actor, ability, i)
		slot.disabled = not hud_interactable or not hud_actor.is_alive or hud_actor.is_ability_locked(ability.ability_id) or hud_actor.is_ability_restricted(ability.ability_id) or not hud_actor.can_spend_stamina(ability.stamina_cost)
		slot.set_selected(ability == hud_selected)

func _show_hud_card(index: int) -> void:
	if hud_actor == null or index >= hud_abilities.size() or index >= hud_slots.size():
		return
	var ability := hud_abilities[index]
	var slot := hud_slots[index]
	$Card/Margin/Content/Title.text = ability.display_name
	var lock_turns := hud_actor.get_ability_lock_remaining_turns(ability.ability_id)
	$Card/Margin/Content/Meta.text = BattleAbilityPresentationBuilder.build_meta_text(ability) + (" · Задержка: %d" % lock_turns if lock_turns > 0 else "")
	$Card/Margin/Content/Description.text = ability.description
	$Card/Margin/Content/Effects.text = BattleAbilityPresentationBuilder.build_effects_text(ability, hud_actor)

	_card_layout_revision += 1
	var revision := _card_layout_revision

	$Card.custom_minimum_size = Vector2(440.0, 0.0)
	$Card.size.x = 440.0
	$Card.modulate.a = 0.0
	$Card.show()

	_finalize_show_hud_card.call_deferred(slot, revision)

func _finalize_show_hud_card(slot: BattleAbilitySlot, revision: int) -> void:
	if revision != _card_layout_revision or not $Card.visible:
		return
	if slot == null or not is_instance_valid(slot) or not slot.is_inside_tree():
		_hide_hud_card()
		return

	$Card.reset_size()
	var card_size: Vector2 = $Card.get_combined_minimum_size()
	$Card.size = Vector2(440.0, card_size.y)

	var slot_rect: Rect2 = slot.get_global_rect()
	var vp_rect: Rect2 = get_viewport_rect()

	const OFFSET_Y: float = 12.0
	const PADDING: float = 10.0

	var target_x: float = slot_rect.position.x + (slot_rect.size.x - 440.0) * 0.5
	var target_y: float = slot_rect.position.y - card_size.y - OFFSET_Y

	# Clamp to screen
	target_x = clampf(target_x, PADDING, maxf(PADDING, vp_rect.size.x - 440.0 - PADDING))
	if target_y < PADDING:
		target_y = PADDING

	$Card.global_position = Vector2(target_x, target_y)
	$Card.modulate.a = 1.0

func _hide_hud_card() -> void:
	_card_layout_revision += 1
	$Card.hide()
	$Card.modulate.a = 1.0

func _hud_changed(_a: Variant = null, _b: Variant = null, _c: Variant = null) -> void:
	_refresh_hud_slots()

func _disconnect_hud_actor() -> void:
	if hud_actor == null:
		return
	for name in [&"stamina_changed", &"max_stamina_changed", &"ability_lock_changed", &"status_added", &"status_updated", &"status_removed"]:
		if hud_actor.is_connected(name, _hud_changed):
			hud_actor.disconnect(name, _hud_changed)

func _exit_tree() -> void:
	_disconnect_hud_actor()
