class_name BattleCombatantHoverPanel
extends PanelContainer


@onready
var name_label: Label = (
	$ContentMargin/VBoxContainer/NameLabel
)

@onready
var relation_label: Label = (
	$ContentMargin/VBoxContainer/RelationLabel
)

@onready
var resources_label: Label = (
	$ContentMargin/VBoxContainer/ResourcesLabel
)

@onready
var armor_label: Label = (
	$ContentMargin/VBoxContainer/ArmorLabel
)

@onready
var attributes_label: Label = (
	$ContentMargin/VBoxContainer/AttributesLabel
)

@onready
var statuses_label: Label = (
	$ContentMargin/VBoxContainer/StatusesLabel
)


var _combatant: CombatantState
var _viewer_team_id: StringName = &""


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
	visible = true


func clear_combatant() -> void:
	_disconnect_combatant_signals()

	_combatant = null
	_viewer_team_id = &""

	name_label.text = ""
	relation_label.text = ""
	resources_label.text = ""
	armor_label.text = ""
	attributes_label.text = ""
	statuses_label.text = ""

	visible = false


func refresh() -> void:
	if _combatant == null:
		clear_combatant()
		return

	var definition := _combatant.definition

	name_label.text = (
		definition.display_name
		if definition != null
		else String(_combatant.instance_id)
	)

	if not _combatant.is_alive:
		relation_label.text = "ПОГИБ"

	elif _combatant.team_id == _viewer_team_id:
		relation_label.text = "СОЮЗНИК"

	else:
		relation_label.text = "ПРОТИВНИК"

	resources_label.text = (
		"Здоровье: %d/%d\n"
		% [
			_combatant.current_health,
			_combatant.max_health,
		]
		+"Оборона: %d/%d\n"
		% [
			_combatant.current_guard,
			_combatant.max_health,
		]
		+"Выносливость: %d/%d  (+%d за раунд)\n"
		% [
			_combatant.current_stamina,
			_combatant.max_stamina,
			_combatant.stamina_regeneration,
		]
		+"Мораль: %d/%d"
		% [
			_combatant.current_morale,
			_combatant.max_morale,
		]
	)

	var effective_armor := (
		_combatant.get_effective_armor()
	)

	var armor_modifier := (
		_combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	if armor_modifier == 0:
		armor_label.text = (
			"Броня: %d"
			% effective_armor
		)

	else:
		armor_label.text = (
			"Броня: %d  (база %d, статусы %s)"
			% [
				effective_armor,
				_combatant.armor,
				_format_signed_integer(
					armor_modifier
				),
			]
		)

	attributes_label.text = (
		"Сила: %d  |  Ловкость: %d\n"
		% [
			_combatant.strength,
			_combatant.agility,
		]
		+"Дух: %d  |  Инициатива: %d"
		% [
			_combatant.spirit,
			_combatant.initiative,
		]
	)

	statuses_label.text = (
		_build_statuses_text()
	)


func _build_statuses_text() -> String:
	if _combatant == null:
		return "Статусы: нет"

	var statuses := (
		_combatant.get_active_statuses()
	)

	if statuses.is_empty():
		return "Статусы: нет"

	var lines := PackedStringArray([
		"Статусы:",
	])

	for status in statuses:
		if (
			status == null
			or status.definition == null
		):
			continue

		var effect_parts := PackedStringArray()

		for modifier in (
			status.definition.stat_modifiers
		):
			if modifier == null:
				continue

			effect_parts.append(
				"%s %s"
				% [
					_get_stat_name(
						modifier.stat
					),
					_format_signed_integer(
						modifier.get_total_amount(
							status.stack_count
						)
					),
				]
			)

		if effect_parts.is_empty():
			if not (
				status.definition
				.description
				.strip_edges()
				.is_empty()
			):
				effect_parts.append(
					status.definition.description
				)

			else:
				effect_parts.append(
					"без модификаторов"
				)

		var stack_text := ""

		if status.stack_count > 1:
			stack_text = (
				" ×%d"
				% status.stack_count
			)

		lines.append(
			"• %s%s — %s, %s"
			% [
				status.definition.display_name,
				stack_text,
				", ".join(effect_parts),
				_format_turn_count(
					status.remaining_turns
				),
			]
		)

	return "\n".join(lines)


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

		BattleStatModifier.Stat.INITIATIVE:
			return "инициатива"

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