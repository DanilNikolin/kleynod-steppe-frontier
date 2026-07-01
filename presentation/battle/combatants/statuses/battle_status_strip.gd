class_name BattleStatusStrip
extends Control


@export
var chip_scene: PackedScene


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

	_clear_chips()

	if state == null:
		visible = false
		return

	if chip_scene == null:
		push_error(
			"BattleStatusStrip requires a chip scene."
		)

		visible = false
		return

	var statuses := state.get_active_statuses()

	statuses.sort_custom(
		Callable(
			self,
			"_is_status_before"
		)
	)

	for status in statuses:
		if (
			status == null
			or status.definition == null
		):
			continue

		var instance := chip_scene.instantiate()

		if not (instance is BattleStatusChip):
			push_error(
				"Status chip scene must inherit "
				+"BattleStatusChip."
			)

			instance.queue_free()
			continue

		var chip := instance as BattleStatusChip

		chip_container.add_child(
			chip
		)

		chip.bind_status(
			status
		)

	visible = (
		chip_container.get_child_count()
		> 0
	)


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


func _clear_chips() -> void:
	for child in chip_container.get_children():
		chip_container.remove_child(
			child
		)

		child.queue_free()


func _is_status_before(
	left: BattleStatusInstance,
	right: BattleStatusInstance
) -> bool:
	if left == null:
		return false

	if right == null:
		return true

	return (
		String(left.status_id)
		< String(right.status_id)
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