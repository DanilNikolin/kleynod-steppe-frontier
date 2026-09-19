class_name BattleStatusStrip
extends Control


const ICON_SCENE = preload("res://presentation/battle/combatants/statuses/battle_status_icon.tscn")
const FALLBACK_SCENE = preload("res://presentation/battle/combatants/statuses/battle_status_chip.tscn")
@export var polarity_filter: int = -1
@export var icon_size: int = 20
@export var interactive_icons: bool = false


@onready
var chip_container: HBoxContainer = (
	$ChipContainer
)


var state: CombatantState


func _ready() -> void:
	refresh_from_state()


func _exit_tree() -> void:
	_disconnect_state_signals()
	state = null


func bind_state(
	new_state: CombatantState
) -> void:
	if state == new_state:
		refresh_from_state()
		return

	_disconnect_state_signals()

	state = new_state

	_connect_state_signals()
	refresh_from_state()


func refresh_from_state() -> void:
	if not is_node_ready():
		return

	render_into(chip_container, state, polarity_filter, icon_size, interactive_icons)
	visible = chip_container.get_child_count() > 0


static func render_into(container: HBoxContainer, model: CombatantState, polarity: int = -1, pixels: int = 20, interactive: bool = false) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	for entry in BattleStatusVisualResolver.entries(model, polarity):
		if entry.semantic == "":
			var chip := FALLBACK_SCENE.instantiate() as BattleStatusChip
			container.add_child(chip)
			chip.bind_status(entry.status)
			# Legacy text remains readable for unmapped/debug statuses.
			for child in chip.find_children("*", "Control", true, false):
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			chip.mouse_filter = Control.MOUSE_FILTER_PASS if interactive else Control.MOUSE_FILTER_IGNORE
			chip.tooltip_text = entry.status.definition.display_name if interactive else ""
		else:
			var icon := ICON_SCENE.instantiate() as BattleStatusIcon
			container.add_child(icon)
			icon.bind_entry(entry, pixels, interactive)


func _connect_state_signals() -> void:
	if state == null:
		return

	var added_callback := Callable(
		self,
		"_on_status_added"
	)

	var updated_callback := Callable(
		self,
		"_on_status_updated"
	)

	var removed_callback := Callable(
		self,
		"_on_status_removed"
	)

	if not state.is_connected(
		&"status_added",
		added_callback
	):
		state.connect(
			&"status_added",
			added_callback
		)

	if not state.is_connected(
		&"status_updated",
		updated_callback
	):
		state.connect(
			&"status_updated",
			updated_callback
		)

	if not state.is_connected(
		&"status_removed",
		removed_callback
	):
		state.connect(
			&"status_removed",
			removed_callback
		)


func _disconnect_state_signals() -> void:
	if state == null:
		return

	var connections: Array[Array] = [
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
	]

	for connection_data in connections:
		var signal_name: StringName = (
			connection_data[0]
		)

		var callback: Callable = (
			connection_data[1]
		)

		if state.is_connected(
			signal_name,
			callback
		):
			state.disconnect(
				signal_name,
				callback
			)


func _on_status_added(
	_status: BattleStatusInstance
) -> void:
	refresh_from_state()


func _on_status_updated(
	_status: BattleStatusInstance,
	_previous_stack_count: int,
	_previous_remaining_turns: int
) -> void:
	refresh_from_state()


func _on_status_removed(
	_status: BattleStatusInstance,
	_reason: StringName
) -> void:
	refresh_from_state()