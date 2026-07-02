class_name BattleSurfaceEffectController
extends RefCounted


signal surface_effect_added(
	instance: BattleSurfaceEffectInstance
)

signal surface_effect_updated(
	instance: BattleSurfaceEffectInstance
)

signal surface_effect_removed(
	coordinate: Vector2i,
	surface_effect_id: StringName
)

signal surface_effect_triggered(
	result: BattleSurfaceTriggerResult
)


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_SURFACE_DEFINITION: StringName = (
	&"invalid_surface_definition"
)

const FAILURE_INVALID_SURFACE_COORDINATE: StringName = (
	&"invalid_surface_coordinate"
)

const FAILURE_SURFACE_CELL_HAS_OBSTACLE: StringName = (
	&"surface_cell_has_obstacle"
)

const FAILURE_NO_EFFECTS_RESOLVED: StringName = (
	&"no_surface_effects_resolved"
)


var effect_resolver := EffectResolver.new()

var _instances_by_coordinate: Dictionary = {}
var _current_round_number: int = 0


func get_placement_failure(
	session: BattleSession,
	coordinate: Vector2i,
	definition: BattleSurfaceEffectDefinition
) -> StringName:
	if (
		session == null
		or session.grid == null
	):
		return FAILURE_INVALID_SESSION

	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return FAILURE_INVALID_SURFACE_DEFINITION

	if not session.grid.is_inside(
		coordinate
	):
		return FAILURE_INVALID_SURFACE_COORDINATE

	var cell := session.grid.get_cell(
		coordinate
	)

	if cell == null:
		return FAILURE_INVALID_SURFACE_COORDINATE

	if cell.has_obstacle():
		return FAILURE_SURFACE_CELL_HAS_OBSTACLE

	return &""


func can_place_effect(
	session: BattleSession,
	coordinate: Vector2i,
	definition: BattleSurfaceEffectDefinition
) -> bool:
	return get_placement_failure(
		session,
		coordinate,
		definition
	) == &""


func get_effect_at(
	coordinate: Vector2i,
	surface_effect_id: StringName
) -> BattleSurfaceEffectInstance:
	if (
		surface_effect_id == &""
		or not _instances_by_coordinate.has(
			coordinate
		)
	):
		return null

	var instances_at_coordinate: Dictionary = (
		_instances_by_coordinate[
			coordinate
		]
	)

	return (
		instances_at_coordinate.get(
			surface_effect_id
		)
		as BattleSurfaceEffectInstance
	)

func place_effect(
	session: BattleSession,
	coordinate: Vector2i,
	definition: BattleSurfaceEffectDefinition,
	source_instance_id: StringName = &"",
	source_team_id: StringName = &""
) -> BattleSurfaceEffectInstance:
	if get_placement_failure(
		session,
		coordinate,
		definition
	) != &"":
		return null

	var cell := session.grid.get_cell(
		coordinate
	)

	var resolved_source_team_id := (
		source_team_id
	)

	if (
		resolved_source_team_id == &""
		and source_instance_id != &""
	):
		var source := session.get_combatant(
			source_instance_id
		)

		if source != null:
			resolved_source_team_id = (
				source.team_id
			)

	var instances_at_coordinate: Dictionary = (
		_instances_by_coordinate.get(
			coordinate,
			{}
		)
	)

	var existing_instance := (
		instances_at_coordinate.get(
			definition.surface_effect_id
		) as BattleSurfaceEffectInstance
	)

	if existing_instance != null:
		existing_instance.refresh(
			definition,
			source_instance_id,
			resolved_source_team_id
		)

		instances_at_coordinate[
			definition.surface_effect_id
		] = existing_instance

		_instances_by_coordinate[
			coordinate
		] = instances_at_coordinate

		if not cell.has_surface_effect(
			definition.surface_effect_id
		):
			cell.add_surface_effect(
				definition.surface_effect_id
			)

		surface_effect_updated.emit(
			existing_instance
		)

		return existing_instance

	var instance := BattleSurfaceEffectInstance.new(
		definition,
		coordinate,
		source_instance_id,
		resolved_source_team_id
	)

	instances_at_coordinate[
		definition.surface_effect_id
	] = instance

	_instances_by_coordinate[
		coordinate
	] = instances_at_coordinate

	cell.add_surface_effect(
		definition.surface_effect_id
	)

	surface_effect_added.emit(
		instance
	)

	return instance


func remove_effect(
	session: BattleSession,
	coordinate: Vector2i,
	surface_effect_id: StringName
) -> bool:
	if (
		session == null
		or session.grid == null
		or surface_effect_id == &""
		or not _instances_by_coordinate.has(
			coordinate
		)
	):
		return false

	var instances_at_coordinate: Dictionary = (
		_instances_by_coordinate[
			coordinate
		]
	)

	if not instances_at_coordinate.has(
		surface_effect_id
	):
		return false

	instances_at_coordinate.erase(
		surface_effect_id
	)

	if instances_at_coordinate.is_empty():
		_instances_by_coordinate.erase(
			coordinate
		)

	else:
		_instances_by_coordinate[
			coordinate
		] = instances_at_coordinate

	var cell := session.grid.get_cell(
		coordinate
	)

	if cell != null:
		cell.remove_surface_effect(
			surface_effect_id
		)

	surface_effect_removed.emit(
		coordinate,
		surface_effect_id
	)

	return true


func get_effects_at(
	coordinate: Vector2i
) -> Array[BattleSurfaceEffectInstance]:
	var result: Array[BattleSurfaceEffectInstance] = []

	if not _instances_by_coordinate.has(
		coordinate
	):
		return result

	var instances_at_coordinate: Dictionary = (
		_instances_by_coordinate[
			coordinate
		]
	)

	for value in instances_at_coordinate.values():
		var instance := (
			value as BattleSurfaceEffectInstance
		)

		if instance != null:
			result.append(
				instance
			)

	result.sort_custom(
		Callable(
			self,
			"_is_surface_instance_before"
		)
	)

	return result


func get_affected_coordinates() -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for value in _instances_by_coordinate.keys():
		var coordinate: Vector2i = value

		result.append(
			coordinate
		)

	result.sort_custom(
		Callable(
			self,
			"_is_coordinate_before"
		)
	)

	return result


func trigger_for_combatant(
	session: BattleSession,
	combatant: CombatantState,
	timing: int
) -> Array[BattleSurfaceTriggerResult]:
	var results: Array[BattleSurfaceTriggerResult] = []

	if (
		session == null
		or session.grid == null
		or combatant == null
		or not combatant.is_alive
		or not session.grid.is_inside(
			combatant.grid_position
		)
	):
		return results

	var coordinate := combatant.grid_position

	var surface_instances := get_effects_at(
		coordinate
	)

	for instance in surface_instances:
		if (
			instance == null
			or instance.definition == null
			or not combatant.is_alive
		):
			continue

		var definition := instance.definition

		if not definition.has_trigger(
			timing
		):
			continue

		if not definition.can_affect_team(
			instance.source_team_id,
			combatant.team_id
		):
			continue

		var trigger_result := _resolve_instance(
			session,
			combatant,
			instance,
			timing
		)

		results.append(
			trigger_result
		)

		if (
			trigger_result.is_successful
			and definition.consume_after_trigger
		):
			trigger_result.was_consumed = true

			remove_effect(
				session,
				coordinate,
				definition.surface_effect_id
			)

		surface_effect_triggered.emit(
			trigger_result
		)

		if not combatant.is_alive:
			break

	return results


func advance_to_round(
	session: BattleSession,
	new_round_number: int
) -> void:
	if (
		session == null
		or session.grid == null
		or new_round_number <= 0
	):
		return

	if _current_round_number <= 0:
		_current_round_number = (
			new_round_number
		)

		return

	if new_round_number <= _current_round_number:
		return

	var elapsed_rounds := (
		new_round_number
		- _current_round_number
	)

	_current_round_number = (
		new_round_number
	)

	var coordinates := get_affected_coordinates()

	for coordinate in coordinates:
		var instances := get_effects_at(
			coordinate
		)

		for instance in instances:
			if (
				instance == null
				or instance.definition == null
				or instance.is_permanent
			):
				continue

			instance.remaining_rounds = maxi(
				0,
				instance.remaining_rounds
				- elapsed_rounds
			)

			if instance.remaining_rounds <= 0:
				remove_effect(
					session,
					coordinate,
					instance
						.definition
						.surface_effect_id
				)

			else:
				surface_effect_updated.emit(
					instance
				)


func clear(
	session: BattleSession
) -> void:
	if session == null:
		_instances_by_coordinate.clear()
		_current_round_number = 0
		return

	var coordinates := get_affected_coordinates()

	for coordinate in coordinates:
		var instances := get_effects_at(
			coordinate
		)

		for instance in instances:
			if (
				instance == null
				or instance.definition == null
			):
				continue

			remove_effect(
				session,
				coordinate,
				instance
					.definition
					.surface_effect_id
			)

	_instances_by_coordinate.clear()
	_current_round_number = 0


func _resolve_instance(
	session: BattleSession,
	target: CombatantState,
	instance: BattleSurfaceEffectInstance,
	timing: int
) -> BattleSurfaceTriggerResult:
	var result := (
		BattleSurfaceTriggerResult.new()
	)

	var definition := instance.definition

	result.surface_effect_id = (
		definition.surface_effect_id
	)

	result.surface_display_name = (
		definition.display_name
	)

	result.coordinate = (
		instance.coordinate
	)

	result.timing = timing

	result.source_id = (
		instance.source_instance_id
	)

	result.target_id = (
		target.instance_id
	)

	var source := _resolve_source(
		session,
		target,
		instance
	)

	var all_effects_succeeded := true

	for effect in definition.effects:
		if not target.is_alive:
			break

		var effect_result := (
			effect_resolver.resolve(
				effect,
				source,
				target,
				session,
				definition.bypass_guard,
				false
			)
		)

		result.effect_results.append(
			effect_result
		)

		if (
			effect_result == null
			or not effect_result.is_successful
		):
			all_effects_succeeded = false

			if (
				effect_result != null
				and result.failure_code == &""
			):
				result.failure_code = (
					effect_result.failure_code
				)

	if result.effect_results.is_empty():
		result.failure_code = (
			FAILURE_NO_EFFECTS_RESOLVED
		)

		return result

	result.target_died = (
		not target.is_alive
	)

	result.stops_movement = (
		definition.stops_movement
		or result.target_died
	)

	result.is_successful = (
		all_effects_succeeded
	)

	return result


func _resolve_source(
	session: BattleSession,
	target: CombatantState,
	instance: BattleSurfaceEffectInstance
) -> CombatantState:
	if instance.source_instance_id != &"":
		var stored_source := (
			session.get_combatant(
				instance.source_instance_id
			)
		)

		if stored_source != null:
			return stored_source

	## Для нейтральной поверхности нужен технический
	## CombatantState, потому что EffectResolver ожидает source.
	## Debug/environmental эффекты обязаны иметь scaling = 0.
	return target


func _is_surface_instance_before(
	left: BattleSurfaceEffectInstance,
	right: BattleSurfaceEffectInstance
) -> bool:
	if left == null:
		return false

	if right == null:
		return true

	return (
		String(
			left.definition.surface_effect_id
		)
		< String(
			right.definition.surface_effect_id
		)
	)


func _is_coordinate_before(
	left: Vector2i,
	right: Vector2i
) -> bool:
	if left.y != right.y:
		return left.y < right.y

	return left.x < right.x