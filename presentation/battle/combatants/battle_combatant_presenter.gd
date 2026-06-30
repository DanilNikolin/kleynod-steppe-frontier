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


func play_melee_feedback(
	actor_id: StringName,
	target_id: StringName,
	target_died: bool = false,
	animated: bool = true
) -> bool:
	var actor_view := get_view(actor_id)
	var target_view := get_view(target_id)

	if actor_view == null or target_view == null:
		return false

	face_toward(actor_id, target_id)

	actor_view.play_visual_animation(&"attack", &"idle")
	target_view.play_visual_animation(&"hit", &"idle")

	if not animated:
		_finish_melee_feedback(
			actor_view,
			target_view,
			target_died
		)
		return true

	var actor_start := actor_view.position
	var target_original_modulate := target_view.modulate
	var direction := (
		target_view.position - actor_view.position
	).normalized()

	var tween := combatant_layer.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		actor_view,
		"position",
		actor_start + direction * 22.0,
		0.08
	)

	tween.parallel().tween_property(
		target_view,
		"modulate",
		Color(1.0, 0.28, 0.22, 1.0),
		0.06
	)

	tween.tween_property(
		actor_view,
		"position",
		actor_start,
		0.11
	)

	tween.parallel().tween_property(
		target_view,
		"modulate",
		target_original_modulate,
		0.11
	)

	await tween.finished

	_finish_melee_feedback(
		actor_view,
		target_view,
		target_died
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


func _finish_melee_feedback(
	actor_view: CombatantView,
	target_view: CombatantView,
	target_died: bool
) -> void:
	if is_instance_valid(actor_view):
		actor_view.play_visual_animation(&"idle", &"")

	if not is_instance_valid(target_view):
		return

	if target_died:
		target_view.play_visual_animation(&"death", &"")
	else:
		target_view.play_visual_animation(&"idle", &"")