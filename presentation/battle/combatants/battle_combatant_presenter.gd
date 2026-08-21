class_name BattleCombatantPresenter
extends RefCounted

signal vfx_requested(
	vfx_id: StringName,
	global_position: Vector2,
	source_id: StringName,
	target_id: StringName
)

signal sound_requested(
	sound_id: StringName,
	global_position: Vector2,
	source_id: StringName
)


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


func play_ability_feedback(
	actor_id: StringName,
	target_ids: Array[StringName],
	defeated_target_ids: Array[StringName],
	action_result: BattleActionResult,
	profile: BattleAbilityPresentationProfile,
	animated: bool = true,
	restart_actor_animation: bool = false
) -> bool:
	var actor_view := get_view(
		actor_id
	)

	if actor_view == null:
		return false

	var resolved_profile := profile

	if resolved_profile == null:
		resolved_profile = (
			BattleAbilityPresentationProfile.new()
		)

	var feedback_kind := (
		resolved_profile.resolve_feedback_kind(
			action_result
		)
	)

	var target_views: Array[CombatantView] = []
	var target_view_ids: Array[StringName] = []

	for target_id in target_ids:
		if target_id == &"":
			continue

		var target_view := get_view(
			target_id
		)

		if target_view == null:
			return false

		if target_views.has(
			target_view
		):
			continue

		target_views.append(
			target_view
		)

		target_view_ids.append(
			target_id
		)

	for target_id in target_view_ids:
		if target_id == actor_id:
			continue

		face_toward(
			actor_id,
			target_id
		)

		break

	var actor_animation := (
		resolved_profile
		.get_actor_animation_key(
			feedback_kind
		)
	)

	actor_view.play_visual_animation(
		actor_animation,
		&"idle",
		restart_actor_animation
	)

	var target_animation := (
		resolved_profile
		.get_target_animation_key(
			feedback_kind
		)
	)

	for target_view in target_views:
		## Не перебиваем анимацию самого применяющего,
		## если способность направлена на себя.
		if target_view == actor_view:
			continue

		target_view.play_visual_animation(
			target_animation,
			&"idle"
		)

	var feedback_views: Array[CombatantView] = []
	var feedback_view_ids: Array[StringName] = []

	for target_index in range(
		target_views.size()
	):
		feedback_views.append(
			target_views[target_index]
		)

		feedback_view_ids.append(
			target_view_ids[target_index]
		)

	## Координатные способности вроде PlaceSurfaceEffect
	## не имеют target_id, поэтому показываем импульс
	## на самом применяющем.
	if (
		feedback_views.is_empty()
		and feedback_kind
			!= BattleAbilityPresentationProfile
				.FeedbackKind
				.NONE
	):
		feedback_views.append(
			actor_view
		)

		feedback_view_ids.append(
			actor_id
		)

	_emit_ability_presentation_hooks(
		actor_view,
		actor_id,
		feedback_views,
		feedback_view_ids,
		resolved_profile
	)

	if not animated:
		_finish_ability_feedback(
			actor_view,
			actor_id,
			target_views,
			target_view_ids,
			defeated_target_ids
		)

		return true

	var original_modulates: Array[Color] = []
	var flash_modulates: Array[Color] = []

	var base_flash_color := (
		resolved_profile.get_flash_color(
			feedback_kind
		)
	)

	for feedback_view in feedback_views:
		original_modulates.append(
			feedback_view.modulate
		)

		var flash_color := base_flash_color

		flash_color.a = (
			feedback_view.modulate.a
		)

		flash_modulates.append(
			flash_color
		)

	var primary_target_view: CombatantView

	for target_view in target_views:
		if target_view == actor_view:
			continue

		primary_target_view = target_view
		break

	var should_lunge := (
		primary_target_view != null
		and resolved_profile
			.should_use_actor_lunge(
				feedback_kind
			)
	)

	var actor_start := actor_view.position

	var tween := combatant_layer.create_tween()

	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_OUT
	)

	if should_lunge:
		var direction := (
			primary_target_view.position
			- actor_view.position
		).normalized()

		tween.tween_property(
			actor_view,
			"position",
			actor_start
				+ direction
				* resolved_profile
					.lunge_distance,
			0.08
		)

	else:
		tween.tween_interval(
			0.05
		)

	for feedback_index in range(
		feedback_views.size()
	):
		tween.parallel().tween_property(
			feedback_views[
				feedback_index
			],
			"modulate",
			flash_modulates[
				feedback_index
			],
			0.06
		)

	if should_lunge:
		tween.tween_property(
			actor_view,
			"position",
			actor_start,
			0.11
		)

	else:
		tween.tween_interval(
			0.08
		)

	for feedback_index in range(
		feedback_views.size()
	):
		tween.parallel().tween_property(
			feedback_views[
				feedback_index
			],
			"modulate",
			original_modulates[
				feedback_index
			],
			0.11
		)

	await tween.finished

	_finish_ability_feedback(
		actor_view,
		actor_id,
		target_views,
		target_view_ids,
		defeated_target_ids
	)

	return true


func play_reaction_feedback(
	reaction_result: BattleActionReactionResult,
	animated: bool = true
) -> bool:
	if (
		reaction_result == null
		or not reaction_result.is_successful
		or reaction_result.reactor_id == &""
	):
		return false

	var reaction_profile := (
		BattleAbilityPresentationProfile.new()
	)

	reaction_profile.feedback_kind = (
		reaction_profile
		.resolve_feedback_kind_from_effect_results(
			reaction_result.effect_results
		) as BattleAbilityPresentationProfile.FeedbackKind
	)

	if (
		reaction_profile.feedback_kind
		== BattleAbilityPresentationProfile
			.FeedbackKind
			.NONE
	):
		return true

	## У реакции уже есть точный боец,
	## чьё действие её вызвало.
	##
	## Для presentation это надёжнее, чем
	## повторно выводить цель из набора эффектов.
	var target_ids: Array[StringName] = []

	if reaction_result.triggering_actor_id != &"":
		target_ids.append(
			reaction_result.triggering_actor_id
		)

	else:
		target_ids = (
			reaction_result
			.get_affected_target_ids()
		)

	return await play_ability_feedback(
		reaction_result.reactor_id,
		target_ids,
		reaction_result.get_defeated_target_ids(),
		null,
		reaction_profile,
		animated,
		true
	)


## Совместимый переходный метод для уже существующих вызовов.
func play_action_feedback(
	actor_id: StringName,
	target_ids: Array[StringName],
	defeated_target_ids: Array[StringName] = [],
	animated: bool = true
) -> bool:
	var default_profile := (
		BattleAbilityPresentationProfile.new()
	)

	default_profile.feedback_kind = (
		BattleAbilityPresentationProfile
			.FeedbackKind
			.DAMAGE
	)

	return await play_ability_feedback(
		actor_id,
		target_ids,
		defeated_target_ids,
		null,
		default_profile,
		animated
	)


func _emit_ability_presentation_hooks(
	actor_view: CombatantView,
	actor_id: StringName,
	feedback_views: Array[CombatantView],
	feedback_view_ids: Array[StringName],
	profile: BattleAbilityPresentationProfile
) -> void:
	if actor_view == null or profile == null:
		return

	if profile.sound_id != &"":
		sound_requested.emit(
			profile.sound_id,
			_get_effects_anchor_position(
				actor_view
			),
			actor_id
		)

	if profile.impact_vfx_id == &"":
		return

	if feedback_views.is_empty():
		vfx_requested.emit(
			profile.impact_vfx_id,
			_get_effects_anchor_position(
				actor_view
			),
			actor_id,
			&""
		)

		return

	for feedback_index in range(
		feedback_views.size()
	):
		vfx_requested.emit(
			profile.impact_vfx_id,
			_get_effects_anchor_position(
				feedback_views[
					feedback_index
				]
			),
			actor_id,
			feedback_view_ids[
				feedback_index
			]
		)


func _get_effects_anchor_position(
	view: CombatantView
) -> Vector2:
	if view == null:
		return Vector2.ZERO

	if view.visual != null:
		return (
			view.visual
			.get_effects_anchor_global_position()
		)

	return view.global_position


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


func _finish_ability_feedback(
	actor_view: CombatantView,
	actor_id: StringName,
	target_views: Array[CombatantView],
	target_view_ids: Array[StringName],
	defeated_target_ids: Array[StringName]
) -> void:
	var defeated_lookup: Dictionary = {}

	for defeated_id in defeated_target_ids:
		defeated_lookup[
			defeated_id
		] = true

	if is_instance_valid(
		actor_view
	):
		if defeated_lookup.has(
			actor_id
		):
			actor_view.play_visual_animation(
				&"death",
				&""
			)

		else:
			actor_view.play_visual_animation(
				&"idle",
				&""
			)

	for target_index in range(
		target_views.size()
	):
		var target_view := (
			target_views[
				target_index
			]
		)

		if not is_instance_valid(
			target_view
		):
			continue

		if target_view == actor_view:
			continue

		var target_id := (
			target_view_ids[
				target_index
			]
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