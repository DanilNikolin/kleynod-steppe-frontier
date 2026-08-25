class_name HeroEquipmentPanel
extends PanelContainer


signal state_changed


var campaign_state: CampaignState
var hero_state: CampaignHeroState

var progression: HeroProgressionState
var inventory_state: CampaignInventoryState

var equipment_service := (
	HeroEquipmentService.new()
)

var campaign_equipment_service := (
	CampaignEquipmentService.new()
)


func bind(
	p_progression: HeroProgressionState,
	p_inventory_state: CampaignInventoryState
) -> void:
	campaign_state = null
	hero_state = null

	progression = p_progression
	inventory_state = p_inventory_state

	_ensure_equipment_state()
	_rebuild_interface()


func bind_campaign(
	p_campaign_state: CampaignState,
	p_hero_state: CampaignHeroState
) -> void:
	campaign_state = p_campaign_state
	hero_state = p_hero_state

	progression = (
		hero_state.progression_state
		if hero_state != null
		else null
	)

	inventory_state = (
		campaign_state.inventory_state
		if campaign_state != null
		else null
	)

	_ensure_equipment_state()
	_rebuild_interface()


func _ensure_equipment_state() -> void:
	if (
		progression != null
		and progression.equipment_state == null
	):
		progression.equipment_state = (
			HeroEquipmentState.new()
		)


func _rebuild_interface() -> void:
	_clear_children()

	var outer := VBoxContainer.new()

	outer.add_theme_constant_override(
		"separation",
		10
	)

	add_child(
		outer
	)

	var title := Label.new()

	title.text = "ИНВЕНТАРЬ И ЭКИПИРОВКА"

	title.add_theme_font_size_override(
		"font_size",
		22
	)

	outer.add_child(
		title
	)

	if (
		progression == null
		or progression.equipment_state == null
		or inventory_state == null
	):
		var error_label := Label.new()

		error_label.text = (
			"Инвентарь или Equipment State недоступны."
		)

		outer.add_child(
			error_label
		)

		return

	var slots_title := Label.new()

	slots_title.text = "ЭКИПИРОВАННЫЕ СЛОТЫ"

	outer.add_child(
		slots_title
	)

	for slot in HeroEquipmentState.get_all_slots():
		outer.add_child(
			_create_equipped_slot_row(
				slot
			)
		)

	outer.add_child(
		HSeparator.new()
	)

	var inventory_title := Label.new()

	inventory_title.text = (
		"ПРЕДМЕТЫ КАМПАНИИ · ЗОЛОТО: %d"
		% (
			inventory_state.gold
			if inventory_state != null
			else 0
		)
	)

	outer.add_child(
		inventory_title
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

	var inventory_content := VBoxContainer.new()

	inventory_content.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	inventory_content.add_theme_constant_override(
		"separation",
		10
	)

	scroll.add_child(
		inventory_content
	)

	if inventory_state.items.is_empty():
		var empty_label := Label.new()

		empty_label.text = "Инвентарь пуст."

		inventory_content.add_child(
			empty_label
		)

		return

	for item in inventory_state.items:
		if (
			item == null
			or item.definition == null
		):
			continue

		inventory_content.add_child(
			_create_inventory_item_row(
				item
			)
		)


func _create_equipped_slot_row(
	slot: int
) -> Control:
	var row := HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		8
	)

	var slot_label := Label.new()

	slot_label.custom_minimum_size = Vector2(
		100,
		0
	)

	slot_label.text = (
		HeroEquipmentState.get_slot_display_name(
			slot
		)
	)

	row.add_child(
		slot_label
	)

	var item := progression.equipment_state.get_item(
		slot
	)

	var item_label := Label.new()

	item_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	if (
		item == null
		or item.definition == null
	):
		item_label.text = "—"

	else:
		item_label.text = (
			item.definition.display_name
		)

	row.add_child(
		item_label
	)

	var remove_button := Button.new()

	remove_button.text = "Снять"
	remove_button.disabled = item == null

	remove_button.pressed.connect(
		_on_unequip_pressed.bind(
			slot
		)
	)

	row.add_child(
		remove_button
	)

	return row


func _create_inventory_item_row(
	item: HeroEquipmentItemInstance
) -> Control:
	var panel := PanelContainer.new()
	var content := VBoxContainer.new()

	content.add_theme_constant_override(
		"separation",
		6
	)

	panel.add_child(
		content
	)

	var name_label := Label.new()

	name_label.text = (
		item.definition.display_name
	)

	content.add_child(
		name_label
	)

	var item_owner := _get_item_owner(
		item.instance_id
	)

	var owner_label := Label.new()

	if item_owner == null:
		owner_label.text = "Свободно"

	elif (
		hero_state != null
		and item_owner == hero_state
	):
		owner_label.text = "Надето на текущем герое"

	else:
		owner_label.text = (
			"Надето: %s"
			% item_owner.get_display_name()
		)

	content.add_child(
		owner_label
	)

	var description := Label.new()

	description.text = item.definition.description
	description.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	content.add_child(
		description
	)

	var button_row := HBoxContainer.new()

	button_row.add_theme_constant_override(
		"separation",
		6
	)

	content.add_child(
		button_row
	)

	for slot in equipment_service.get_compatible_slots(
		item
	):
		var equip_button := Button.new()

		var button_text := _get_equip_button_text(
			item,
			slot
		)

		if (
			owner != null
			and hero_state != null
			and owner != hero_state
		):
			button_text = (
				"Передать → %s"
				% button_text
			)

		equip_button.text = button_text

		equip_button.pressed.connect(
			_on_equip_pressed.bind(
				item.instance_id,
				slot
			)
		)

		button_row.add_child(
			equip_button
		)

	return panel


func _get_item_owner(
	item_instance_id: StringName
) -> CampaignHeroState:
	if campaign_state == null:
		return null

	return campaign_equipment_service.get_item_owner(
		campaign_state,
		item_instance_id
	)


func _get_equip_button_text(
	item: HeroEquipmentItemInstance,
	slot: int
) -> String:
	if (
		item.definition.category
			== HeroEquipmentItemDefinition.Category.WEAPON
		and item.definition.is_two_handed
	):
		return "В обе руки"

	match slot:
		HeroEquipmentState.Slot.WEAPON_1:
			return "Weapon 1"

		HeroEquipmentState.Slot.WEAPON_2:
			return "Weapon 2"

		HeroEquipmentState.Slot.RING_1:
			return "Ring 1"

		HeroEquipmentState.Slot.RING_2:
			return "Ring 2"

	return "Экипировать"


func _on_equip_pressed(
	item_instance_id: StringName,
	slot: int
) -> void:
	if (
		campaign_state != null
		and hero_state != null
	):
		var campaign_result := (
			campaign_equipment_service.equip_item(
				campaign_state,
				hero_state.get_hero_id(),
				item_instance_id,
				slot
			)
		)

		if not campaign_result.is_successful:
			push_warning(
				"Campaign equipment failed: %s"
				% campaign_result.failure_code
			)

			return

		state_changed.emit()
		return

	var item := inventory_state.get_item(
		item_instance_id
	)

	if item == null:
		push_warning(
			"Inventory does not contain item '%s'."
			% item_instance_id
		)

		return

	var result := equipment_service.equip(
		progression.equipment_state,
		item,
		slot
	)

	if not result.is_successful:
		push_warning(
			"Equipment failed: %s"
			% result.failure_code
		)

		return

	state_changed.emit()


func _on_unequip_pressed(
	slot: int
) -> void:
	if (
		campaign_state != null
		and hero_state != null
	):
		var campaign_result := (
			campaign_equipment_service.unequip_slot(
				campaign_state,
				hero_state.get_hero_id(),
				slot
			)
		)

		if not campaign_result.is_successful:
			push_warning(
				"Campaign unequip failed: %s"
				% campaign_result.failure_code
			)

			return

		state_changed.emit()
		return

	var result := equipment_service.unequip(
		progression.equipment_state,
		slot
	)

	if not result.is_successful:
		push_warning(
			"Unequip failed: %s"
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