class_name BattleSurfaceHoverPanel
extends PanelContainer


@export var standalone_left: float = -404.0
@export var standalone_right: float = -24.0

@export var companion_left: float = -808.0
@export var companion_right: float = -428.0


@onready
var title_label: Label = (
	$ContentMargin/VBoxContainer/TitleLabel
)

@onready
var coordinate_label: Label = (
	$ContentMargin/VBoxContainer/CoordinateLabel
)

@onready
var effects_label: Label = (
	$ContentMargin/VBoxContainer/EffectsLabel
)


var _coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var _instances: Array[BattleSurfaceEffectInstance] = []
var _layout_revision: int = 0


func _ready() -> void:
	clear_surfaces()


func show_surfaces(
	coordinate: Vector2i,
	instances: Array[BattleSurfaceEffectInstance],
	has_combatant_neighbor: bool
) -> void:
	_coordinate = coordinate
	_instances.clear()

	for instance in instances:
		if (
			instance == null
			or instance.definition == null
		):
			continue

		_instances.append(
			instance
		)

	if _instances.is_empty():
		clear_surfaces()
		return

	_layout_revision += 1
	var revision := _layout_revision

	title_label.text = "Эффекты клетки"
	coordinate_label.text = "Клетка: %s" % coordinate
	effects_label.text = _build_effects_text()

	custom_minimum_size.x = 380.0
	custom_minimum_size.y = 0.0
	size.x = 380.0

	modulate.a = 0.0
	visible = true

	_fit_to_content.call_deferred(has_combatant_neighbor, revision)


func _fit_to_content(has_combatant_neighbor: bool, revision: int) -> void:
	if revision != _layout_revision or not visible:
		return

	reset_size()
	var minimum := get_combined_minimum_size()
	size = Vector2(380.0, minimum.y)

	_apply_layout(has_combatant_neighbor)
	modulate.a = 1.0


func clear_surfaces() -> void:
	_layout_revision += 1
	_coordinate = (
		BattleGrid.INVALID_COORDINATE
	)

	_instances.clear()

	if is_node_ready():
		title_label.text = ""
		coordinate_label.text = ""
		effects_label.text = ""

	visible = false
	modulate.a = 1.0


func _apply_layout(
	has_combatant_neighbor: bool
) -> void:
	anchor_left = 1.0
	anchor_right = 1.0
	offset_left = standalone_left
	offset_right = standalone_right

	const TOP_MARGIN: float = 96.0
	const STACK_GAP: float = 14.0

	var combatant_panel: Control = get_node_or_null("../CombatantHoverPanel") as Control
	if has_combatant_neighbor and combatant_panel != null and combatant_panel.visible:
		var c_bottom: float = combatant_panel.offset_top + combatant_panel.size.y
		offset_top = c_bottom + STACK_GAP
	else:
		offset_top = TOP_MARGIN


func _build_effects_text() -> String:
	var blocks := PackedStringArray()

	for instance in _instances:
		var block := _build_surface_block(
			instance
		)

		if block.is_empty():
			continue

		blocks.append(
			block
		)

	return "\n\n────────────\n\n".join(
		blocks
	)


func _build_surface_block(
	instance: BattleSurfaceEffectInstance
) -> String:
	if (
		instance == null
		or instance.definition == null
	):
		return ""

	var definition := instance.definition
	var lines := PackedStringArray()

	var surface_name := (
		definition.display_name
	)

	if surface_name.strip_edges().is_empty():
		surface_name = String(
			definition.surface_effect_id
		)

	lines.append(
		"«%s»"
		% surface_name
	)

	if not (
		definition.description
		.strip_edges()
		.is_empty()
	):
		lines.append(
			definition.description
		)

	lines.append(
		"Срабатывает: %s"
		% _build_trigger_text(
			definition
		)
	)

	lines.append(
		"Цели: %s"
		% _build_target_relation_text(
			definition.target_relation
		)
	)

	if instance.is_permanent:
		lines.append(
			"Длительность: постоянно"
		)

	else:
		lines.append(
			"Осталось: %s"
			% _format_round_count(
				instance.remaining_rounds
			)
		)

	if _has_damage_effect(
		definition.effects
	):
		lines.append(
			(
				"Оборона: игнорируется"
				if definition.bypass_guard
				else "Оборона: поглощает урон"
			)
		)

	if definition.stops_movement:
		lines.append(
			"Останавливает перемещение"
		)

	if definition.consume_after_trigger:
		lines.append(
			"Исчезает после срабатывания"
		)

	var effects_text := (
		BattleAbilityPresentationBuilder
		.build_effect_list_text(
			definition.effects
		)
	)

	if not effects_text.is_empty():
		lines.append(
			"Эффекты:\n%s"
			% _indent_text(
				effects_text
			)
		)

	return "\n".join(
		lines
	)


func _build_trigger_text(
	definition: BattleSurfaceEffectDefinition
) -> String:
	var parts := PackedStringArray()

	if definition.has_trigger(
		BattleSurfaceEffectDefinition
			.TriggerTiming
			.ON_ENTER
	):
		parts.append(
			"при входе"
		)

	if definition.has_trigger(
		BattleSurfaceEffectDefinition
			.TriggerTiming
			.OWNER_TURN_START
	):
		parts.append(
			"в начале хода"
		)

	if definition.has_trigger(
		BattleSurfaceEffectDefinition
			.TriggerTiming
			.OWNER_TURN_END
	):
		parts.append(
			"в конце хода"
		)

	if parts.is_empty():
		return "не указано"

	return ", ".join(
		parts
	)


func _build_target_relation_text(
	target_relation: int
) -> String:
	match target_relation:
		BattleSurfaceEffectDefinition.TargetRelation.ALL:
			return "все бойцы"

		BattleSurfaceEffectDefinition.TargetRelation.SOURCE_TEAM:
			return "союзники источника"

		BattleSurfaceEffectDefinition.TargetRelation.OPPOSING_TEAM:
			return "противники источника"

	return "неизвестно"


func _has_damage_effect(
	effects: Array[BattleEffect]
) -> bool:
	for effect in effects:
		if effect is DamageEffect:
			return true

	return false


func _indent_text(
	text: String
) -> String:
	if text.is_empty():
		return ""

	return (
		"  "
		+ text.replace(
			"\n",
			"\n  "
		)
	)


func _format_round_count(
	value: int
) -> String:
	var absolute_value := absi(
		value
	)

	var last_two_digits := (
		absolute_value % 100
	)

	var last_digit := (
		absolute_value % 10
	)

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d раундов" % value

	if last_digit == 1:
		return "%d раунд" % value

	if (
		last_digit >= 2
		and last_digit <= 4
	):
		return "%d раунда" % value

	return "%d раундов" % value