class_name SkillGridDebugSandbox
extends Control


const HERO_PREPARATION_PANEL_SCENE: PackedScene = preload(
	"res://presentation/campaign/hero_preparation/"
	+"hero_preparation_panel.tscn"
)


@export
var hero_definition: HeroDefinition

@export
var progression_source: HeroProgressionState


@export_group("Debug Equipment")

@export
var available_equipment_instances: Array[HeroEquipmentItemInstance] = []


var hero_state: CampaignHeroState
var inventory_state: CampaignInventoryState


func _ready() -> void:
	_reset_debug_state()


func _reset_debug_state() -> void:
	if (
		hero_definition == null
		or progression_source == null
	):
		_show_initialization_error()
		return

	var progression := (
		progression_source.duplicate(true)
		as HeroProgressionState
	)

	if progression == null:
		_show_initialization_error()
		return

	if progression.equipment_state == null:
		progression.equipment_state = (
			HeroEquipmentState.new()
		)

	inventory_state = CampaignInventoryState.new()

	for source_item in available_equipment_instances:
		if source_item == null:
			continue

		var item_copy := (
			source_item.duplicate(true)
			as HeroEquipmentItemInstance
		)

		if item_copy == null:
			continue

		inventory_state.items.append(
			item_copy
		)

	hero_state = CampaignHeroState.new()

	hero_state.hero_definition = hero_definition
	hero_state.progression_state = progression

	if (
		not hero_state.is_valid_state()
		or not inventory_state.is_valid_state()
	):
		_show_initialization_error()
		return

	_show_preparation_panel()


func _show_preparation_panel() -> void:
	_clear_children()

	var panel := (
		HERO_PREPARATION_PANEL_SCENE.instantiate()
		as HeroPreparationPanel
	)

	if panel == null:
		_show_initialization_error()
		return

	add_child(
		panel
	)

	panel.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	panel.close_requested.connect(
		_reset_debug_state
	)

	panel.bind(
		hero_state,
		inventory_state,
		"Сбросить debug-сборку"
	)


func _show_initialization_error() -> void:
	_clear_children()

	var label := Label.new()

	label.text = (
		"Skill Grid Debug Sandbox:\n"
		+"не удалось создать Hero Preparation State."
	)

	label.position = Vector2(
		24,
		24
	)

	add_child(
		label
	)


func _clear_children() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()