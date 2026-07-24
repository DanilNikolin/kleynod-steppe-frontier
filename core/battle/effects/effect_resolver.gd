class_name EffectResolver
extends RefCounted
enum StandardCriticalMode {
	RANDOM,
	NEVER,
	ALWAYS,
}

const FAILURE_INVALID_EFFECT: StringName = &"invalid_effect"
const FAILURE_INVALID_SOURCE: StringName = &"invalid_source"
const FAILURE_INVALID_TARGET: StringName = &"invalid_target"
const FAILURE_UNSUPPORTED_EFFECT: StringName = &"unsupported_effect"
const FAILURE_SURFACE_PLACEMENT_FAILED: StringName = (
	&"surface_placement_failed"
)

const FAILURE_INVALID_STATUS_DEFINITION: StringName = (
	&"invalid_status_definition"
)

const FAILURE_STATUS_APPLICATION_FAILED: StringName = (
	&"status_application_failed"
)


var damage_calculator := DamageCalculator.new()

var forced_movement_service := (
	BattleForcedMovementService.new()
)

var relocation_service := (
	BattleRelocationService.new()
)

var random_number_generator: RandomNumberGenerator


func _init(
	p_random_number_generator: RandomNumberGenerator = null
) -> void:
	if p_random_number_generator != null:
		random_number_generator = (
			p_random_number_generator
		)

		return

	random_number_generator = (
		RandomNumberGenerator.new()
	)

	random_number_generator.randomize()

func can_resolve(
	effect: BattleEffect
) -> bool:
	return (
		effect is DamageEffect
		or effect is HealEffect
		or effect is GrantGuardEffect
		or effect is ApplyStatusEffect
		or effect is RemoveStatusEffect
		or effect is ForcedMovementEffect
		or effect is PlaceSurfaceEffect
		or effect is SwapPositionsEffect
		or effect is TeleportEffect
	)

func requires_combatant_target(
	effect: BattleEffect
) -> bool:
	return (
		not effect is PlaceSurfaceEffect
		and not effect is TeleportEffect
	)


func resolve(
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession = null,
	bypass_guard: bool = false,
	allow_critical: bool = true,
	target_coordinate: Vector2i = BattleGrid.INVALID_COORDINATE,
	standard_critical_mode: int = StandardCriticalMode.RANDOM
) -> BattleEffectResult:
	if effect == null:
		return _create_failure_result(
			FAILURE_INVALID_EFFECT,
			effect,
			source,
			target
		)

	if source == null:
		return _create_failure_result(
			FAILURE_INVALID_SOURCE,
			effect,
			source,
			target
		)

	if effect is PlaceSurfaceEffect:
		return _resolve_place_surface(
			effect as PlaceSurfaceEffect,
			source,
			target,
			session,
			target_coordinate
		)

	if effect is TeleportEffect:
		return _resolve_teleport(
			effect as TeleportEffect,
			source,
			session,
			target_coordinate
		)

	if target == null:
		return _create_failure_result(
			FAILURE_INVALID_TARGET,
			effect,
			source,
			target
		)

	if effect is SwapPositionsEffect:
		return _resolve_swap_positions(
			effect as SwapPositionsEffect,
			source,
			target,
			session
		)

	if effect is DamageEffect:
		return _resolve_damage(
			effect as DamageEffect,
			source,
			target,
			bypass_guard,
			allow_critical,
			standard_critical_mode
		)

	if effect is HealEffect:
		return _resolve_heal(
			effect as HealEffect,
			source,
			target
		)

	if effect is GrantGuardEffect:
		return _resolve_grant_guard(
			effect as GrantGuardEffect,
			source,
			target
		)

	if effect is ApplyStatusEffect:
		return _resolve_apply_status(
			effect as ApplyStatusEffect,
			source,
			target
		)

	if effect is RemoveStatusEffect:
		return _resolve_remove_status(
			effect as RemoveStatusEffect,
			source,
			target
		)
	if effect is ForcedMovementEffect:
		return _resolve_forced_movement(
			effect as ForcedMovementEffect,
			source,
			target,
			session
		)

	return _create_failure_result(
		FAILURE_UNSUPPORTED_EFFECT,
		effect,
		source,
		target
	)


func _resolve_swap_positions(
	effect: SwapPositionsEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"swap_positions"

	result.source_id = source.instance_id
	result.target_id = target.instance_id
	result.secondary_target_id = target.instance_id
	result.relocation_kind = &"swap"

	var relocation_result := relocation_service.swap(
		session,
		source,
		target,
		true,
		false,
		0
	)

	if not relocation_result.is_successful:
		result.failure_code = (
			relocation_result.failure_code
		)

		return result

	result.movement_origin = (
		relocation_result.primary_origin
	)

	result.movement_destination = (
		relocation_result.primary_destination
	)

	result.secondary_movement_origin = (
		relocation_result.secondary_origin
	)

	result.secondary_movement_destination = (
		relocation_result.secondary_destination
	)

	if not source.is_alive:
		result.relocation_defeated_ids.append(
			source.instance_id
		)

	if not target.is_alive:
		result.relocation_defeated_ids.append(
			target.instance_id
		)

	result.target_died = not target.is_alive
	result.applied_amount = 1
	result.is_successful = true

	return result


func _resolve_teleport(
	effect: TeleportEffect,
	source: CombatantState,
	session: BattleSession,
	target_coordinate: Vector2i
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"teleport"

	result.source_id = source.instance_id
	result.target_id = source.instance_id
	result.relocation_kind = &"teleport"

	var relocation_result := relocation_service.teleport(
		session,
		source,
		target_coordinate,
		0
	)

	if not relocation_result.is_successful:
		result.failure_code = (
			relocation_result.failure_code
		)

		return result

	result.movement_origin = (
		relocation_result.primary_origin
	)

	result.movement_destination = (
		relocation_result.primary_destination
	)

	if not source.is_alive:
		result.relocation_defeated_ids.append(
			source.instance_id
		)

	result.target_died = not source.is_alive
	result.applied_amount = 1
	result.is_successful = true

	return result

func _resolve_place_surface(
	effect: PlaceSurfaceEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession,
	target_coordinate: Vector2i
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"place_surface"

	result.source_id = source.instance_id
	result.effect_coordinate = target_coordinate

	if target != null:
		result.target_id = target.instance_id

	if (
		session == null
		or session.surface_effect_controller == null
	):
		result.failure_code = (
			BattleSurfaceEffectController
				.FAILURE_INVALID_SESSION
		)

		return result

	var definition := effect.surface_definition

	if definition != null:
		result.surface_effect_id = (
			definition.surface_effect_id
		)

		result.surface_display_name = (
			definition.display_name
		)

	var surface_controller := (
		session.surface_effect_controller
	)

	var placement_failure := (
		surface_controller.get_placement_failure(
			session,
			target_coordinate,
			definition
		)
	)

	if placement_failure != &"":
		result.failure_code = placement_failure
		return result

	var existing_instance := (
		surface_controller.get_effect_at(
			target_coordinate,
			definition.surface_effect_id
		)
	)

	if existing_instance != null:
		result.previous_surface_remaining_rounds = (
			existing_instance.remaining_rounds
		)

	var placed_instance := (
		surface_controller.place_effect(
			session,
			target_coordinate,
			definition,
			source.instance_id,
			source.team_id
		)
	)

	if placed_instance == null:
		result.failure_code = (
			FAILURE_SURFACE_PLACEMENT_FAILED
		)

		return result

	result.surface_was_added = (
		existing_instance == null
	)

	result.surface_was_updated = (
		existing_instance != null
	)

	result.surface_is_permanent = (
		placed_instance.is_permanent
	)

	result.current_surface_remaining_rounds = (
		placed_instance.remaining_rounds
	)

	result.applied_amount = 1
	result.is_successful = true

	return result

	
func _resolve_damage(
	effect: DamageEffect,
	source: CombatantState,
	target: CombatantState,
	bypass_guard: bool,
	allow_critical: bool,
	standard_critical_mode: int
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"damage"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.target_base_armor = (
		target.armor
	)

	result.target_status_armor_modifier = (
		target.get_stat_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	result.target_modified_armor = (
		target.get_effective_armor()
	)

	result.armor_piercing = (
		effect.armor_piercing
	)

	result.effective_armor = (
		damage_calculator.calculate_effective_armor(
			target,
			effect
		)
	)

	result.raw_amount_before_critical = (
		damage_calculator.calculate_raw_damage(
			source,
			effect
		)
	)

	result.critical_was_enabled = (
		allow_critical
		and effect.crit_mode
			!= DamageEffect.CritMode.DISABLED
	)

	result.critical_multiplier = (
		effect.critical_multiplier
	)

	result.critical_chance_percent = (
		damage_calculator
		.calculate_critical_chance_percent(
			source,
			effect,
			allow_critical
		)
	)

	if result.critical_was_enabled:
		match effect.crit_mode:
			DamageEffect.CritMode.GUARANTEED:
				result.critical_was_guaranteed = true
				result.was_critical = true

			DamageEffect.CritMode.STANDARD:
				if (
					result
						.critical_chance_percent
					> 0
				):
					match standard_critical_mode:
						StandardCriticalMode.NEVER:
							pass

						StandardCriticalMode.ALWAYS:
							result.was_critical = true

						_:
							result.critical_roll_percent = (
								random_number_generator
									.randi_range(
										1,
										100
									)
							)

							result.was_critical = (
								result
									.critical_roll_percent
								<= result
									.critical_chance_percent
							)

	result.raw_amount = (
		result.raw_amount_before_critical
	)

	if result.was_critical:
		result.raw_amount = (
			damage_calculator
			.apply_critical_multiplier(
				result
					.raw_amount_before_critical,
				result.critical_multiplier
			)
		)

	result.resolved_amount = (
		damage_calculator
		.calculate_resolved_damage_from_raw(
			target,
			effect,
			result.raw_amount
		)
	)

	result.mitigated_amount = maxi(
		0,
		result.raw_amount
		- result.resolved_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.guard_was_bypassed = (
		bypass_guard
	)

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = (
		target.apply_resolved_damage(
			result.resolved_amount,
			bypass_guard
		)
	)

	result.current_guard = (
		target.current_guard
	)

	if bypass_guard:
		result.guard_absorbed_amount = 0

	else:
		result.guard_absorbed_amount = maxi(
			0,
			result.previous_guard
			- result.current_guard
		)

	result.current_value = (
		target.current_health
	)

	result.target_died = (
		result.previous_value > 0
		and result.current_value == 0
	)

	result.is_successful = true

	return result


func _resolve_heal(
	effect: HealEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"heal"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.base_healing
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = target.heal(
		result.resolved_amount
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true

	return result
	
func _resolve_grant_guard(
	effect: GrantGuardEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"grant_guard"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.guard_amount
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.previous_value = (
		target.current_guard
	)

	result.applied_amount = target.grant_guard(
		result.resolved_amount
	)

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_guard
	)

	result.is_successful = true

	return result
	
func _resolve_apply_status(
	effect: ApplyStatusEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"apply_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	if (
		effect.status_definition == null
		or not effect
		.status_definition
		.is_valid_definition()
	):
		result.failure_code = (
			FAILURE_INVALID_STATUS_DEFINITION
		)

		return result

	var status_definition := (
		effect.status_definition
	)

	result.status_id = (
		status_definition.status_id
	)

	result.status_display_name = (
		status_definition.display_name
	)

	result.status_polarity = (
		status_definition.polarity
	)

	if target.definition != null:
		if target.definition.has_status_id_immunity(
			status_definition.status_id
		):
			result.status_application_blocked_by_immunity = true
			result.status_immunity_kind = &"status_id"
			result.status_immunity_value = (
				status_definition.status_id
			)

			result.is_successful = true
			return result

		var matching_immunity_tag := (
			target.definition
			.get_matching_status_immunity_tag(
				status_definition
			)
		)

		if matching_immunity_tag != &"":
			result.status_application_blocked_by_immunity = true
			result.status_immunity_kind = &"tag"
			result.status_immunity_value = (
				matching_immunity_tag
			)

			result.is_successful = true
			return result

	var existing_status := target.get_status(
		status_definition.status_id
	)

	result.status_was_added = (
		existing_status == null
	)

	if existing_status != null:
		result.previous_status_stack_count = (
			existing_status.stack_count
		)

		result.previous_status_remaining_turns = (
			existing_status.remaining_turns
		)

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	var applied_status := target.add_status(
		status_definition,
		source.instance_id
	)

	if applied_status == null:
		result.failure_code = (
			FAILURE_STATUS_APPLICATION_FAILED
		)

		return result

	result.current_status_stack_count = (
		applied_status.stack_count
	)

	result.current_status_remaining_turns = (
		applied_status.remaining_turns
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true

	return result
	

func _resolve_remove_status(
	effect: RemoveStatusEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"remove_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	var removed_statuses := (
		target.remove_statuses_matching(
			effect,
			&"removed_by_effect"
		)
	)

	for removed_status in removed_statuses:
		if (
			removed_status == null
			or removed_status.definition == null
		):
			continue

		result.removed_status_ids.append(
			removed_status.status_id
		)

		result.removed_status_display_names.append(
			removed_status.definition.display_name
		)

		result.removed_status_polarities.append(
			removed_status.definition.polarity
		)
	result.applied_amount = (
		result.removed_status_ids.size()
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true
	return result

func _resolve_forced_movement(
	effect: ForcedMovementEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"forced_movement"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.requested_movement_distance = (
		effect.distance
	)

	result.movement_origin = (
		target.grid_position
	)

	if session == null or session.grid == null:
		result.failure_code = (
			&"invalid_session"
		)

		return result

	var resolution := (
		forced_movement_service
		.create_resolution(
			session.grid,
			source,
			target,
			effect
		)
	)

	if not resolution.is_valid:
		result.failure_code = (
			resolution.failure_code
		)

		return result

	var surface_trigger_results: Array[BattleSurfaceTriggerResult] = []

	var surface_step_callback := Callable(
		self,
		"_on_forced_movement_surface_step"
	).bind(
		session,
		surface_trigger_results
	)

	var committed := (
		forced_movement_service
		.commit_resolution(
			session.grid,
			target,
			resolution,
			surface_step_callback
		)
	)

	if not committed:
		result.failure_code = (
			&"forced_movement_commit_failed"
		)

		return result

	## Копируем данные после commit, потому что опасная
	## клетка могла обрезать исходный путь.
	result.movement_origin = (
		resolution.origin
	)

	result.movement_destination = (
		resolution.destination
	)

	result.movement_direction = (
		resolution.direction
	)

	result.movement_path = (
		resolution.path.duplicate()
	)

	result.applied_movement_distance = (
		resolution.get_applied_distance()
	)

	result.movement_was_blocked = (
		resolution.was_blocked
	)

	result.movement_block_reason = (
		resolution.block_reason
	)

	result.target_died = (
		not target.is_alive
	)

	result.surface_trigger_results = (
		surface_trigger_results.duplicate()
	)

	result.is_successful = true
	return result

func _on_forced_movement_surface_step(
	target: CombatantState,
	_coordinate: Vector2i,
	session: BattleSession,
	surface_trigger_results: Array[BattleSurfaceTriggerResult]
) -> bool:
	if (
		session == null
		or target == null
		or not target.is_alive
	):
		return false

	if session.surface_effect_controller == null:
		return true

	var trigger_results := (
		session
		.surface_effect_controller
		.trigger_for_combatant(
			session,
			target,
			BattleSurfaceEffectDefinition
				.TriggerTiming
				.ON_ENTER
		)
	)

	for trigger_result in trigger_results:
		if trigger_result != null:
			surface_trigger_results.append(
				trigger_result
			)

	if not target.is_alive:
		return false

	for trigger_result in trigger_results:
		if (
			trigger_result != null
			and trigger_result.stops_movement
		):
			return false

	return true

func _create_failure_result(
	failure_code: StringName,
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.failure_code = failure_code

	if effect != null:
		result.effect_id = effect.effect_id

	if source != null:
		result.source_id = source.instance_id

	if target != null:
		result.target_id = target.instance_id

	return result
