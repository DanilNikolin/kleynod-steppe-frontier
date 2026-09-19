class_name BattleCombatantHoverPanel
extends PanelContainer


@onready var name_label: Label = $ContentMargin/VBoxContainer/NameLabel
@onready var relation_label: Label = $ContentMargin/VBoxContainer/RelationLabel

@onready var health_label: Label = $ContentMargin/VBoxContainer/ResourcesRow/HealthBox/HealthLabel
@onready var guard_label: Label = $ContentMargin/VBoxContainer/ResourcesRow/GuardBox/GuardLabel
@onready var stamina_label: Label = $ContentMargin/VBoxContainer/ResourcesRow/StaminaBox/StaminaLabel
@onready var armor_label: Label = $ContentMargin/VBoxContainer/ResourcesRow/ArmorBox/ArmorLabel
@onready var morale_label: Label = $ContentMargin/VBoxContainer/MoraleLabel

@onready var strength_label: Label = $ContentMargin/VBoxContainer/AttributesRow/StrengthLabel
@onready var agility_label: Label = $ContentMargin/VBoxContainer/AttributesRow/AgilityLabel
@onready var spirit_label: Label = $ContentMargin/VBoxContainer/AttributesRow/SpiritLabel

@onready var hero_core_section: VBoxContainer = $ContentMargin/VBoxContainer/HeroCoreSection
@onready var hero_core_entries: VBoxContainer = $ContentMargin/VBoxContainer/HeroCoreSection/HeroCoreEntries

@onready var statuses_section: VBoxContainer = $ContentMargin/VBoxContainer/StatusesSection
@onready var statuses_container: VBoxContainer = $ContentMargin/VBoxContainer/StatusesSection/StatusesContainer

@onready var immunities_section: VBoxContainer = $ContentMargin/VBoxContainer/ImmunitiesSection
@onready var immunities_label: Label = $ContentMargin/VBoxContainer/ImmunitiesSection/ImmunitiesLabel

const HERO_CORE_ICONS = {
	"unbroken": preload("res://Graphics/UI/battle/hero_core/bayda/unbroken_active.png"),
	"fractured": preload("res://Graphics/UI/battle/hero_core/bayda/fractured_active.png"),
	"debt": preload("res://Graphics/UI/battle/hero_core/bayda/exhaustion_debt_active.png"),
	"penalty": preload("res://Graphics/UI/battle/hero_core/bayda/max_stamina_penalty_active.png"),
}

var _combatant: CombatantState
var _viewer_team_id: StringName = &""
var _layout_revision: int = 0


func _ready() -> void:
	visible = false


func bind_combatant(
	combatant: CombatantState,
	viewer_team_id: StringName
) -> void:
	if _combatant == combatant:
		_viewer_team_id = viewer_team_id
		refresh()
		return

	_disconnect_combatant_signals()

	_combatant = combatant
	_viewer_team_id = viewer_team_id

	if _combatant == null:
		clear_combatant()
		return

	_connect_combatant_signals()

	refresh()


func clear_combatant() -> void:
	_layout_revision += 1
	_disconnect_combatant_signals()

	_combatant = null
	_viewer_team_id = &""

	name_label.text = ""
	relation_label.text = ""
	health_label.text = ""
	guard_label.text = ""
	stamina_label.text = ""
	armor_label.text = ""
	morale_label.text = ""
	strength_label.text = ""
	agility_label.text = ""
	spirit_label.text = ""

	_clear_container(hero_core_entries)
	hero_core_section.visible = false

	_clear_container(statuses_container)
	statuses_section.visible = false

	immunities_label.text = ""
	immunities_section.visible = false

	visible = false
	modulate.a = 1.0


func refresh() -> void:
	if _combatant == null:
		clear_combatant()
		return

	var definition := _combatant.definition

	name_label.text = (
		definition.display_name.to_upper()
		if definition != null and not definition.display_name.is_empty()
		else String(_combatant.instance_id).to_upper()
	)

	if not _combatant.is_alive:
		relation_label.text = "ПОГИБ"
		relation_label.add_theme_color_override("font_color", Color(0.7, 0.3, 0.3, 1.0))
	elif _combatant.team_id == _viewer_team_id:
		relation_label.text = "СОЮЗНИК"
		relation_label.add_theme_color_override("font_color", Color(0.4, 0.85, 0.45, 1.0))
	else:
		relation_label.text = "ПРОТИВНИК"
		relation_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.35, 1.0))

	# Resources row
	health_label.text = "%d/%d" % [_combatant.current_health, _combatant.max_health]
	guard_label.text = "%d" % _combatant.current_guard
	stamina_label.text = "%d/%d (+%d)" % [
		_combatant.current_stamina,
		_combatant.max_stamina,
		_combatant.get_effective_stamina_regeneration(),
	]
	armor_label.text = "%d" % _combatant.get_effective_armor()
	morale_label.text = "Мораль: %d/%d" % [_combatant.current_morale, _combatant.max_morale]

	# Attributes row (СИЛ / ЛОВ / ВОЛ)
	strength_label.text = "СИЛ %d" % _combatant.get_effective_strength()
	agility_label.text = "ЛОВ %d" % _combatant.get_effective_agility()
	spirit_label.text = "ВОЛ %d" % _combatant.get_effective_spirit()

	# Hero Core section
	_populate_hero_core()

	# Statuses section
	_populate_statuses()

	# Immunities section
	_populate_immunities()

	_layout_revision += 1
	var revision := _layout_revision

	custom_minimum_size = Vector2(380.0, 0.0)
	size = Vector2(380.0, 1.0)

	visible = true
	modulate.a = 0.0

	_fit_to_content(revision)


func _fit_to_content(revision: int) -> void:
	await get_tree().process_frame

	if revision != _layout_revision or not visible:
		return

	var minimum: Vector2 = $ContentMargin.get_combined_minimum_size()
	size = Vector2(380.0, minimum.y)
	modulate.a = 1.0


func _clear_container(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()


func _populate_hero_core() -> void:
	_clear_container(hero_core_entries)

	if _combatant == null or _combatant.hero_core_runtime_state == null:
		hero_core_section.visible = false
		return

	var core: HeroCoreRuntimeState = _combatant.hero_core_runtime_state
	var has_entries := false

	if core is BaydaCoreRuntimeState:
		var bayda := core as BaydaCoreRuntimeState
		if bayda.unbroken_available:
			_add_hero_core_row(HERO_CORE_ICONS["unbroken"], "Несломленность — готова")
			has_entries = true
		if bayda.is_fractured:
			_add_hero_core_row(HERO_CORE_ICONS["fractured"], "Надлом")
			has_entries = true
		if bayda.exhaustion_debt > 0:
			_add_hero_core_row(HERO_CORE_ICONS["debt"], "Долг истощения %d" % bayda.exhaustion_debt)
			has_entries = true
		if bayda.grit_teeth_max_stamina_penalty > 0:
			_add_hero_core_row(HERO_CORE_ICONS["penalty"], "Макс. выносливость −%d" % bayda.grit_teeth_max_stamina_penalty)
			has_entries = true

	hero_core_section.visible = has_entries


func _add_hero_core_row(icon_texture: Texture2D, text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(20, 20)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = icon_texture
	row.add_child(icon)

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(1, 0.88, 0.5, 1.0))
	row.add_child(label)

	hero_core_entries.add_child(row)


func _populate_statuses() -> void:
	_clear_container(statuses_container)

	if _combatant == null:
		statuses_section.visible = false
		return

	var active_statuses := _combatant.get_active_statuses()
	if active_statuses.is_empty():
		statuses_section.visible = false
		return

	for status in active_statuses:
		if status == null or status.definition == null:
			continue

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		# Resolve icon
		var icon_tex: Texture2D = null
		var semantics := BattleStatusVisualResolver.resolve(status.definition)
		for sem in semantics:
			if BattleStatusVisualResolver.TEXTURES.has(sem):
				icon_tex = BattleStatusVisualResolver.TEXTURES[sem]
				break

		if icon_tex != null:
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(18, 18)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture = icon_tex
			row.add_child(icon)

		var stack_str := " ×%d" % status.stack_count if status.stack_count > 1 else ""
		var duration_str := _format_turn_count(status.remaining_turns) if status.remaining_turns > 0 else "бессрочно"

		var name_lbl := Label.new()
		name_lbl.text = "%s%s" % [status.definition.display_name, stack_str]
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var turns_lbl := Label.new()
		turns_lbl.text = duration_str
		turns_lbl.add_theme_font_size_override("font_size", 12)
		turns_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 1.0))
		row.add_child(turns_lbl)

		statuses_container.add_child(row)

	statuses_section.visible = true


func _populate_immunities() -> void:
	if _combatant == null or _combatant.definition == null:
		immunities_section.visible = false
		return

	var definition := _combatant.definition
	var lines := PackedStringArray()

	for status_id in definition.status_immunity_ids:
		lines.append("• статус: %s" % status_id)

	for tag in definition.status_immunity_tags:
		lines.append("• категория: %s" % tag)

	if lines.is_empty():
		immunities_section.visible = false
		return

	immunities_label.text = "\n".join(lines)
	immunities_section.visible = true


func _connect_combatant_signals() -> void:
	if _combatant == null:
		return

	_connect_signal_if_needed(
		&"health_changed",
		Callable(
			self,
			"_on_resource_changed"
		)
	)

	_connect_signal_if_needed(
		&"guard_changed",
		Callable(
			self,
			"_on_resource_changed"
		)
	)

	_connect_signal_if_needed(
		&"stamina_changed",
		Callable(
			self,
			"_on_resource_changed"
		)
	)

	_connect_signal_if_needed(
		&"max_stamina_changed",
		Callable(
			self,
			"_on_resource_changed"
		)
	)

	_connect_signal_if_needed(
		&"morale_changed",
		Callable(
			self,
			"_on_resource_changed"
		)
	)

	_connect_signal_if_needed(
		&"status_added",
		Callable(
			self,
			"_on_status_added"
		)
	)

	_connect_signal_if_needed(
		&"status_updated",
		Callable(
			self,
			"_on_status_updated"
		)
	)

	_connect_signal_if_needed(
		&"status_removed",
		Callable(
			self,
			"_on_status_removed"
		)
	)

	_connect_signal_if_needed(
		&"died",
		Callable(
			self,
			"_on_died"
		)
	)

	_connect_hero_core_signal()

func _disconnect_combatant_signals() -> void:
	if _combatant == null:
		return

	var connections: Array[Array] = [
		[
			&"health_changed",
			Callable(
				self,
				"_on_resource_changed"
			),
		],
		[
			&"guard_changed",
			Callable(
				self,
				"_on_resource_changed"
			),
		],
		[
			&"stamina_changed",
			Callable(
				self,
				"_on_resource_changed"
			),
		],
		[
			&"max_stamina_changed",
			Callable(
				self,
				"_on_resource_changed"
			),
		],
		[
			&"morale_changed",
			Callable(
				self,
				"_on_resource_changed"
			),
		],
		[
			&"status_added",
			Callable(
				self,
				"_on_status_added"
			),
		],
		[
			&"status_updated",
			Callable(
				self,
				"_on_status_updated"
			),
		],
		[
			&"status_removed",
			Callable(
				self,
				"_on_status_removed"
			),
		],
		[
			&"died",
			Callable(
				self,
				"_on_died"
			),
		],
	]

	for connection_data in connections:
		var signal_name: StringName = (
			connection_data[0]
		)

		var callback: Callable = (
			connection_data[1]
		)

		if _combatant.is_connected(
			signal_name,
			callback
		):
			_combatant.disconnect(
				signal_name,
				callback
			)

	_disconnect_hero_core_signal()


func _connect_hero_core_signal() -> void:
	if (
		_combatant == null
		or _combatant.hero_core_runtime_state == null
	):
		return

	var core: HeroCoreRuntimeState = (
		_combatant.hero_core_runtime_state
	)

	var callback := Callable(
		self,
		"_on_hero_core_state_changed"
	)

	if core.is_connected(
		&"state_changed",
		callback
	):
		return

	core.connect(
		&"state_changed",
		callback
	)


func _disconnect_hero_core_signal() -> void:
	if (
		_combatant == null
		or _combatant.hero_core_runtime_state == null
	):
		return

	var core: HeroCoreRuntimeState = (
		_combatant.hero_core_runtime_state
	)

	var callback := Callable(
		self,
		"_on_hero_core_state_changed"
	)

	if core.is_connected(
		&"state_changed",
		callback
	):
		core.disconnect(
			&"state_changed",
			callback
		)


func _connect_signal_if_needed(
	signal_name: StringName,
	callback: Callable
) -> void:
	if _combatant.is_connected(
		signal_name,
		callback
	):
		return

	_combatant.connect(
		signal_name,
		callback
	)


func _on_hero_core_state_changed() -> void:
	refresh()
	
func _on_resource_changed(
	_previous_value: int,
	_current_value: int
) -> void:
	refresh()


func _on_status_added(
	_status: BattleStatusInstance
) -> void:
	refresh()


func _on_status_updated(
	_status: BattleStatusInstance,
	_previous_stack_count: int,
	_previous_remaining_turns: int
) -> void:
	refresh()


func _on_status_removed(
	_status: BattleStatusInstance,
	_reason: StringName
) -> void:
	refresh()


func _on_died() -> void:
	refresh()



func _build_stat_line(
	stat_name: String,
	base_value: int,
	effective_value: int,
	modifier_total: int
) -> String:
	if modifier_total == 0:
		return (
			"%s: %d"
			% [
				stat_name,
				effective_value,
			]
		)

	return (
		"%s: %d  (база %d, модификаторы %s)"
		% [
			stat_name,
			effective_value,
			base_value,
			_format_signed_integer(
				modifier_total
			),
		]
	)

func _get_stat_name(
	stat: int
) -> String:
	match stat:
		BattleStatModifier.Stat.ARMOR:
			return "броня"

		BattleStatModifier.Stat.STRENGTH:
			return "сила"

		BattleStatModifier.Stat.AGILITY:
			return "ловкость"

		BattleStatModifier.Stat.SPIRIT:
			return "дух"

		BattleStatModifier.Stat.STAMINA_REGENERATION:
			return "восстановление выносливости"


	return "характеристика"


func _format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


func _format_turn_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d ходов" % value

	if last_digit == 1:
		return "%d ход" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d хода" % value

	return "%d ходов" % value