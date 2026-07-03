class_name BattleCombatantPresenter
extends RefCounted


var grid_view: BattleGridView
var combatant_layer: Node2D
var combatant_view_scene: PackedScene

var _views: Dictionary = {}


func _init(
	p_grid_view: BattleGridView,
	p_combatant_layer: Node2D,
	p_combatant_view_scene: PackedScene
) -> void:
	assert(p_grid_view != null, "Grid view is required.")
	assert(p_combatant_layer != null, "Combatant layer is required.")
	assert(p_combatant_view_scene != null, "Combatant view scene is required.")

	grid_view = p_grid_view
	combatant_layer = p_combatant_layer
	combatant_view_scene = p_combatant_view_scene


func add_combatant(
	state: CombatantState,
	selected: bool = false
) -> CombatantView:
	if state == null or state.instance_id == &"":
		return null

	if has_view(state.instance_id):
		return null

	var instance := combatant_view_scene.instantiate()

	if not (instance is CombatantView):
		push_error(
			"Combatant view scene must inherit CombatantView."
		)
		instance.queue_free()
		return null

	var view := instance as CombatantView

	combatant_layer.add_child(view)
	view.bind_state(state)
	view.set_selected_state(selected)
	view.snap_to_local_position(
		grid_view.get_cell_center(state.grid_position)
	)

	_views[state.instance_id] = view
	return view


func has_view(instance_id: StringName) -> bool:
	return get_view(instance_id) != null


func get_view(instance_id: StringName) -> CombatantView:
	if not _views.has(instance_id):
		return null

	var value: Variant = _views[instance_id]

	if not is_instance_valid(value):
		_views.erase(instance_id)
		return null

	return value as CombatantView


func move_along_grid_path(
	instance_id: StringName,
	grid_path: Array[Vector2i],
	animated: bool = true
) -> bool:
	var view := get_view(instance_id)

	if view == null or grid_path.is_empty():
		return false

	var local_path: Array[Vector2] = []

	for coordinate in grid_path:
		if not grid_view.is_valid_coordinate(coordinate):
			return false

		local_path.append(
			grid_view.get_cell_center(coordinate)
		)

	view.move_along_local_path(local_path, animated)

	if animated:
		await view.movement_finished

	return true


func present_swap(
	first_id: StringName,
	second_id: StringName,
	first_destination: Vector2i,
	second_destination: Vector2i,
	animated: bool = true
) -> bool:
	var first_view := get_view(
		first_id
	)

	var second_view := get_view(
		second_id
	)

	if first_view == null or second_view == null:
		return false

	if (
		not grid_view.is_valid_coordinate(
			first_destination
		)
		or not grid_view.is_valid_coordinate(
			second_destination
		)
	):
		return false

	var first_target_position := (
		grid_view.get_cell_center(
			first_destination
		)
	)

	var second_target_position := (
		grid_view.get_cell_center(
			second_destination
		)
	)

	if not animated:
		first_view.snap_to_local_position(
			first_target_position
		)

		second_view.snap_to_local_position(
			second_target_position
		)

		return true

	var first_horizontal_distance := (
		first_target_position.x
		- first_view.position.x
	)

	if not is_zero_approx(
		first_horizontal_distance
	):
		first_view.set_facing_direction(
			1
			if first_horizontal_distance > 0.0
			else -1
		)

	var second_horizontal_distance := (
		second_target_position.x
		- second_view.position.x
	)

	if not is_zero_approx(
		second_horizontal_distance
	):
		second_view.set_facing_direction(
			1
			if second_horizontal_distance > 0.0
			else -1
		)

	first_view.play_visual_animation(
		&"move",
		&"idle"
	)

	second_view.play_visual_animation(
		&"move",
		&"idle"
	)

	var movement_duration := maxf(
		first_view.movement_duration,
		second_view.movement_duration
	)

	var tween := combatant_layer.create_tween()

	tween.set_parallel(
		true
	)

	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_IN_OUT
	)

	tween.tween_property(
		first_view,
		"position",
		first_target_position,
		movement_duration
	)

	tween.tween_property(
		second_view,
		"position",
		second_target_position,
		movement_duration
	)

	await tween.finished

	if (
		is_instance_valid(first_view)
		and first_view.state != null
		and first_view.state.is_alive
	):
		first_view.play_visual_animation(
			&"idle",
			&""
		)

	if (
		is_instance_valid(second_view)
		and second_view.state != null
		and second_view.state.is_alive
	):
		second_view.play_visual_animation(
			&"idle",
			&""
		)

	return true

func present_teleport(
	combatant_id: StringName,
	destination: Vector2i,
	animated: bool = true
) -> bool:
	var view := get_view(
		combatant_id
	)

	if (
		view == null
		or not grid_view.is_valid_coordinate(
			destination
		)
	):
		return false

	var target_position := (
		grid_view.get_cell_center(
			destination
		)
	)

	if not animated:
		view.snap_to_local_position(
			target_position
		)

		return true

	var original_modulate := view.modulate
	var hidden_modulate := original_modulate

	hidden_modulate.a = 0.0

	var tween := view.create_tween()

	tween.set_trans(
		Tween.TRANS_SINE
	)

	tween.set_ease(
		Tween.EASE_IN_OUT
	)

	tween.tween_property(
		view,
		"modulate",
		hidden_modulate,
		0.08
	)

	tween.tween_callback(
		Callable(
			view,
			"snap_to_local_position"
		).bind(
			target_position
		)
	)

	tween.tween_property(
		view,
		"modulate",
		original_modulate,
		0.10
	)

	await tween.finished

	view.modulate = original_modulate

	return true
	
func face_toward(
	actor_id: StringName,
	target_id: StringName
) -> bool:
	var actor_view := get_view(actor_id)
	var target_view := get_view(target_id)

	if actor_view == null or target_view == null:
		return false

	var horizontal_distance := (
		target_view.position.x - actor_view.position.x
	)

	if not is_zero_approx(horizontal_distance):
		actor_view.set_facing_direction(
			1 if horizontal_distance > 0.0 else -1
		)

	return true


func play_action_feedback(
	actor_id: StringName,
	target_ids: Array[StringName],
	defeated_target_ids: Array[StringName] = [],
	animated: bool = true
) -> bool:
	var actor_view := get_view(
		actor_id
	)

	if actor_view == null:
		return false

	var target_views: Array[CombatantView] = []
	var original_modulates: Array[Color] = []

	for target_id in target_ids:
		var target_view := get_view(
			target_id
		)

		if target_view == null:
			return false

		target_views.append(
			target_view
		)

		original_modulates.append(
			target_view.modulate
		)

	if not target_ids.is_empty():
		face_toward(
			actor_id,
			target_ids[0]
		)

	actor_view.play_visual_animation(
		&"attack",
		&"idle"
	)

	for target_view in target_views:
		target_view.play_visual_animation(
			&"hit",
			&"idle"
		)

	if not animated:
		_finish_action_feedback(
			actor_view,
			target_views,
			defeated_target_ids
		)

		return true

	var tween := (
		combatant_layer.create_tween()
	)

	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_OUT
	)

	if target_views.is_empty():
		tween.tween_interval(
			0.08
		)

	else:
		var actor_start := (
			actor_view.position
		)

		var primary_target_view := (
			target_views[0]
		)

		var direction := (
			primary_target_view.position
			- actor_view.position
		).normalized()

		tween.tween_property(
			actor_view,
			"position",
			actor_start + direction * 22.0,
			0.08
		)

		for target_view in target_views:
			tween.parallel().tween_property(
				target_view,
				"modulate",
				Color(
					1.0,
					0.28,
					0.22,
					1.0
				),
				0.06
			)

		tween.tween_property(
			actor_view,
			"position",
			actor_start,
			0.11
		)

		for target_index in range(
			target_views.size()
		):
			var target_view := (
				target_views[
					target_index
				]
			)

			tween.parallel().tween_property(
				target_view,
				"modulate",
				original_modulates[
					target_index
				],
				0.11
			)

	await tween.finished

	_finish_action_feedback(
		actor_view,
		target_views,
		defeated_target_ids
	)

	return true


func remove_view(instance_id: StringName) -> bool:
	var view := get_view(instance_id)

	if view == null:
		return false

	_views.erase(instance_id)
	view.queue_free()
	return true


func clear() -> void:
	for value in _views.keys():
		var instance_id: StringName = value
		remove_view(instance_id)


func _finish_action_feedback(
	actor_view: CombatantView,
	target_views: Array[CombatantView],
	defeated_target_ids: Array[StringName]
) -> void:
	if is_instance_valid(
		actor_view
	):
		actor_view.play_visual_animation(
			&"idle",
			&""
		)

	var defeated_lookup: Dictionary = {}

	for target_id in defeated_target_ids:
		defeated_lookup[target_id] = true

	for target_view in target_views:
		if not is_instance_valid(
			target_view
		):
			continue

		var target_id: StringName = &""

		if target_view.state != null:
			target_id = (
				target_view.state.instance_id
			)

		if defeated_lookup.has(
			target_id
		):
			target_view.play_visual_animation(
				&"death",
				&""
			)

		else:
			target_view.play_visual_animation(
				&"idle",
				&""
			)